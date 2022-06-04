/*
    This class is the game editor.
    This is what I made to help create the game.
    Feel free to look around if you like.
*/

import java.io.File;
import javax.swing.*;

enum EditorStates {
    EDITOR,
    PLAYTESTING,
    TILE_PICKER,
    OPTIONS
}

class EditorState {

    Map current_map;

    ArrayList<Integer> current_tiles = new ArrayList<>();
    int current_layer = 0;
    int current_tool = 0;
    int current_subtool = 0;
    int selection_height = 0;
    int selection_width = 0;
    int selection_x = 0;
    int selection_y = 0;

    double camera_x = 0;
    double camera_y = 0;
    double camera_left = 0;
    double camera_right = 0;
    double camera_top = 0;
    double camera_bottom = 0;

    EditorStates state = EditorStates.EDITOR;

    EditorState() {
        current_tiles.clear();
        current_tiles.add(0);
        selection_width = 1;
        selection_height = 1;
    }

    void enter() {
        current_map = loadMap("start");
    }

    MapEntity getEntityUnderCursor() {
        for (int i = current_map.entities.size() - 1; i >= 0; i--) {
            MapEntity entity = current_map.entities.get(i);
            // Check if the entity is under the cursor
            double x = entity.x;
            double y = entity.y;
            double w = entity.width;
            double h = entity.height;

            double mouse_x = mouseX + camera_left;
            double mouse_y = mouseY + camera_top;
            // AABB
            if (mouse_x + camera_left >= x && mouse_x <= x + w && mouse_y >= y && mouse_y <= y + h) {
                return entity;
            }
        }
        return null;
    }

    Map loadMap(String name) {
        // Load the map
        return new Map(name);
    }

    void unloadMap() {
        current_map = null;
    }

    void switchMap(String name) {
        unloadMap();
        current_map = loadMap(name);
    }

