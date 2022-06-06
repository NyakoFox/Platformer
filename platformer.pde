boolean DEBUG = true;
boolean DEBUG_RENDER = false;

PFont FONT;

enum GameStates {
    MENU,
    GAMEPLAY,
    EDITOR,
    PAUSED,
    OPTIONS,
    CREDITS
}

GameStates STATE = GameStates.MENU;

GameplayState STATE_GAMEPLAY;
EditorState STATE_EDITOR;

platformer MAIN = this;

void setup() {
    FONT = createFont("pcsenior.ttf", 16, false);
    // Resize the screen to my favorite resolution (640x480)
    // Also set the renderer to P2D so I can use shaders
    size(640, 480, P2D);
    surface.setTitle("Platforming");
    surface.setResizable(false);
    Graphics.init(this);
    Graphics.setFont(FONT);
    Registry.loadAssets(sketchPath(), this);
    frameRate(60);
    loop();
    noSmooth();
    background(0);
    // Since we're using P2D, we need to set the texture sampling to POINT which is 2
    // Just so everything isn't blurry
    // It defaults to 5 which is trilinear which makes the game look really bad
    ((PGraphicsOpenGL)g).textureSampling(2);

    enterState(GameStates.EDITOR);
}

void draw() {
    // Run logic
    updateStates();
    // Draw
    drawStates();
    // Modify key states
    Input.changeKeys();
}

void enterPlaytesting() {
    // Don't remove STATE_EDITOR, we'll go back to it later
    STATE_GAMEPLAY = new GameplayState();
    STATE = GameStates.GAMEPLAY;
    STATE_GAMEPLAY.enterPlaytesting(STATE_EDITOR.current_map.name);
}

void exitPlaytesting() {
    // Go back to the (still active) editor
    STATE = GameStates.EDITOR;
    STATE_EDITOR.switchMap(STATE_GAMEPLAY.current_map.name);
    STATE_EDITOR.camera_x = STATE_GAMEPLAY.camera_x;
    STATE_EDITOR.camera_y = STATE_GAMEPLAY.camera_y;
    // And clean up the gameplay state
    STATE_GAMEPLAY = null;
}

void enterState(GameStates new_state) {
    // Hand these off to the garbage collector if they exist
    STATE_GAMEPLAY = null;
    STATE_EDITOR = null;

    // Set the new state
    switch (new_state) {
        case MENU:
            break;
        case GAMEPLAY:
            STATE_GAMEPLAY = new GameplayState();
            STATE_GAMEPLAY.enter("start");
            break;
        case EDITOR:
            STATE_EDITOR = new EditorState();
            STATE_EDITOR.enter();
            break;
        case PAUSED:
            break;
        case OPTIONS:
            break;
        case CREDITS:
            break;
    }
    STATE = new_state;
}

// Call the functions in input
void keyPressed()    { Input.onKeyPressed(keyCode);        }
void keyReleased()   { Input.onKeyReleased(keyCode);       }
void mousePressed()  { Input.onMousePressed(mouseButton);  }
void mouseReleased() { Input.onMouseReleased(mouseButton); }

void updateStates() {
    switch (STATE) {
        case MENU:
            break;
        case GAMEPLAY:
            STATE_GAMEPLAY.update();
            break;
        case PAUSED:
            break;
        case EDITOR:
            STATE_EDITOR.update();
            break;
        case OPTIONS:
            break;
        case CREDITS:
            break;
    }
}

// Draw
void drawStates() {
    // Clear the canvas
    background(29, 33, 45);

    switch (STATE) {
        case MENU:
            break;
        case GAMEPLAY:
            STATE_GAMEPLAY.draw();
            break;
        case PAUSED:
            break;
        case EDITOR:
            STATE_EDITOR.draw();
            break;
        case OPTIONS:
            break;
        case CREDITS:
            break;
    }
}
