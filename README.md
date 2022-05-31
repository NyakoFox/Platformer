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

## Technical stuff
Some extra details if you're a nerd.

### Map format
It's pretty simple, just a JSON file. Everything should be self-explanatory, however the game DOES put every tile on it's own line.

* `collision` is just a 2d array of numbers -- 0 for non-solid, 1 for solid. Other collision types might be coming soon, which is why this isn't a boolean.
* `layers` is a collection of layers, with each layer being a 2d array of tiles. The numbers refer to tile ID, being the number of the tile on the tile sheet.
* `tileset` is the filename of the tileset. Tilesets are just simple images right now, but they might get their own JSON files too in the future, since I want animated tiles.
* `connected_left/right/up/down` - The map to go to if you leave through that side of the screen.
* `connected_left/right/up/down_offset` - The amount of tiles to offset the player when they cross into that room, for alignment.
* `start_x/y` - Where the player will spawn in, only really useful for the first room. You can place this in-game.
* `width` - The width of the map in tiles.
* `height` - The height of the map in tiles.

### Entities
All entities extend from the base class `Entity`. To spawn one, you create a new one (`new Entity(...)`) and then call `addToWorld(Entity entity);` in `Game`. The global instance of `Game` is called `game`. The only entity that carries over room transitions currently is the player, because `addToWorld(player);` is called in `switchMap`.

* `x`, `y`, `width`, `height` - All pretty self-explanatory.
* `x_scale`, `y_scale` - How big the entity is. Defaults to 2.
* `x_velocity`, `y_velocity` - The velocity of the current entity. If gravity is enabled, it'll affect your `y_velocity`. Use `setVelocity(x, y);` or `addVelocity(x, y)` to modify these.
* `uses_gravity` - If gravity is enabled. Use `enableGravity(boolean on);` to enable it.
* `gravity` - The force of gravity. You probably shouldn't change this...?
* `max_gravity` - The max force of gravity. Ditto.
* `id` - The ID of this entity, normally set in the constructor.
* `sprites` - A map of arrays of sprites. Used to store animations. This is automatically filled when the entity is loaded, using filenames. Check how the player sprites are set up.
* `animation_speeds` - The speeds of animations. Use `registerAnimationSpeed(String name, float speed);` to add to this. A value of `1` will make it change every frame, `0.5` will make it change every 2 frames, etc.
* `animation` - The current animation. Use `setAnimation(String animation);` for setting this.
* `animation_timer` - When this hits `1`, the animation will advance to the next frame. No need to touch this variable.
* `animation_index` - The current frame of the animation. Ditto.
* `animation_speed` - The speed of the current animation. Ditto.
* `sprite_offset_x`, `sprite_offst_y` - The offset of the sprite that gets drawn, relative to the X and Y.
* `flipped` - Whether the sprite should be rendered flipped or not.
* `map` - The map that the entity is in. It's pretty safe to say that if this isn't the current map, the garbage collector will be coming for it very soon.

And for some functions...

* `onAdd()` - Callback function for when this entity is added to the map. Unused by default.
* `registerAnimationSpeed(String name, float speed)` - Set the speed of the animation with this name. All speeds default to `1`.
* `getWidth()` - Get the current width of this entity, applying the scale.
* `getHeight()` - Ditto.
* `setAnimation(String name[, double speed])` - Set the current animation (with an optional speed argument.) This won't do anything if you try to set the animation to the one which is currently playing.
* `registerSprites()` - Called during initialization; crawls through `sprites/ENTITY_ID/` and loads images for animations. Check out how player sprites are stored.
* `enableGravity(boolean enable)` - Whether gravity should be enabled or not, defaulting to false.
* `setVelocity(double x, double y)` - Set the current velocity.
* `addVelocity(double x, double y)` - Add to the current velocity.
* `animationLooped(String animation)` - Callback function for when the current animation loops. Unused by default, but `Player`s use it.
* `update()` - Function that gets called every frame. Use this for logic.
* `draw()` - Function that gets called every frame. Use this for drawing.
* `isInSolid(double x, double y)` - Check if these coordinates are inside of a solid tile.
* `onGround()` - Check if the entity is on the ground.

### Input
This is pretty simple.

* `input.down(String key)` - Check if this key is being pressed down.
* `input.pressed(String key)` - Check if this key was just pressed.
* `input.released(String key)` - Check if this key was just released.
* `input.up(String key)` - Check if this key is not being held down.
* `input.mouseDown/mousePressed/mouseReleased/mouseUp(int button)` - Ditto. `0` is the left button, `1` is the right button, and `2` is the middle button.
* `clearPressed()` - Unpress all keys. This does not trigger `input.released`.

Everything else is for internal use only.

