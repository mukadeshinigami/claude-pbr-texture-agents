---
name: pbr-lookdev-render
description: Look-dev and render rules for PBR material presentations in headless Blender Cycles (neutral grey series look, lighting variants, 4K stills, macro, turntable loop, mp4). Use when rendering ball/plane/landscape shots of a texture set or building lighting options for the user to choose.
---

# Look-dev and rendering

## Series look (default - all sheets must look the same)
- Mid-grey seamless gradient backdrop (top ~0.165, bottom ~0.285 linear), floor of the same grey, roughness 0.85, with a radial transparent fade (3-12 units) so there is no horizon line.
- Key light: neutral/slightly cool (0.96, 0.98, 1.0), large area light (size ~3.6), ~1900 W at (-4.4, -4.2, 4.0); white fill 650 W at (4.2, -5.0, 1.4), size 7; cool rim 1100 W at (4.6, 4.2, 3.0), size 2.4. Fill and rim are invisible to glossy rays (`visible_glossy = False`). View transform AgX with the *Base Contrast* look, exposure 0.
- The camera sees the gradient; every other ray sees a dim neutral environment (a "Is Camera Ray" mix in the world shader).
- Frame sizes that match the sheet cards: sphere 2000x1880, plane 3000x1150, macro 1560x1155. Never render a multi-object "set" frame.
- Warm golden-hour looks only on request; they recolour the material.

## Lighting-variant sheet (the user picks)
Ten setups on ball + plane: golden hour, moonlight, overcast softbox, sunset raking, studio 3-point, chiaroscuro, teal-orange, forest, backlit glow, high key. Build a numbered 2x5 contact sheet with labels and comment honestly on which read the material best.

## Quality rules
- Soft, large key lights = volume; small hard keys look plastic. Make lights huge-area; rim lights invisible to glossy to avoid floor glare.
- Short test first (small size, 48-64 samples), look at it, then the final (3840x2160, 256 samples, OptiX denoise, adaptive sampling).
- Macro: 85-135 mm, f/4-f/9, DOF on. A soft macro usually means the source map resolution is too low: do not use it as a hero shot. Close camera: the ball fills 80-90 % of the frame, never small and far (about 3.9 units away for a radius-1 ball at 58 mm).
- Wide landscape: mist pass haze in the compositor (not a world volume), saturation tweak, Nishita sky.

## Turntable loop
- 240 frames at 24 fps, 360 degrees, ball hover bob that loops; check that the first/last frame diff equals a neighbour diff.
- Render to `renders/<proj>/turntable/frames_*/f%04d.png` (skip existing frames), then encode: `ffmpeg -framerate 24 -i f%04d.png -c:v libx264 -pix_fmt yuv420p -crf 16 -preset slow -movflags +faststart out.mp4`.
- ~5 s/frame at 1080p on a mid-range RTX card.

## GPU etiquette
One GPU Blender job at a time. If `Error: System is out of GPU memory`, check `nvidia-smi`, wait and retry; kill only your own PIDs.
