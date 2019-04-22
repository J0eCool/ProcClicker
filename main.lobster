import vec
import color
import imgui

class Building:
  name: string
  gps: int
  cost: int

let all_buildings = [
  Building { "Hut", 1, 10 },
  Building { "House", 4, 75 },
  Building { "Store", 10, 675 },
]

fatal(gl_window("imgui demo", 1280, 1024))

im_init(false)
assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)

def main():
  let window_flags = (
      im_window_no_collapse
    | im_window_always_autoresize
    | im_window_no_nav_inputs
    )
  while gl_frame():
    if gl_button("escape") == 1:
      return

    gl_clear(color_grey)

    // <- Render game here.
    im_frame():
      im_window("Buildings", window_flags):
        for(all_buildings) building:
          im_text(building.name)

main()
