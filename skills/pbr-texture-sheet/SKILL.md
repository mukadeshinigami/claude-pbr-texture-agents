---
name: pbr-texture-sheet
description: Build the "texture-guide" presentation sheet (cream page, serif title with an orange italic accent, mascot, sphere + plane cards, texture-map grid, source note card) from rendered stills with PIL. Use when the user asks for a presentation / poster / sheet of a material.
---

# Texture-guide sheet

Template = an image supplied by the user (2560x1600) that gives the mascot crop and the style. Build the sheet with a PIL script (run in a Python env with Pillow); keep one script per project and adapt title/paths/subtitle.

## Layout (px, 2560x1600)
- Colours: page cream (250,248,243), ink (28,26,24), accent (203,102,72), grey text (128,122,114).
- Header: mascot crop (110x110 from the template) + title (serif roman, 128 px) + ` /word` (serif italic 112, accent). Sub line: `/texture-guide` italic accent + spaced mono caps `PBR <NAME> · <W> × <H> · TILEABLE · MADE WITH CLAUDE`.
- Cards with a soft shadow, corner radius 26: sphere at (90,300) size 679x640, plane at (796,300) size 1673x640; a white chip at the bottom-left of each card (`01 Sphere  neutral key · Cycles`).
- Divider row at y ~975: italic `texture maps`, a dotted line, and a right-aligned mono caption.
- Bottom row at y=1036: a detail card (90, 540x400) + the map grid: 3 columns at x 655 / 1266 / 1878, 591x192 each (rows 1036 and 1244; image strip 136 px + a white label strip with `01 Albedo` ... and `sRGB` / `non-color` / `16-bit`), plus a dashed note card (the last grid slot) with the source and honesty wording.
- NO "set" card and no set render. The freed right slot is used by the grid.
- Footer: spaced mono caps on the left (`MATERIAL · KEYWORDS`) and the right (`TILEABLE · CYCLES · AGX`, with `CYCLES` in the accent colour).
- Fonts: serif (C059 from gsfonts) and a mono (Nimbus Mono PS); the template's real fonts are usually unavailable, say so.

## Inputs
Neutral-look renders from `pbr-lookdev-render` (ball, plane, a detail crop) and the maps (albedo, roughness, normal GL, height, AO). 16-bit maps must be converted to 8-bit previews with OpenCV first (PIL `convert('RGB')` on 16-bit gray gives pure white). Use the same neutral renders for every sheet in a series.

## Honesty wording
Scan set: name the source and its resolution; do not claim a higher resolution than the maps have. Stylised / procedural / inferred sets: keep "stylised, not a scan" (or "inferred maps") in the note card. Add a credit line when the source licence asks for one.

## Check
Open the PNG and look for text overlapping lines/dots, a complete dashed border, nothing cut, and the grid aligned to the right edge of the hero cards.
