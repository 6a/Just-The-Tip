# JustTheTip

JustTheTip positions the tooltip at your cursor instead of in a fixed location. Highly customizable; position, anchor, offset, fade delay etc. can all be modified using the commands below.

## How to use it

Type `/jtt` for the command list. `/justthetip` does the same thing.

| Command | What it does |
| --- | --- |
| `/jtt on` | Enables cursor tracking |
| `/jtt off` | Disables cursor tracking |
| `/jtt toggle` | Toggle cursor tracking on and off |
| `/jtt offset <x> <y>` | Offset from the current anchor. Positive x is right, positive y is up. Default `0, 0` |
| `/jtt anchor <position>` | Where the tooltip sits relative to the cursor. Default bottom right |
| `/jtt origin <position>` | Which point on the cursor the offset is measured from. Default is bottom right |
| `/jtt scale <10-500>` | Tooltip scale, as a percentage of the current UI scale. Default `100` |
| `/jtt flip <x\|y\|xy\|off>` | Configure x, y or both axis to flip the position/offset/anchor of the tooltip when you cross the halfway point on the screen . Default off |
| `/jtt cursor <32\|48\|64\|96\|128\|auto>` | Cursor size used to place the origin. `auto` follows the game's Cursor Size option |
| `/jtt fade <seconds>` | How long, in seconds, the tooltip stays fully visible after you stop hovering before starting to fade out. Default `0`. From `0` to `5` |
| `/jtt <command> reset` | Restore a specific setting. For example `/jtt fade reset` |
| `/jtt reset all` | Restore all settings to default and turn the addon back on |

Valid positions: 
- top left
- top middle
- top right
- middle left
- center
- middle right
- bottom left
- bottom middle
- bottom right

Note: Positions can be typed with or without a space: `bottom right` and `bottomright` both work.

`/jtt fade` applies when the game fades a tooltip, such as a world object. Bag, spell, and button tooltips still disappear immediately, because those are hidden instead of faded.

## Why I made it

For some reason, all the tooltip addons I could find would place the tooltip above the cursor. I find this pretty distracting, so I made this addon so that I could position the tooltip exactly where I wanted, and have it bevave exactly as I liked.