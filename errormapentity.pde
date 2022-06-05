class ErrorMapEntity extends MapEntity {

    ErrorMapEntity() {
        super("error");
        width = 84;
        height = 20;
    }

    Entity createEntity() {
        // Create your entity here
        Entity entity = new ErrorEntity(x, y);
        entity.uuid = uuid;
        return entity;
    }

    void draw() {
        fill(255, 0, 0);
        Graphics.outlineText("ERROR", (float)x + 3, (float)y + 15);
        super.draw();
    }
}
