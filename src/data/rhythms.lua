-- Patrones de percussion dentro de un compas de 4/4; los tiempos son beats
-- relativos al compas (0-indexados) para poder repetirlos sin acumular error.
local Rhythms = {
  {
    id = "recto", name = "Recto",
    kick = { 0, 2 }, snare = { 1, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 2 }, gate = 0.85
  },
  {
    id = "galope", name = "Galope",
    kick = { 0, 1.5, 2 }, snare = { 1, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 1.5, 2 }, gate = 0.60
  },
  {
    id = "sincopado", name = "Sincopado",
    kick = { 0, 2.5 }, snare = { 1, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 2.5 }, gate = 0.70
  },
  {
    id = "marcha", name = "Marcha",
    kick = { 0, 1, 2, 3 }, snare = { 2 },
    hat = { 0, 1, 2, 3 },
    bass = { 0, 2 }, gate = 0.90
  },
  {
    id = "medio_tiempo", name = "Medio tiempo",
    kick = { 0 }, snare = { 2 },
    hat = { 0, 1, 2, 3 },
    bass = { 0, 2 }, gate = 0.95
  },
  {
    id = "tresillo_mecanico", name = "Reloj / Tresillo",
    kick = { 0, 1.5, 3 }, snare = { 1, 3 },
    hat = { 0, 0.75, 1.5, 2.25, 3, 3.5 },
    bass = { 0, 1.5, 3 }, gate = 0.55
  },
  {
    id = "contrapulso", name = "Contrapulso",
    kick = { 0, 2 }, snare = { 1.5, 3 },
    hat = { 0.5, 1.5, 2.5, 3.5 },
    bass = { 0, 1.5, 2, 3.5 }, gate = 0.65
  },
  {
    id = "vals_industrial", name = "Pulso 3+3+2",
    kick = { 0, 1.5, 3 }, snare = { 1, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 1.5, 3 }, gate = 0.75
  },
  {
    id = "frenesi_engranajes", name = "Frenesí",
    kick = { 0, 1, 2, 2.5, 3 }, snare = { 1, 3 },
    hat = { 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75 },
    bass = { 0, 1, 2, 2.5, 3 }, gate = 0.45
  },
  {
    id = "bruma_lenta", name = "Bruma / Legato",
    kick = { 0, 2.5 }, snare = { 3 },
    hat = { 0, 1, 2, 3 },
    bass = { 0, 2 }, gate = 0.95
  },
  {
    id = "staccato_automata", name = "Autómata Staccato",
    kick = { 0, 2 }, snare = { 1, 2.5, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 0.75, 2, 2.75 }, gate = 0.35
  },
  {
    id = "doble_pulso", name = "Doble Pulso",
    kick = { 0, 0.75, 2, 2.75 }, snare = { 1, 3 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 0.75, 2, 2.75 }, gate = 0.65
  },
  {
    id = "tren_vapor", name = "Tren de Vapor",
    kick = { 0, 0.5, 1.5, 2, 3 }, snare = { 1, 3 },
    hat = { 0.25, 0.75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75 },
    bass = { 0, 1.5, 2, 3 }, gate = 0.50
  },
  {
    id = "respiracion", name = "Respiración",
    kick = { 0, 3 }, snare = { 2 },
    hat = { 0, 1, 2, 3 },
    bass = { 0, 2 }, gate = 0.95
  },
  {
    id = "golpe_doble", name = "Golpe Doble",
    kick = { 0, 1, 2, 3 }, snare = { 0.5, 2.5 },
    hat = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 },
    bass = { 0, 1, 2, 3 }, gate = 0.55
  }
}

function Rhythms.at(index)
  return Rhythms[index]
end

return Rhythms
