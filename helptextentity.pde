class HelpTextEntity extends Entity {
    String text;
    int spawn_timer;
    int type;
    double start_y;
    double progress;
    boolean flashing;
    int center_size;

    HelpTextEntity(double x, double y, String text) {
        super("helptext", x, y, 15, 15);

        this.text = text;
        spawn_timer = 0;
        start_y = y;
        progress = 0;
        center_size = 640;

        type = 0;

        flashing = false;
    }

    void onAdd() {
        // When added to the world (UUID should be set at this point)

        if (getFlagBoolean("completed")) {
            visible = false;
        }

        calculateSize();
    }

    void calculateSize() {
        textFont(FONT, 16);
        width = textWidth(text) + 4;
        height = textAscent() + textDescent() + 4; // 4 pixels of padding
        // Center the text horizontally (anchored to the left), the screen width is 640
        x = (center_size / 2) - (width / 2);
    }

    // t is the time
    // b is the beginning value
    // c is the change in value
    // d is the duration
    float easeExpoOut(float t, float b, float c, float d) {
        return (t==d) ? b+c : c * (-(float)Math.pow(2, -10 * t/d) + 1) + b;
    }

    void update() {
        super.update();

        if (progress >= 1) {

            if (frameCount % 4 == 0) {
                flashing = !flashing;
            }

            if (spawn_timer > 90) {
                spawn_timer = 90;
            }

            spawn_timer--;
        } else {
            spawn_timer++;
        }

        y = (double) easeExpoOut((float)spawn_timer, (float)start_y, -10f, 60f);

        switch (type) {
            case 0:
                break;
            case 1:
                // If we're moving, increment progress
                if (Input.down("left") || Input.down("right")) {
                    progress += 0.015;
                }
                break;
            case 2:
                // If we press Z, complete
                if (Input.pressed("Z")) {
                    progress = 1;
                }
        }

        if (progress >= 1) {
            setFlag("completed", true);
        }

    }

    void draw() {
        textFont(FONT, 16);

        noClip();
        float alpha = easeExpoOut((float)spawn_timer, 0, 255f, 60f);
        fill(214, 248, 255, alpha);
        Graphics.outlineText(text, (float)x + 3, (float)(y + 3 + textAscent()));

        if (progress > 0) {
            clip((float)(x - STATE_GAMEPLAY.camera_left), (float)(y - STATE_GAMEPLAY.camera_top), (float)(width * progress), (float)height);

            if (progress >= 1) {
                if (flashing) {
                    fill(127, 255, 127, alpha);
                } else {
                    fill(200, 255, 127, alpha);
                }
            } else {
                fill(127, 255, 127, alpha);
            }

            text(text, (float)x + 3, (float)(y + 3 + textAscent()));

            noClip();
        }
    }
}