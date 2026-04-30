# Atari Brick Breaker

A classic Brick Breaker game implemented in x86 Assembly language for DOS.

## Description

This is a recreation of the Atari Breakout game where the player controls a paddle to bounce a ball and break bricks. The game features multiple levels, scoring system, lives, and powerups.

## Features

- Multiple levels with increasing difficulty
- Score-based progression
- Lives system
- Powerups that extend the paddle
- Sound effects
- Random brick patterns

## Requirements

- DOS environment or emulator (e.g., DOSBox)
- Assembler (e.g., NASM)

## Building

To assemble the game:

```
nasm Project.asm -f bin -o Project.com
```

## Running

Run the generated COM file in a DOS environment:

```
Project.com
```

## Controls

- Left Arrow: Move paddle left
- Right Arrow: Move paddle right

## Gameplay

- Break all bricks to advance to the next level.
- Avoid letting the ball fall below the paddle.
- Collect powerups to extend your paddle temporarily.
- Levels increase ball speed.

Enjoy the game!</content>
<parameter name="filePath">d:\CS\SEM 3\COAL\Project\Atari-Brick-Breaker\README.md