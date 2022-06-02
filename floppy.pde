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
            setFlag("collected", true);
            doRippleEffect(x, y);
            floppy_timer = 0;
            flags.set("floppies", flags.getInteger("floppies", 0) + 1);
            registry.playSound("collectible");
            collected = true;
            visible = false;
        }
    }

    void save(JSONObject json) {
        // Save data to the map (for the hacky editor)
        json.setBoolean("collected", collected);
        super.save(json);
    }

    void load(JSONObject json) {
        // Load data from the map
        collected = json.getBoolean("collected");
        super.load(json);
    }

    void onAdd() {
        // When added to the world (UUID should be set at this point)
        if (getFlagBoolean("collected") || collected) {
            collected = true;
            visible = false;
        }
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