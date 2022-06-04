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
        super.draw();
        ArrayList<PImage> sprites = Registry.SPRITES.get("floppy").get("idle");
        image(sprites.get((frameCount / 8) % sprites.size()), (float)x, (float)y, 32, 32);
    }
}
