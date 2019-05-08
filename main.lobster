import vec
import color
import imgui

def debug_t() -> void
let debug_items = []
def debug(f: debug_t):
  debug_items.push(f)

let gui_window_flags = (
    im_window_no_collapse
  | im_window_always_autoresize
  | im_window_no_nav_inputs
  )

var tri_res: resource? = nil
def draw_triangle(pos, size, angle):
  gl_translate(pos):
    gl_rotate_z(angle):
      gl_scale(size):
        gl_render_mesh(tri_res)
def draw_triangle(pos, size):
  draw_triangle(pos, size, xy_f { 0.0, -1.0 })

let left  = xy_f { -1,  0 }
let right = xy_f {  1,  0 }
let up    = xy_f {  0, -1 }
let down  = xy_f {  0,  1 }
let all_dirs = [up, right, down, left]

enum Dir:
  d_up
  d_right
  d_down
  d_left
def to_vec(d: Dir) -> xy_f:
  return all_dirs[int(d)]
let dirs: [Dir] = [
  d_up,
  d_right,
  d_down,
  d_left,
]


class Building:
  name: string
  color: color

let all_buildings = [
  Building { "Copper Mine", color { 0.8, 0.7, 0.3, 1.0 }},
  Building { "Belt", color { 0.6, 0.6, 0.6, 1.0 }},
]

var gold = 0.0

var selected_building_idx = 0
def building_gui():
  im_window("Buildings", gui_window_flags):
    for(all_buildings) info, idx:
      let name = if idx == selected_building_idx:
        "**" + info.name + "**"
      else:
        info.name
      im_button(name):
        selected_building_idx = idx

var grid_w = 10
var grid_h = 10
var grid_origin = xy_f { 600, 100 }
var cell_size = xy_f { 48, 48 }
var cell_border = 4.0
var arrow_offset_pct = 0.45
var arrow_size = 12
var hovered_cell = xy_i { -1, -1 }
def do_grid(dt):
  let all_size = xy_f { grid_w, grid_h } * (cell_size + cell_border)

  debug():
    im_treenode("grid"):
      grid_w = im_sliderint("grid w", grid_w, 1, 32)
      grid_h = im_sliderint("grid h", grid_h, 1, 32)
      grid_origin = xy_f {
        im_sliderint("grid pos x", int(grid_origin.x), 0, 1024),
        im_sliderint("grid pox y", int(grid_origin.y), 0, 1024),
      }
      cell_size = xy_f {
        int(im_sliderint("cell w", int(cell_size.x), 8, 128) / 4) * 4.0,
        int(im_sliderint("cell h", int(cell_size.y), 8, 128) / 4) * 4.0,
      }
      cell_border = im_sliderfloat("border", cell_border, 0.0, 10.0)
      arrow_offset_pct = im_sliderfloat("arrow_offset_pct", arrow_offset_pct, 0.0, 1.0)
      arrow_size = im_sliderint("arrow_size", arrow_size, 2, 32)

  // borders
  gl_color(color { .4, .6, .3, 1 })
  for(grid_w + 1) i:
    let start = grid_origin + xy_f { (cell_size.x + cell_border) * i, 0.0 } - cell_border/2
    let end = start + xy_f { 0.0, all_size.y }
    gl_line(start, end, cell_border)
  for(grid_h + 1) i:
    let start = grid_origin + xy_f { 0.0, (cell_size.y + cell_border) * i } - cell_border/2
    let end = start + xy_f { all_size.x, 0.0 }
    gl_line(start, end, cell_border)

  // grid
  for(grid_h) y:
    for(grid_w) x:
      let pos = grid_origin + (cell_size + cell_border) * xy_f { x, y }
      gl_translate(pos):
        if gl_hit(cell_size, 0):
          hovered_cell = xy {x, y}
        gl_color(color_green)
        gl_rect(cell_size)
        if hovered_cell.x == x and hovered_cell.y == y:
          gl_color(color_white)
          let center = cell_size / 2
          let arrow_offset = cell_size * arrow_offset_pct
          for(dirs) d:
            let dv = d.to_vec()
            draw_triangle(center + dv * arrow_offset, arrow_size, dv)

var selected_dir = d_right
def update_dir():
  let axes = ["up", "right", "down", "left"]
  for(axes) input, i:
    if gl_button(input) == 1:
      selected_dir = dirs[i]
      return

def main():
  fatal(gl_window("Simple Clicker", 1280, 1024))
  tri_res = gl_new_poly([
    xy_f {0.5, 0},
    xy_f {-0.5, .7},
    xy_f {-0.5, -.7},
  ])

  im_init(false)
  assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)

  var background_color = color { 162, 168, 132, 255 } / 255
  var is_debugging = true
  while gl_frame():
    if gl_button("escape") == 1:
      return

    update_dir()

    let dt = gl_delta_time()
    let gps = 0.0
    gold += dt * gps

    debug():
      background_color = im_coloredit("background_color", background_color)
    gl_clear(background_color)

    gl_color(color_blue)
    draw_triangle(xy_f { 300, 600 }, 300, selected_dir.to_vec())

    do_grid(dt)

    im_frame():
      im_window("Money", gui_window_flags):
        im_text("Gold: " + int(gold) + " (+" + gps + "/s)")
      building_gui()

      if gl_button("f12") == 0:
        is_debugging = !is_debugging
      if is_debugging:
        im_window("Debug", gui_window_flags):
          for(debug_items) item:
            item()
      debug_items.remove(0, debug_items.length())

main()