    void switchMap(Map map) {
        unloadMap();
        current_map = map;
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

        // Make sure the camera is in bounds
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

        mouse_tile_x = (int) ((mouseX + camera_left) / 32);
        mouse_tile_y = (int) ((mouseY + camera_top) / 32);

        switch (state) {
            case EDITOR:
                // CTRL+SHIFT+ALT+Arrow keys to change room connections
                if (Input.down("ctrl") && Input.down("shift") && Input.down("alt")) {
                    if (Input.pressed("left")) {
                        Input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of left-connected map");
                        if (new_name != null) {
                            current_map.connected_left = new_name;
                        }
                        return;
                    }
                    if (Input.pressed("right")) {
                        Input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of right-connected map");
                        if (new_name != null) {
                            current_map.connected_right = new_name;
                        }
                        return;
                    }
                    if (Input.pressed("up")) {
                        Input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of up-connected map");
                        if (new_name != null) {
                            current_map.connected_up = new_name;
                        }
                        return;
                    }
                    if (Input.pressed("down")) {
                        Input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of down-connected map");
                        if (new_name != null) {
                            current_map.connected_down = new_name;
                        }
                        return;
                    }
                }

                // CTRL+SHIFT+F+Arrow keys to decrease room size
                if (Input.down("ctrl") && Input.down("shift") && Input.down("F")) {
                    if (Input.pressed("right")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width - 1, current_map.height);
                        current_map.shiftTiles(-1, 0);
                        return;
                    }
                    if (Input.pressed("left")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width - 1, current_map.height);
                        return;
                    }
                    if (Input.pressed("down")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width, current_map.height - 1);
                        current_map.shiftTiles(0, -1);
                        return;
                    }
                    if (Input.pressed("up")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width, current_map.height - 1);
                        return;
                    }
                }

                // CTRL+SHIFT+G+Arrow keys to increase connected side offsets
                if (Input.down("ctrl") && Input.down("shift") && Input.down("G")) {
                    if (Input.pressed("right")) {
                        Input.clearPressed();
                        current_map.connected_right_offset++;
                        return;
                    }
                    if (Input.pressed("left")) {
                        Input.clearPressed();
                        current_map.connected_left_offset++;
                        return;
                    }
                    if (Input.pressed("down")) {
                        Input.clearPressed();
                        current_map.connected_down_offset++;
                        return;
                    }
                    if (Input.pressed("up")) {
                        Input.clearPressed();
                        current_map.connected_up_offset++;
                        return;
                    }
                }

                // CTRL+SHIFT+H+Arrow keys to decrease connected side offsets
                if (Input.down("ctrl") && Input.down("shift") && Input.down("H")) {
                    if (Input.pressed("right")) {
                        Input.clearPressed();
                        current_map.connected_right_offset--;
                        return;
                    }
                    if (Input.pressed("left")) {
                        Input.clearPressed();
                        current_map.connected_left_offset--;
                        return;
                    }
                    if (Input.pressed("down")) {
                        Input.clearPressed();
                        current_map.connected_down_offset--;
                        return;
                    }
                    if (Input.pressed("up")) {
                        Input.clearPressed();
                        current_map.connected_up_offset--;
                        return;
                    }
                }


                // CTRL+SHIFT+Arrow keys to increase room size
                if (Input.down("ctrl") && Input.down("shift")) {
                    if (Input.pressed("left")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width + 1, current_map.height);
                        current_map.shiftTiles(1, 0);
                        return;
                    }
                    if (Input.pressed("right")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width + 1, current_map.height);
                        return;
                    }
                    if (Input.pressed("up")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width, current_map.height + 1);
                        current_map.shiftTiles(0, 1);
                        return;
                    }
                    if (Input.pressed("down")) {
                        Input.clearPressed();
                        current_map.resize(current_map.width, current_map.height + 1);
                        return;
                    }
                }

                // Shift+Arrow keys to move camera
                boolean moved_camera = false;

                if (Input.down("shift") && Input.down("left"))  { camera_x -= 8; moved_camera = true; }
                if (Input.down("shift") && Input.down("right")) { camera_x += 8; moved_camera = true; }
                if (Input.down("shift") && Input.down("up"))    { camera_y -= 8; moved_camera = true; }
                if (Input.down("shift") && Input.down("down"))  { camera_y += 8; moved_camera = true; }

                if (moved_camera) {
                    return;
                }

                // Arrow keys to switch between rooms
                if (Input.pressed("left")) {
                    Input.clearPressed();
                    if (current_map.connected_left != "") {
                        switchMap(current_map.connected_left);
                    }
                    return;
                }
                if (Input.pressed("right")) {
                    Input.clearPressed();
                    if (current_map.connected_right != "") {
                        switchMap(current_map.connected_right);
                    }
                    return;
                }
                if (Input.pressed("up")) {
                    Input.clearPressed();
                    if (current_map.connected_up != "") {
                        switchMap(current_map.connected_up);
                    }
                    return;
                }
                if (Input.pressed("down")) {
                    Input.clearPressed();
                    if (current_map.connected_down != "") {
                        switchMap(current_map.connected_down);
                    }
                    return;
                }

                if (Input.pressed("S")) {
                    if (Input.down("ctrl")) {
                        Input.clearPressed();
                        String new_name = JOptionPane.showInputDialog("Enter name of map to save to");
                        if (new_name != null) {
                            current_map.name = new_name;
                            current_map.saveMap(current_map.name);
                        }
                    } else {
                        current_map.saveMap(current_map.name);
                    }
                }

                if (Input.pressed("L")) {
                    if (Input.down("ctrl")) {
                        Input.clearPressed();
                        String open = JOptionPane.showInputDialog("Enter name of map to load");
                        if (open != null) {
                            switchMap(open);
                        }
                    } else {
                        switchMap(current_map.name);
                    }
                }

                if (Input.pressed("N") && Input.down("ctrl")) {
                    Input.clearPressed();
                    String new_name = JOptionPane.showInputDialog("Enter name of new map");
                    if (new_name != null) {
                        Map new_map = new Map(20, 15, "indust");
                        new_map.name = new_name;
                        new_map.saveMap(new_name);
                        switchMap(new_name);
                    }
                }

                if (Input.down("tab")) {
                    state = EditorStates.TILE_PICKER;
                    break;
                }

                if (Input.pressed("enter")) {
                    MAIN.enterPlaytesting();
                    break;
                }

                switch (current_tool) {
                    case 0: // TILES tool
                        if (Input.mouseDown(0)) { // If we're holding down the left mouse button
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
                        } else if (Input.mouseDown(1)) {
                            if (current_subtool == 0) {
                                for (int y = 0; y < selection_height; y++) {
                                    for (int x = 0; x < selection_width; x++) {
                                        current_map.setTile(current_layer, mouse_tile_x + x, mouse_tile_y + y, 0);
                                    }
                                }
                            } else {
                                current_map.setTile(current_layer, mouse_tile_x, mouse_tile_y, 0);
                            }
                        } else if (Input.mouseDown(2)) {
                            current_tiles.clear();
                            current_tiles.add(current_map.getTile(current_layer, mouse_tile_x, mouse_tile_y));
                            selection_width = 1;
                            selection_height = 1;
                        }
                        break;
                    case 1:
                        if (Input.mouseDown(0)) {
                            current_map.setCollisionTile(mouse_tile_x, mouse_tile_y, true);
                        } else if (Input.mouseDown(1)) {
                            current_map.setCollisionTile(mouse_tile_x, mouse_tile_y, false);
                        }
                        break;
                    case 3: // COLLECTIBLES
                        if (Input.mousePressed(0)) {
                            placeEntity("floppy", mouse_tile_x * 32, mouse_tile_y * 32);
                            //addSavedEntity("floppy", mouse_tile_x * 32, mouse_tile_y * 32);
                        } else if (Input.mousePressed(1)) {
                            MapEntity entity = getEntityUnderCursor();
                            if (entity != null) {
                                removeEntity(entity);
                                //removeSavedEntity(entity);
                            }
                        }
                        break;
                    case 4: // CHECKPOINTS
                        break;
                    case 8: // GENERIC ENTITIES
                        break;
                    case 9:
                        if (Input.mousePressed(0)) {
                            current_map.start_x = (mouse_tile_x * 32) + 4;
                            current_map.start_y = (mouse_tile_y * 32) + 10;
                            //player.setCheckpoint(current_map.start_x, current_map.start_y);
                        }
                    default:
                        break;
                }

                if (Input.pressed("1")) setTool(0);
                if (Input.pressed("2")) setTool(1);
                if (Input.pressed("3")) setTool(2);
                if (Input.pressed("4")) setTool(3);
                if (Input.pressed("5")) setTool(4);
                if (Input.pressed("6")) setTool(5);
                if (Input.pressed("7")) setTool(6);
                if (Input.pressed("8")) setTool(7);
                if (Input.pressed("9")) setTool(8);
                if (Input.pressed("0")) setTool(9);

                if (Input.pressed("T")) setSubtool(0);
                if (Input.pressed("Y")) setSubtool(1);
                break;
            case TILE_PICKER:
                mouse_tile_x = (int) (mouseX / 32);
                mouse_tile_y = (int) (mouseY / 32);
                if (current_subtool == 0) {
                    // Drag using the left mouse button to select a region of tiles
                    if (Input.mousePressed(0)) {
                        selection_x = mouse_tile_x;
                        selection_y = mouse_tile_y;
                        selection_width = 1;
                        selection_height = 1;
                    }
                    if (Input.mouseDown(0)) {
                        selection_width = mouse_tile_x - selection_x + 1;
                        selection_height = mouse_tile_y - selection_y + 1;
                    }
                    if (Input.mouseReleased(0)) {
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
                    if (Input.mousePressed(0)) {
                        if (Input.down("ctrl")) {
                            current_tiles.add(mouse_tile_x + mouse_tile_y * current_map.tileset.horizontal_tiles);
                        } else {
                            current_tiles.clear();
                            current_tiles.add(mouse_tile_x + mouse_tile_y * current_map.tileset.horizontal_tiles);
                        }
                    }
                }

                if (Input.released("tab")) {
                    state = EditorStates.EDITOR;
                }
                break;
        }
    }

    MapEntity placeEntity(String name, int x, int y) {
        MapEntity entity = current_map.createEntityFromName(name);
        entity.x = x;
        entity.y = y;
        current_map.entities.add(entity);
        return entity;
    }

    void removeEntity(MapEntity entity) {
        current_map.entities.remove(entity);
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

        updateCamera();

        switch (state) {
            case EDITOR:
                pushMatrix();
                applyCameraTransform();
                // Draw the map
                current_map.draw();

                // Draw a translucent 32x32 grid overtop of the tiles
                stroke(255, 255, 255, 32);
                strokeWeight(1);
                for (int x = 0; x < current_map.width; x++) {
                    for (int y = 0; y < current_map.height; y++) {
                        line(x * 32, y * 32, x * 32 + 32, y * 32);
                        line(x * 32, y * 32, x * 32, y * 32 + 32);
                    }
                }

                // Loop through all entities and draw them (in reverse)
                for (int i = current_map.entities.size() - 1; i >= 0; i--) {
                    MapEntity entity = current_map.entities.get(i);
                    entity.draw();
                }

                DEBUG_RENDER = false;
                if (Input.down("shift") || current_tool == 1) {
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
                        int player_sprite_offset_x = 4;
                        int player_sprite_offset_y = 4;

                        PImage sprite = Registry.SPRITES.get("player").get("idle").get(2);
                        float draw_x = (float) (current_map.getStartX() + player_sprite_offset_x);
                        float draw_y = (float) (current_map.getStartY() + player_sprite_offset_y);
                        tint(255, 255, 255, 127);
                        image(sprite, draw_x, draw_y, (float) (sprite.width * 2), (float) (sprite.height * 2));

                        // Do the same but under the cursor
                        int cursor_x = (int) ((mouseX / 32) * 32);
                        int cursor_y = (int) ((mouseY / 32) * 32);
                        draw_x = (float) ((float) cursor_x + player_sprite_offset_x) + 4;
                        draw_y = (float) ((float) cursor_y + player_sprite_offset_y) + 10;
                        image(sprite, draw_x, draw_y, (float) (sprite.width * 2), (float) (sprite.height * 2));
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
                GRAPHICS.outlineText("Tool: " + tool_name, 16 + 32 + 16, 32);
                GRAPHICS.outlineText("Subtool: " + subtool_name, 16 + 32 + 16, 32 + 16);

                noFill();
                strokeWeight(2);
                stroke(230, 230, 230); // slightly gray is cool
                rect(15, 15, 32 + 2, 32 + 2);

                GRAPHICS.outlineText("FPS: " + frameRate, 16, 64);
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
}
