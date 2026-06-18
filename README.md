# Jet

A small experimental 2D top-down space game prototype made in Godot. The project focuses on spaceship movement, manually defined collision behavior, destructible physics objects, and custom sprite palette workflows.

## Current Features

- Top-down spaceship controller
- Static space station object with manually defined collision
- Physics-based asteroid object
- Shooting mechanic that can break asteroids into smaller pieces
- Carefully defined custom collision shapes
- Hand-drawn and generated space assets
- Space backgrounds generated using [Deep-Fold's Space Background Generator](https://deep-fold.itch.io/space-background-generator)
- Fog and lighting effects for atmosphere
- Custom shader material for runtime sprite recoloring

## Sprite Palette Shader

The project includes a custom shader workflow where base sprites use a red-green 4x4 color coordinate grid. These coordinates are mapped to a separate 4x4 palette sprite, allowing the same base sprite to be reused with different color palettes at runtime.

This is used for objects such as:

- Space stations
- Ships
- Asteroids

The spaceship itself is defined using a tile grid, making it easier to compose and recolor modular ship designs.

## Status

This is an unfinished learning prototype. It currently serves as a sandbox for experimenting with 2D space movement, collision handling, destructible asteroids, lighting, fog, and runtime sprite recoloring.

<img width="1955" height="1167" alt="image" src="https://github.com/user-attachments/assets/ca4b0071-4edd-41cf-ab62-d1be5e5dee08" />
<img width="1957" height="1125" alt="image" src="https://github.com/user-attachments/assets/f9eb8b04-6030-4673-bd5d-b0c16fe019b2" />
