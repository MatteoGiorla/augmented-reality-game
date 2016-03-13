float depth = 2000;

void settings() {
  size(500, 500, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);
  float rz = map(mouseY, 0, height, 0, PI/3);
  float rx = map(mouseX, 0, width, 0, PI/3);
  rotateZ(rz);
  rotateX(rx);
  box(1000, 1000, 50);
}

float mouseWheel(MouseEvent event) {
  float e = event.getCount();
  return e;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}
