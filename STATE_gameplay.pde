class GameplayState {
    ArrayList<Entity> entities;
    Player player;
    Map current_map;

    PShader shader_ripple;
    float ripple_timer;

    float floppy_x;
    float floppy_y;
    float floppy_bounce;
    int   floppy_timer;

    double camera_x;
    double camera_y;
    double camera_left;
    double camera_right;
    double camera_top;
    double camera_bottom;

    boolean playtesting;

    Flags flags;

    GameplayState() {
        flags = new Flags();

        // Shader setup for the ripple effect
        shader_ripple = loadShader("ripple.glsl");
        shader_ripple.set("time", 0.0f);
        shader_ripple.set("center", 0.5, 0.5);
        shader_ripple.set("shockParams", 10f, 0.8f, 0.1f);

        // Ripple effect state variables
        ripple_timer = -1f;
        floppy_x = 0f;
        floppy_y = 0f;
        floppy_bounce = 0f;
        floppy_timer = -1;

        camera_x = 0;
        camera_y = 0;
        camera_left = 0;
        camera_right = 0;
        camera_top = 0;
        camera_bottom = 0;

        playtesting = false;

        entities = new ArrayList<>();
    }

    void enter(String map) {
        current_map = loadMap(map);
        createPlayer();
        loadMapEntities();
        player.onInitialAdd();
    }

    void enterPlaytesting(String map) {
        enter(map);
        playtesting = true;
        // Update is already done at this point so we need to do it manually
        updateCamera();
    }

    void doRippleEffect(double x, double y) {
        // The ripple effect is active as long as the timer isn't -1
        ripple_timer = 0f;
        shader_ripple.set("center", (float)((x - camera_left) / width), (float)((y - camera_top) / height));
    }

    void createPlayer() {
        if (player == null) {
            player = new Player(current_map.getStartX(), current_map.getStartY()); // Make a new player in the center
        }
        addToWorld(player);
    }

    void addToWorld(Entity entity) {
        entity.map = current_map;
        entities.add(entity);
        entity.onAdd();
    }

    void loadMapEntities() {
        // Load all entities from the map
        for (MapEntity data : current_map.entities) {
            Entity entity = data.createEntity();
            if (entity != null) {
                addToWorld(entity);
            }
        }
    }

    Map loadMap(String name) {
        entities.clear(); // Clear the entity list

        // Load the map
        return Registry.MAPS.get(name);
    }

    void unloadMap() {
        entities.clear();
        current_map = null;
    }

    void switchMap(String name) {
        unloadMap();
        current_map = loadMap(name);
        addToWorld(player);
        loadMapEntities();
    }

    void switchMap(Map map) {
        unloadMap();
        current_map = map;
        addToWorld(player);
    }

    Player getPlayer() {
        return player;
    }

    void updateCamera() {
        camera_x = player.x;
        camera_y = player.y;
        // Make camera be in bounds
        if (camera_x < 320) {
            camera_x = 320;
        }
        if (camera_y < 240) {
            camera_y = 240;
        }
        if (camera_x > current_map.real_width - 320) {
            camera_x = current_map.real_width - 320;
        }
        if (camera_y > current_map.real_height - 240) {
            camera_y = current_map.real_height - 240;
        }

        camera_left = camera_x - 320;
        camera_right = camera_x + 320;
        camera_top = camera_y - 240;
        camera_bottom = camera_y + 240;
    }

    void update() {
        // Loop through all entities and run their logic.
        for (int i = 0; i < entities.size(); i++) {
            entities.get(i).update();
        }

        if (Input.pressed("R")) {
            player.gotoCheckpoint();
            updateCamera();
            return;
        }

        if (Input.pressed("enter")) {
            MAIN.exitPlaytesting();
            return;
        }

        updateCamera();
    }

    void applyCameraTransform() {
        // The coordinates will be the center of the viewpoint
        translate((float) -camera_x + 320, (float) -camera_y + 240);
    }

    // Draw
    void draw() {
        // Clear the canvas
        background(28, 32, 44);

        Tileset tileset = current_map.tileset;

        // Drawn in world-space:
        pushMatrix();
        applyCameraTransform();
        // Draw the map
        current_map.draw();

        // Loop through all entities and draw them
        // In reverse so the player is on the top
        for (int i = entities.size() - 1; i >= 0; i--) {
            Entity entity = entities.get(i);
            if (entity.visible) {
                entity.draw();
            }
        }

        DEBUG_RENDER = false;
        if (Input.down("shift")) {
            DEBUG_RENDER = true;
            // Draw all collision tiles as red outlines
            for (int y = 0; y < current_map.height; y++) {
                for (int x = 0; x < current_map.width; x++) {
                    if (current_map.collision[y][x]) {
                        noFill();
                        stroke(255, 0, 0);
                        strokeWeight(2);
                        rect(x * 32, y * 32, 32, 32);
                    }
                }
            }
        }

        popMatrix();

        // Drawn in screen-space:

        fill(255);
        if (playtesting) {
            GRAPHICS.outlineText("Press ENTER to return to editor", 16, 32);
        }
        GRAPHICS.outlineText("FPS: " + frameRate, 16, 64 + 16);

        // HUD

        drawFloppyDisplay();

        // Handle the ripple shader

        // Update ripple effect

        drawRippleEffect();
    }

    void drawFloppyDisplay() {
        // Handle the floppy disk display
        // Note: while this animation code is horrible,
        // I won't have to touch it for a while,
        // so future me can worry about that

        if (floppy_timer >= 0) {
            int base_floppy_y = 480 - 32;

            if (floppy_timer == 0) {
                floppy_bounce = -4;
                floppy_x = 32;
                floppy_y = base_floppy_y;
            }

            if (floppy_timer > 80) {
                floppy_x -= (floppy_timer - 80) / 2;
            }

            if (floppy_timer > 160) {
                floppy_timer = -1;
                return;
            }

            floppy_bounce += 0.5f;
            floppy_timer++;
            floppy_y += floppy_bounce;
            if (floppy_y > base_floppy_y) floppy_y = base_floppy_y;

            fill(255);
            var sprites = Registry.SPRITES.get("floppy").get("idle");
            image(sprites.get((frameCount / 8) % sprites.size()), (int) floppy_x, floppy_y - 16, 32, 32);
            GRAPHICS.outlineText(" - " + flags.getInteger("floppies"), (int) floppy_x + 32, base_floppy_y);
        }
    }

    void drawRippleEffect() {
        if (!(ripple_timer < 0f)) {
            ripple_timer += 1f/60f;
        }

        if (ripple_timer > 1.5f) {
            ripple_timer = -1f;
        }

        boolean ripple_active = (ripple_timer > 0) && (ripple_timer < 1.5);

        if (ripple_active) {
            // WE DON'T WANT TO SHOW THE SHADER WHEN IT'S NOT NEEDED.
            // IT'S EXTREMELY SLOW.
            shader_ripple.set("time", ripple_timer);
            shader_ripple.set("tex0", get());
            filter(shader_ripple);
        }
    }
}
