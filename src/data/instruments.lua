-- Instrumentos generados por suma de armonicos; cada tabla de onda se
-- construye una sola vez al cargar para no gastar CPU durante el render.
local Instruments = {
  { id = "sine",     name = "Seno",       harmonics = { { 1, 1.00 } } },
  { id = "triangle", name = "Triángulo",  harmonics = { { 1, 1.00 }, { 3, 0.11 }, { 5, 0.04 } } },
  { id = "square",   name = "Cuadrada",   harmonics = { { 1, 1.00 }, { 3, 0.33 }, { 5, 0.20 }, { 7, 0.14 } } },
  { id = "saw",      name = "Sierra",     harmonics = { { 1, 1.00 }, { 2, 0.50 }, { 3, 0.33 }, { 4, 0.25 }, { 5, 0.20 } } },
  { id = "organ",    name = "Órgano",     harmonics = { { 1, 1.00 }, { 2, 0.45 }, { 3, 0.20 }, { 4, 0.12 } } },
  { id = "bell",     name = "Campana",    harmonics = { { 1, 1.00 }, { 2.01, 0.35 }, { 3.91, 0.15 } } },
  { id = "pluck",    name = "Pizzicato",  harmonics = { { 1, 1.00 }, { 2, 0.40 }, { 3, 0.15 } } },
  { id = "brass",    name = "Latón",      harmonics = { { 1, 1.00 }, { 2, 0.60 }, { 3, 0.40 }, { 4, 0.25 }, { 5, 0.15 } } },
  { id = "musicbox", name = "Caja Música", harmonics = { { 1, 1.00 }, { 3, 0.25 }, { 6, 0.12 }, { 8, 0.06 } } },
  { id = "sub_bass", name = "Sub / Pistón", harmonics = { { 1, 1.00 }, { 2, 0.30 }, { 1.5, 0.08 } } },
  { id = "reed",     name = "Lengüeta",    harmonics = { { 1, 1.00 }, { 2, 0.55 }, { 3, 0.45 }, { 4, 0.30 }, { 5, 0.20 }, { 6, 0.12 } } },
  { id = "chime",    name = "Carrillón",   harmonics = { { 1, 1.00 }, { 2.76, 0.30 }, { 5.40, 0.14 } } },
  { id = "hollow",   name = "Tubo Hueco",  harmonics = { { 1, 1.00 }, { 3, 0.45 }, { 5, 0.25 }, { 7, 0.10 } } },
  { id = "vapor_det", name = "Vapor / Chorus", harmonics = { { 1, 1.00 }, { 1.006, 0.65 }, { 2, 0.35 }, { 2.008, 0.25 } } },
  { id = "harpsichord", name = "Clavecín", harmonics = { { 1, 1.00 }, { 2, 0.55 }, { 3, 0.38 }, { 4, 0.28 }, { 5, 0.18 }, { 6, 0.10 } } },
  { id = "vox_organ", name = "Órgano Vox", harmonics = { { 1, 1.00 }, { 2, 0.70 }, { 3, 0.15 }, { 4, 0.50 }, { 8, 0.20 } } }
}

function Instruments.at(index)
  return Instruments[index]
end

return Instruments
