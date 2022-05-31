class Input {
    int[] keyStatus = new int[256];
    int[] mouseStatus = new int[3];

    void clearPressed() {
        for (int i = 0; i < keyStatus.length; i++) {
            keyStatus[i] = 0;
        }
        for (int i = 0; i < mouseStatus.length; i++) {
            mouseStatus[i] = 0;
        }
    }

    void keyPressed() {
        if (keyCode >= 256) return;

        if (keyStatus[keyCode] <= 0) { // Ignore key repeat
            keyStatus[keyCode] = 1;
        }
    }

    void keyReleased() {
        if (keyCode >= 256) return;

        keyStatus[keyCode] = -1;
    }

    void mousePressed() {
        // oops this version of java doesn't have enhanced switches
        int button = -1;
        if (mouseButton == LEFT) button = 0;
        if (mouseButton == RIGHT) button = 1;
        if (mouseButton == CENTER) button = 2;
        if (button == -1) return;

        mouseStatus[button] = 1;
    }

    void mouseReleased() {
        int button = -1;
        if (mouseButton == LEFT) button = 0;
        if (mouseButton == RIGHT) button = 1;
        if (mouseButton == CENTER) button = 2;
        if (button == -1) return;

        mouseStatus[button] = -1;
    }

    int getKeyStatus(String key) {
        int keyCode = (int) key.charAt(0);
        switch (key) {
            case "left":   keyCode = 37; break;
            case "right":  keyCode = 39; break;
            case "up":     keyCode = 38; break;
            case "down":   keyCode = 40; break;
            case "space":  keyCode = 32; break;
            case "enter":  keyCode = 13; break;
            case "escape": keyCode = 27; break;
            case "tab":    keyCode = 9;  break;
            case "shift":  keyCode = 16; break;
            case "ctrl":   keyCode = 17; break;
            case "alt":    keyCode = 18; break;
        }

        if (keyCode >= 256) return 0;
        return keyStatus[keyCode];
    }

    boolean mouseDown(int button) {
        return mouseStatus[button] >= 1;
    }

    boolean mouseUp(int button) {
        return mouseStatus[button] <= 0;
    }

    boolean mousePressed(int button) {
        return mouseStatus[button] == 1;
    }

    boolean mouseReleased(int button) {
        return mouseStatus[button] == -1;
    }

    boolean down(String key) {
        return getKeyStatus(key) >= 1;
    }

    boolean pressed(String key) {
        return getKeyStatus(key) == 1;
    }

    boolean released(String key) {
        return getKeyStatus(key) == -1;
    }

    boolean up(String key) {
        return getKeyStatus(key) <= 0;
    }

    void changeKeys() {
        for (int i = 0; i < keyStatus.length; i++) {
            if (keyStatus[i] == 1) {
                keyStatus[i] = 2;
            }
            if (keyStatus[i] == -1) {
                keyStatus[i] = 0;
            }
        }
        for (int i = 0; i < mouseStatus.length; i++) {
            if (mouseStatus[i] == 1) {
                mouseStatus[i] = 2;
            }
            if (mouseStatus[i] == -1) {
                mouseStatus[i] = 0;
            }
        }
    }
}
