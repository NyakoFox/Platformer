class HelpText extends Entity {

    HelpText(double x, double y) {
        super("helptext", x, y, 15, 15);

        collected = false;

        registerAnimationSpeed("idle", 0.15);
        setAnimation("idle");
    }

    void update() {
        super.update();
    }

    void draw() {

    }
}