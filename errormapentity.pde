class ErrorMapEntity extends MapEntity {

    ErrorMapEntity() {
        super("error");
    }

    Entity createEntity() {
        // Create your entity here
        return new ErrorEntity(x, y);
    }

    void draw() {
        fill(255, 0, 0);
        GRAPHICS.outlineText("ERROR", (float)x, (float)y);
        super.draw();
    }
}
