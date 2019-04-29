import vec
import color
import imgui

class Building:
  name: string
  color: color

let all_buildings = [
  Building { "Copper Mine", color { 0.8, 0.7, 0.3, 1.0 }},
  Building { "Belt", color { 0.6, 0.6, 0.6, 1.0 }},
]

var gold = 0.0

def building_gui(idx):
  let info = all_buildings[idx]
  im_text(info.name + ": " + info.color)

def do_grid(dt):
  let w = 8
  let h = 8
  let size = xy_f { 64, 64 }
  let border = 4
  let all_size = xy_f { w, h } * (size + border)
  let origin = xy_f { 300, 200 }

  // borders
  gl_color(color { .4, .6, .3, 1 })
  for(w + 1) i:
    let start = origin + xy_f { 0.0, (size.y + border) * i } - border/2
    let end = start + xy_f { all_size.x, 0.0 }
    gl_line(start, end, border)
  for(h + 1) i:
    let start = origin + xy_f { (size.x + border) * i, 0.0 } - border/2
    let end = start + xy_f { 0.0, all_size.y }
    gl_line(start, end, border)

  // grid
  for(h) y:
    for(w) x:
      let pos = origin + (size + border) * xy_f { x, y }
      gl_translate(pos):
        if gl_hit(size, 0):
          gl_color(color_red)
        else:
          gl_color(color_green)
        gl_rect(size)

def main():
  fatal(gl_window("Simple Clicker", 1280, 1024))

  im_init(false)
  assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)

  let window_flags = (
      im_window_no_collapse
    | im_window_always_autoresize
    | im_window_no_nav_inputs
    )
  var background_color = color { 162, 168, 132, 255 } / 255
  var is_debugging = false
  while gl_frame():
    if gl_button("escape") == 1:
      return

    let dt = gl_delta_time()
    let gps = 0.0
    gold += dt * gps

    gl_clear(background_color)

    do_grid(dt)

    im_frame():
      im_window("Money", window_flags):
        im_text("Gold: " + int(gold) + " (+" + gps + "/s)")
      im_window("Buildings", window_flags):
        for(length(all_buildings)) idx:
          building_gui(idx)

      if gl_button("f12") == 0:
        is_debugging = !is_debugging
      if is_debugging:
        im_window("Debug", window_flags):
          background_color = im_coloredit("background_color", background_color)

main()
