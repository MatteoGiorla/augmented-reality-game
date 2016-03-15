float depth = 2000;
float speed = 1.0;
float rxSaved = 0.0;
float rzSaved = 0.0;
float mouseXSaved = 0.0;
float mouseYSaved = 0.0;
float rxImmobile = 0.0;
float rzImmobile = 0.0;

void settings() {
  size(1000, 700, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);
  background(200);
  if (mousePressed == true) {
    //probleme que c'est dnas le coin en haut a gauche, problene de detection ou on fout cette souris
    float mouseXmapped = bound(mouseX, 0, width);
    float mouseYmapped = bound(mouseY, 0, height);
    println("X :" + (mouseXmapped - bound(mouseXSaved, 0, width)));
    println("Y :" + (mouseYmapped - bound(mouseYSaved, 0, height)));
    println("Mouse X : " + mouseXmapped);
    println("Mouse Y : " + mouseYmapped);
    println("Mouse X SAVED : " + mouseXSaved);
    println("Mouse Y SAVED : " + mouseYSaved);

    float rz = map(mouseXmapped - bound(mouseXSaved, 0, width) + width/2, 0, width, (-PI/3), PI/3)*speed;
    float rx = map(mouseYmapped - bound(mouseYSaved, 0, height) + height/2, 0, height, (-PI/3), PI/3)*speed;
    rxSaved = bound(rx + rxImmobile, -PI/3, PI/3);
    rzSaved= bound(rz + rzImmobile, -PI/3, PI/3);
    rotateX(rxSaved);
    rotateZ(rzSaved);
  } else {
    rxImmobile = rxSaved;
    rzImmobile = rzSaved;
    mouseXSaved = mouseX;
    mouseYSaved = mouseY;
    rotateX(rxImmobile);
    rotateZ(rzImmobile);
  }
  box(1000, 50, 1000);
}

void mouseWheel(MouseEvent event) {
  float wheelCount;
  wheelCount = event.getCount();
  speed = bound(wheelCount, 0.2, 1.5);
}

float bound(float toBound, float lowerBound, float upperBound) {
  if (toBound > upperBound) {
    return upperBound;
  } else if (toBound < lowerBound) {
    return lowerBound;
  } else {
    return toBound;
  }
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