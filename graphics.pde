public static class Graphics {
    public static platformer MAIN;
    public static PFont FONT;

    public static void init(platformer main) {
        MAIN = main;
    }

    public static void setFont(PFont font) {
        FONT = font;
    }

    public static void outlineText(String text, float x, float y) {
        int fillColor = MAIN.g.fillColor;
        MAIN.textFont(FONT, 16);

        MAIN.fill(0, 0, 0, MAIN.alpha(fillColor));
        MAIN.text(text, x - 2, y    );
        MAIN.text(text, x + 2, y    );
        MAIN.text(text, x,     y - 2);
        MAIN.text(text, x,     y + 2);

        MAIN.fill(fillColor);
        MAIN.text(text, x, y);
    }
}
