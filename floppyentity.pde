class FloppyEntity extends Entity {
    boolean collected;

    FloppyEntity(double x, double y) {
        super("floppy", x, y, 15, 15);

        collected = false;

        registerAnimationSpeed("idle", 0.15);
        setAnimation("idle");
    }

    void onCollision(Entity other) {
        if (!collected) {
            setFlag("collected", true);
            MAIN.STATE_GAMEPLAY.doRippleEffect(x, y);
            MAIN.STATE_GAMEPLAY.floppy_timer = 0;
            MAIN.STATE_GAMEPLAY.flags.set("floppies", MAIN.STATE_GAMEPLAY.flags.getInteger("floppies", 0) + 1);
            Registry.playSound("collectible");
            collected = true;
            visible = false;
        }
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