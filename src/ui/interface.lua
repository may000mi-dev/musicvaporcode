local Melody = require("src.utils.melody")
local Screen = require("src.utils.screen")

local UI = {}

local fonts = {}
local buttons = {
  main = {}, saved = {}, import = {}, details = {}, add_to = {}, new_playlist = {}
}
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

  add_button("saved", "new_playlist", 360, 6, 140, 36)
  add_button("saved", "export_all", 508, 6, 140, 36)
  add_button("saved", "import", 656, 6, 130, 36)
  add_button("saved", "volver", 794, 6, 136, 36)

  add_button("saved", "tab_prev", 42, 48, 28, 30)
  add_button("saved", "tab_all", 76, 48, 90, 30)
  for index = 1, 6 do
    add_button("saved", "tab_playlist_" .. index, 172 + (index - 1) * 106, 48, 100, 30)
  end
  add_button("saved", "tab_next", 812, 48, 28, 30)

  for index = 1, 5 do
    local y = 116 + (index - 1) * 60
    add_button("saved", "list_toggle_" .. index, 42, y, 52, 52)
    add_button("saved", "list_stop_" .. index, 100, y, 52, 52)
    add_button("saved", "load_" .. index, 408, y, 80, 52)
    add_button("saved", "copy_" .. index, 494, y, 100, 52)
    add_button("saved", "delete_" .. index, 600, y, 80, 52)
    add_button("saved", "details_" .. index, 686, y, 90, 52)
    add_button("saved", "playlist_toggle_" .. index, 782, y, 120, 52)
  end
  add_button("saved", "page_prev", 42, 420, 120, 44)
  add_button("saved", "page_next", 170, 420, 120, 44)
  add_button("saved", "list_prev", 300, 420, 80, 44)
  add_button("saved", "list_play_all", 388, 420, 140, 44)
  add_button("saved", "list_stop_all", 536, 420, 100, 44)
  add_button("saved", "list_next", 644, 420, 80, 44)

  add_button("details", "details_copy", 620, 410, 130, 44)
  add_button("details", "details_close", 760, 410, 120, 44)
  add_button("details", "details_scroll_up", 868, 150, 40, 40)
  add_button("details", "details_scroll_down", 868, 290, 40, 40)

  for index = 1, 5 do
    add_button("add_to", "add_playlist_" .. index, 170, 140 + (index - 1) * 50, 500, 44)
  end
  add_button("add_to", "add_prev", 680, 140, 30, 44)
  add_button("add_to", "add_next", 718, 140, 30, 44)
  add_button("add_to", "add_create", 770, 140, 120, 44)
  add_button("add_to", "add_cancel", 770, 420, 120, 44)

  add_button("new_playlist", "new_playlist_confirm", 300, 360, 160, 44)
  add_button("new_playlist", "new_playlist_cancel", 480, 360, 160, 44)

  add_button("import", "import_confirm", 60, 430, 180, 44)
  add_button("import", "import_cancel", 250, 430, 180, 44)
end

