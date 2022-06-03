import java.io.File;
import javax.swing.*;

Registry registry;
Flags flags;
Game game;
Input input;

boolean DEBUG = true;
boolean DEBUG_RENDER = false;

PFont font;

PShader shader_ripple;
float ripple_timer;

float floppy_x;
float floppy_y;
float floppy_bounce;
int   floppy_timer;

double camera_x = 0;
double camera_y = 0;
double camera_left = 0;
double camera_right = 0;
double camera_top = 0;
double camera_bottom = 0;


// NOTE: IF YOU RENAME THE PROJECT, THIS TYPE NEEDS TO BE RENAMED.
// THIS IS HORRIBLE, BUT REQUIRED FOR THE SOUND LIBRARY
platformer GLOBAL_MAIN_CLASS = this;

void setup() {
    font = createFont("pcsenior.ttf", 16, false);
    // Resize the screen to my favorite resolution (640x480)
    // Also set the renderer to P2D so I can use shaders
    size(640, 480, P2D);
    surface.setTitle("Platforming");
    surface.setResizable(false);
    frameRate(60);
    registry = new Registry();
    flags = new Flags();
    game = new Game();
    input = new Input();
    loop();
    noSmooth();
    background(0);
    // Since we're using P2D, we need to set the texture sampling to POINT which is 2
    // Just so everything isn't blurry
    // It defaults to 5 which is trilinear which makes the game look really bad
    ((PGraphicsOpenGL)g).textureSampling(2);

    // Shader setup for the ripple effect
    shader_ripple = loadShader("ripple.glsl");
    shader_ripple.set("time", 0.0f);
    shader_ripple.set("center", 0.5, 0.5);
    shader_ripple.set("shockParams", 10f, 0.8f, 0.1f);

    // Ripple effect state variables
    ripple_timer = -1f;
    floppy_x = 0f;
    floppy_y = 0f;
    floppy_bounce = 0f;
    floppy_timer = -1;
}

void doRippleEffect(double x, double y) {
    // The ripple effect is active as long as the timer isn't -1
    ripple_timer = 0f;
    shader_ripple.set("center", (float)((x - camera_left) / width), (float)((y - camera_top) / height));
}

void draw() {

    if (!(ripple_timer < 0f)) {
        ripple_timer += 1f/60f;
    }

    if (ripple_timer > 1.5f) {
        ripple_timer = -1f;
    }

    boolean ripple_active = (ripple_timer > 0) && (ripple_timer < 1.5);

    // Run logic
    game.update();
    // Draw
    game.draw();
    // Modify key states
    input.changeKeys();

    if (ripple_active) {
        // WE DON'T WANT TO SHOW THE SHADER WHEN IT'S NOT NEEDED.
        // IT'S EXTREMELY SLOW.
        shader_ripple.set("time", ripple_timer);
        shader_ripple.set("tex0", get());
        filter(shader_ripple);
    }
}

void keyPressed() {
    input.keyPressed();
}

void keyReleased() {
    input.keyReleased();
}

void mousePressed() {
    input.mousePressed();
}

void mouseReleased() {
    input.mouseReleased();
}

enum GameState {
    MENU,
    GAME,
    PAUSED,
    OPTIONS,
    CREDITS,
    TILE_PICKER
}

class Game {
    ArrayList<Entity> entities;
    Player player;
    Map current_map;

    // Dev stuff
    ArrayList<Integer> current_tiles = new ArrayList<>();
    int current_layer = 0;
    int current_tool = 0;
    int current_subtool = 0;
    int selection_height = 0;
    int selection_width = 0;
    int selection_x = 0;
    int selection_y = 0;

    GameState state = GameState.GAME;

    Game() {
        current_tiles.clear();
        current_tiles.add(0);
        selection_width = 1;
        selection_height = 1;
        entities = new ArrayList<>();
        setupGame();
        current_map = loadMap("start");
        createPlayer();
        loadMapEntities();
        player.onInitialAdd();
    }

