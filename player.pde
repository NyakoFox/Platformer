import java.util.Random;

class Player extends Entity {

    double walking_speed = 5;
    double current_walk_speed = 0;
    double walking_acceleration = 0.5;
    double ground_deceleration = 0.5;
    boolean squishing = false;
    double checkpoint_x = 0;
    double checkpoint_y = 0;
    int coyote_time = 0;
    String checkpoint_map = "";
    boolean dying = false;
    int death_timer = 0;
    int death_angle = 0;
    double death_speed = 0;

    Player(double x, double y) {
        super("player", x, y, 10, 24);

        sprite_offset_x = -6;
        sprite_offset_y = -14;

        registerAnimationSpeed("idle", 0.05);
        registerAnimationSpeed("squish", 0.25);
        registerAnimationSpeed("walk", 0.1);
        registerAnimationSpeed("explode", 0.5);

        setAnimation("idle");

        enableGravity(true);
    }

    void onInitialAdd() {
        setCheckpoint(x, y);
    }

    void setCheckpoint() {
        checkpoint_x = x;
        checkpoint_y = y;
    }

    void setCheckpoint(double x, double y) {
        checkpoint_x = x;
        checkpoint_y = y;
        checkpoint_map = map.name;
    }

    void gotoCheckpoint() {
        x = checkpoint_x;
        y = checkpoint_y;
        x_velocity = 0;
        y_velocity = 0;
        MAIN.STATE_GAMEPLAY.switchMap(checkpoint_map);
    }

    void jump() {
        float min = 0.95;
        float max = 1.05;
        float random = min + (new Random()).nextFloat() * (max - min);
        Registry.playSound("jump", 1, random);
        addVelocity(0, -8);
        if ((y_velocity < -8) && coyote_time > 0) {
            y_velocity = -8;
        }
    }

    void kill() {
        if (!dying) {
            dying = true;
            death_timer = 0;

            squishing = false;

            // Get angle of velocity
            int old_angle = (int) Math.round(Math.toDegrees(Math.atan2(y_velocity, x_velocity)));
            // Set death_angle to the opposite direction
            death_angle = (old_angle + 180) % 360;

            death_speed = 5.5;

            Registry.playSound("death");
            setAnimation("death");
        }
    }

