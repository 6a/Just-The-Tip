# Just The Tip

Just The Tip positions the tooltip at your cursor instead of in a fixed location. Highly customizable; position, anchor, offset, fade delay etc. can all be modified using the commands below.

## How to use it

Type `/jtt` for the command list.

| Command | What it does |
| --- |--- |
| <code>/jtt on</code> | Enables cursor tracking  |
| <code>/jtt off</code> | Disables cursor tracking |
| <code>/jtt toggle</code> | Toggle cursor tracking on and off |
| <code>/jtt offset <x> <y></code> | Offset from the current anchor. Positive x is right, positive y is up. Default <code>0, 0</code> |
| <code>/jtt anchor <position></code> | Where the tooltip sits relative to the cursor. Default bottom right |
| <code>/jtt origin <position></code> | Which point on the cursor the offset is measured from. Default is bottom right |
| <code>/jtt scale <10-500></code> | Tooltip scale, as a percentage of the current UI scale. Default <code>100</code> |
| <code>/jtt flip <x|y|xy|off></code> | Configure x, y or both axis to flip the position/offset/anchor of the tooltip when you cross the halfway point on the screen . Default off |
| <code>/jtt cursor <32|48|64|96|128|auto></code> | Cursor size used to place the origin. <code>auto</code> follows the game's Cursor Size option |
| <code>/jtt fade <seconds></code> | How long, in seconds, the tooltip stays fully visible after you stop hovering before starting to fade out. Default <code>0</code>. From <code>0</code> to <code>5</code> |
| <code>/jtt <command> reset</code> | Restore a specific setting. For example <code>/jtt fade reset</code> |
| <code>/jtt reset all</code> | Restore all settings to default and turn the addon back on |

Valid positions:

* top left
* top middle
* top right
* middle left
* center
* middle right
* bottom left
* bottom middle
* bottom right

Note: Positions can be typed with or without a space: `bottom right` and `bottomright` both work.

`/jtt fade` applies when the game fades a tooltip, such as a world object. Bag, spell, and button tooltips still disappear immediately, because those are hidden instead of faded.

## Why I made it

For some reason, all the tooltip addons I could find would place the tooltip above the cursor. I find this pretty distracting, so I made this addon so that I could position the tooltip exactly where I wanted, and have it bevave exactly as I liked.