import java.util.UUID;

class MapEntity {
    String name;
    double x, y, width, height;
    String uuid;

    JSONObject data;

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

    Entity createEntity() {
        // Create your entity here
        return new ErrorEntity(x, y);
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