    void createPlayer() {
        if (player == null) {
            player = new Player(current_map.getStartX(), current_map.getStartY()); // Make a new player in the center
        }
        addToWorld(player);
    }

    void addToWorld(Entity entity) {
        entity.map = current_map;
        entities.add(entity);
        entity.onAdd();
    }

    void loadMapEntities() {
        // Load all entities from the map
        for (EntityData data : current_map.entities) {
            Entity entity = createFromData(data);
            if (entity != null) {
                entity.data_reference = data;
                addToWorld(entity);
            }
        }
    }

    Entity getEntityUnderCursor() {
        for (int i = entities.size() - 1; i >= 0; i--) {
            Entity entity = entities.get(i);
            // Check if the entity is under the cursor
            double x = entity.x;
            double y = entity.y;
            double w = entity.getWidth();
            double h = entity.getHeight();

            double mouse_x = mouseX + camera_left;
            double mouse_y = mouseY + camera_top;
            // AABB
            if (mouse_x + camera_left >= x && mouse_x <= x + w && mouse_y >= y && mouse_y <= y + h) {
                return entity;
            }
        }
        return null;
    }

    Entity addSavedEntity(String entity_id, double x, double y) {
        // Create this entity
        Entity entity = createEntity(entity_id, x, y);
        // Add them to the world
        addToWorld(entity);
        // Add them to the map data
        entity.data_reference = current_map.addEntityData(entity);
        return entity;
    }

    void removeSavedEntity(Entity entity) {
        // Remove them from the world
        entities.remove(entity);
        // Loop through the map entities and remove them
        for (int i = 0; i < current_map.entities.size(); i++) {
            if (current_map.entities.get(i) == entity.data_reference) {
                current_map.entities.remove(i);
                break;
            }
        }
    }

    Entity createEntity(String entity_id, double x, double y) {
        Entity entity = null;

        switch (entity_id) {
            case "floppy":
                entity = new Floppy(x, y);
                break;
        }

        return entity;
    }

    Entity createFromData(EntityData data) {
        Entity entity = createEntity(data.name, data.x, data.y);
        if (entity != null) {
            entity.load(data.data);
            return entity;
        }
        return null;
    }

    void setupGame() {
        entities.clear(); // Clear the entity list
    }

    Map loadMap(String name) {
        entities.clear(); // Clear the entity list

        // Load the map
        Map map = new Map(name);

        return map;
    }

    void unloadMap() {
        entities.clear();
        current_map = null;
    }

    void switchMap(String name) {
        unloadMap();
        current_map = loadMap(name);
        addToWorld(player);
        loadMapEntities();
    }

    void switchMap(Map map) {
        unloadMap();
        current_map = map;
        addToWorld(player);
    }

    Player getPlayer() {
        return player;
    }

    void setSubtool(int tool) {
        if (tool == current_subtool) return;
        current_subtool = tool;
        switch (current_tool) {
            case 0:
                if (current_subtool == 0) {
                    // If they're switching to the first subtool,
                    // just clear the selected tiles.
                    current_tiles.clear();
                    current_tiles.add(0);
                }
                break;
            default:
                break;
        }
    }

    void setTool(int tool) {
        if (tool == current_tool) return;
        current_tool = tool;
        switch (tool) {
            case 0:
                if (current_subtool > 1) {
                    setSubtool(0);
                }
                break;
            default:
                break;
        }
    }

    void updateCamera() {
        camera_x = player.x;
        camera_y = player.y;
        // Make camera be in bounds
        if (camera_x < 320) {
            camera_x = 320;
        }
        if (camera_y < 240) {
            camera_y = 240;
        }
        if (camera_x > current_map.real_width - 320) {
            camera_x = current_map.real_width - 320;
        }
        if (camera_y > current_map.real_height - 240) {
            camera_y = current_map.real_height - 240;
        }

        camera_left = camera_x - 320;
        camera_right = camera_x + 320;
        camera_top = camera_y - 240;
        camera_bottom = camera_y + 240;
    }

