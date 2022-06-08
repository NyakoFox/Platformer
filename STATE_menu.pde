class MenuState {
    int selected_option;
    PImage logo;
    int timer;
    boolean selected;

    MenuState() {
        selected_option = 0;
        logo = loadImage("logo.png");
        timer = 0;
        selected = false;
    }

    void enter() {
    }

    void update() {
        if (selected) {
            timer++;
            if (timer > 30) {
                switch (selected_option) {
                    case 0:
                        fadeIn();
                        enterState(GameStates.GAMEPLAY);
                        break;
                    case 1:
                        fadeIn();
                        enterState(GameStates.EDITOR);
                        break;
                    case 2:
                        exit();
                        break;
                }
            }
            return;
        }

        if (Input.pressed("down") || Input.pressed("right")) {
            Registry.playSound("menumove");
            selected_option++;
            if (selected_option > 2) {
                selected_option = 0;
            }
        }
        if (Input.pressed("up") || Input.pressed("left")) {
            Registry.playSound("menumove");
            selected_option--;
            if (selected_option < 0) {
                selected_option = 2;
            }
        }

        if (Input.pressed("Z")) {
            Registry.playSound("menuselect");
            selected = true;
            fadeOut();
        }
    }

    // Draw
    void draw() {
        // Clear the canvas
        background(29, 33, 45);
        fill(255);
        Graphics.outlineText("(C) Nyakorita 2022", 16, 32);

        image(logo, 92, 96);

        int menu_x = 162 + 64 - 32;
        int menu_y = 240;
        // Draw options
        Graphics.outlineText("Play",         menu_x + 32, menu_y + 32);
        Graphics.outlineText("Level Editor", menu_x + 32, menu_y + 64);
        Graphics.outlineText("Quit",         menu_x + 32, menu_y + 96);

        // Draw cursor
        Graphics.outlineText(">", menu_x, menu_y + 32 + (selected_option * 32));

        Graphics.outlineText("Arrow keys to select", 162, 480 - 96);
        Graphics.outlineText("Press [Z] to confirm", 161, 480 - 64);

        Graphics.outlineText("https://github.com/NyakoFox/Platformer", 162, 480 - 32);
    }
}
