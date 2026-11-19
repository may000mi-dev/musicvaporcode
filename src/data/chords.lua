-- Acordes diatonicos de la escala usada por los leitmotivs (A3..G4).
-- Las progresiones se repiten por compas para dar contexto al motivo.
local Chords = {}

local function chord(id, name, notes, suffix)
  return { id = id, name = name, notes = notes, suffix = suffix }
end

local library = {
  Am7 = chord("Am7", "Am7", { "A", "C", "E", "G" }, "m7"),
  Cmaj7 = chord("Cmaj7", "Cmaj7", { "C", "E", "G", "B" }, "maj7"),
  Dm7 = chord("Dm7", "Dm7", { "D", "F", "A", "C" }, "m7"),
  Em7 = chord("Em7", "Em7", { "E", "G", "B", "D" }, "m7"),
  Fmaj7 = chord("Fmaj7", "Fmaj7", { "F", "A", "C", "E" }, "maj7"),
  G7 = chord("G7", "G7", { "G", "B", "D", "F" }, "7")
}

Chords.progressions = {
  {
    id = "epica", name = "Épica",
    chords = { library.Am7, library.Fmaj7, library.Cmaj7, library.G7 }
  },
  {
    id = "pop", name = "Pop",
    chords = { library.Cmaj7, library.G7, library.Am7, library.Fmaj7 }
  },
  {
    id = "jazz", name = "Jazz",
    chords = { library.Dm7, library.G7, library.Cmaj7, library.Am7 }
  },
  {
    id = "quintas", name = "Quintas",
    chords = { library.Em7, library.Am7, library.Dm7, library.G7 }
  },
  {
    id = "melancolica", name = "Melancólica",
    chords = { library.Am7, library.Dm7, library.G7, library.Cmaj7 }
  },
  {
    id = "ciclica", name = "Cíclica",
    chords = { library.Cmaj7, library.Am7, library.Fmaj7, library.G7 }
  },
  {
    id = "dron_am", name = "Dron Am",
    chords = { library.Am7 }
  },
  {
    id = "dron_c", name = "Dron C",
    chords = { library.Cmaj7 }
  },
  {
    id = "andaluza_relativa", name = "Descenso Gótico",
    chords = { library.Am7, library.G7, library.Fmaj7, library.Em7 }
  },
  {
    id = "subdominante_suave", name = "Bruma / Etérea",
    chords = { library.Fmaj7, library.Em7, library.Dm7, library.Cmaj7 }
  },
  {
    id = "tension_resolucion", name = "Tensión y Reloj",
    chords = { library.Dm7, library.Em7, library.Fmaj7, library.G7 }
  },
  {
    id = "cadencia_clasica", name = "Cadencia Clásica",
    chords = { library.Cmaj7, library.Dm7, library.G7, library.Cmaj7 }
  },
  {
    id = "relativo_luminoso", name = "Amanecer / Esperanza",
    chords = { library.Fmaj7, library.Cmaj7, library.Am7, library.Em7 }
  },
  {
    id = "nocturno_mecanico", name = "Nocturno Mecánico",
    chords = { library.Em7, library.Fmaj7, library.Am7, library.G7 }
  },
  {
    id = "bucle_hipnotico", name = "Bucle Hipnótico",
    chords = { library.Am7, library.Em7, library.Fmaj7, library.Cmaj7 }
  },
  {
    id = "dron_f", name = "Dron Fmaj7",
    chords = { library.Fmaj7 }
  },
  {
    id = "dron_em", name = "Dron Em7",
    chords = { library.Em7 }
  },
  {
    id = "catedral_vapor", name = "Catedral de Vapor",
    chords = { library.Am7, library.Em7, library.Fmaj7, library.G7 }
  },
  {
    id = "forja_enfocada", name = "Forja Encendida",
    chords = { library.Em7, library.Am7, library.Cmaj7, library.Dm7 }
  },
  {
    id = "taller_engranajes", name = "Taller de Engranajes",
    chords = { library.Dm7, library.Am7, library.Em7, library.G7 }
  },
  {
    id = "ascenso_vapor", name = "Ascenso de Vapor",
    chords = { library.Cmaj7, library.Em7, library.Fmaj7, library.G7 }
  },
  {
    id = "dron_g", name = "Dron G7",
    chords = { library.G7 }
  }
}

function Chords.at(index)
  return Chords.progressions[index]
end

return Chords