    void update() {
        int mouse_tile_x = 0;
        int mouse_tile_y = 0;
        switch (state) {
            case MENU:
                break;
            case GAME:
                mouse_tile_x = (int) ((mouseX + camera_left) / 32);
                mouse_tile_y = (int) ((mouseY + camera_top) / 32);
                // Loop through all entities and run their logic.
                for (int i = 0; i < entities.size(); i++) {
                    entities.get(i).update();
                }

                updateCamera();

                // TODO: remove
                if (input.pressed("Q")) {
                    DEBUG = !DEBUG;
                    return;
                }

                if (DEBUG) {
                    // CTRL+SHIFT+ALT+Arrow keys to change room connections
                    if (input.down("ctrl") && input.down("shift") && input.down("alt")) {
                        if (input.pressed("left")) {
                            input.clearPressed();
                            String new_name = JOptionPane.showInputDialog("Enter name of left-connected map");
                            if (new_name != null) {
                                current_map.connected_left = new_name;
                            }
                            return;
                        }
                        if (input.pressed("right")) {
                            input.clearPressed();
                            String new_name = JOptionPane.showInputDialog("Enter name of right-connected map");
                            if (new_name != null) {
                                current_map.connected_right = new_name;
                            }
                            return;
                        }
                        if (input.pressed("up")) {
                            input.clearPressed();
                            String new_name = JOptionPane.showInputDialog("Enter name of up-connected map");
                            if (new_name != null) {
                                current_map.connected_up = new_name;
                            }
                            return;
                        }
                        if (input.pressed("down")) {
                            input.clearPressed();
                            String new_name = JOptionPane.showInputDialog("Enter name of down-connected map");
                            if (new_name != null) {
                                current_map.connected_down = new_name;
                            }
                            return;
                        }
                    }

                    // CTRL+SHIFT+F+Arrow keys to decrease room size
                    if (input.down("ctrl") && input.down("shift") && input.down("F")) {
                        if (input.pressed("right")) {
                            input.clearPressed();
                            current_map.resize(current_map.width - 1, current_map.height);
                            current_map.shiftTiles(-1, 0);
                            return;
                        }
                        if (input.pressed("left")) {
                            input.clearPressed();
                            current_map.resize(current_map.width - 1, current_map.height);
                            return;
                        }
                        if (input.pressed("down")) {
                            input.clearPressed();
                            current_map.resize(current_map.width, current_map.height - 1);
                            current_map.shiftTiles(0, -1);
                            return;
                        }
                        if (input.pressed("up")) {
                            input.clearPressed();
                            current_map.resize(current_map.width, current_map.height - 1);
                            return;
                        }
                    }

                    // CTRL+SHIFT+G+Arrow keys to increase connected side offsets
                    if (input.down("ctrl") && input.down("shift") && input.down("G")) {
                        if (input.pressed("right")) {
                            input.clearPressed();
                            current_map.connected_right_offset++;
                            return;
                        }
                        if (input.pressed("left")) {
                            input.clearPressed();
                            current_map.connected_left_offset++;
                            return;
                        }
                        if (input.pressed("down")) {
                            input.clearPressed();
                            current_map.connected_down_offset++;
                            return;
                        }
                        if (input.pressed("up")) {
                            input.clearPressed();
                            current_map.connected_up_offset++;
                            return;
                        }
                    }

                    // CTRL+SHIFT+H+Arrow keys to decrease connected side offsets
                    if (input.down("ctrl") && input.down("shift") && input.down("H")) {
                        if (input.pressed("right")) {
                            input.clearPressed();
                            current_map.connected_right_offset--;
                            return;
                        }
                        if (input.pressed("left")) {
                            input.clearPressed();
                            current_map.connected_left_offset--;
                            return;
                        }
                        if (input.pressed("down")) {
                            input.clearPressed();
                            current_map.connected_down_offset--;
                            return;
                        }
                        if (input.pressed("up")) {
                            input.clearPressed();
                            current_map.connected_up_offset--;
                            return;
                        }
                    }


                    // CTRL+SHIFT+Arrow keys to increase room size
                    if (input.down("ctrl") && input.down("shift")) {
                        if (input.pressed("left")) {
                            input.clearPressed();
                            current_map.resize(current_map.width + 1, current_map.height);
                            current_map.shiftTiles(1, 0);
                            return;
                        }
                        if (input.pressed("right")) {
                            input.clearPressed();
                            current_map.resize(current_map.width + 1, current_map.height);
                            return;
                        }
                        if (input.pressed("up")) {
                            input.clearPressed();
                            current_map.resize(current_map.width, current_map.height + 1);
                            current_map.shiftTiles(0, 1);
                            return;
                        }
                        if (input.pressed("down")) {
                            input.clearPressed();
                            current_map.resize(current_map.width, current_map.height + 1);
                            return;
                        }
                    }

                    if (input.pressed("R")) {
                        player.gotoCheckpoint();
                        return;
                    }
                    if (input.pressed("S")) {
                        if (input.down("ctrl")) {
                            input.clearPressed();
                            String new_name = JOptionPane.showInputDialog("Enter name of map to save to");
                            if (new_name != null) {
                                current_map.name = new_name;
                                current_map.saveMap(current_map.name);
                            }
                        } else {
                            current_map.saveMap(current_map.name);
                        }
                    }
                    if (input.pressed("L")) {
                        if (input.down("ctrl")) {
                            input.clearPressed();
                            String open = JOptionPane.showInputDialog("Enter name of map to load");
                            if (open != null) {
                                switchMap(open);
                            }
                        } else {
                            switchMap(current_map.name);
                        }
                    }
                    if (input.pressed("N") && input.down("ctrl")) {
                        input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of new map");
                        if (new_name != null) {
                            Map new_map = new Map(20, 15, "indust");
                            new_map.name = new_name;
                            new_map.saveMap(new_name);
                            switchMap(new_name);
                        }
                    }
                    if (input.down("tab")) {
                        state = GameState.TILE_PICKER;
                        break;
                    }

                    switch (current_tool) {
                        case 0: // TILES tool
                            if (input.mouseDown(0)) { // If we're holding down the left mouse button
                                if (current_subtool == 0) { // If we're using the Region subtool
                                    // Place the current selected tiles down
                                    int tile = 0;
                                    for (int y = 0; y < selection_height; y++) {
                                        for (int x = 0; x < selection_width; x++) {
                                            int current_tile = current_tiles.get(tile);
                                            tile++;

                                            current_map.setTile(current_layer, mouse_tile_x + x, mouse_tile_y + y, current_tile);
                                        }
                                    }
                                } else if (current_subtool == 1) {
                                    // If we're using the random subtool, place a random tile down.
                                    // NOTE: Since this runs every frame, if you're holding down left mouse on a tile,
                                    // It'll change every frame. This is technically a bug but not one that really
                                    // matters, so whatever.
                                    int random_tile = (int) random(0, current_tiles.size());
                                    current_map.setTile(current_layer, mouse_tile_x, mouse_tile_y, current_tiles.get(random_tile));
                                } else {
                                    // Fallback
                                    current_map.setTile(current_layer, mouse_tile_x, mouse_tile_y, current_tiles.get(0));
                                }
                            } else if (input.mouseDown(1)) {
                                if (current_subtool == 0) {
                                    for (int y = 0; y < selection_height; y++) {
                                        for (int x = 0; x < selection_width; x++) {
                                            current_map.setTile(current_layer, mouse_tile_x + x, mouse_tile_y + y, 0);
                                        }
                                    }
                                } else {
                                    current_map.setTile(current_layer, mouse_tile_x, mouse_tile_y, 0);
                                }
                            } else if (input.mouseDown(2)) {
                                current_tiles.clear();
                                current_tiles.add(current_map.getTile(current_layer, mouse_tile_x, mouse_tile_y));
                                selection_width = 1;
                                selection_height = 1;
                            }
                            break;
                        case 1:
                            if (input.mouseDown(0)) {
                                current_map.setCollisionTile(mouse_tile_x, mouse_tile_y, true);
                            } else if (input.mouseDown(1)) {
                                current_map.setCollisionTile(mouse_tile_x, mouse_tile_y, false);
                            }
                            break;
                        case 3: // COLLECTIBLES
                            if (input.mousePressed(0)) {
                                addSavedEntity("floppy", mouse_tile_x * 32, mouse_tile_y * 32);
                            } else if (input.mousePressed(1)) {
                                Entity entity = getEntityUnderCursor();
                                if (entity != null) {
                                    removeSavedEntity(entity);
                                }
                            }
                            break;
                        case 4: // CHECKPOINTS
                            break;
                        case 8: // GENERIC ENTITIES
                            break;
                        case 9:
                            if (input.mousePressed(0)) {
                                current_map.start_x = (mouse_tile_x * 32) + 4;
                                current_map.start_y = (mouse_tile_y * 32) + 10;
                                player.setCheckpoint(current_map.start_x, current_map.start_y);
                            }
                        default:
                            break;
                    }

                    if (input.pressed("1")) setTool(0);
                    if (input.pressed("2")) setTool(1);
                    if (input.pressed("3")) setTool(2);
                    if (input.pressed("4")) setTool(3);
                    if (input.pressed("5")) setTool(4);
                    if (input.pressed("6")) setTool(5);
                    if (input.pressed("7")) setTool(6);
                    if (input.pressed("8")) setTool(7);
                    if (input.pressed("9")) setTool(8);
                    if (input.pressed("0")) setTool(9);

                    if (input.pressed("T")) setSubtool(0);
                    if (input.pressed("Y")) setSubtool(1);
                }
                break;
            case PAUSED:
                break;
            case TILE_PICKER:
                mouse_tile_x = (int) (mouseX / 32);
                mouse_tile_y = (int) (mouseY / 32);
                if (current_subtool == 0) {
                    // Drag using the left mouse button to select a region of tiles
                    if (input.mousePressed(0)) {
                        selection_x = mouse_tile_x;
                        selection_y = mouse_tile_y;
                        selection_width = 1;
                        selection_height = 1;
                    }
                    if (input.mouseDown(0)) {
                        selection_width = mouse_tile_x - selection_x + 1;
                        selection_height = mouse_tile_y - selection_y + 1;
                    }
                    if (input.mouseReleased(0)) {
                        selection_width  = mouse_tile_x - selection_x + 1;
                        selection_height = mouse_tile_y - selection_y + 1;
                        current_tiles.clear();
                        for (int y = selection_y; y < selection_y + selection_height; y++) {
                            for (int x = selection_x; x < selection_x + selection_width; x++) {
                                // Get tile index from coordinates
                                current_tiles.add(x + y * current_map.tileset.horizontal_tiles);
                            }
                        }
                    }
                } else if (current_subtool == 1) {
                    if (input.mousePressed(0)) {
                        if (input.down("ctrl")) {
                            current_tiles.add(mouse_tile_x + mouse_tile_y * current_map.tileset.horizontal_tiles);
                        } else {
                            current_tiles.clear();
                            current_tiles.add(mouse_tile_x + mouse_tile_y * current_map.tileset.horizontal_tiles);
                        }
                    }
                }
                //if (input.mousePressed(0)) {
                //    // Get tile index based on mouse position
                //    current_tiles.clear();
                //    current_tiles.add(mouse_tile_x + mouse_tile_y * current_map.tileset.horizontal_tiles);
                //}
                if (input.released("tab")) {
                    state = GameState.GAME;
                }
                break;
        }
    }

