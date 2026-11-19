local Exporter = {}

local PATH = "exports/seeds.lua"
local load_chunk = loadstring or load

local function quote(value)
  local text = tostring(value)
  text = text:gsub("\\", "\\\\"):gsub('"', '\\"')
  return '"' .. text .. '"'
end

local function find_field(text, key, value_pattern)
  local pattern = key .. "%s*=%s*" .. value_pattern
  local from = 1
  while true do
    local start, finish, value = text:find(pattern, from)
    if not start then
      return nil
    end
    local previous = start > 1 and text:sub(start - 1, start - 1) or ""
    if previous == "" or not previous:match("[%w_]") then
      return finish, value
    end
    from = start + 1
  end
end

local function read_quoted(text, key)
  local finish = find_field(text, key, '"')
  if not finish then
    return nil
  end

  local result = {}
  local index = finish + 1
  while index <= #text do
    local character = text:sub(index, index)
    if character == '"' then
      return table.concat(result)
    elseif character == "\\" then
      local escaped = text:sub(index + 1, index + 1)
      if escaped == "" then
        return nil
      elseif escaped == "n" then
        result[#result + 1] = "\n"
      elseif escaped == "r" then
        result[#result + 1] = "\r"
      elseif escaped == "t" then
        result[#result + 1] = "\t"
      elseif escaped == "\\" or escaped == '"' then
        result[#result + 1] = escaped
      elseif escaped:match("%d") then
        local digits = text:sub(index + 1, index + 3):match("^%d+")
        result[#result + 1] = string.char(tonumber(digits) % 256)
        index = index + #digits - 1
      else
        result[#result + 1] = escaped
      end
      index = index + 2
    else
      result[#result + 1] = character
      index = index + 1
    end
  end
  return nil
end

local function read_number(text, key)
  local _, value = find_field(text, key, "(-?%d+)")
  return tonumber(value)
end

local function read_bool(text, key)
  local _, value = find_field(text, key, "(%a+)")
  if value == "true" then
    return true
  elseif value == "false" then
    return false
  end
  return nil
end

local function entry_id(entry)
  local text = tostring(entry.text or ""):gsub("[^%w]", "")
  if text == "" then
    text = "A"
  end
  return string.format("%s_%s_%d_%d", tostring(entry.seed or 0), text,
    entry.bpm or 0, entry.variation or 1)
end

local function format_entry(item)
  return string.format(
    "  { id = %s, text = %s, dungeon = %s, bpm = %d, rhythm = %s, progression = %s, seed = %d, variation = %d, transpose = %d, instrument = %s, arp_instrument = %s, mute_rhythm = %s, mute_harmony = %s, mute_lead = %s, mute_arp = %s, bars = %d, beats_per_bar = %d },",
    quote(item.id or entry_id(item)), quote(item.text), quote(item.dungeon), item.bpm or 0,
    quote(item.rhythm), quote(item.progression), item.seed or 0, item.variation or 1,
    item.transpose or 0, quote(item.instrument), quote(item.arp_instrument),
    tostring(item.mute_rhythm == true), tostring(item.mute_harmony == true),
    tostring(item.mute_lead == true), tostring(item.mute_arp == true),
    item.bars or 4, item.beats_per_bar or 4
  )
end

local function normalize(data)
  if type(data) ~= "table" then
    return {}
  end

  for index = 1, #data do
    if type(data[index]) == "table" and data[index].id == nil then
      data[index].id = entry_id(data[index])
    end
  end

  if type(data.playlists) ~= "table" then
    data.playlists = {}
  end
  for index = #data.playlists, 1, -1 do
    local playlist = data.playlists[index]
    if type(playlist) ~= "table" or type(playlist.name) ~= "string" then
      table.remove(data.playlists, index)
    else
      if type(playlist.tracks) ~= "table" then
        playlist.tracks = {}
      end
      for track_index = #playlist.tracks, 1, -1 do
        if type(playlist.tracks[track_index]) ~= "string" then
          table.remove(playlist.tracks, track_index)
        end
      end
    end
  end

  return data
end

local function load_real()
  if not io or not io.open then
    return nil
  end

  local ok, data = pcall(function()
    local file = io.open(PATH, "r")
    if not file then
      return nil
    end
    local contents = file:read("*a")
    file:close()
    local chunk = load_chunk(contents, PATH)
    if not chunk then
      return nil
    end
    return chunk()
  end)

  if ok and type(data) == "table" then
    return data
  end
  return nil
end

local function write_real(contents)
  if not io or not io.open then
    return false
  end

  return pcall(function()
    if os and os.execute then
      pcall(os.execute, "mkdir -p exports")
    end
    local file = io.open(PATH, "w")
    if not file then
      error("no se pudo abrir " .. PATH)
    end
    file:write(contents)
    file:close()
  end)
end

local function format_playlist(playlist)
  local tracks = {}
  for index = 1, #playlist.tracks do
    tracks[index] = quote(playlist.tracks[index])
  end
  return string.format("    { name = %s, tracks = { %s } },",
    quote(playlist.name or "Lista"), table.concat(tracks, ", "))
end

local function build_contents(data)
  local lines = {
    "-- Configuraciones guardadas en MusicVaporCode.",
    "-- Cada entrada reproduce el mismo resultado en el sandbox.",
    "-- playlists agrupa ids de entradas en listas de reproducción.",
    "return {"
  }

  for index = 1, #data do
    lines[#lines + 1] = format_entry(data[index])
  end

  lines[#lines + 1] = "  playlists = {"
  for index = 1, #data.playlists do
    lines[#lines + 1] = format_playlist(data.playlists[index])
  end
  lines[#lines + 1] = "  }"
  lines[#lines + 1] = "}"

  return table.concat(lines, "\n")
end

local function write_data(data)
  if type(data.playlists) ~= "table" then
    data.playlists = {}
  end
  local contents = build_contents(data)
  love.filesystem.createDirectory("exports")
  local written, err = love.filesystem.write(PATH, contents)
  -- En Termux el proyecto es writable: espejo para sobrevivir a rebuilds.
  local mirrored = write_real(contents)
  if not written and mirrored then
    written, err = true, nil
  end
  return written, love.filesystem.getSaveDirectory() .. "/" .. PATH, err, #data, contents
end

local function same_entry(old, entry)
  return old.seed == entry.seed and old.rhythm == entry.rhythm and old.text == entry.text and
    (old.bpm or 0) == (entry.bpm or 0) and (old.variation or 1) == (entry.variation or 1) and
    old.instrument == entry.instrument and old.arp_instrument == entry.arp_instrument and
    (old.mute_rhythm == true) == (entry.mute_rhythm == true) and
    (old.mute_harmony == true) == (entry.mute_harmony == true) and
    (old.mute_lead == true) == (entry.mute_lead == true) and
    (old.mute_arp == true) == (entry.mute_arp == true)
end

function Exporter.load()
  local ok, chunk = pcall(love.filesystem.load, PATH)
  if ok and chunk then
    local loaded, data = pcall(chunk)
    if loaded and type(data) == "table" and (#data > 0 or (#(data.playlists or {}) > 0)) then
      return normalize(data)
    end
  end

  return normalize(load_real() or {})
end

function Exporter.add(entry)
  local data = Exporter.load()

  for index = #data, 1, -1 do
    if same_entry(data[index], entry) then
      table.remove(data, index)
    end
  end
  data[#data + 1] = entry

  return write_data(data)
end

function Exporter.export(entry)
  local written, path, err, count, contents = Exporter.add(entry)

  -- En Android el archivo queda en el save dir de la app; el portapapeles
  -- permite sacarlo sin acceso a root ni a almacenamiento compartido.
  if love.system and love.system.setClipboardText then
    pcall(love.system.setClipboardText, contents)
  end

  return written, path, err, count
end

function Exporter.copy_entry(entry)
  if not love.system or not love.system.setClipboardText then
    return false, "portapapeles no disponible"
  end
  return pcall(love.system.setClipboardText,
    "-- Configuración guardada en MusicVaporCode.\n" .. format_entry(entry))
end

function Exporter.copy_all()
  if not love.system or not love.system.setClipboardText then
    return false, "portapapeles no disponible"
  end

  local data = Exporter.load()
  if #data == 0 then
    return false, "no hay configuraciones guardadas"
  end

  return pcall(love.system.setClipboardText, build_contents(data))
end

function Exporter.delete_entry(index)
  local data = Exporter.load()
  if not data[index] then
    return false, "entrada no encontrada", nil, #data
  end

  local id = entry_id(data[index])
  table.remove(data, index)
  for _, playlist in ipairs(data.playlists) do
    for track_index = #playlist.tracks, 1, -1 do
      if playlist.tracks[track_index] == id then
        table.remove(playlist.tracks, track_index)
      end
    end
  end
  return write_data(data)
end

function Exporter.entry_id(entry)
  return entry_id(entry)
end

function Exporter.create_playlist(name)
  local data = Exporter.load()
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    name = "Lista " .. (#data.playlists + 1)
  end

  for _, playlist in ipairs(data.playlists) do
    if playlist.name == name then
      return false, "ya existe una lista con ese nombre", nil, name
    end
  end

  data.playlists[#data.playlists + 1] = { name = name, tracks = {} }
  local written, path, err = write_data(data)
  return written, path, err, name, #data.playlists
end

local function playlist_at(index)
  local data = Exporter.load()
  return data, data.playlists[index]
end

function Exporter.add_to_playlist(index, id)
  local data, playlist = playlist_at(index)
  if not playlist then
    return false, "lista no encontrada", nil, 0
  end
  if type(id) ~= "string" then
    return false, "pista no encontrada", nil, #playlist.tracks
  end

  for _, track_id in ipairs(playlist.tracks) do
    if track_id == id then
      return true, nil, nil, #playlist.tracks, false
    end
  end

  playlist.tracks[#playlist.tracks + 1] = id
  local written, path, err = write_data(data)
  return written, path, err, #playlist.tracks, true
end

function Exporter.remove_from_playlist(index, id)
  local data, playlist = playlist_at(index)
  if not playlist then
    return false, "lista no encontrada", nil, 0
  end

  for track_index = #playlist.tracks, 1, -1 do
    if playlist.tracks[track_index] == id then
      table.remove(playlist.tracks, track_index)
    end
  end
  local written, path, err = write_data(data)
  return written, path, err, #playlist.tracks, true
end

function Exporter.playlist_items(index)
  local data = Exporter.load()
  local playlist = data.playlists[index]
  if not playlist then
    return {}
  end

  local items = {}
  for _, id in ipairs(playlist.tracks) do
    for entry_index = #data, 1, -1 do
      if entry_id(data[entry_index]) == id then
        items[#items + 1] = { index = entry_index, entry = data[entry_index] }
        break
      end
    end
  end
  return items
end

function Exporter.format_details(entry)
  local function on_off(value)
    return value and "sí" or "no"
  end

  return table.concat({
    "CONFIGURACIÓN GUARDADA EN MUSICVAPORCODE",
    "",
    "ID: " .. tostring(entry.id or entry_id(entry)),
    "Texto: " .. tostring(entry.text or ""),
    "Mazmorra: " .. tostring(entry.dungeon or ""),
    "BPM: " .. tostring(entry.bpm or 0),
    "Ritmo: " .. tostring(entry.rhythm or ""),
    "Progresión: " .. tostring(entry.progression or ""),
    "Instrumento: " .. tostring(entry.instrument or ""),
    "Arpeggio: " .. tostring(entry.arp_instrument or ""),
    "Semilla: " .. tostring(entry.seed or 0),
    "Variación: " .. tostring(entry.variation or 1),
    "Transposición: " .. tostring(entry.transpose or 0),
    "Compases: " .. tostring(entry.bars or 4),
    "Beats por compás: " .. tostring(entry.beats_per_bar or 4),
    "",
    "Capas activas:",
    "  Ritmo: " .. on_off(entry.mute_rhythm ~= true),
    "  Armonía: " .. on_off(entry.mute_harmony ~= true),
    "  Melodía: " .. on_off(entry.mute_lead ~= true),
    "  Arpeggio: " .. on_off(entry.mute_arp ~= true)
  }, "\n")
end

function Exporter.copy_details(entry)
  if not love.system or not love.system.setClipboardText then
    return false, "portapapeles no disponible"
  end
  return pcall(love.system.setClipboardText, Exporter.format_details(entry))
end

local function count_field(text, key)
  local pattern = key .. "%s*=%s*"
  local total = 0
  local from = 1
  while true do
    local start = text:find(pattern, from)
    if not start then
      return total
    end
    local previous = start > 1 and text:sub(start - 1, start - 1) or ""
    if previous == "" or not previous:match("[%w_]") then
      total = total + 1
    end
    from = start + 1
  end
end

local function strip_comments(text)
  local result = {}
  local index = 1
  local in_quote = false
  while index <= #text do
    local character = text:sub(index, index)
    if in_quote then
      result[#result + 1] = character
      if character == "\\" then
        result[#result + 1] = text:sub(index + 1, index + 1)
        index = index + 2
      else
        if character == '"' then
          in_quote = false
        end
        index = index + 1
      end
    elseif character == '"' then
      in_quote = true
      result[#result + 1] = character
      index = index + 1
    elseif character == "-" and text:sub(index + 1, index + 1) == "-" then
      while index <= #text and text:sub(index, index) ~= "\n" do
        index = index + 1
      end
    else
      result[#result + 1] = character
      index = index + 1
    end
  end
  return table.concat(result)
end

local function split_blocks(text)
  local blocks = {}
  local stack = {}
  local in_quote = false
  local index = 1
  while index <= #text do
    local character = text:sub(index, index)
    if in_quote then
      if character == "\\" then
        index = index + 2
      else
        if character == '"' then
          in_quote = false
        end
        index = index + 1
      end
    elseif character == '"' then
      in_quote = true
      index = index + 1
    elseif character == "{" then
      stack[#stack + 1] = index
      index = index + 1
    elseif character == "}" then
      if #stack > 0 then
        local start = table.remove(stack)
        blocks[#blocks + 1] = text:sub(start, index)
      end
      index = index + 1
    else
      index = index + 1
    end
  end
  return blocks
end

local function parse_one(block)
  local entry = {
    id = read_quoted(block, "id"),
    text = read_quoted(block, "text"),
    dungeon = read_quoted(block, "dungeon"),
    rhythm = read_quoted(block, "rhythm"),
    progression = read_quoted(block, "progression"),
    instrument = read_quoted(block, "instrument"),
    arp_instrument = read_quoted(block, "arp_instrument")
  }

  local required = { "text", "dungeon", "rhythm", "progression", "instrument", "arp_instrument" }
  for index = 1, #required do
    if not entry[required[index]] then
      return nil, "Falta el campo " .. required[index] .. "."
    end
  end

  entry.bpm = read_number(block, "bpm") or 120
  entry.seed = read_number(block, "seed") or 0
  entry.variation = read_number(block, "variation") or 1
  entry.transpose = read_number(block, "transpose") or 0
  entry.bars = read_number(block, "bars") or 4
  entry.beats_per_bar = read_number(block, "beats_per_bar") or 4
  entry.mute_rhythm = read_bool(block, "mute_rhythm") == true
  entry.mute_harmony = read_bool(block, "mute_harmony") == true
  entry.mute_lead = read_bool(block, "mute_lead") == true
  entry.mute_arp = read_bool(block, "mute_arp") == true
  entry.id = entry.id or entry_id(entry)

  return entry
end

function Exporter.parse_entries(text)
  if type(text) ~= "string" or text == "" then
    return {}, "Pega una entrada con el formato de EXPORTAR."
  end

  local blocks = split_blocks(strip_comments(text))
  local entries = {}
  for index = 1, #blocks do
    if count_field(blocks[index], "text") == 1 then
      local entry = parse_one(blocks[index])
      if entry then
        entries[#entries + 1] = entry
      end
    end
  end

  if #entries == 0 then
    return {}, "No encontré tablas válidas con el formato de EXPORTAR."
  end
  return entries
end

function Exporter.parse_entry(text)
  local entries, err = Exporter.parse_entries(text)
  if #entries == 0 then
    return nil, err
  end
  return entries[1]
end

return Exporter
