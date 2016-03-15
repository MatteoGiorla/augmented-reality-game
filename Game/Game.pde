
//variables globales du programme
//pourraient peut être 'etre déclarées dans le draw directement ? (Certaines en tout cas)
static float depth = 2000;
static float speed = 1.0;
static float rxSaved = 0.0;
static float rzSaved = 0.0;
static float mouseXSaved = 0.0;
static float mouseYSaved = 0.0;
static float rxImmobile = 0.0;
static float rzImmobile = 0.0;

void settings() {
  size(1000, 700, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  background(200);
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);
  
  //peut être modularisé ce bout de code dans une fonctions pour améliorer la lisibilité ? A voir...
  if (mousePressed == true) {
    float mouseXmapped = bound(mouseX, 0, width);
    float mouseYmapped = bound(mouseY, 0, height);
    float rz = map(mouseXmapped - bound(mouseXSaved, 0, width) + width/2, 0, width, (-PI/3), PI/3)*speed;
    float rx = map(mouseYmapped - bound(mouseYSaved, 0, height) + height/2, 0, height, (-PI/3), PI/3)*speed;
    rxSaved = bound(rx + rxImmobile, -PI/3, PI/3);
    rzSaved = bound(rz + rzImmobile, -PI/3, PI/3);
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

// méthode qui retourne le premier float donné en argument déléimité par deux limites également en float.
float bound(float toBound, float lowerBound, float upperBound) {
  if (toBound > upperBound) {
    return upperBound;
  } else if (toBound < lowerBound) {
    return lowerBound;
  } else {
    return toBound;
  }
}

//simple méthode permettant de déterminer quand est pressée la souris.
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}