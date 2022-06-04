class FloppyMapEntity extends MapEntity {

    FloppyMapEntity() {
        super("floppy");
        width = 32;
        height = 32;
    }

    Entity createEntity() {
        // Create your entity here
        return new FloppyEntity(x, y);
    }

    void draw() {
        fill(255, 0, 0);
        GRAPHICS.outlineText("FLOPPY", (float)x, (float)y);
        super.draw();
    }
}
