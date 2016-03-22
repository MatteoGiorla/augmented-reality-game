
//NOTE Peut être serait il judicieux de créer des classes ? (genre pour le plateau et la balle) Pour rendre notre code plus modularisable et lisible...

//Constantes du programe.
final static float gravityConstant = 0.81; //une trop grand force gravitationnelle n'est pas super non plus.
final static float mu = 0.16; //ceci représente le coefficient de frottement du chêne savonné. Parce qu'à la fin du projet je veux que notre plaque soit du bois de chêne savonné.
final static float normalForce = 1;
float frictionMagnitude = mu*normalForce;

//variables globales du programme
//pourraient peut être 'etre déclarées dans le draw directement ? (Certaines en tout cas)

//variablesde la caméra.
static float depth = 2000;

//variables relatives à la plaque et son déplacement.
static float mouseXSaved = 0.0;
static float mouseYSaved = 0.0;
static float rxImmobile = 0.0;
static float rzImmobile = 0.0;
static float angleX = 0.0;
static float angleZ = 0.0;
static float speed = 1.0;
static final float boxWidth = 1500; // valeur qui sé'tend sur l'axe des x
static final float boxThick =  50; // valeur qui s'étend sur l'axe des y
static final float boxHeight = 1500; // valeur qui s'étend sur l'axe des z
static final  float ballRadius = 50;

//variables relatives à la balle.
static PVector gravityForce = new PVector(0, 0, 0);
static PVector velocity = new PVector(0, 0, 0);
static PVector location = new PVector(0, -(ballRadius + boxThick/2) , 0); // location de base pour que la sphère soit sur le plateau.

void settings() {
  size(1250, 700, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  background(235);
  textSize(40);
  text("Angle x : " + Math.toDegrees(angleX) + "°  Angle Z : " + Math.toDegrees(angleZ) + "°  Speed : " + speed, 20, 20);
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);

  //peut être modularisé ce bout de code dans une fonctions pour améliorer la lisibilité ? A voir...
  if (mousePressed == true) {
    float mouseXmapped = bound(mouseX, 0, width);
    float mouseYmapped = bound(mouseY, 0, height);
    float rz = map(mouseXmapped - bound(mouseXSaved, 0, width) + width/2, 0, width, (-PI/3), PI/3)*speed;
    float rx = map(mouseYmapped - bound(mouseYSaved, 0, height) + height/2, 0, height, (-PI/3), PI/3)*speed;
    angleX = bound(rx + rxImmobile, -PI/3, PI/3);
    angleZ = bound(rz + rzImmobile, -PI/3, PI/3);
    rotateX(-angleX);
    rotateZ(angleZ);
  } else {        
    rxImmobile = angleX;
    rzImmobile = angleZ;

    mouseXSaved = mouseX;
    mouseYSaved = mouseY;
    rotateX(-rxImmobile);
    rotateZ(rzImmobile);
  }
  box(boxWidth, boxThick, boxHeight);
  translate(location.x, location.y, location.z); 
  sphere(ballRadius);

  //friction
  PVector friction = velocity.copy();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);

  //gravity
  gravityForce.x = sin(angleZ) * gravityConstant;
  gravityForce.z = sin(angleX) * gravityConstant;

  velocity.add(friction);
  velocity.add(gravityForce);
  checkXEdges(location, velocity);
  checkZEdges(location, velocity);
  location.add(velocity);
  
}

void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  speed = bound(speed * map(wheelCount*30,-100, 100, 0.2, 1.5), 0.2, 1.5);
}

void checkXEdges(PVector loca, PVector velo){
  if(loca.x + ballRadius > boxWidth/2 || loca.x - ballRadius < -boxWidth/2){
       velo.x = -velo.x;
  }
}

void checkZEdges(PVector loca, PVector velo){
  if(loca.z + ballRadius > boxHeight/2 || loca.z - ballRadius < -boxHeight/2){
       velo.z = -velo.z;
  }
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