    void update() {
        if (dying) {
            noclip = true;
            enableGravity(false);

            // Move player by the angle of death_angle, and speed of death_speed
            x += Math.cos(Math.toRadians(death_angle)) * death_speed;
            y += Math.sin(Math.toRadians(death_angle)) * death_speed;

            death_speed = Double.max(death_speed - 0.25, 0);

            x_velocity = 0;
            y_velocity = 0;

            death_timer++;

            if (death_timer == 20) {
                death_speed = 0;
                sprite_offset_x = -90;
                sprite_offset_y = -120;
                Registry.stopSound("death");
                Registry.playSound("explosion");
                setAnimation("explode");
            }
            if (death_timer == 30) {
                MAIN.fadeOut();
            }
            if (death_timer > 60) {
                MAIN.fadeIn();
                noclip = false;
                enableGravity(true);
                sprite_offset_x = -6;
                sprite_offset_y = -14;
                setAnimation("idle");
                dying = false;
                death_timer = 0;
                gotoCheckpoint();
            }
            super.update();
            return;
        }

        if (Input.pressed("R")) {
            kill();
            return;
        }

        // Jump if we're on the ground
        // Or if we WERE in the past 6 frames (coyote time)
        if (onGround()) coyote_time = 6;

        if (coyote_time > 0) coyote_time--;
        if (Input.pressed("Z")) {
            if (coyote_time > 0) {
                jump();
            }
        }

        double horizontal_speed_cap = walking_speed;

        if (Input.down("left")) {
            if (onGround()) flipped = true;
		    // If you're holding left, and you're not already at max walking speed...
		    if ((x_velocity) > -horizontal_speed_cap) {
		    	// Make them walk faster
		    	x_velocity -= walking_acceleration;
		    }
    	} else {
    		// Otherwise, if you're not holding left, slow them down if they're on the ground...
    		if ((x_velocity < 0) && onGround()) {
    			x_velocity += ground_deceleration;
    			// But make sure we don't send them in the other direction.
    			if (x_velocity > 0) x_velocity = 0;
    		}
    	}

    	if (Input.down("right")) {
            if (onGround()) flipped = false;
    		// If you're holding right, and you're not already at max walking speed...
    		if ((x_velocity) < horizontal_speed_cap) {
    			// Make them walk faster
    			x_velocity += walking_acceleration;
    		}
    	} else {
    		// Otherwise, if you're not holding right, slow them down if they're on the ground...
    		if ((x_velocity > 0) && onGround()) {
    			x_velocity -= ground_deceleration;
    			// But make sure we don't send them in the other direction.
    			if (x_velocity < 0) x_velocity = 0;
    		}
    	}

        boolean wasOnGround = onGround();
        super.update();

        if (x + width > MAIN.STATE_GAMEPLAY.current_map.real_width) {
            x -= MAIN.STATE_GAMEPLAY.current_map.real_width;
            if (!MAIN.STATE_GAMEPLAY.current_map.connected_right.equals("")) {
                y += MAIN.STATE_GAMEPLAY.current_map.connected_right_offset * 32;
                MAIN.STATE_GAMEPLAY.switchMap(MAIN.STATE_GAMEPLAY.current_map.connected_right);
                // Loop through the map entities and find the closest checkpoint to the left side of the screen
                double closest_distance = Double.MAX_VALUE;
                for (MapEntity entity : MAIN.STATE_GAMEPLAY.current_map.entities) {
                    if (entity instanceof CheckpointMapEntity) {
                        // Distance from the left side of the screen to the checkpoint
                        double distance = entity.x;
                        if (distance < closest_distance) {
                            closest_distance = distance;
                            checkpoint_x = entity.x;
                            checkpoint_y = entity.y;
                            checkpoint_map = MAIN.STATE_GAMEPLAY.current_map.name;
                        }
                    }
                }
            } else {
                setCheckpoint();
            }
        }

        if (x + width < 0) {
            if (!MAIN.STATE_GAMEPLAY.current_map.connected_left.equals("")) {
                y += MAIN.STATE_GAMEPLAY.current_map.connected_left_offset * 32;
                MAIN.STATE_GAMEPLAY.switchMap(MAIN.STATE_GAMEPLAY.current_map.connected_left);
                // Loop through the map entities and find the closest checkpoint to the right side of the screen
                double closest_distance = Double.MAX_VALUE;
                for (MapEntity entity : MAIN.STATE_GAMEPLAY.current_map.entities) {
                    if (entity instanceof CheckpointMapEntity) {
                        // Distance from the right side of the screen to the checkpoint
                        double distance = MAIN.STATE_GAMEPLAY.current_map.real_width - entity.x - entity.width;
                        if (distance < closest_distance) {
                            closest_distance = distance;
                            checkpoint_x = entity.x;
                            checkpoint_y = entity.y;
                            checkpoint_map = MAIN.STATE_GAMEPLAY.current_map.name;
                        }
                    }
                }
            } else {
                setCheckpoint();
            }
            x += MAIN.STATE_GAMEPLAY.current_map.real_width;
        }

        if (y + height > MAIN.STATE_GAMEPLAY.current_map.real_height) {
            y -= MAIN.STATE_GAMEPLAY.current_map.real_height;
            if (!MAIN.STATE_GAMEPLAY.current_map.connected_down.equals("")) {
                x += MAIN.STATE_GAMEPLAY.current_map.connected_down_offset * 32;
                MAIN.STATE_GAMEPLAY.switchMap(MAIN.STATE_GAMEPLAY.current_map.connected_down);
                // Loop through the map entities and find the closest checkpoint to the top of the screen
                double closest_distance = Double.MAX_VALUE;
                for (MapEntity entity : MAIN.STATE_GAMEPLAY.current_map.entities) {
                    if (entity instanceof CheckpointMapEntity) {
                        // Distance from the top of the screen to the checkpoint
                        double distance = entity.y;
                        if (distance < closest_distance) {
                            closest_distance = distance;
                            checkpoint_x = entity.x;
                            checkpoint_y = entity.y;
                            checkpoint_map = MAIN.STATE_GAMEPLAY.current_map.name;
                        }
                    }
                }
            } else {
                setCheckpoint();
            }
        }

        if (y + height < 0) {
            if (!MAIN.STATE_GAMEPLAY.current_map.connected_up.equals("")) {
                x += MAIN.STATE_GAMEPLAY.current_map.connected_up_offset * 32;
                MAIN.STATE_GAMEPLAY.switchMap(MAIN.STATE_GAMEPLAY.current_map.connected_up);
                // Loop through the map entities and find the closest checkpoint to the bottom of the screen
                double closest_distance = Double.MAX_VALUE;
                for (MapEntity entity : MAIN.STATE_GAMEPLAY.current_map.entities) {
                    if (entity instanceof CheckpointMapEntity) {
                        // Distance from the bottom of the screen to the checkpoint
                        double distance = MAIN.STATE_GAMEPLAY.current_map.real_height - entity.y - entity.height;
                        if (distance < closest_distance) {
                            closest_distance = distance;
                            checkpoint_x = entity.x;
                            checkpoint_y = entity.y;
                            checkpoint_map = MAIN.STATE_GAMEPLAY.current_map.name;
                        }
                    }
                }
            } else {
                setCheckpoint();
            }
            y += MAIN.STATE_GAMEPLAY.current_map.real_height;
        }

        if (!wasOnGround && onGround()) {
            squishing = true;
            setAnimation("squish");
        }

        updateAnimation();

        // Check for collisions using AABB and getWidth/getHeight
        for (Entity entity : MAIN.STATE_GAMEPLAY.entities) {
            if (entity == this) continue;
            double x = entity.x;
            double y = entity.y;
            double w = entity.getWidth();
            double h = entity.getHeight();
            // AABB
            if (this.x < x + w && this.x + this.getWidth() > x && this.y < y + h && this.y + this.getHeight() > y) {
                // Collision!
                entity.onCollision(this);
            }
        }

        if (isInSpike(x, y)) {
            kill();
        }
    }