    void applyCameraTransform() {
        // The coordinates will be the center of the viewpoint
        translate((float) -camera_x + 320, (float) -camera_y + 240);
    }

    // Draw
    void draw() {
        // Clear the canvas
        background(28, 32, 44);

        Tileset tileset = current_map.tileset;

        switch (state) {
            case MENU:
                break;
            case GAME:
                pushMatrix();
                applyCameraTransform();
                // Draw the map
                current_map.draw();

                // Loop through all entities and draw them (in reverse)
                for (int i = entities.size() - 1; i >= 0; i--) {
                    Entity entity = entities.get(i);
                    if (entity.visible) {
                        entity.draw();
                    }
                }

                DEBUG_RENDER = false;
                if (input.down("shift") || current_tool == 1) {
                    DEBUG_RENDER = true;
                    // Draw all collision tiles as red outlines
                    for (int y = 0; y < current_map.height; y++) {
                        for (int x = 0; x < current_map.width; x++) {
                            if (current_map.collision[y][x]) {
                                noFill();
                                stroke(255, 0, 0);
                                strokeWeight(2);
                                rect(x * 32, y * 32, 32, 32);
                            }
                        }
                    }
                }

                popMatrix();

                if (DEBUG) {
                    boolean show_tile_cursor = true;
                    int cursor_width = 32;
                    int cursor_height = 32;

                    String tool_name = "";
                    String subtool_name = "None";
                    switch (current_tool) {
                        case 0:
                            if (current_subtool == 0) subtool_name = "Region";
                            if (current_subtool == 1) subtool_name = "Random";

                            tool_name = "TILES";
                            // Draw current tile in the top-left box
                            int current_tile = current_tiles.get(0);
                            if (current_tile != 0) {
                                tileset.drawTile(16, 16, current_tile);
                            } else {
                                // Draw red X using two lines
                                stroke(255, 0, 0);
                                strokeWeight(4);
                                line(16, 16, 48, 48);
                                line(48, 16, 16, 48);
                            }
                            if (current_subtool == 0) {
                                cursor_width = selection_width * 32;
                                cursor_height = selection_height * 32;
                            }
                            break;
                        case 1:
                            tool_name = "COLLISION";

                            // Draw red box outline in the top-left box
                            noFill();
                            stroke(255, 0, 0);
                            strokeWeight(2);
                            rect(16 + 4, 16 + 4, 32 - 8, 32 - 8);

                            break;
                        case 2: tool_name = "???"; break;
                        case 3: tool_name = "COLLECTIBLES"; break;
                        case 4: tool_name = "CHECKPOINTS"; break;
                        case 5: tool_name = "???"; break;
                        case 6: tool_name = "???"; break;
                        case 7: tool_name = "???"; break;
                        case 8: tool_name = "ENTITY"; break;
                        case 9:
                            tool_name = "START";
                            // Draw the player's sprite at their spawn point
                            Player player = getPlayer();
                            PImage sprite = registry.sprites.get("player").get("idle").get(2);
                            float draw_x = (float) (current_map.getStartX() + player.sprite_offset_x);
                            float draw_y = (float) (current_map.getStartY() + player.sprite_offset_y);
                            tint(255, 255, 255, 127);
                            image(sprite, draw_x, draw_y, (float) (sprite.width * player.x_scale), (float) (sprite.height * player.y_scale));

                            // Do the same but under the cursor
                            int cursor_x = (int) ((mouseX / 32) * 32);
                            int cursor_y = (int) ((mouseY / 32) * 32);
                            draw_x = (float) ((float) cursor_x + player.sprite_offset_x) + 4;
                            draw_y = (float) ((float) cursor_y + player.sprite_offset_y) + 10;
                            image(sprite, draw_x, draw_y, (float) (sprite.width * player.x_scale), (float) (sprite.height * player.y_scale));
                            break;
                    }

                    pushMatrix();
                    applyCameraTransform();

                    if (show_tile_cursor) {
                        // Get tile position underneath the mouse, taking into account the camera
                        float draw_rect_x = (float) ((int) ((mouseX + camera_left) / 32) * 32);
                        float draw_rect_y = (float) ((int) ((mouseY + camera_top) / 32) * 32);
                        noFill();
                        stroke(230, 230, 230);
                        strokeWeight(2);
                        rect(draw_rect_x, draw_rect_y, cursor_width, cursor_height);
                    }

                    popMatrix();

                    fill(255);
                    outlineText("Tool: " + tool_name, 16 + 32 + 16, 32);
                    outlineText("Subtool: " + subtool_name, 16 + 32 + 16, 32 + 16);

                    noFill();
                    strokeWeight(2);
                    stroke(230, 230, 230); // slightly gray is cool
                    rect(15, 15, 32 + 2, 32 + 2);

                    outlineText("FPS: " + frameRate, 16, 64);
                }

                // HUD

                // Handle the floppy disk display
                // Note: while this animation code is horrible,
                // I won't have to touch it for a while,
                // so future me can worry about that

                if (floppy_timer >= 0) {
                    int base_floppy_y = 480 - 32;

                    if (floppy_timer == 0) {
                        floppy_bounce = -4;
                        floppy_x = 32;
                        floppy_y = base_floppy_y;
                    }

                    if (floppy_timer > 80) {
                        floppy_x -= (floppy_timer - 80) / 2;
                    }

                    if (floppy_timer > 160) {
                        floppy_timer = -1;
                        return;
                    }

                    floppy_bounce += 0.5f;

                    floppy_timer++;

                    floppy_y += floppy_bounce;

                    if (floppy_y > base_floppy_y) floppy_y = base_floppy_y;

                    fill(255);
                    var sprites = registry.sprites.get("floppy").get("idle");
                    image(sprites.get((frameCount / 8) % sprites.size()), (int) floppy_x, floppy_y - 16, 32, 32);
                    outlineText(" - " + flags.getInteger("floppies"), (int) floppy_x + 32, base_floppy_y);
                }
                break;
            case TILE_PICKER:
                boolean alt = true;
                // Draw all tiles in the tileset
                for (int y = 0; y < tileset.vertical_tiles; y++) {
                    for (int x = 0; x < tileset.horizontal_tiles; x++) {
                        if (alt) {
                            fill(0, 230, 156);
                        } else {
                            fill(32, 180, 156);
                        }
                        noStroke();
                        rect(x * 32, y * 32, (x * 32) + 32 + 1, (y * 32) + 32 + 1);
                        var index = x + y * tileset.horizontal_tiles;
                        tileset.drawTile(x * 32, y * 32, index);
                    
                        alt = !alt;
                    }
                    alt = !alt;
                }

                if (current_subtool == 0) {
                    // Draw selection box
                    noFill();
                    stroke(255, 0, 255);
                    strokeWeight(2);
                    rect(selection_x * 32, selection_y * 32, selection_width * 32, selection_height * 32);
                } else if (current_subtool == 1) {
                    // Draw all currently selected tiles
                    for (int i = 0; i < current_tiles.size(); i++) {
                        int tile = current_tiles.get(i);
                        int tile_x = tile % tileset.horizontal_tiles;
                        int tile_y = tile / tileset.horizontal_tiles;
                        noFill();
                        stroke(255, 0, 255);
                        strokeWeight(2);
                        rect(tile_x * 32, tile_y * 32, 32 + 1, 32 + 1);
                    }
                }

                // Draw the cursor
                float draw_rect_x = (float) ((int) (mouseX / 32) * 32);
                float draw_rect_y = (float) ((int) (mouseY / 32) * 32);
                noFill();
                stroke(230, 230, 230);
                strokeWeight(2);
                rect(draw_rect_x, draw_rect_y, 32, 32);
                break;
        }
    }

    void outlineText(String text, float x, float y) {
        int fillColor = g.fillColor;
        textFont(font, 16);

        fill(0, 0, 0);
        text(text, x - 2, y    );
        text(text, x + 2, y    );
        text(text, x,     y - 2);
        text(text, x,     y + 2);

        fill(fillColor);
        text(text, x, y);
    }
}
