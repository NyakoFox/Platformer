
class EntityData {
    String name;
    double x;
    double y;
    JSONObject data;
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
    ArrayList<EntityData> entities;

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
        // Load all entities
        JSONArray entities = json.getJSONArray("entities");
        this.entities = new ArrayList<>();
        if (entities != null) {
            for (int i = 0; i < entities.size(); i++) {
                JSONObject entity = entities.getJSONObject(i);
                EntityData data = new EntityData();
                data.name = entity.getString("name");
                data.x = entity.getDouble("x");
                data.y = entity.getDouble("y");
                data.data = entity.getJSONObject("data");
                this.entities.add(data);
            }
        }
    }

    void addEntityData(EntityData data) {
        entities.add(data);
    }

    EntityData addEntityData(Entity entity) {
        EntityData data = new EntityData();
        data.name = entity.id;
        data.x = entity.x;
        data.y = entity.y;
        // Make a new JSON object
        JSONObject entity_data = new JSONObject();
        // Call the serialize function on the entity
        entity.save(entity_data);
        data.data = entity_data;
        addEntityData(data);
        return data;
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

        // Save entity data
        JSONArray entities = new JSONArray();
        for (EntityData data : this.entities) {
            JSONObject entity = new JSONObject();
            entity.setString("name", data.name);
            entity.setDouble("x", data.x);
            entity.setDouble("y", data.y);
            entity.setJSONObject("data", data.data);
            entities.setJSONObject(entities.size(), entity);
        }
        map.setJSONArray("entities", entities);

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

    void shiftTiles(int x, int y) {
        // Shift all tile positions by x and y
        // Make new layers and copy the data
        ArrayList<int[][]> new_layers = new ArrayList<>();
        for (int[][] layer : layers) {
            int[][] new_layer = new int[height][width];
            for (int i = 0; i < height; i++) {
                for (int j = 0; j < width; j++) {
                    int new_x = j - x;
                    int new_y = i - y;
                    if (new_x < 0 || new_x >= width || new_y < 0 || new_y >= height) {
                        // If the new position is out of bounds, then continue
                        continue;
                    } else {
                        new_layer[i][j] = layer[new_y][new_x];
                    }
                }
            }
            new_layers.add(new_layer);
        }
        layers = new_layers;

        // Shift the collision data
        boolean[][] new_collision = new boolean[height][width];
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                int new_x = j - x;
                int new_y = i - y;
                if (new_x < 0 || new_x >= width || new_y < 0 || new_y >= height) {
                    // If the new position is out of bounds, then continue
                    continue;
                } else {
                    new_collision[i][j] = collision[new_y][new_x];
                }
            }
        }
        collision = new_collision;

        // And entities
        for (EntityData data : entities) {
            data.x += x * 32;
            data.y += y * 32;
        }
        // And any current game entities
        for (Entity entity : game.entities) {
            entity.x += x * 32;
            entity.y += y * 32;
        }
    }

    void resize(int new_width, int new_height) {
        // Resize the map, adding empty space
        // Layers are an ArrayList
        ArrayList<int[][]> new_layers = new ArrayList<>();
        for (int[][] layer : layers) {
            int[][] new_layer = new int[new_height][new_width];
            for (int y = 0; y < new_height; y++) {
                for (int x = 0; x < new_width; x++) {
                    if (y < height && x < width) {
                        new_layer[y][x] = layer[y][x];
                    }
                }
            }
            new_layers.add(new_layer);
        }
        layers = new_layers;
        // Resize the collision array
        boolean[][] new_collision = new boolean[new_height][new_width];
        for (int y = 0; y < new_height; y++) {
            for (int x = 0; x < new_width; x++) {
                if (y < height && x < width) {
                    new_collision[y][x] = collision[y][x];
                }
            }
        }
        collision = new_collision;
        // Resize the map
        width = new_width;
        height = new_height;
        real_width = width * 32;
        real_height = height * 32;
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
