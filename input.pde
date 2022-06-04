public static class Input {
    public static int[] KEYSTATUS = new int[256];
    public static int[] MOUSESTATUS = new int[3];

    public static void clearPressed() {
        for (int i = 0; i < KEYSTATUS.length; i++) {
            KEYSTATUS[i] = 0;
        }
        for (int i = 0; i < MOUSESTATUS.length; i++) {
            MOUSESTATUS[i] = 0;
        }
    }

    public static void onKeyPressed(int keyCode) {
        if (keyCode >= 256) return;

        if (KEYSTATUS[keyCode] <= 0) { // Ignore key repeat
            KEYSTATUS[keyCode] = 1;
        }
    }

    public static void onKeyReleased(int keyCode) {
        if (keyCode >= 256) return;

        KEYSTATUS[keyCode] = -1;
    }

    public static void onMousePressed(int mouseButton) {
        // oops this version of java doesn't have enhanced switches
        int button = -1;
        if (mouseButton == LEFT) button = 0;
        if (mouseButton == RIGHT) button = 1;
        if (mouseButton == CENTER) button = 2;
        if (button == -1) return;

        MOUSESTATUS[button] = 1;
    }

    public static void onMouseReleased(int mouseButton) {
        int button = -1;
        if (mouseButton == LEFT) button = 0;
        if (mouseButton == RIGHT) button = 1;
        if (mouseButton == CENTER) button = 2;
        if (button == -1) return;

        MOUSESTATUS[button] = -1;
    }

    public static int getKeyStatus(String key) {
        int keyCode = (int) key.charAt(0);
        switch (key) {
            case "left":   keyCode = 37; break;
            case "right":  keyCode = 39; break;
            case "up":     keyCode = 38; break;
            case "down":   keyCode = 40; break;
            case "space":  keyCode = 32; break;
            case "escape": keyCode = 27; break;
            case "tab":    keyCode = 9;  break;
            case "shift":  keyCode = 16; break;
            case "ctrl":   keyCode = 17; break;
            case "alt":    keyCode = 18; break;
            case "enter":  keyCode = 10; break; // ???? Why is this 10?? The keycode for enter is 13
        }

        if (keyCode >= 256) return 0;
        return KEYSTATUS[keyCode];
    }

    public static boolean mouseDown(int button) {
        return MOUSESTATUS[button] >= 1;
    }

    public static boolean mouseUp(int button) {
        return MOUSESTATUS[button] <= 0;
    }

    public static boolean mousePressed(int button) {
        return MOUSESTATUS[button] == 1;
    }

    public static boolean mouseReleased(int button) {
        return MOUSESTATUS[button] == -1;
    }

    public static boolean down(String key) {
        return getKeyStatus(key) >= 1;
    }

    public static boolean pressed(String key) {
        return getKeyStatus(key) == 1;
    }

    public static boolean released(String key) {
        return getKeyStatus(key) == -1;
    }

    public static boolean up(String key) {
        return getKeyStatus(key) <= 0;
    }

    public static void changeKeys() {
        for (int i = 0; i < KEYSTATUS.length; i++) {
            if (KEYSTATUS[i] == 1) {
                KEYSTATUS[i] = 2;
            }
            if (KEYSTATUS[i] == -1) {
                KEYSTATUS[i] = 0;
            }
        }
        for (int i = 0; i < MOUSESTATUS.length; i++) {
            if (MOUSESTATUS[i] == 1) {
                MOUSESTATUS[i] = 2;
            }
            if (MOUSESTATUS[i] == -1) {
                MOUSESTATUS[i] = 0;
            }
        }
    }
}
