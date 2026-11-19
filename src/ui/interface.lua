local Melody = require("src.utils.melody")
local Screen = require("src.utils.screen")

local UI = {}

local fonts = {}
local buttons = { main = {}, saved = {}, import = {} }
local by_id = {}

local function add_button(view, id, x, y, width, height)
  local button = { id = id, x = x, y = y, width = width, height = height }
  buttons[view][#buttons[view] + 1] = button
  by_id[id] = button
end

function UI.load()
  fonts.title = love.graphics.newFont(24)
  fonts.normal = love.graphics.newFont(17)
  fonts.small = love.graphics.newFont(14)
  fonts.note = love.graphics.newFont(18)

  add_button("main", "cadena", 42, 90, 386, 42)

  for index = 1, 5 do
    add_button("main", "dungeon_" .. index, 472, 100 + (index - 1) * 48, 446, 44)
  end

  -- Transporte junto a la lectura de notas, dentro del panel izquierdo.
  add_button("main", "play_pause", 42, 390, 100, 44)
  add_button("main", "stop", 152, 390, 80, 44)

  -- Cada capa tiene su mute a la izquierda y su selector a la derecha.
  local row_y = { 136, 180, 224, 268 }
  add_button("main", "mute_rhythm", 42, row_y[1], 52, 44)
  add_button("main", "rhythm", 102, row_y[1], 326, 44)
  add_button("main", "mute_harmony", 42, row_y[2], 52, 44)
  add_button("main", "progression", 102, row_y[2], 326, 44)
  add_button("main", "mute_lead", 42, row_y[3], 52, 44)
  add_button("main", "inst_next", 102, row_y[3], 326, 44)
  add_button("main", "mute_arp", 42, row_y[4], 52, 44)
  add_button("main", "arp_next", 102, row_y[4], 326, 44)

  -- BPM propio, sin quitar los cinco valores base de la mazmorra.
  add_button("main", "bpm_down", 472, 344, 64, 44)
  add_button("main", "bpm_display", 544, 344, 278, 44)
  add_button("main", "bpm_up", 830, 344, 88, 44)

  -- Una sola fila inferior de acciones.
  add_button("main", "variation", 30, 492, 130, 44)
  add_button("main", "transpose_down", 168, 492, 84, 44)
  add_button("main", "transpose_up", 260, 492, 84, 44)
  add_button("main", "cadena_edit", 352, 492, 96, 44)
  add_button("main", "ready", 456, 492, 84, 44)
  add_button("main", "save", 548, 492, 120, 44)
  add_button("main", "saved", 676, 492, 130, 44)
  add_button("main", "quit", 814, 492, 104, 44)

  for index = 1, 5 do
    local y = 100 + (index - 1) * 60
    add_button("saved", "load_" .. index, 460, y, 110, 52)
    add_button("saved", "copy_" .. index, 578, y, 140, 52)
    add_button("saved", "delete_" .. index, 726, y, 120, 52)
  end
  add_button("saved", "page_prev", 42, 404, 120, 44)
  add_button("saved", "page_next", 170, 404, 120, 44)
  add_button("saved", "export_all", 500, 8, 150, 44)
  add_button("saved", "import", 660, 8, 130, 44)
  add_button("saved", "volver", 800, 8, 130, 44)

  add_button("import", "import_confirm", 60, 430, 180, 44)
  add_button("import", "import_cancel", 250, 430, 180, 44)
end

function UI.action_at(x, y, view)
  local virtual_x, virtual_y = Screen.to_virtual(x, y)
  local list = buttons[view or "main"]
  for index = 1, #list do
    local button = list[index]
    if virtual_x >= button.x and virtual_x <= button.x + button.width and
       virtual_y >= button.y and virtual_y <= button.y + button.height then
      return button.id
    end
  end
  return nil
end

local function draw_panel(x, y, width, height)
  love.graphics.setColor(0.08, 0.10, 0.13, 0.95)
  love.graphics.rectangle("fill", x, y, width, height)
  love.graphics.setColor(0.25, 0.32, 0.40)
  love.graphics.rectangle("line", x, y, width, height)
end

local function draw_box(x, y, width, height, color)
  love.graphics.setColor(color[1] * 0.18, color[2] * 0.18, color[3] * 0.18)
  love.graphics.rectangle("fill", x, y, width, height)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", x, y, width, height)
end

local function draw_row(button, selected, color, label, detail)
  if selected then
    love.graphics.setColor(color[1] * 0.25, color[2] * 0.25, color[3] * 0.25)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
  end
  love.graphics.setColor(selected and color or { 0.45, 0.50, 0.56 })
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

  love.graphics.setColor(selected and { 1, 1, 1 } or { 0.72, 0.76, 0.80 })
  love.graphics.setFont(fonts.normal)
  love.graphics.print(label, button.x + 14, button.y + 8)
  if detail then
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.62, 0.68, 0.74)
    love.graphics.print(detail, button.x + 14, button.y + 30)
  end
