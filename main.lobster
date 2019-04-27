import vec
import color
import imgui

class Building:
  name: string
  gps: int
  cost: int

let all_buildings = [
  Building { "Hut", 1, 5 },
  Building { "House", 4, 35 },
  Building { "Store", 10, 195 },
]

var gold = 0.0
let buildings = [1, 0, 0]

def building_infonum(idx):
  return all_buildings[idx], buildings[idx]

def building_cost(idx):
  let info, num = building_infonum(idx)
  return int(info.cost * pow(1.1, num))

def buildings_gps():
  var ret = 0.0
  for(length(all_buildings)) i:
    ret += buildings[i] * all_buildings[i].gps
  return ret

def building_gui(idx):
  let info, num = building_infonum(idx)
  let cost = building_cost(idx)
  im_text(info.name + ": " + num)
  im_button("Buy: " + cost + "g"):
    if gold >= cost:
      buildings[idx] += 1
      gold -= cost

def do_grid(dt):
  let w = 8
  let h = 8
  let size = xy_f { 64, 64 }
  let origin = xy_f { 300, 200 }
  let border = 4
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
  while gl_frame():
    if gl_button("escape") == 1:
      return

    let dt = gl_delta_time()
    let gps = buildings_gps()
    gold += dt * gps

    gl_clear(color_grey)

    do_grid(dt)

    im_frame():
      im_window("Money", window_flags):
        im_text("Gold: " + int(gold) + " (+" + gps + "/s)")
      im_window("Buildings", window_flags):
        for(length(all_buildings)) idx:
          building_gui(idx)

main()
