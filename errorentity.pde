class ErrorEntity extends Entity {

    ErrorEntity(double x, double y) {
        super("error", x, y, 15, 15);
    }

    void draw() {
        fill(255, 0, 0);
        GRAPHICS.outlineText("ERROR", (float)x, (float)y);
    }
}