    void draw() {
        tint(255, 255, 255);

        if (animation == "walk") {
            ArrayList<PImage> sprites = Registry.SPRITES.get("player").get("runfire");
            PImage sprite = sprites.get((frameCount / 8) % sprites.size());
            if (!flipped) {
                image(sprite, (float)x - 24, (float)y + 28, 16, 16);
            } else {
                pushMatrix();
                translate((float)x + sprite.width, (float)y + 28);
                scale(-1,1);
                image(sprite, - ((float)(width * 2) + 16), 0, 16, 16);
                popMatrix();
                //image(sprite, (float)(x + (width * 2) + 22), (float)y + 28, -16, 16);
            }
        }

        if (dying && (animation != "explode")) {
            tint(255, 0, 0);
        }
        super.draw();
        tint(255, 255, 255);
    }

    void updateAnimation() {
        if (!squishing) {
            if (!onGround()) {
                if (y_velocity < 0) {
                    setAnimation("jump");
                } else {
                    setAnimation("fall");
                }
            } else if (x_velocity > 0) {
                setAnimation("walk");
            } else if (x_velocity < 0) {
                setAnimation("walk");
            } else {
                setAnimation("idle");
            }
        }
    }

    void animationLooped(String animation) {
        if (animation.equals("squish")) {
            squishing = false;
        }
        if (animation.equals("explode")) {
            setAnimation(null);
        }
    }
}