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

    Player(double x, double y) {
        super("player", x, y, 12, 10);

        sprite_offset_x = -4;
        sprite_offset_y = -10;

        registerAnimationSpeed("idle", 0.05);
        registerAnimationSpeed("squish", 0.25);
        registerAnimationSpeed("walk", 0.25);

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
        game.switchMap(checkpoint_map);
    }

    void jump() {
        addVelocity(0, -8);
        if ((y_velocity < -8) && coyote_time > 0) {
            y_velocity = -8;
        }
    }

    void update() {
        // Jump if we're on the ground
        // Or if we WERE in the past 6 frames (coyote time)
        if (onGround()) coyote_time = 6;

        if (coyote_time > 0) coyote_time--;
        if (input.pressed("Z")) {
            if (coyote_time > 0) {
                jump();
            }
        }

        double horizontal_speed_cap = walking_speed;

        if (input.down("left")) {
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

    	if (input.down("right")) {
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

        if (x + width > game.current_map.real_width) {
            if (!game.current_map.connected_right.equals("")) {
                y += game.current_map.connected_right_offset * 32;
                game.switchMap(game.current_map.connected_right);
            }
            x -= game.current_map.real_width;
        }

        if (x + width < 0) {
            if (!game.current_map.connected_left.equals("")) {
                y += game.current_map.connected_left_offset * 32;
                game.switchMap(game.current_map.connected_left);
            }
            x += game.current_map.real_width;
        }

        if (y + height > game.current_map.real_height) {
            if (!game.current_map.connected_down.equals("")) {
                x += game.current_map.connected_down_offset * 32;
                game.switchMap(game.current_map.connected_down);
            }
            y -= game.current_map.real_height;
        }

        if (y + height < 0) {
            if (!game.current_map.connected_up.equals("")) {
                x += game.current_map.connected_up_offset * 32;
                game.switchMap(game.current_map.connected_up);
            }
            y += game.current_map.real_height;
        }

        if (!wasOnGround && onGround()) {
            squishing = true;
            setAnimation("squish");
        }

        updateAnimation();

        // Check for collisions using AABB and getWidth/getHeight
        for (Entity entity : game.entities) {
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
    }
}