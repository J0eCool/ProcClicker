import vec
import color
import imgui

def debug_t() -> void
var debug_items = []
def debug(f: debug_t):
  debug_items.push(f)

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

var grid_w = 8
var grid_h = 8
var cell_size = xy_f { 64, 64 }
var cell_border = 4
def do_grid(dt):
  let all_size = xy_f { grid_w, grid_h } * (cell_size + cell_border)
  let origin = xy_f { 300, 200 }

  debug():
    grid_h = im_sliderint("grid h", grid_h, 1, 32)
    grid_w = im_sliderint("grid w", grid_w, 1, 32)

  // borders
  gl_color(color { .4, .6, .3, 1 })
  for(grid_w + 1) i:
    let start = origin + xy_f { 0.0, (cell_size.y + cell_border) * i } - cell_border/2
    let end = start + xy_f { all_size.x, 0.0 }
    gl_line(start, end, cell_border)
  for(grid_h + 1) i:
    let start = origin + xy_f { (cell_size.x + cell_border) * i, 0.0 } - cell_border/2
    let end = start + xy_f { 0.0, all_size.y }
    gl_line(start, end, cell_border)

  // grid
  for(grid_h) y:
    for(grid_w) x:
      let pos = origin + (cell_size + cell_border) * xy_f { x, y }
      gl_translate(pos):
        if gl_hit(cell_size, 0):
          gl_color(color_red)
        else:
          gl_color(color_green)
        gl_rect(cell_size)

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
  var is_debugging = true
  while gl_frame():
    if gl_button("escape") == 1:
      return

    let dt = gl_delta_time()
    let gps = 0.0
    gold += dt * gps

    debug():
      background_color = im_coloredit("background_color", background_color)
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
          for(debug_items) item:
            item()
      debug_items.remove(0, debug_items.length())

main()
