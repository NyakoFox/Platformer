class ErrorEntity extends Entity {

    ErrorEntity(double x, double y) {
        super("error", x, y, 84, 20);
    }

    void draw() {
        fill(255, 0, 0);
        Graphics.outlineText("ERROR", (float)x + 3, (float)y + 15);
    }
}