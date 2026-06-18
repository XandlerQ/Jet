# Jet

A small experimental 2D top-down space game prototype made in Godot. The project focuses on spaceship movement, manually defined collision behavior, destructible physics objects, and custom sprite palette.

## Current Features

- Top-down spaceship controller
- Static space station object
- Physics-based asteroid object
- Shooting mechanic that can break asteroids into smaller pieces
- Carefully defined custom collision
- Hand-drawn and generated space assets
- Space backgrounds generated using [Deep-Fold's Space Background Generator](https://deep-fold.itch.io/space-background-generator)
- Fog and lighting effects for atmosphere
- Custom shader material for runtime sprite recoloring

## Sprite Palette Shader

The project includes a custom shader where base sprites use colors from a red-green 4x4 color grid. These colors are used as coordinates to map the color to a separate 4x4 palette sprite, allowing the same base sprite to be reused with different color palettes.

This is used for:

- Space stations
- Ships
- Asteroids

The spacestation is defined using a tile grid.

<img width="1955" height="1167" alt="image" src="https://github.com/user-attachments/assets/ca4b0071-4edd-41cf-ab62-d1be5e5dee08" />
<img width="1957" height="1125" alt="image" src="https://github.com/user-attachments/assets/f9eb8b04-6030-4673-bd5d-b0c16fe019b2" />
