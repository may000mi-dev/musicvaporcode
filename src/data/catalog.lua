-- Espejo minimo de los datos canonicos de VaporCode para que el experimento
-- sea comparable sin tocar el proyecto principal.
local Chords = require("src.data.chords")
local Instruments = require("src.data.instruments")
local Rhythms = require("src.data.rhythms")

local Catalog = {}

Catalog.rhythms = Rhythms
Catalog.progressions = Chords.progressions
Catalog.instruments = Instruments

Catalog.dungeons = {
  { id = "sandbox",  name = "Sala de pruebas",            bpm = 120 },
  { id = "cripta",   name = "Cripta de latón",            bpm = 104 },
  { id = "forja",    name = "Forja de vapor",             bpm = 124 },
  { id = "catedral", name = "Catedral de engranajes",     bpm = 138 },
  { id = "torre",    name = "Torre del Tiempo Detenido",  bpm = 150 }
}

Catalog.beats_per_bar = 4
Catalog.bars = 4

-- El sandbox no queda atado a los cinco BPM de las mazmorras.
Catalog.bpm_min = 40
Catalog.bpm_max = 240
Catalog.bpm_step = 1

-- Transporte continuo: una octava abajo, la nota original y una octava arriba.
Catalog.transpose_min = -12
Catalog.transpose_max = 12

function Catalog.transpose_label(value)
  if value == 0 then
    return "0 (original)"
  end
  return string.format("%+d st", value)
end

function Catalog.dungeon_at(index)
  return Catalog.dungeons[index]
end

function Catalog.dungeon_index_of(id)
  if id == "pruebas" then
    id = "sandbox"
  end
  for index = 1, #Catalog.dungeons do
    if Catalog.dungeons[index].id == id then
      return index
    end
  end
  return nil
end

return Catalog
