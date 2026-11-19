local Catalog = require("src.data.catalog")
local Melody = require("src.utils.melody")
local Synth = require("src.utils.synth")
local Screen = require("src.utils.screen")
local UI = require("src.ui.interface")
local Exporter = require("src.utils.exporter")

local MAX_TEXT = 32
local MAX_IMPORT = 65536
local touch_device = love.system.getOS() == "Android" or love.system.getOS() == "iOS"

local function index_of_id(list, id)
  for index = 1, #list do
    if list[index].id == id then
      return index
    end
  end
  return 1
end

local state = {
  dungeon_index = 2,
  rhythm_index = 1,
  progression_index = 1,
  instrument_index = 1,
  arp_index = 6,
  muted = { rhythm = false, harmony = false, lead = false, arp = false },
  variation = 1,
  motif = {},
  custom_text = "aaaabbbb aaaaaaaa",
  edit_buffer = "",
  editing = false,
  seed = 0,
  instrument = "sine",
  arp_instrument = "bell",
  bpm = 104,
  bpm_custom = nil,
  view = "main",
  saved_entries = {},
  saved_page = 1,
  import_buffer = "",
  import_error = "",
  transpose = 0,
  duration = 0,
  elapsed = 0,
  beat = 0,
  step = 0,
  current_note = "—",
  current_freq = "",
  current_steps = 1,
  current_duration = "—",
  current_chord = "—",
  beat_text = "Paso —/64 · Compás —/4",
  exported_count = 0,
  source = nil,
  playing = false,
  paused = false,
  auto_paused = false,
  status = "Escribe tu cadena y elige mazmorra, luego reproduce."
}

local function start_playback()
  if state.source then
    state.source:stop()
  end

  local dungeon = Catalog.dungeon_at(state.dungeon_index)
  local rhythm = Catalog.rhythms[state.rhythm_index]
  local progression = Catalog.progressions[state.progression_index]
  local layers = {
    rhythm = not state.muted.rhythm,
    harmony = not state.muted.harmony,
    lead = not state.muted.lead,
    arp = not state.muted.arp
  }
  local sound_data, duration = Synth.render({
    bpm = state.bpm,
    motif = state.motif,
    timbre = state.instrument,
    arp_timbre = state.arp_instrument,
    seed = state.seed,
    rhythm = rhythm,
    progression = progression,
    layers = layers,
    transpose = state.transpose,
    bars = Catalog.bars,
    beats_per_bar = Catalog.beats_per_bar
  })

  state.duration = duration
  state.elapsed = 0
  state.beat = 0
  state.source = love.audio.newSource(sound_data, "static")
  state.source:setLooping(true)
  state.source:setVolume(0.75)
  state.source:play()
  state.playing = true
  state.paused = false
  state.status = "Sonando: " .. state.custom_text .. " · " .. dungeon.name .. " · " ..
    state.bpm .. " BPM · " .. rhythm.name
end

local function refresh(keep_playing)
  local dungeon = Catalog.dungeon_at(state.dungeon_index)
  local text = state.custom_text ~= "" and state.custom_text or "A"

  state.motif = Melody.from_text(text)
  if #state.motif == 0 then
    state.motif = { "A" }
  end
  state.seed = Melody.make_seed("custom", dungeon.id, state.variation, state.custom_text)
  state.instrument = Catalog.instruments.at(state.instrument_index).id
  state.arp_instrument = Catalog.instruments.at(state.arp_index).id
  state.bpm = state.bpm_custom or dungeon.bpm
  state.duration = Catalog.bars * Catalog.beats_per_bar * 60 / state.bpm
  state.elapsed = 0
  state.beat = 0
  state.step = 0
  state.current_note = "—"
  state.current_freq = ""
  state.current_steps = 1
  state.current_duration = "—"
  local first_chord = Catalog.progressions[state.progression_index].chords[1]
  local root = Melody.label(first_chord.notes[1], state.transpose):gsub("%d+$", "")
  state.current_chord = root .. first_chord.suffix
  state.beat_text = "Paso —/64 · Compás —/4"

  if keep_playing then
    start_playback()
  else
    state.status = "Listo: " .. state.custom_text .. " · " .. dungeon.name .. " · " .. state.bpm .. " BPM"
  end
end

local function begin_edit()
  state.editing = true
  state.edit_buffer = state.custom_text
  if love.keyboard.setTextInput then
    pcall(love.keyboard.setTextInput, true, 42, 90, 386, 42)
  end
  state.status = "Escribe A-Z y espacios (máx. 32). Enter o LISTO para aplicar."
end