function UI.action_at(x, y, view, modal)
  local virtual_x, virtual_y = Screen.to_virtual(x, y)
  local list = buttons[modal or view or "main"] or buttons[view or "main"]
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
  local playlists = state.playlists or {}
  local items = state.saved_items or {}

  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.55, 0.90, 1.00)
  love.graphics.print("CONFIGURACIONES GUARDADAS", 30, 8)

  draw_button(by_id.new_playlist, "NUEVA LISTA", { 0.95, 0.72, 0.30 }, true)
  draw_button(by_id.export_all, "EXPORTAR TODO", { 0.30, 0.80, 0.90 }, true)
  draw_button(by_id.import, "IMPORTAR", { 0.95, 0.60, 0.25 }, true)
  draw_button(by_id.volver, "VOLVER", { 0.90, 0.40, 0.35 }, true)

  draw_button(by_id.tab_prev, "<", { 0.55, 0.45, 0.95 }, state.tab_offset > 0)
  draw_button(by_id.tab_all, "TODAS", { 0.30, 0.80, 0.90 }, state.active_tab == 0)
  for slot = 1, 6 do
    local playlist_index = state.tab_offset + slot
    local label = ""
    if playlists[playlist_index] then
      label = tostring(playlists[playlist_index].name):sub(1, 12)
    end
    draw_button(by_id["tab_playlist_" .. slot], label, { 0.70, 0.45, 0.95 },
      state.active_tab == playlist_index and playlist_index > 0)
  end
  draw_button(by_id.tab_next, ">", { 0.55, 0.45, 0.95 }, state.tab_offset < math.max(0, #playlists - 6))
  draw_panel(30, 84, 900, 408)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.65, 0.72, 0.78)
  love.graphics.print("PLAY/PAUSA y STOP a la izquierda · DETALLES copia el texto · AÑADIR/RETIRAR organiza listas.", 36, 90)

  local per_page = 5
  local total_pages = math.max(1, math.ceil(#items / per_page))
  state.saved_page = math.max(1, math.min(state.saved_page, total_pages))
  local first = (state.saved_page - 1) * per_page + 1

  if #items == 0 then
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(0.72, 0.76, 0.80)
    love.graphics.print(state.active_tab == 0 and
      "Aún no hay configuraciones guardadas. Usa GUARDAR en la pantalla principal." or
      "Esta lista está vacía. Usa AÑADIR en la pestaña TODAS.", 60, 140)
  else
    for slot = 1, per_page do
      local item = items[first + slot - 1]
      if item then
        local entry = item.entry
        local y = 116 + (slot - 1) * 60
        local is_current = state.list_index == item.index and state.list_playing
        local play_mode = is_current and not state.list_paused and "pause" or "play"

        draw_transport_icon(by_id["list_toggle_" .. slot], play_mode, { 0.30, 0.90, 0.55 }, is_current)
        draw_transport_icon(by_id["list_stop_" .. slot], "stop", { 0.90, 0.40, 0.35 }, is_current)

        draw_box(160, y, 240, 52, { 0.25, 0.55, 0.80 })
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print((entry.text or ""):sub(1, 24), 172, y + 6)
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(0.68, 0.74, 0.80)
        love.graphics.print(string.format("BPM %s · %s · semilla %s",
          tostring(entry.bpm), tostring(entry.dungeon),
          tostring(entry.seed)):sub(1, 26), 172, y + 30)

        draw_button(by_id["load_" .. slot], "CARGAR", { 0.30, 0.90, 0.55 }, true)
        draw_button(by_id["copy_" .. slot], "EXPORTAR", { 0.30, 0.80, 0.90 }, true)
        draw_button(by_id["delete_" .. slot], "BORRAR", { 0.90, 0.40, 0.35 }, true)
        draw_button(by_id["details_" .. slot], "DETALLES", { 0.45, 0.80, 1.00 }, true)
        local list_label = state.active_tab > 0 and "RETIRAR" or "AÑADIR"
        local list_color = state.active_tab > 0 and { 0.95, 0.55, 0.35 } or { 0.70, 0.45, 0.95 }
        draw_button(by_id["playlist_toggle_" .. slot], list_label, list_color, true)
      end
    end
  end

  local all_active = state.list_playing and state.list_mode == "all"
  local all_label = all_active and not state.list_paused and "PAUSAR TODO" or "REPRODUCIR TODO"

  draw_button(by_id.page_prev, "ANTERIOR", { 0.55, 0.45, 0.95 }, state.saved_page > 1)
  draw_button(by_id.page_next, "SIGUIENTE", { 0.55, 0.45, 0.95 }, state.saved_page < total_pages)
  draw_button(by_id.list_prev, "<", { 0.55, 0.45, 0.95 }, #items > 0)
  draw_button(by_id.list_play_all, all_label, { 0.30, 0.90, 0.55 }, #items > 0)
  draw_button(by_id.list_stop_all, "DETENER", { 0.90, 0.40, 0.35 }, state.list_playing)
  draw_button(by_id.list_next, ">", { 0.55, 0.45, 0.95 }, #items > 0)

  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(string.format("Página %d/%d · %d en esta pestaña",
    state.saved_page, total_pages, #items), 734, 452)
  love.graphics.print(state.status or "", 42, 476)
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

local function draw_modal_scrim()
  love.graphics.setColor(0.00, 0.00, 0.00, 0.72)
  love.graphics.rectangle("fill", 0, 0, 960, 540)
end

local function draw_details_modal(state)
  draw_modal_scrim()
  draw_panel(100, 90, 820, 390)
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.45, 0.85, 1.00)
  love.graphics.print("DETALLES DE LA CONFIGURACIÓN", 120, 100)

  draw_box(120, 140, 720, 250, { 0.30, 0.80, 0.90 })
  local lines = {}
  for line in tostring(state.modal_text or ""):gmatch("[^\n]+") do
    lines[#lines + 1] = line
  end
  if #lines == 0 then
    lines[1] = ""
  end

  local first = (state.modal_scroll or 0) + 1
  love.graphics.setFont(fonts.small)
  for index = 1, 14 do
    local line = lines[first + index - 1]
    if line then
      love.graphics.setColor(0.92, 0.95, 0.98)
      love.graphics.print(line, 136, 152 + (index - 1) * 16)
    end
  end

  love.graphics.setColor(0.62, 0.70, 0.78)
  love.graphics.print(string.format("Líneas %d-%d de %d · rueda o flechas",
    first, math.min(#lines, first + 13), #lines), 120, 396)

  draw_button(by_id.details_copy, "COPIAR", { 0.30, 0.80, 0.90 }, true)
  draw_button(by_id.details_close, "CERRAR", { 0.90, 0.40, 0.35 }, true)
  draw_button(by_id.details_scroll_up, "▲", { 0.55, 0.45, 0.95 }, (state.modal_scroll or 0) > 0)
  draw_button(by_id.details_scroll_down, "▼", { 0.55, 0.45, 0.95 },
    (state.modal_scroll or 0) < (state.modal_max_scroll or 0))
end

local function draw_add_modal(state)
  draw_modal_scrim()
  draw_panel(100, 90, 820, 390)
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.70, 0.45, 0.95)
  love.graphics.print("AÑADIR A LISTA DE REPRODUCCIÓN", 120, 100)

  draw_box(160, 130, 680, 270, { 0.70, 0.45, 0.95 })
  local playlists = state.playlists or {}
  if #playlists == 0 then
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.72, 0.78, 0.84)
    love.graphics.print("Todavía no hay listas. Crea una para organizar esta pista.", 180, 180)
  else
    for slot = 1, 5 do
      local playlist_index = (state.modal_list_offset or 0) + slot
      local playlist = playlists[playlist_index]
      if playlist then
        local included = false
        for _, id in ipairs(playlist.tracks or {}) do
          if id == state.modal_target_id then
            included = true
            break
          end
        end
        local label = tostring(playlist.name):sub(1, 40) .. (included and "  ·  YA INCLUIDA" or "")
        draw_button(by_id["add_playlist_" .. slot], label,
          included and { 0.35, 0.75, 0.55 } or { 0.70, 0.45, 0.95 }, true)
      else
        draw_button(by_id["add_playlist_" .. slot], "", { 0.70, 0.45, 0.95 }, false)
      end
    end
  end

  draw_button(by_id.add_prev, "<", { 0.55, 0.45, 0.95 }, (state.modal_list_offset or 0) > 0)
  draw_button(by_id.add_next, ">", { 0.55, 0.45, 0.95 },
    (state.modal_list_offset or 0) < math.max(0, #playlists - 5))
  draw_button(by_id.add_create, "NUEVA", { 0.95, 0.72, 0.30 }, true)
  draw_button(by_id.add_cancel, "CANCELAR", { 0.90, 0.40, 0.35 }, true)
end

local function draw_new_playlist_modal(state)
  draw_modal_scrim()
  draw_panel(240, 130, 480, 290)
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.95, 0.72, 0.30)
  love.graphics.print("NUEVA LISTA", 260, 142)

  draw_box(280, 190, 400, 44, { 0.95, 0.72, 0.30 })
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print((state.modal_buffer or "") .. "_", 294, 204)

  love.graphics.setColor(state.modal_error ~= "" and { 1.00, 0.40, 0.35 } or { 0.62, 0.70, 0.78 })
  love.graphics.print(state.modal_error ~= "" and state.modal_error or
    "Nombre libre · Enter confirma · Esc cancela", 280, 250)

  draw_button(by_id.new_playlist_confirm, "CREAR", { 0.30, 0.90, 0.55 }, true)
  draw_button(by_id.new_playlist_cancel, "CANCELAR", { 0.90, 0.40, 0.35 }, true)
end

local function draw_modal_if_needed(state)
  if state.modal == "details" then
    draw_details_modal(state)
  elseif state.modal == "add_to" then
    draw_add_modal(state)
  elseif state.modal == "new_playlist" then
    draw_new_playlist_modal(state)
  end
end

function UI.draw(state, catalog)
  if state.view == "saved" then
    draw_saved(state)
    draw_modal_if_needed(state)
    return
  end
  if state.view == "import" then
    draw_import(state)
    draw_modal_if_needed(state)
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
  draw_modal_if_needed(state)
end

return UI