end

local function draw_button(button, label, accent, active)
  local color = active and accent or { accent[1] * 0.5, accent[2] * 0.5, accent[3] * 0.5 }
  love.graphics.setColor(color[1] * 0.22, color[2] * 0.22, color[3] * 0.22)
  love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(active and { 1, 1, 1 } or { 0.55, 0.58, 0.62 })
  local text_width = fonts.small:getWidth(label)
  local text_y = button.y + (button.height - 14) / 2
  love.graphics.print(label, button.x + (button.width - text_width) / 2, text_y)
end

local function draw_mute(button, muted)
  local color = muted and { 0.95, 0.35, 0.30 } or { 0.30, 0.85, 0.55 }
  love.graphics.setColor(color[1] * 0.20, color[2] * 0.20, color[3] * 0.20)
  love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(muted and { 1.00, 0.85, 0.80 } or { 0.80, 1.00, 0.85 })
  local label = muted and "MUTE" or "ON"
  local text_width = fonts.small:getWidth(label)
  local text_y = button.y + (button.height - 14) / 2
  love.graphics.print(label, button.x + (button.width - text_width) / 2, text_y)
end

local function draw_transport_icon(button, mode, accent, active)
  local color = active and accent or { accent[1] * 0.5, accent[2] * 0.5, accent[3] * 0.5 }
  love.graphics.setColor(color[1] * 0.22, color[2] * 0.22, color[3] * 0.22)
  love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
  love.graphics.setColor(active and { 1, 1, 1 } or color)

  local cx = button.x + button.width / 2
  local cy = button.y + button.height / 2
  if mode == "play" then
    love.graphics.polygon("fill", cx - 7, cy - 9, cx + 9, cy, cx - 7, cy + 9)
  elseif mode == "pause" then
    love.graphics.rectangle("fill", cx - 9, cy - 9, 6, 18)
    love.graphics.rectangle("fill", cx + 3, cy - 9, 6, 18)
  elseif mode == "stop" then
    love.graphics.rectangle("fill", cx - 8, cy - 8, 16, 16)
  end
end

