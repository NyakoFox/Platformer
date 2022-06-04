class Graphics {
    public void outlineText(String text, float x, float y) {
        int fillColor = g.fillColor;
        textFont(font, 16);

        fill(0, 0, 0);
        text(text, x - 2, y    );
        text(text, x + 2, y    );
        text(text, x,     y - 2);
        text(text, x,     y + 2);

        fill(fillColor);
        text(text, x, y);
    }
}
