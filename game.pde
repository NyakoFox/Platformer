import java.io.File;
import javax.swing.*;

Game game;
Input input;

boolean DEBUG = true;
boolean DEBUG_RENDER = false;

PFont font;

void setup() {
    font = createFont("pcsenior.ttf", 16, false);
    // Resize the screen to my favorite resolution
    size(640, 480);
    surface.setTitle("Platforming");
    surface.setResizable(false);
    frameRate(60);
    game = new Game();
    input = new Input();
    loop();
    noSmooth();
    background(0);
}

void draw() {
    // Run logic
    game.update();
    // Draw
    game.draw();
    // Modify key states
    input.changeKeys();
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
                current_tiles.clear();
                current_tiles.add(0);
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

    void update() {

        int mouse_tile_x = (int) (mouseX / 32);
        int mouse_tile_y = (int) (mouseY / 32);

        switch (state) {
            case MENU:
                break;
            case GAME:
                // Loop through all entities and run their logic.
                for (int i = 0; i < entities.size(); i++) {
                    entities.get(i).update();
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
                    if (input.pressed("Y")) setSubtool(1);;
                }
                break;
            case PAUSED:
                break;
            case TILE_PICKER:
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


    // Draw
    void draw() {
        // Clear the canvas
        background(28, 32, 44);

        Tileset tileset = current_map.tileset;

        switch (state) {
            case MENU:
                break;
            case GAME:
                // Draw the map
                current_map.draw();

                // Loop through all entities and draw them.
                for (int i = 0; i < entities.size(); i++) {
                    entities.get(i).draw();
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
                    case 2: tool_name = "ENTITIES"; break;
                    case 3: tool_name = "LIGHTING"; break;
                    case 4: tool_name = "LAYERS"; break;
                    case 5: tool_name = "MAP"; break;
                    case 6: tool_name = "OBJECTS"; break;
                    case 7: tool_name = "PLAYER"; break;
                    case 8: tool_name = "TILESET"; break;
                    case 9:
                        tool_name = "START";
                        // Draw the player's sprite at their spawn point
                        Player player = getPlayer();
                        PImage sprite = player.sprites.get("idle").get(2);
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

                if (show_tile_cursor) {
                    float draw_rect_x = (float) ((int) (mouseX / 32) * 32);
                    float draw_rect_y = (float) ((int) (mouseY / 32) * 32);
                    noFill();
                    stroke(230, 230, 230);
                    strokeWeight(2);
                    rect(draw_rect_x, draw_rect_y, cursor_width, cursor_height);
                }

                fill(255);
                outlineText("Tool: " + tool_name, 16 + 32 + 16, 32);
                outlineText("Subtool: " + subtool_name, 16 + 32 + 16, 32 + 16);

                noFill();
                strokeWeight(2);
                stroke(230, 230, 230); // slightly gray is cool
                rect(15, 15, 32 + 2, 32 + 2);

                outlineText("FPS: " + frameRate, 16, 64);
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

class Map {
    int width, height;
    int real_width, real_height;
    ArrayList<int[][]> layers;
    boolean[][] collision;
    Tileset tileset;
    String name;
    int start_x;
    int start_y;
    String connected_left;
    String connected_right;
    String connected_up;
    String connected_down;
    int connected_left_offset;
    int connected_right_offset;
    int connected_up_offset;
    int connected_down_offset;

    Map(int width, int height, Tileset tileset) {
        this.width = width;
        this.height = height;
        this.real_width = this.width * 32;
        this.real_height = this.height * 32;
        this.tileset = tileset;
        this.name = "untitled";
        this.start_x = 320;
        this.start_y = 240;
        this.connected_left = "";
        this.connected_right = "";
        this.connected_up = "";
        this.connected_down = "";
        this.connected_left_offset = 0;
        this.connected_right_offset = 0;
        this.connected_up_offset = 0;
        this.connected_down_offset = 0;

        collision = new boolean[height][width];

        this.layers = new ArrayList<>();
        layers.add(new int[height][width]);
    }

    Map(int width, int height, String tileset) {
        this(width, height, new Tileset(tileset));
    }

    Map(String filename) {
        // Load a map from disk
        // No caching since they're so small
        this.name = filename;
        JSONObject json = loadJSONObject("maps/" + filename + ".json");
        this.width = json.getInt("width", 20);
        this.height = json.getInt("height", 15);
        this.real_width = this.width * 32;
        this.real_height = this.height * 32;
        this.start_x = json.getInt("start_x", 320);
        this.start_y = json.getInt("start_y", 240);
        this.connected_left = json.getString("connected_left", "");
        this.connected_right = json.getString("connected_right", "");
        this.connected_up = json.getString("connected_up", "");
        this.connected_down = json.getString("connected_down", "");
        this.connected_left_offset = json.getInt("connected_left_offset", 0);
        this.connected_right_offset = json.getInt("connected_right_offset", 0);
        this.connected_up_offset = json.getInt("connected_up_offset", 0);
        this.connected_down_offset = json.getInt("connected_down_offset", 0);
        JSONArray layers = json.getJSONArray("layers");
        this.layers = new ArrayList<>();
        for (int i = 0; i < layers.size(); i++) {
            JSONArray layer = layers.getJSONArray(i);
            int[][] layer_data = new int[height][width];
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    layer_data[y][x] = layer.getJSONArray(y).getInt(x);
                }
            }
            this.layers.add(layer_data);
        }
        this.tileset = new Tileset(json.getString("tileset"));
        // Load collision
        JSONArray collision_data = json.getJSONArray("collision");
        this.collision = new boolean[height][width];
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int data = collision_data.getJSONArray(y).getInt(x);
                collision[y][x] = (data == 1); // Possibly support other collision types in the future
            }
        }
    }

    double getStartX() {
        return start_x;
    }

    double getStartY() {
        return start_y;
    }

    void saveMap(String name) {
        // Save the map to a json file. For development only
        println("[DEV] SAVING MAP " + name);
        JSONObject map = new JSONObject();
        map.setInt("width", width);
        map.setInt("height", height);
        map.setInt("start_x", start_x);
        map.setInt("start_y", start_y);
        map.setString("connected_left", connected_left);
        map.setString("connected_right", connected_right);
        map.setString("connected_up", connected_up);
        map.setString("connected_down", connected_down);
        map.setInt("connected_left_offset", connected_left_offset);
        map.setInt("connected_right_offset", connected_right_offset);
        map.setInt("connected_up_offset", connected_up_offset);
        map.setInt("connected_down_offset", connected_down_offset);
        JSONArray layers = new JSONArray();
        for (int[][] layer : this.layers) {
            JSONArray layer_data = new JSONArray();
            for (int y = 0; y < height; y++) {
                JSONArray row = new JSONArray();
                for (int x = 0; x < width; x++) {
                    row.setInt(x, layer[y][x]);
                }
                layer_data.setJSONArray(y, row);
            }
            layers.setJSONArray(layers.size(), layer_data);
        }
        map.setJSONArray("layers", layers);
        map.setString("tileset", tileset.name);
        JSONArray collision_data = new JSONArray();
        for (boolean[] row : collision) {
            JSONArray row_data = new JSONArray();
            for (boolean col : row) {
                row_data.setInt(row_data.size(), col ? 1 : 0);
            }
            collision_data.setJSONArray(collision_data.size(), row_data);
        }
        map.setJSONArray("collision", collision_data);
        saveJSONObject(map, "maps/" + name + ".json");

    }

    int getTile(int layer, int x, int y) {
        return layers.get(layer)[y][x];
    }

    void setTile(int layer, int x, int y, int tile) {
        if (x < 0 || x >= width || y < 0 || y >= height) {
            return;
        }
        layers.get(layer)[y][x] = tile;
    }

    void setCollisionTile(int x, int y, boolean tile) {
        if (x < 0 || x >= width || y < 0 || y >= height) {
            return;
        }
        collision[y][x] = tile;
    }

    boolean isPosInSolid(double x, double y) {
        return isSolid((int) (x / 32), (int) (y / 32));
    }

    boolean isSolid(int x, int y) {
        // Check bounds
        if (x < 0 || x >= width || y < 0 || y >= height) {
            // If collision is out of bounds, then check the edge
            // of the map instead
            x = min(max(x, 0), width - 1);
            y = min(max(y, 0), height - 1);
        }
        return collision[y][x];
    }

    void draw() {
        for (int i = 0; i < layers.size(); i++) {
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    int tile = layers.get(i)[y][x];
                    if (tile != 0) {
                        tileset.drawTile(x * 32, y * 32, tile);
                    }
                }
            }
        }
    }
}

class Tileset {
    ArrayList<PImage> tiles;
    int horizontal_tiles, vertical_tiles;
    String name;
    Tileset(String filename) {
        name = filename;
        PImage image = loadImage("tilesets/" + filename + ".png");
        horizontal_tiles = image.width / 16;
        vertical_tiles   = image.height / 16;

        tiles = new ArrayList<>();

        // Split the image into tiles
        for (int y = 0; y < vertical_tiles; y++) {
            for (int x = 0; x < horizontal_tiles; x++) {
                tiles.add(image.get(x * 16, y * 16, 16, 16));
            }
        }
    }

    void drawTile(int x, int y, int tile) {
        // Get the tile's position in the tileset using the tile's index

        //int tile_x = tile % horizontal_tiles;
        //int tile_y = tile / horizontal_tiles;

        tint(255, 255, 255, 255);
        image(tiles.get(tile), x, y, 32, 32);
    }
}
