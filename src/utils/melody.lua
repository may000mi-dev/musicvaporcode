local Melody = {}

local LETTER_TO_NOTE = { "A", "B", "C", "D", "E", "F", "G" }

-- A3..G4: las siete letras se mapean a una escala diatonica real.
local NOTE_FREQUENCY = {
  A = 220.00, B = 246.94, C = 261.63, D = 293.66,
  E = 329.63, F = 349.23, G = 392.00
}

local NOTE_OCTAVE = { A = 3, B = 3, C = 4, D = 4, E = 4, F = 4, G = 4 }
local PITCH_CLASS = { C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11 }
local CHROMATIC = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
local OCTAVE_SHIFTS = { 0, 12, 0, -12 }

-- Regla del diseno: A-G se repiten cada 7 letras, asi que H vuelve a ser A.
function Melody.note_from_letter(letter)
  local code = string.byte(letter)
  if not code then
    return nil
  end
  if code >= 97 and code <= 122 then
    code = code - 32
  end
  if code < 65 or code > 90 then
    return nil
  end
  return LETTER_TO_NOTE[((code - 65) % 7) + 1]
end

-- Una corrida de caracteres iguales fija la duracion en semicorcheas:
-- "a"=1/16, "aa"=1/8, "aaa"=3/16, "aaaa"=1/4, "aaaaaaaa"=1/2.
-- El espacio es silencio; "aahh" son dos corcheas de la misma altura.
function Melody.from_text(text)
  local tokens = {}
  local index = 1
  while index <= #text do
    local character = text:sub(index, index)
    local run_length = 0
    while index + run_length <= #text and
          text:sub(index + run_length, index + run_length) == character do
      run_length = run_length + 1
    end

    local note = Melody.note_from_letter(character)
    local letter = note and character:upper() or nil
    local remaining = run_length
    while remaining > 0 do
      local steps = remaining > 8 and 8 or remaining
      tokens[#tokens + 1] = { letter = letter, note = note, steps = steps }
      remaining = remaining - steps
    end
    index = index + run_length
  end
  return tokens
end

function Melody.pulse_length(motif)
  local total = 0
  for i = 1, #motif do
    total = total + motif[i].steps
  end
  return total
end

function Melody.frequency(note, semitones)
  return NOTE_FREQUENCY[note] * 2 ^ ((semitones or 0) / 12)
end

-- djb2 con modulo pequeno: cabe en un double sin perder precision.
function Melody.make_seed(source_id, dungeon_id, variation, text)
  local key = source_id .. "|" .. dungeon_id .. "|" .. tostring(variation) .. "|" .. (text or "")
  local hash = 5381
  for i = 1, #key do
    hash = (hash * 33 + string.byte(key, i)) % 2147483647
  end
  return hash
end

function Melody.next_random(state)
  local next_state = (state * 48271) % 2147483647
  return next_state, next_state / 2147483647
end

-- El sintetizador y el HUD comparten este calculo para que la nota resaltada
-- sea exactamente la que suena, sin depender de un contador paralelo.
function Melody.note_for_step(motif, seed, step, transpose)
  local total = Melody.pulse_length(motif)
  if total == 0 then
    return nil, 0, 0, 1
  end

  local position = step % total
  local cycle = math.floor(step / total)
  local shift = OCTAVE_SHIFTS[((cycle + (seed % #OCTAVE_SHIFTS)) % #OCTAVE_SHIFTS) + 1]
  local total_shift = shift + (transpose or 0)
  local cursor = 0

  for i = 1, #motif do
    local token = motif[i]
    if position >= cursor and position < cursor + token.steps then
      local note = token.note
      local frequency = note and Melody.frequency(note, total_shift) or 0
      return note, total_shift, frequency, token.steps
    end
    cursor = cursor + token.steps
  end
  return nil, total_shift, 0, 1
end

function Melody.note_for_beat(motif, seed, beat, transpose)
  return Melody.note_for_step(motif, seed, beat * 4, transpose)
end

local STEP_NAMES = {
  [1] = "Semicorchea", [2] = "Corchea", [3] = "Corchea+Semi",
  [4] = "Negra", [6] = "Negra+Corchea", [8] = "Blanca"
}

function Melody.duration_name(steps)
  return STEP_NAMES[steps] or (tostring(steps) .. "/16")
end

-- Etiqueta cromatica: transportar C4 +7 debe mostrar G4, no C5.
function Melody.label(note, shift)
  local index = (NOTE_OCTAVE[note] + 1) * 12 + PITCH_CLASS[note] + (shift or 0)
  local pitch_class = index % 12
  local octave = math.floor(index / 12) - 1
  return CHROMATIC[pitch_class + 1] .. octave
end

return Melody