local function draw_saved(state)
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.55, 0.90, 1.00)
  love.graphics.print("CONFIGURACIONES GUARDADAS", 30, 10)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.65, 0.72, 0.78)
  love.graphics.print("CARGAR usa la configuración · EXPORTAR copia al portapapeles · BORRAR la quita.", 30, 42)

  draw_button(by_id.export_all, "EXPORTAR TODO", { 0.30, 0.80, 0.90 }, true)
  draw_button(by_id.import, "IMPORTAR", { 0.95, 0.60, 0.25 }, true)
  draw_button(by_id.volver, "VOLVER", { 0.90, 0.40, 0.35 }, true)
  draw_panel(30, 84, 900, 408)

  local entries = state.saved_entries or {}
  local per_page = 5
  local total_pages = math.max(1, math.ceil(#entries / per_page))
  state.saved_page = math.max(1, math.min(state.saved_page, total_pages))
  local first = (state.saved_page - 1) * per_page + 1

  if #entries == 0 then
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(0.72, 0.76, 0.80)
    love.graphics.print("Aún no hay configuraciones guardadas. Usa GUARDAR en la pantalla principal.", 60, 130)
  else
    for slot = 1, per_page do
      local entry = entries[first + slot - 1]
      if entry then
        local y = 100 + (slot - 1) * 60
        draw_box(42, y, 410, 52, { 0.25, 0.55, 0.80 })
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print((entry.text or ""):sub(1, 32), 54, y + 6)
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.68, 0.74, 0.80)
        love.graphics.print(string.format("BPM %s · %s · %s · semilla %s",
          tostring(entry.bpm), tostring(entry.dungeon), tostring(entry.rhythm),
          tostring(entry.seed)):sub(1, 58), 54, y + 30)

        draw_button(by_id["load_" .. slot], "CARGAR", { 0.30, 0.90, 0.55 }, true)
        draw_button(by_id["copy_" .. slot], "EXPORTAR", { 0.30, 0.80, 0.90 }, true)
        draw_button(by_id["delete_" .. slot], "BORRAR", { 0.90, 0.40, 0.35 }, true)
      end
    end
  end

  draw_button(by_id.page_prev, "ANTERIOR", { 0.55, 0.45, 0.95 }, state.saved_page > 1)
  draw_button(by_id.page_next, "SIGUIENTE", { 0.55, 0.45, 0.95 }, state.saved_page < total_pages)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(string.format("Página %d/%d · %d guardadas",
    state.saved_page, total_pages, #entries), 306, 416)
  love.graphics.print(state.status or "", 42, 460)
end

local function draw_import(state)
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.55, 0.90, 1.00)
  love.graphics.print("IMPORTAR CONFIGURACIÓN", 30, 10)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.65, 0.72, 0.78)
  love.graphics.print("Pega una entrada o un return { ... } completo; se crea un registro por tabla válida.", 30, 42)

  draw_box(60, 100, 840, 300, { 0.30, 0.80, 0.90 })
  love.graphics.setFont(fonts.small)
  local text = state.import_buffer or ""
  if text == "" then
    love.graphics.setColor(0.55, 0.60, 0.66)
    love.graphics.print('Formato: { text = "...", dungeon = "...", bpm = 120, ... }', 76, 116)
  else
    love.graphics.setColor(0.90, 0.94, 0.98)
    love.graphics.printf(text, 76, 116, 808, "left")
  end

  draw_button(by_id.import_confirm, "IMPORTAR", { 0.30, 0.90, 0.55 }, true)
  draw_button(by_id.import_cancel, "CANCELAR", { 0.90, 0.40, 0.35 }, true)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(state.import_error ~= "" and { 1.00, 0.40, 0.35 } or { 0.62, 0.70, 0.78 })
  love.graphics.print(state.import_error ~= "" and state.import_error or
    string.format("%d caracteres · Enter confirma · Esc cancela", #text), 60, 486)
end

function UI.draw(state, catalog)
  if state.view == "saved" then
    draw_saved(state)
    return
  end
  if state.view == "import" then
    draw_import(state)
    return
  end

  local rhythm = catalog.rhythms[state.rhythm_index]
  local progression = catalog.progressions[state.progression_index]
  local dungeon = catalog.dungeon_at(state.dungeon_index)

  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.55, 0.90, 1.00)
  love.graphics.print("MUSIC VAPORCODE", 30, 10)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.65, 0.72, 0.78)
  love.graphics.print("SANDBOX DE MÚSICA PROCEDURAL · LÖVE 11.5", 30, 40)
  love.graphics.print("I/O · Flechas · Esp · R/T/A · B/N · G/V", 330, 40)
  love.graphics.setColor(state.playing and { 0.30, 0.95, 0.55 } or { 0.70, 0.74, 0.78 })
  love.graphics.print(state.status, 30, 64)

  love.graphics.setColor(0.80, 0.72, 1.00)
  love.graphics.print(string.format("Rit: %s · Arm: %s · %d BPM",
    rhythm.name, progression.name, state.bpm), 650, 40)
  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(string.format("Tono: %s · %s",
    catalog.transpose_label(state.transpose), state.beat_text), 650, 64)

  draw_panel(30, 84, 410, 350)
  draw_panel(460, 84, 470, 350)

  local chain_button = by_id.cadena
  love.graphics.setColor(0.30, 0.22, 0.08)
  love.graphics.rectangle("fill", chain_button.x, chain_button.y, chain_button.width, chain_button.height)
  love.graphics.setColor(1.00, 0.82, 0.30)
  love.graphics.rectangle("line", chain_button.x, chain_button.y, chain_button.width, chain_button.height)
  love.graphics.setFont(fonts.normal)
  love.graphics.setColor(1.00, 0.88, 0.55)
  local chain_label = "CADENA: " .. (state.editing and (state.edit_buffer .. "_") or state.custom_text)
  love.graphics.print(chain_label:sub(1, 36), chain_button.x + 14, chain_button.y + 12)

  draw_mute(by_id.mute_rhythm, state.muted.rhythm)
  draw_button(by_id.rhythm, "RITMO: " .. rhythm.name,
    { 0.55, 0.45, 0.95 }, not state.muted.rhythm)
  draw_mute(by_id.mute_harmony, state.muted.harmony)
  draw_button(by_id.progression, "ARM: " .. progression.name,
    { 0.95, 0.60, 0.25 }, not state.muted.harmony)
  draw_mute(by_id.mute_lead, state.muted.lead)
  draw_button(by_id.inst_next, "INST: " .. catalog.instruments[state.instrument_index].name,
    { 0.20, 0.80, 1.00 }, not state.muted.lead)
  draw_mute(by_id.mute_arp, state.muted.arp)
  draw_button(by_id.arp_next, "ARP: " .. catalog.instruments[state.arp_index].name,
    { 1.00, 0.72, 0.35 }, not state.muted.arp)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.45, 0.80, 1.00)
  love.graphics.print("RITMO DE CADENA (1 carácter = 1/16)", 42, 316)
  local motif_steps = Melody.pulse_length(state.motif)
  local active_position = state.step % math.max(1, motif_steps)
  local scale = 350 / math.max(motif_steps, 1)
  local cursor = 0
  local x = 42
  for index = 1, #state.motif do
    local token = state.motif[index]
    local width = math.max(2, token.steps * scale - 1)
    local active = state.playing and active_position >= cursor and
      active_position < cursor + token.steps
    if token.note then
      love.graphics.setColor(active and { 0.20, 0.90, 1.00 } or { 0.30, 0.38, 0.46 })
    else
      love.graphics.setColor(active and { 0.60, 0.45, 0.80 } or { 0.18, 0.20, 0.26 })
    end
    love.graphics.rectangle("fill", x, 330, width, 22)
    if width >= 9 then
      love.graphics.setColor({ 0.95, 0.97, 1.00 })
      love.graphics.setFont(fonts.small)
      love.graphics.print(token.letter or "·", x + 2, 336)
    end
    cursor = cursor + token.steps
    x = x + token.steps * scale
  end

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.45, 0.80, 1.00)
  love.graphics.print("NOTA ACTUAL", 42, 354)
  love.graphics.setFont(fonts.note)
  love.graphics.setColor(0.30, 0.95, 0.70)
  love.graphics.print(state.current_note or "—", 42, 366)
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(state.current_freq or "", 120, 371)
  love.graphics.print(state.current_duration or "", 182, 371)
  love.graphics.print("Acorde: " .. (state.current_chord or "—"), 272, 371)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.45, 0.80, 1.00)
  love.graphics.print("MAZMORRA / BPM", 472, 86)

  for index = 1, #catalog.dungeons do
    local room = catalog.dungeons[index]
    local detail = "BPM " .. room.bpm .. "   ·   " .. string.format("%.2f s por beat", 60 / room.bpm)
    draw_row(by_id["dungeon_" .. index], state.dungeon_index == index,
      { 0.95, 0.72, 0.30 }, room.name, detail)
  end

  draw_button(by_id.bpm_down, "BPM -", { 0.30, 0.90, 0.55 }, true)
  local bpm_box = by_id.bpm_display
  draw_box(bpm_box.x, bpm_box.y, bpm_box.width, bpm_box.height, { 0.80, 0.72, 1.00 })
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(1, 1, 1)
  local bpm_label = state.bpm_custom and
    string.format("BPM: %d · PERSONALIZADO (base %d)", state.bpm, dungeon.bpm) or
    string.format("BPM: %d · BASE DE %s", state.bpm, dungeon.name:upper())
  love.graphics.print(bpm_label:sub(1, 38), bpm_box.x + 14, bpm_box.y + 15)
  draw_button(by_id.bpm_up, "BPM +", { 0.30, 0.90, 0.55 }, true)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(string.format("4/4 · %d compases · %.2f s · Semilla %d · guardadas %d",
    catalog.bars, state.duration, state.seed, state.exported_count), 472, 400)

  draw_transport_icon(by_id.play_pause, state.playing and "pause" or "play",
    { 0.20, 0.75, 1.00 }, true)
  draw_transport_icon(by_id.stop, "stop", { 0.90, 0.40, 0.35 }, true)

  draw_button(by_id.variation, "SEMILLA +", { 0.95, 0.72, 0.30 }, true)
  draw_button(by_id.transpose_down, "TONO -", { 0.85, 0.55, 0.95 }, true)
  draw_button(by_id.transpose_up, "TONO +", { 0.85, 0.55, 0.95 }, true)
  draw_button(by_id.cadena_edit, "EDITAR", { 0.30, 0.80, 0.90 }, true)
  draw_button(by_id.ready, "LISTO", { 0.30, 0.90, 0.55 }, state.editing)
  draw_button(by_id.save, "GUARDAR", { 0.30, 0.90, 0.55 }, true)
  draw_button(by_id.saved, "GUARDADOS", { 0.95, 0.60, 0.25 }, true)
  draw_button(by_id.quit, "SALIR", { 0.90, 0.40, 0.35 }, true)
end

return UI