local function confirm_edit()
  if not state.editing then
    return
  end

  local was_active = state.playing or state.paused
  local text = state.edit_buffer:gsub("[^A-Za-z ]", ""):upper()
  if text == "" then
    text = "A"
  end

  state.custom_text = text:sub(1, MAX_TEXT)
  state.editing = false
  if love.keyboard.setTextInput then
    pcall(love.keyboard.setTextInput, false)
  end
  refresh(was_active)
end

local function export_seed()
  local dungeon = Catalog.dungeon_at(state.dungeon_index)
  local rhythm = Catalog.rhythms[state.rhythm_index]

  local written, path, err, count = Exporter.export({
    text = state.custom_text,
    dungeon = dungeon.id,
    bpm = state.bpm,
    rhythm = rhythm.id,
    progression = Catalog.progressions[state.progression_index].id,
    seed = state.seed,
    variation = state.variation,
    transpose = state.transpose,
    instrument = state.instrument,
    arp_instrument = state.arp_instrument,
    mute_rhythm = state.muted.rhythm,
    mute_harmony = state.muted.harmony,
    mute_lead = state.muted.lead,
    mute_arp = state.muted.arp,
    bars = Catalog.bars,
    beats_per_bar = Catalog.beats_per_bar
  })

  state.exported_count = count
  if written then
    state.status = "Guardada (" .. count .. ") en exports/seeds.lua · también en portapapeles"
  else
    state.status = "Error al guardar: " .. tostring(err) .. " (" .. path .. ")"
  end
end

local function open_saved()
  state.saved_entries = Exporter.load()
  state.saved_page = 1
  state.view = "saved"
end

local function close_saved()
  state.view = "main"
end

local function load_saved(slot)
  local index = (state.saved_page - 1) * 5 + slot
  local entry = state.saved_entries[index]
  if not entry then
    return
  end

  state.dungeon_index = Catalog.dungeon_index_of(entry.dungeon) or 1
  local base_bpm = Catalog.dungeon_at(state.dungeon_index).bpm
  local imported_bpm = math.max(Catalog.bpm_min,
    math.min(Catalog.bpm_max, entry.bpm or base_bpm))
  state.bpm_custom = imported_bpm ~= base_bpm and imported_bpm or nil
  state.rhythm_index = index_of_id(Catalog.rhythms, entry.rhythm)
  state.progression_index = index_of_id(Catalog.progressions, entry.progression)
  state.instrument_index = index_of_id(Catalog.instruments, entry.instrument)
  state.arp_index = index_of_id(Catalog.instruments, entry.arp_instrument)
  state.transpose = entry.transpose or 0
  state.variation = entry.variation or 1
  state.custom_text = (entry.text ~= "" and entry.text) or "A"
  state.muted.rhythm = entry.mute_rhythm == true
  state.muted.harmony = entry.mute_harmony == true
  state.muted.lead = entry.mute_lead == true
  state.muted.arp = entry.mute_arp == true

  state.view = "main"
  refresh(false)
  state.status = "Cargada: " .. state.custom_text .. " · " .. state.bpm .. " BPM"
end

local function copy_saved(slot)
  local index = (state.saved_page - 1) * 5 + slot
  local entry = state.saved_entries[index]
  if not entry then
    return
  end

  local ok, err = Exporter.copy_entry(entry)
  state.status = ok and "Configuración copiada al portapapeles." or
    ("No se pudo copiar: " .. tostring(err))
end

