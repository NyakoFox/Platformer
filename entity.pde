import java.util.UUID;
import java.awt.Point;

class Entity {
    double x, y, width, height;
    double x_velocity, y_velocity;
    double x_scale, y_scale;
    boolean uses_gravity;
    double gravity;
    double max_gravity;
    String id;
    HashMap<String, Float> animation_speeds;
    String animation;
    double animation_timer;
    int animation_index;
    double animation_speed;
    double sprite_offset_x;
    double sprite_offset_y;
    boolean flipped;
    Map map;
    boolean visible;
    boolean noclip;

    String uuid;

    // Initialize variables
    Entity(String id, double x, double y, double width, double height) {
        this.id = id;
        this.uuid = UUID.randomUUID().toString();
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
        noclip = false;

        visible = true;

        // This started as 30 FPS, but I changed it to 60, so I had to change these too
        gravity = 1.2d / 4;
        max_gravity = 16d / 2;

        animation_timer = 0;
        animation_index = 0;
        animation_speed = 1;

        flipped = false;

        animation_speeds = new HashMap<>();

        animation = null;
    }

    public void setFlag(String key, String  value) { MAIN.STATE_GAMEPLAY.flags.set(uuid + "/" + key, value); }
    public void setFlag(String key, Boolean value) { MAIN.STATE_GAMEPLAY.flags.set(uuid + "/" + key, value); }
    public void setFlag(String key, Integer value) { MAIN.STATE_GAMEPLAY.flags.set(uuid + "/" + key, value); }
    public void setFlag(String key, Float   value) { MAIN.STATE_GAMEPLAY.flags.set(uuid + "/" + key, value); }
    public void setFlag(String key, Double  value) { MAIN.STATE_GAMEPLAY.flags.set(uuid + "/" + key, value); }

    public String  getFlagString (String key) { return MAIN.STATE_GAMEPLAY.flags.getString (uuid + "/" + key); }
    public Boolean getFlagBoolean(String key) { return MAIN.STATE_GAMEPLAY.flags.getBoolean(uuid + "/" + key); }
    public Integer getFlagInteger(String key) { return MAIN.STATE_GAMEPLAY.flags.getInteger(uuid + "/" + key); }
    public Float   getFlagFloat  (String key) { return MAIN.STATE_GAMEPLAY.flags.getFloat  (uuid + "/" + key); }
    public Double  getFlagDouble (String key) { return MAIN.STATE_GAMEPLAY.flags.getDouble (uuid + "/" + key); }

    public String  getFlagString (String key, String  defaultValue) { return MAIN.STATE_GAMEPLAY.flags.getString (uuid + "/" + key, defaultValue); }
    public Boolean getFlagBoolean(String key, Boolean defaultValue) { return MAIN.STATE_GAMEPLAY.flags.getBoolean(uuid + "/" + key, defaultValue); }
    public Integer getFlagInteger(String key, Integer defaultValue) { return MAIN.STATE_GAMEPLAY.flags.getInteger(uuid + "/" + key, defaultValue); }
    public Float   getFlagFloat  (String key, Float   defaultValue) { return MAIN.STATE_GAMEPLAY.flags.getFloat  (uuid + "/" + key, defaultValue); }
    public Double  getFlagDouble (String key, Double  defaultValue) { return MAIN.STATE_GAMEPLAY.flags.getDouble (uuid + "/" + key, defaultValue); }

    void onCollision(Entity other) {
        // Override this
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

    HashMap<String, ArrayList<PImage>> getSprites() {
        return Registry.SPRITES.get(id);
    }

    void update() {
        if (animation != null) {
            animation_timer += animation_speed;
            while (animation_timer >= 1) {
                animation_timer -= 1;
                animation_index++;
                if (animation_index >= getSprites().get(animation).size()) {
                    animationLooped(animation);
                    animation_index = 0;
                }
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
        if (noclip) return false;
        // Check if we're inside a solid tile, taking into account width and height.

        Point top_left = getTileCoordinates(x, y);
        Point bottom_right = getTileCoordinates(x + getWidth(), y + getHeight());

        for (int y2 = (int)top_left.getY(); y2 <= (int)bottom_right.getY(); y2++) {
            for (int x2 = (int)top_left.getX(); x2 <= (int)bottom_right.getX(); x2++) {
                if (MAIN.STATE_GAMEPLAY.current_map.isSolid(x2, y2)) {
                    return true;
                }
            }
        }
        return false;
    }

    Point getTileCoordinates(double x, double y) {
        return new Point((int) (x / 32), (int) (y / 32));
    }



    boolean isInSpike(double x, double y) {
        // Do the same but for spikes.
        Point top_left = getTileCoordinates(x, y);
        Point bottom_right = getTileCoordinates(x + getWidth(), y + getHeight());

        for (int y2 = (int)top_left.getY(); y2 <= (int)bottom_right.getY(); y2++) {
            for (int x2 = (int)top_left.getX(); x2 <= (int)bottom_right.getX(); x2++) {
                if (MAIN.STATE_GAMEPLAY.current_map.isSpike(x2, y2)) {
                    return true;
                }
            }
        }
        return false;
    }

    boolean onGround() {
        // Check if we're on the ground, taking into account velocity.
        if (y_velocity > 0) return false;
        return isInSolid(x, (int) (y + 4));

    }

        // TODO: this is bad and sometimes goes off when it shouldn't
        //return isInSolid(x, y + getHeight() + 1);

    double getDrawX() {
        return x + sprite_offset_x;
    }

    double getDrawY() {
        return y + sprite_offset_y;
    }

    PImage getCurrentImage() {
        return getSprites().get(animation).get(animation_index);
    }

    void draw() {
        // Draw debug rectangle of width and height
        if (DEBUG_RENDER) {
            fill(255, 0, 0);
            noStroke();
            rect((float) x, (float) y, (float) getWidth(), (float) getHeight());
        }

        if ((animation != null) && (getSprites().get(animation) != null)) {
            var current_image = getCurrentImage();
            var draw_x = getDrawX();
            var draw_y = getDrawY();
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
