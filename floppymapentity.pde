class FloppyMapEntity extends MapEntity {

    FloppyMapEntity() {
        super("floppy");
        width = 32;
        height = 32;
    }

    Entity createEntity() {
        // Create your entity here
        Entity entity = new FloppyEntity(x, y);
        entity.uuid = uuid;
        return entity;
    }

    void draw() {
        super.draw();
        ArrayList<PImage> sprites = Registry.SPRITES.get("floppy").get("idle");
        image(sprites.get((frameCount / 8) % sprites.size()), (float)x, (float)y, 32, 32);
    }
}
