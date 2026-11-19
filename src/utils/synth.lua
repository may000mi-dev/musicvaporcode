local Melody = require("src.utils.melody")
local Chords = require("src.data.chords")
local Instruments = require("src.data.instruments")
local Rhythms = require("src.data.rhythms")

local Synth = {}

-- Tablas de onda y envolventes precalculadas: en el telefono el render debe
-- ocurrir en un solo cambio de seleccion sin allocations por muestra.
local RATE = 22050
local TABLE_SIZE = 2048
local waveforms = {}
local buffer = {}
local events = {}

local function build_waveforms()
  for i = 1, #Instruments do
    local definition = Instruments[i]
    local harmonics = definition.harmonics
    local total = 0
    for h = 1, #harmonics do
      total = total + harmonics[h][2]
    end

    local table_data = {}
    for sample = 1, TABLE_SIZE do
      local phase = (sample - 1) / TABLE_SIZE
      local value = 0
      for h = 1, #harmonics do
        local harmonic = harmonics[h]
        value = value + harmonic[2] * math.sin(phase * 2 * math.pi * harmonic[1])
      end
      table_data[sample] = value / total
    end
    waveforms[definition.id] = table_data
  end
end

build_waveforms()

function Synth.render(spec)
  local motif = spec.motif
  local spb = 60 / spec.bpm
  local total_beats = spec.bars * spec.beats_per_bar
  local duration = total_beats * spb
  local sample_count = math.floor(duration * RATE)
  local wave = waveforms[spec.timbre] or waveforms.sine
  local arp_wave = waveforms[spec.arp_timbre] or waveforms.bell
  local sine_wave = waveforms.sine
  local rhythm = spec.rhythm or Rhythms[1]
  local progression = spec.progression or Chords.progressions[1]
  local layers = spec.layers or { lead = true, arp = true, rhythm = true, harmony = true }
  local gate = rhythm.gate or 0.85
  local event_count = 0

  for i = 1, sample_count do
    buffer[i] = 0
  end

  local function add_event(kind, beat, length, freq, amp, attack, decay)
    event_count = event_count + 1
    events[event_count] = {
      kind = kind, start = beat * spb, length = length,
      freq = freq, amp = amp, attack = attack, decay = decay
    }
  end

  -- Cada corrida ocupa N semicorcheas; los espacios son silencios.
  local motif_steps = Melody.pulse_length(motif)
  local total_steps = total_beats * 4
  local step = 0
  while step < total_steps and motif_steps > 0 do
    for i = 1, #motif do
      if step >= total_steps then
        break
      end
      local token = motif[i]
      local note, _, frequency, steps = Melody.note_for_step(motif, spec.seed, step, spec.transpose)
      if layers.lead and note then
        add_event("lead", step * 0.25, spb * steps * 0.25 * gate,
          frequency, 0.42, 0.012, 2.5)
      end
      step = step + token.steps
    end
  end

  -- Armonia, bajo y percussion se repiten por compas segun la seleccion.
  for bar = 0, spec.bars - 1 do
    local bar_start = bar * spec.beats_per_bar
    local chord = progression.chords[(bar % #progression.chords) + 1]
    local transpose = spec.transpose or 0
    local root_frequency = Melody.frequency(chord.notes[1], -12 + transpose)

    if layers.harmony ~= false then
      for i = 1, math.min(3, #chord.notes) do
        add_event("pad", bar_start, spb * spec.beats_per_bar * 0.94,
          Melody.frequency(chord.notes[i], -12 + transpose), 0.085, 0.10, 1.4)
      end
    end

    if layers.arp then
      for step = 0, 7 do
        local note = chord.notes[(step % #chord.notes) + 1]
        add_event("arp", bar_start + step * 0.5, spb * 0.30,
          Melody.frequency(note, transpose), 0.075, 0.005, 3.2)
      end
    end

    if layers.harmony ~= false then
      for i = 1, #rhythm.bass do
        local beat = bar_start + rhythm.bass[i]
        add_event("bass", beat, spb * 1.5, root_frequency, 0.28, 0.008, 2.0)
      end
    end

    if layers.rhythm then
      for i = 1, #rhythm.kick do
        local beat = bar_start + rhythm.kick[i]
        add_event("kick", beat, math.min(0.22, spb * 0.6), nil, 0.50)
      end

      for i = 1, #rhythm.snare do
        local beat = bar_start + rhythm.snare[i]
        add_event("snare", beat, math.min(0.16, spb * 0.5), nil, 0.30)
      end

      for i = 1, #rhythm.hat do
        local beat = bar_start + rhythm.hat[i]
        add_event("hat", beat, 0.045, nil, 0.10)
      end
    end
  end

  local noise_state = (spec.seed % 2147483646) + 1

  for event_index = 1, event_count do
    local event = events[event_index]
    local first = math.floor(event.start * RATE) + 1
    local count = math.floor(event.length * RATE)
    if first + count - 1 > sample_count then
      count = sample_count - first + 1
    end

    local kind = event.kind
    local tonal = kind == "lead" or kind == "bass" or kind == "pad" or kind == "arp"
    local event_wave = wave
    if kind == "pad" then
      event_wave = waveforms.organ
    elseif kind == "arp" then
      event_wave = arp_wave
    end

    local phase = 0
    local phase_step = 0
    local amplitude = event.amp
    local attack_value = 0
    local attack_step = 0
    local release_value = 1
    local release_step = 1 / (0.025 * RATE)
    local release_at = count - 0.025 * RATE
    local decay_value = 1
    local decay_factor = 1
    local sweep = 1
    local sweep_factor = 1

    if tonal then
      phase_step = event.freq / RATE
      attack_step = 1 / (event.attack * RATE)
      decay_factor = math.exp(-event.decay / (event.length * RATE))
    elseif kind == "kick" then
      attack_step = 1 / (0.003 * RATE)
      decay_factor = math.exp(-16 / RATE)
      sweep_factor = math.exp(-26 / RATE)
    elseif kind == "snare" then
      attack_step = 1
      phase_step = 180 / RATE
      decay_factor = math.exp(-24 / RATE)
    else
      attack_step = 1
      decay_factor = math.exp(-70 / RATE)
    end

    for offset = 0, count - 1 do
      local value = 0

      if tonal then
        phase = phase + phase_step
        if phase >= 1 then
          phase = phase - 1
        end
        value = event_wave[math.floor(phase * TABLE_SIZE) + 1]
        attack_value = attack_value + attack_step
        if attack_value > 1 then
          attack_value = 1
        end
        if offset > release_at then
          release_value = release_value - release_step
          if release_value < 0 then
            release_value = 0
          end
        end
      elseif kind == "kick" then
        phase = phase + (48 + 110 * sweep) / RATE
        if phase >= 1 then
          phase = phase - 1
        end
        value = sine_wave[math.floor(phase * TABLE_SIZE) + 1]
        attack_value = attack_value + attack_step
        if attack_value > 1 then
          attack_value = 1
        end
        sweep = sweep * sweep_factor
      else
        noise_state = (noise_state * 48271) % 2147483647
        value = noise_state / 2147483647 * 2 - 1
        if kind == "snare" then
          phase = phase + phase_step
          if phase >= 1 then
            phase = phase - 1
          end
          value = value * 0.6 + sine_wave[math.floor(phase * TABLE_SIZE) + 1] * 0.4
        end
        attack_value = 1
      end

      decay_value = decay_value * decay_factor
      local sample_index = first + offset
      buffer[sample_index] = buffer[sample_index] + value * amplitude * attack_value * release_value * decay_value
    end
  end

  -- Fundido de 4 ms para que el loop no haga clic al repetirse.
  local fade = math.floor(RATE * 0.004)
  for i = 1, fade do
    local factor = i / fade
    buffer[i] = buffer[i] * factor
    buffer[sample_count - i + 1] = buffer[sample_count - i + 1] * factor
  end

  local peak = 0
  for i = 1, sample_count do
    local magnitude = buffer[i] < 0 and -buffer[i] or buffer[i]
    if magnitude > peak then
      peak = magnitude
    end
  end

  local gain = 1
  if peak > 0.95 then
    gain = 0.95 / peak
  end

  local sound_data = love.sound.newSoundData(sample_count, RATE, 16, 1)
  for i = 1, sample_count do
    sound_data:setSample(i - 1, buffer[i] * gain)
  end

  return sound_data, duration
end

return Synth
