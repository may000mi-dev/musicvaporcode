local function loveConf(t)
  t.identity = "musicvaporcode"
  t.version = "11.5"
  t.window.title = "MusicVaporCode - Sandbox de música procedural"
  t.window.width = 960
  t.window.height = 540
  t.window.vsync = 1
  t.window.msaa = 0
  t.modules.joystick = false
  t.modules.physics = false
  t.modules.video = false
  t.modules.touch = true
end

return loveConf
