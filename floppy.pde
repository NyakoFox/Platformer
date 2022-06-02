class Floppy extends Entity {
    boolean collected;

    Floppy(double x, double y) {
        super("floppy", x, y, 15, 15);

        collected = false;

        registerAnimationSpeed("idle", 0.15);
        setAnimation("idle");
    }

    void onCollision(Entity other) {
        if (!collected) {
            doRippleEffect(x, y);
            registry.playSound("collectible");
            collected = true;
            visible = false;
        }
    }

    void save(JSONObject json) {
        json.setBoolean("collected", collected);
        super.save(json);
    }

    void load(JSONObject json) {
        collected = json.getBoolean("collected");
        super.load(json);
    }

    void update() {
        super.update();
    }

    void draw() {
        super.draw();
        //var current_image = getCurrentImage();
        //var draw_x = getDrawX();
        //var draw_y = getDrawY();
        //image(current_image, (float) draw_x, (float) draw_y, (float) (current_image.width * x_scale), (float) (current_image.height * y_scale));
    }
}