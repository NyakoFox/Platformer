# Platformer
A small little platformer I wrote for a class

This platformer was written using [Processing](https://processing.org/), with the code being written in [Visual Studio Code](https://code.visualstudio.com/) instead of the built-in IDE.

Player sprites (temporary) and a lot of BG tiles were made by [0x72](https://0x72.itch.io/16x16-industrial-tileset)

# How do I play?
It's explained in-game, but the basics are:

**Left and right arrow keys** to move. **Z** to jump.

Other mechanics are explained in-game, so pay attention to those!

# Modding
It's possible to make custom levels if you want to deal with my weird editor system. Open up `game.pde` and set `DEBUG` to `true`. You can ignore `DEBUG_RENDER` since that automatically gets set in some places.

## Tools
You can use the number keys to switch tools. You can use Y to go to subtool 1, and U to go to subtool 2. Weird, I know.

1. **Tile placement tool** - Place tiles down. Press middle click to select a tile from the map. Press/hold right click to delete a tile. Hold down TAB to open the tile picker.
    1. **Region mode** - Default. Place a region of tiles or just a single one. In the tile picker, you can drag a rectangle to select a region.
    2. **Random mode** - Place down a random tile out of the selected ones. In the tile picker, clicking on a tile selects it, holding down CTRL and clicking adds it to the selected tiles.
2. **Collision placement tool** - View and place collision. Right click removes it.
3. Unimplemented
4. Unimplemented
5. Unimplemented
6. Unimplemented
7. Unimplemented
8. Unimplemented
9. Unimplemented
10. **Start position placement tool** - If you load the game in this room, this is where the player will spawn. This is only really useful in the first room, because checkpoints exist. And save files don't exist.

## Misc. hotkeys
* `CTRL+ALT+SHIFT+<Arrow key>` - Set the connected room in that direction; aka the room you'll go to if you exit the screen from that way.
* `R` - Go to the player's spawn point. (Checkpoints set this too, remember.)
* `S` - Save the current map.
* `CTRL+S` - Save the current map, asking for a filename.
* `L` - (Re)load the current map.
* `CTRL+L` - Load a map, asking for a filename.
* `CTRL+N` - Create a new room.
* `TAB` - Open the tile picker.
* `SHIFT` - Show debug rendering, including collision, hitboxes etc.
