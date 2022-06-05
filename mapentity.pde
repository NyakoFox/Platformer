import java.util.UUID;

class MapEntity {
    String name;
    double x, y, width, height;
    String uuid;

    boolean hovered;

    // Initialize variables
    MapEntity(String name) {
        this.name = name;

        this.uuid = UUID.randomUUID().toString();
        width = 32;
        height = 32;

        this.hovered = false;
    }

    JSONObject save(JSONObject json) {
        // Write data to the JSON

        // By default, don't write anything
        return json;
    }

    void load(JSONObject json) {
        // Read data from the JSON
    }

    void onAdd() {
        // Called when the entity is added to the map
    }

    Entity createEntity() {
        // Create your entity here
        Entity entity = new ErrorEntity(x, y);
        entity.uuid = uuid;
        return entity;
    }

    void update() {
    }

    void draw() {
        if (hovered) {
            stroke(90, 255, 255);
        } else {
            stroke(0, 255, 255);
        }
        noFill();
        strokeWeight(2);
        rect((float) x, (float) y, (float) width, (float) height);
    }
}
