class HelpTextMapEntity extends MapEntity {

    String text;
    int type;
    int center_size;

    HelpTextMapEntity() {
        super("helptext");
        text = "ERROR";
        type = 0;
        center_size = 640;
        calculateSize();
    }

    Entity createEntity() {
        // Create your entity here
        HelpTextEntity entity = new HelpTextEntity(x, y, text);
        entity.uuid = uuid;
        entity.type = type;
        entity.center_size = center_size;
        return entity;
    }

    JSONObject save(JSONObject json) {
        json = super.save(json);
        // Write data to the JSON
        json.setString("text", text);
        json.setInt("type", type);
        json.setInt("center_size", center_size);
        return json;
    }

    void load(JSONObject json) {
        // Read data from the JSON
        super.load(json);
        text = json.getString("text", "ERROR");
        type = json.getInt("type", 0);
        center_size = json.getInt("center_size", 640);
        calculateSize();
    }

    void onAdd() {
        // Called when the entity is added to the map
        calculateSize();
    }

    void calculateSize() {
        textFont(FONT, 16);
        width = textWidth(text) + 4;
        height = textAscent() + textDescent() + 4; // 4 pixels of padding
        // Center the text horizontally (anchored to the left)
        x = (center_size / 2) - (width / 2);
    }

    void draw() {
        textFont(FONT, 16);
        fill(214, 248, 255);
        Graphics.outlineText(text, (float)x + 3, (float)(y + 3 + textAscent()));
        super.draw();
    }
}
