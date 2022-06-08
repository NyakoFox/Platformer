class CheckpointMapEntity extends MapEntity {

    CheckpointMapEntity() {
        super("checkpoint");
        width = 32;
        height = 32;
    }

    Entity createEntity() {
        // Create your entity here
        //Entity entity = new FloppyEntity(x, y);
        //entity.uuid = uuid;
        //return entity;
        return null;
    }

    void draw() {
        super.draw();
        ArrayList<PImage> sprites = Registry.SPRITES.get("checkpoint").get("idle");
        image(sprites.get(0), (float)x, (float)y, 32, 32);
    }
}
