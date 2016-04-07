
//NOTE Peut être serait il judicieux de créer des classes ? (genre pour le plateau et la balle) Pour rendre notre code plus modularisable et lisible...

//Constantes du programe.
final static float gravityConstant = 0.81; //une trop grand force gravitationnelle n'est pas super non plus.
final static float mu = 0.16; //ceci représente le coefficient de frottement du chêne savonné. Parce qu'à la fin du projet je veux que notre plaque soit du bois de chêne savonné.
final static float normalForce = 1;
float frictionMagnitude = mu*normalForce;

static int windowHeight = 1250;
static int windowWidth = 700;

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
static PVector location = new PVector(0, -(ballRadius + boxThick/2), 0); // position de base pour que la sphère soit sur le plateau.

//variables relatives au SHIFT
static boolean shiftKeyPressed = false;
static ArrayList<PVector> arrayCyl = new ArrayList(); 

//variables relatives au cylindre
static float cylinderBaseSize = 100;
static float cylinderHeight = 70;
static int cylinderResolution = 40;
static PShape cylinder = new PShape();
static PShape cylinderSHIFT = new PShape();
static boolean cylinderKeyPressed = false; 

void settings() {
  size(windowHeight, windowWidth, P3D);
}

void setup () {
  // création d'un cylindre (cylinder)
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  cylinder = createShape();
  cylinder.beginShape(TRIANGLE);
  //dessine le "couvercle"
  /*if(shiftKeyPressed) {
    for (int a = 0; a < x.length; a++) {
    cylinder.vertex(x[a], y[a], cylinderHeight);
    if (a + 1 >= x.length) {
      cylinder.vertex(x[0], y[0], cylinderHeight);
    } else {
      cylinder.vertex(x[a+1], y[a+1], cylinderHeight);
    }
    cylinder.vertex(0, 0, cylinderHeight);
  }
  } else {*/
    for (int a = 0; a < x.length; a++) {
    cylinder.vertex(x[a], cylinderHeight, y[a]);
    if (a + 1 >= x.length) {
      cylinder.vertex(x[0], cylinderHeight, y[0]);
    } else {
      cylinder.vertex(x[a+1], cylinderHeight, y[a+1]);
    }
    cylinder.vertex(0, cylinderHeight, 0);
  }
  //}
  
  //dessine le "bottom"
  /*if(shiftKeyPressed) {
   for (int b = 0; b < x.length; b++) {
    cylinder.vertex(x[b], y[b], 0);
    if (b + 1 >= x.length) {
      cylinder.vertex(x[0], y[0], 0);
    } else {
      cylinder.vertex(x[b+1], y[b+1], 0);
    }
    cylinder.vertex(0, 0, 0);
  } 
  } else {*/
    for (int b = 0; b < x.length; b++) {
    cylinder.vertex(x[b], 0, y[b]);
    if (b + 1 >= x.length) {
      cylinder.vertex(x[0], 0, y[0]);
    } else {
      cylinder.vertex(x[b+1], 0, y[b+1]);
    }
    cylinder.vertex(0, 0, 0);
  //}
  }
  
  //cylinder.endShape();

  //cylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  /*if(shiftKeyPressed) {
    for (int c = 0; c < x.length; c++) {
    cylinder.vertex(x[c], y[c], 0);
    cylinder.vertex(x[c], y[c], cylinderHeight);
  } 
  } else {*/
    for (int c = 0; c < x.length; c++) {
    cylinder.vertex(x[c], 0, y[c]);
    cylinder.vertex(x[c], cylinderHeight, y[c]);
  //}
  }
  
  cylinder.endShape();

  //noStroke();
  
  cylinderSHIFT = createShape();
  cylinderSHIFT.beginShape(TRIANGLE);
  //dessine le "couvercle"
    for (int a = 0; a < x.length; a++) {
    cylinderSHIFT.vertex(x[a], y[a], cylinderHeight);
    if (a + 1 >= x.length) {
      cylinderSHIFT.vertex(x[0], y[0], cylinderHeight);
    } else {
      cylinderSHIFT.vertex(x[a+1], y[a+1], cylinderHeight);
    }
    cylinderSHIFT.vertex(0, 0, cylinderHeight);
  }
  
  //dessine le "bottom"
   for (int b = 0; b < x.length; b++) {
    cylinderSHIFT.vertex(x[b], y[b], 0);
    if (b + 1 >= x.length) {
      cylinderSHIFT.vertex(x[0], y[0], 0);
    } else {
      cylinderSHIFT.vertex(x[b+1], y[b+1], 0);
    }
    cylinderSHIFT.vertex(0, 0, 0);
  } 
  //cylinder.endShape();

  //cylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
    for (int c = 0; c < x.length; c++) {
    cylinderSHIFT.vertex(x[c], y[c], 0);
    cylinderSHIFT.vertex(x[c], y[c], cylinderHeight);
  }  
  
  cylinderSHIFT.endShape();
  
  noStroke(); 
  
}

void draw() {
  background(235);
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);

  if (!shiftKeyPressed) {
    textSize(40);
    text("Angle x : " + Math.toDegrees(angleX) + "°  Angle Z : " + Math.toDegrees(angleZ) + "°  Speed : " + speed, 20, 20);
    directionalLight(50, 100, 125, 0, 1, 0);
    translate(width/2, height/2, 0);
    ambientLight(102, 102, 102);
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
    fill(255);
    box(boxWidth, boxThick, boxHeight);

    //cylinder
    for (int i = 0; i < arrayCyl.size(); i++) {
      cylinder.setFill(color(255, 204, 0));
      shape(cylinder, arrayCyl.get(i).x, arrayCyl.get(i).y);
    }
    
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

  //SHIFT
  else if (shiftKeyPressed) {
    float rectCornerX = width/2 - boxWidth/2;
    float rectCornerY = height/2 - boxHeight/2;
    fill(125);
    rect(rectCornerX, rectCornerY, boxWidth, boxHeight);
    fill(0);
    ellipse(width/2 + location.x, height/2 + location.z, 2*ballRadius, 2*ballRadius);
    translate(mouseX, mouseY, 0);
    cylinderSHIFT.setFill(color(255, 204, 0));
    shape(cylinderSHIFT);
    if (cylinderKeyPressed) {
      float x = mouseX; 
      float y = mouseY; 
      PVector v1 = new PVector(x, y); 
      arrayCyl.add(v1);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  speed = bound(speed * map(wheelCount*30, -100, 100, 0.2, 1.5), 0.2, 1.5);
}

void checkXEdges(PVector loca, PVector velo) {
  if (loca.x + ballRadius > boxWidth/2 || loca.x - ballRadius < -boxWidth/2) {
    velo.x = -velo.x;
  }
}

void checkZEdges(PVector loca, PVector velo) {
  if (loca.z + ballRadius > boxHeight/2 || loca.z - ballRadius < -boxHeight/2) {
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

    if (keyCode == SHIFT) {
      shiftKeyPressed = true;
    }
  }
}

void keyReleased() {
  shiftKeyPressed = false;
}

void mouseReleased() {
  // trouver un moyen "d'accrocher un cylindre"
  cylinderKeyPressed = false;
}

void mouseClicked() {
  cylinderKeyPressed = true;
}