local Exporter = {}

local PATH = "exports/seeds.lua"

local function quote(value)
  local text = tostring(value)
  text = text:gsub("\\", "\\\\"):gsub('"', '\\"')
  return '"' .. text .. '"'
end

local function format_entry(item)
  return string.format(
    "  { text = %s, dungeon = %s, bpm = %d, rhythm = %s, progression = %s, seed = %d, variation = %d, transpose = %d, instrument = %s, arp_instrument = %s, mute_rhythm = %s, mute_harmony = %s, mute_lead = %s, mute_arp = %s, bars = %d, beats_per_bar = %d },",
    quote(item.text), quote(item.dungeon), item.bpm or 0,
    quote(item.rhythm), quote(item.progression), item.seed or 0, item.variation or 1,
    item.transpose or 0, quote(item.instrument), quote(item.arp_instrument),
    tostring(item.mute_rhythm == true), tostring(item.mute_harmony == true),
    tostring(item.mute_lead == true), tostring(item.mute_arp == true),
    item.bars or 4, item.beats_per_bar or 4
  )
end

local function write_data(data)
  local lines = {
    "-- Configuraciones guardadas en MusicVaporCode.",
    "-- Cada entrada reproduce el mismo resultado en el sandbox.",
    "return {"
  }

  for index = 1, #data do
    lines[#lines + 1] = format_entry(data[index])
  end
  lines[#lines + 1] = "}"

  local contents = table.concat(lines, "\n")
  love.filesystem.createDirectory("exports")
  local written, err = love.filesystem.write(PATH, contents)
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
  if not ok or not chunk then
    return {}
  end

  local loaded, data = pcall(chunk)
  if not loaded or type(data) ~= "table" then
    return {}
  end
  return data
end

function Exporter.export(entry)
  local data = Exporter.load()

  for index = #data, 1, -1 do
    if same_entry(data[index], entry) then
      table.remove(data, index)
    end
  end
  data[#data + 1] = entry

  local written, path, err, count, contents = write_data(data)

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

function Exporter.delete_entry(index)
  local data = Exporter.load()
  if not data[index] then
    return false, "entrada no encontrada", nil, #data
  end

  table.remove(data, index)
  return write_data(data)
end

return Exporter
