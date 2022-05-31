class Entity {
    double x, y, width, height;
    double x_velocity, y_velocity;
    double x_scale, y_scale;
    boolean uses_gravity;
    double gravity;
    double max_gravity;
    String id;
    HashMap<String, ArrayList<PImage>> sprites;
    HashMap<String, Float> animation_speeds;
    String animation;
    double animation_timer;
    int animation_index;
    double animation_speed;
    double sprite_offset_x;
    double sprite_offset_y;
    boolean flipped;
    Map map;

    // Initialize variables
    Entity(String id, double x, double y, double width, double height) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.x_scale = 2;
        this.y_scale = 2;

        this.sprite_offset_x = 0;
        this.sprite_offset_y = 0;

        this.x_velocity = 0d;
        this.y_velocity = 0d;

        uses_gravity = false;

        // This started as 30 FPS, but I changed it to 60, so I had to change these too
        gravity = 1.2d / 4;
        max_gravity = 16d / 2;

        animation_timer = 0;
        animation_index = 0;
        animation_speed = 1;

        flipped = false;

        sprites = new HashMap<>();
        animation_speeds = new HashMap<>();

        registerSprites();
    }

    void onAdd() {
        
    }

    void registerAnimationSpeed(String animation, float speed) {
        animation_speeds.put(animation, speed);
    }

    double getWidth() {
        return width * x_scale;
    }

    double getHeight() {
        return height * y_scale;
    }

    void setAnimation(String animation, double speed) {
        if (this.animation == null || !this.animation.equals(animation)) {
            this.animation = animation;
            animation_timer = 0;
            animation_index = 0;
            animation_speed = speed;
        }
    }

    void setAnimation(String animation) {
        if (this.animation == null || !this.animation.equals(animation)) {
            this.animation = animation;
            animation_timer = 0;
            animation_index = 0;
            if (animation_speeds.containsKey(animation)) {
                animation_speed = animation_speeds.get(animation);
            } else {
                animation_speed = 1;
            }
        }
    }

    void registerSprites() {
        // Loop through the sprites directory
        File dir = new File(sketchPath() + "/sprites/" + id + "/");
        File[] files = dir.listFiles();
        for (int i = 0; i < files.length; i++) {
            String name = files[i].getName();
            String path = files[i].getAbsolutePath();
            if (files[i].isFile()) {
                name = name.substring(0, name.length() - 4);
                ArrayList<PImage> images = new ArrayList<>();
                images.add(loadImage(path));
                sprites.put(name, images);
            } else {
                ArrayList<PImage> images = new ArrayList<>();
                for (int j = 0; j < files[i].listFiles().length; j++) {
                    images.add(loadImage(files[i].listFiles()[j].getAbsolutePath()));
                }
                sprites.put(name, images);
            }
        }
    }

    void enableGravity(boolean enable) {
        uses_gravity = enable;
    }

    void setVelocity(double x, double y) {
        x_velocity = x;
        y_velocity = y;
    }

    void addVelocity(double x, double y) {
        x_velocity += x;
        y_velocity += y;
    }

    void animationLooped(String animation) {

    }

    void update() {
        animation_timer += animation_speed;
        while (animation_timer >= 1) {
            animation_timer -= 1;
            animation_index++;
            if (animation_index >= sprites.get(animation).size()) {
                animationLooped(animation);
                animation_index = 0;
            }
        }

        if (uses_gravity) {
             if (y_velocity < max_gravity) {
                 y_velocity += Double.min(gravity, max_gravity);
             }
        }

        // Check for map collision horizontally

        int multiplier_x = (int) Math.signum(x_velocity);
        int multiplier_y = (int) Math.signum(y_velocity);

        float precision = 0.1;
        int infinite = 0;
        boolean hit_x = false;
        boolean hit_y = false;
        while (isInSolid(x + x_velocity, y)) {
            x_velocity -= (precision * multiplier_x);
            hit_x = true;
            infinite++;
            if (infinite > 1000) break;
        }

        x += x_velocity;
        if (hit_x) x_velocity = 0;

        infinite = 0;
        while (isInSolid(x, y + y_velocity)) {
            y_velocity -= (precision * multiplier_y);
            hit_y = true;
            infinite++;
            if (infinite > 1000) break;
        }

        y += y_velocity;
        if (hit_y) y_velocity = 0;
    }

    boolean isInSolid(double x, double y) {
        // Check if we're inside a solid tile, taking into account width and height.
        // use AABB collision detection.
        return game.current_map.isPosInSolid(x, y) || game.current_map.isPosInSolid(x + getWidth(), y) || game.current_map.isPosInSolid(x, y + getHeight()) || game.current_map.isPosInSolid(x + getWidth(), y + getHeight());
    }

    boolean onGround() {
        // TODO: this is bad and sometimes goes off when it shouldn't
        return isInSolid(x, y + getHeight() + 1);
    }

    void draw() {
        // Draw debug rectangle of width and height
        if (DEBUG_RENDER) {
            fill(255, 0, 0);
            noStroke();
            rect((float) x, (float) y, (float) getWidth(), (float) getHeight());
        }

        if ((animation != null) && (sprites.get(animation) != null)) {
            var current_image = sprites.get(animation).get(animation_index);
            var draw_x = x + sprite_offset_x;
            var draw_y = y + sprite_offset_y;
            if (flipped) {
                pushMatrix();
                translate((float) (draw_x + (current_image.width * x_scale)), (float) draw_y);
                scale(-1, 1);
                image(current_image, 0, 0, (float) (current_image.width * x_scale), (float) (current_image.height * y_scale));
                popMatrix();
            } else {
                image(current_image, (float) draw_x, (float) draw_y, (float) (current_image.width * x_scale), (float) (current_image.height * y_scale));
            }
        }
    }
}