local function delete_saved(slot)
  local index = (state.saved_page - 1) * 5 + slot
  if not state.saved_entries[index] then
    return
  end

  local written, _, err, count = Exporter.delete_entry(index)
  state.saved_entries = Exporter.load()
  state.exported_count = #state.saved_entries
  local total_pages = math.max(1, math.ceil(#state.saved_entries / 5))
  state.saved_page = math.max(1, math.min(state.saved_page, total_pages))
  state.status = written and ("Eliminada. Quedan " .. count .. " guardadas.") or
    ("No se pudo eliminar: " .. tostring(err))
end

local function open_import()
  state.view = "import"
  state.import_buffer = ""
  state.import_error = ""
  if love.keyboard.setTextInput then
    pcall(love.keyboard.setTextInput, true, 60, 100, 840, 300)
  end
end

local function close_import()
  if love.keyboard.setTextInput then
    pcall(love.keyboard.setTextInput, false)
  end
  state.view = "saved"
end

local function confirm_import()
  local entries, err = Exporter.parse_entries(state.import_buffer)
  if #entries == 0 then
    state.import_error = err
    return
  end

  local total = 0
  for index = 1, #entries do
    local written, _, write_err, count = Exporter.add(entries[index])
    if not written then
      state.import_error = "No se pudo guardar: " .. tostring(write_err)
      return
    end
    total = count
  end

  state.exported_count = total
  state.saved_entries = Exporter.load()
  state.saved_page = 1
  close_import()
  state.status = "Importadas (" .. #entries .. ") · total " .. total .. " guardadas"
end

local function handle_action(action)
  if not action then
    return
  end

  local active = state.playing or state.paused

  if action == "inst_next" then
    state.instrument_index = (state.instrument_index % #Catalog.instruments) + 1
    refresh(active)
  elseif action == "arp_next" then
    state.arp_index = (state.arp_index % #Catalog.instruments) + 1
    refresh(active)
  elseif action:match("^mute_") then
    local key = action:sub(6)
    if state.muted[key] ~= nil then
      state.muted[key] = not state.muted[key]
      refresh(active)
    end
  elseif action:match("^instrument_%d+$") then
    state.instrument_index = tonumber(action:sub(12))
    refresh(active)
  elseif action:match("^arp_%d+$") then
    state.arp_index = tonumber(action:sub(5))
    refresh(active)
  elseif action:match("^dungeon_%d+$") then
    state.dungeon_index = tonumber(action:sub(9))
    state.bpm_custom = nil
    refresh(active)
  elseif action == "bpm_down" or action == "bpm_up" then
    local delta = action == "bpm_up" and Catalog.bpm_step or -Catalog.bpm_step
    state.bpm_custom = math.max(Catalog.bpm_min,
      math.min(Catalog.bpm_max, state.bpm + delta))
    refresh(active)
  elseif action == "play" or action == "play_pause" then
    if state.playing then
      state.source:pause()
      state.playing = false
      state.paused = true
      state.status = "Pausado."
    elseif state.paused then
      -- En LÖVE 11 no existe Source:resume; play() reanuda una fuente pausada.
      state.source:play()
      state.playing = true
      state.paused = false
      state.status = "Reanudado."
    else
      start_playback()
    end
  elseif action == "rhythm" then
    state.rhythm_index = (state.rhythm_index % #Catalog.rhythms) + 1
    refresh(active)
  elseif action == "progression" then
    state.progression_index = (state.progression_index % #Catalog.progressions) + 1
    refresh(active)
  elseif action == "transpose_down" then
    state.transpose = math.max(Catalog.transpose_min, state.transpose - 1)
    refresh(active)
  elseif action == "transpose_up" then
    state.transpose = math.min(Catalog.transpose_max, state.transpose + 1)
    refresh(active)
  elseif action == "variation" then
    state.variation = state.variation + 1
    refresh(active)
  elseif action == "cadena" or action == "cadena_edit" then
    begin_edit()
  elseif action == "ready" then
    confirm_edit()
  elseif action == "save" then
    export_seed()
  elseif action == "saved" then
    open_saved()
  elseif action == "import" then
    open_import()
  elseif action == "import_confirm" then
    confirm_import()
  elseif action == "import_cancel" then
    close_import()
  elseif action == "volver" then
    close_saved()
  elseif action == "page_prev" then
    state.saved_page = math.max(1, state.saved_page - 1)
  elseif action == "page_next" then
    local total_pages = math.max(1, math.ceil(#state.saved_entries / 5))
    state.saved_page = math.min(total_pages, state.saved_page + 1)
  elseif action:match("^load_%d+$") then
    load_saved(tonumber(action:sub(6)))
  elseif action:match("^copy_%d+$") then
    copy_saved(tonumber(action:sub(6)))
  elseif action:match("^delete_%d+$") then
    delete_saved(tonumber(action:sub(8)))
  elseif action == "stop" then
    if state.source then
      state.source:stop()
      state.source = nil
    end
    state.playing = false
    state.paused = false
    state.status = "Detenido."
  elseif action == "quit" then
    love.event.quit()
  end
end

function love.load()
  state.exported_count = #Exporter.load()
  Screen.update()
  UI.load()
  refresh(false)
end

function love.update(dt)
  -- Reloj propio: getPosition() de una fuente estatica no avanza en Android.
  if not state.source or not state.playing then
    return
  end

  state.elapsed = state.elapsed + dt
  local total_beats = Catalog.bars * Catalog.beats_per_bar
  local total_steps = total_beats * 4
  local step_duration = 60 / state.bpm / 4
  state.step = math.floor(state.elapsed / step_duration) % total_steps
  state.beat = math.floor(state.step / 4)

  local note, shift, frequency, steps =
    Melody.note_for_step(state.motif, state.seed, state.step, state.transpose)
  state.current_note = note and Melody.label(note, shift) or "SIL"
  state.current_freq = note and string.format("%.1f Hz", frequency) or "silencio"
  state.current_steps = steps
  state.current_duration = Melody.duration_name(steps)
  state.beat_text = string.format("Paso %d/%d · Compás %d/4",
    state.step + 1, total_steps, math.floor(state.beat / Catalog.beats_per_bar) + 1)

  local progression = Catalog.progressions[state.progression_index]
  local chord_index = (math.floor(state.beat / Catalog.beats_per_bar) % #progression.chords) + 1
  local chord = progression.chords[chord_index]
  local root = Melody.label(chord.notes[1], state.transpose):gsub("%d+$", "")
  state.current_chord = root .. chord.suffix
end

function love.draw()
  love.graphics.clear(0.02, 0.03, 0.05)
  love.graphics.push()
  Screen.apply()
  UI.draw(state, Catalog)
  love.graphics.pop()
end

function love.textinput(text)
  if state.view == "import" then
    local cleaned = text:gsub("\r", "")
    if cleaned ~= "" and #state.import_buffer < MAX_IMPORT then
      state.import_buffer = state.import_buffer .. cleaned:sub(1, MAX_IMPORT - #state.import_buffer)
    end
    return
  end

  if not state.editing then
    return
  end

  local cleaned = text:upper():gsub("[^A-Z ]", "")
  if cleaned ~= "" and #state.edit_buffer < MAX_TEXT then
    state.edit_buffer = state.edit_buffer .. cleaned:sub(1, MAX_TEXT - #state.edit_buffer)
  end
end

function love.keypressed(key)
  if state.editing then
    if key == "backspace" then
      state.edit_buffer = state.edit_buffer:sub(1, -2)
    elseif key == "enter" or key == "keypad enter" or key == "escape" then
      confirm_edit()
    end
    return
  end

  if state.view == "import" then
    if key == "backspace" then
      state.import_buffer = state.import_buffer:sub(1, -2)
      state.import_error = ""
    elseif key == "enter" or key == "keypad enter" then
      confirm_import()
    elseif key == "escape" then
      close_import()
    end
    return
  end

  if state.view == "saved" then
    if key == "escape" then
      close_saved()
    end
    return
  end

  if key == "escape" then
    love.event.quit()
  elseif key == "right" or key == "i" then
    handle_action("instrument_" .. ((state.instrument_index % #Catalog.instruments) + 1))
  elseif key == "left" then
    handle_action("instrument_" .. ((state.instrument_index - 2) % #Catalog.instruments + 1))
  elseif key == "o" then
    handle_action("arp_" .. ((state.arp_index % #Catalog.instruments) + 1))
  elseif key == "down" then
    handle_action("dungeon_" .. ((state.dungeon_index % #Catalog.dungeons) + 1))
  elseif key == "up" then
    handle_action("dungeon_" .. ((state.dungeon_index - 2) % #Catalog.dungeons + 1))
  elseif key == "space" then
    handle_action("play")
  elseif key == "r" then
    handle_action("variation")
  elseif key == "t" then
    handle_action("rhythm")
  elseif key == "a" then
    handle_action("progression")
  elseif key == "-" or key == "[" then
    handle_action("transpose_down")
  elseif key == "=" or key == "]" then
    handle_action("transpose_up")
  elseif key == "b" then
    handle_action("bpm_down")
  elseif key == "n" then
    handle_action("bpm_up")
  elseif key == "c" then
    handle_action("cadena")
  elseif key == "g" or key == "e" then
    handle_action("save")
  elseif key == "v" then
    handle_action("saved")
  end
end

function love.mousepressed(x, y, button)
  -- En Android LÖVE emite mousepressed ademas de touchpressed para el mismo
  -- toque, y el orden no es estable: filtrar por tiempo deja pasar duplicados.
  -- Cada plataforma usa un solo canal de entrada.
  if button == 1 and not touch_device then
    handle_action(UI.action_at(x, y, state.view))
  end
end

function love.touchpressed(id, x, y)
  if not touch_device then
    return
  end
  handle_action(UI.action_at(x, y, state.view))
end

function love.resize(width, height)
  Screen.update()
end

function love.focus(focused)
  if not state.source then
    return
  end

  if not focused then
    state.auto_paused = state.playing
    if state.playing then
      state.source:pause()
      state.playing = false
    end
  elseif state.auto_paused then
    state.source:play()
    state.playing = true
    state.auto_paused = false
  end
end

function love.quit()
  if state.source then
    state.source:stop()
  end
end
