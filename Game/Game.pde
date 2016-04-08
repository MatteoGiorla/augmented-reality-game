
//NOTE Peut être serait il judicieux de créer des classes ? (genre pour le plateau et la balle) Pour rendre notre code plus modularisable et lisible...

static int windowHeight = 1250;
static int windowWidth = 700;

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

Mover mover = new Mover();

//variables relatives au SHIFT
static boolean shiftKeyPressed = false;
static ArrayList<PVector> arrayCyl = new ArrayList(); 

//variables relatives au cylindre
static float cylinderBaseSize = 100;
static float cylinderHeight = 70;
static int cylinderResolution = 40;
static PShape cylinder = new PShape();
static boolean cylinderKeyPressed = false; 

void settings() {
  size(windowHeight, windowWidth, P3D);
}

void setup () {
  // création d'un cylindre (cylinder)
  noStroke();
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
  
  for (int a = 0; a < x.length; a++) {
    cylinder.vertex(x[a], cylinderHeight, y[a]);
    if (a + 1 >= x.length) {
      cylinder.vertex(x[0], cylinderHeight, y[0]);
    } else {
      cylinder.vertex(x[a+1], cylinderHeight, y[a+1]);
    }
    cylinder.vertex(0, cylinderHeight, 0);
  }

  for (int b = 0; b < x.length; b++) {
    cylinder.vertex(x[b], 0, y[b]);
    if (b + 1 >= x.length) {
      cylinder.vertex(x[0], 0, y[0]);
    } else {
      cylinder.vertex(x[b+1], 0, y[b+1]);
    }
    cylinder.vertex(0, 0, 0);
  }

  for (int c = 0; c < x.length; c++) {
    cylinder.vertex(x[c], 0, y[c]);
    cylinder.vertex(x[c], cylinderHeight, y[c]);
  }

  cylinder.endShape();
}

void draw() {
  background(235);

  if (!shiftKeyPressed) {
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
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
    stroke(0);
    box(boxWidth, boxThick, boxHeight);

    //cylinder
    for (int i = 0; i < arrayCyl.size(); i++) {
      pushMatrix();
      cylinder.setFill(color(255, 204, 0));
      //println("x: "+arrayCyl.get(i).x+"y:"+ arrayCyl.get(i).y);
      translate(arrayCyl.get(i).x, -2*boxThick, arrayCyl.get(i).y);
      shape(cylinder);
      popMatrix();
    }

    mover.update(); 
    mover.checkEdges(); 
    mover.checkCylinderCollision();
    mover.display();
  }

  //SHIFT
  else if (shiftKeyPressed) {
    float cameraDistance = -height*2;
    camera(width/2, cameraDistance, 1, width/2, height/2, 0, 0, 1, 0);
    //ortho();
    directionalLight(50, 100, 125, 0, 1, 0);
    translate(width/2, height/2, 0);
    ambientLight(102, 102, 102);
    fill(255);
    stroke(0);
    box(boxWidth, boxThick, boxHeight);
    mover.updateSHIFT();

    //cylinder
    for (int i = 0; i < arrayCyl.size(); i++) {
      pushMatrix();
      cylinder.setFill(color(255, 204, 0));
      //println("x: "+arrayCyl.get(i).x+"y:"+ arrayCyl.get(i).y);
      translate(arrayCyl.get(i).x, -2*boxThick, arrayCyl.get(i).y);
      shape(cylinder);
      popMatrix();
    }

    // MAGIC NUMBERS 0.675 ET 0.15 ! TROUVER UNE RELATION AVEC WIDTH HEIGHT ETC BLABLA BLA
    float cylX = map(mouseX, 0, width, -(boxWidth/2 + abs(cameraDistance)*0.675),(boxWidth/2 + abs(cameraDistance)*0.675));
    float cylY = map(mouseY, 0, height, -(boxHeight/2 + abs(cameraDistance)*0.15),(boxHeight/2 + abs(cameraDistance)*0.15));
    translate(constrain(cylX, -boxWidth/2, boxWidth/2) , -2*boxThick, constrain(cylY, -boxHeight/2, boxHeight/2));
    cylinder.setFill(color(255, 204, 0));
    shape(cylinder);


    if (cylinderKeyPressed) {
     float x = cylX; 
     float y = cylY; 
     PVector v1 = new PVector(x, y); 
     arrayCyl.add(v1);
     cylinderKeyPressed = false;
     }
  }
}

void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  speed = bound(speed * map(wheelCount*30, -100, 100, 0.2, 1.5), 0.2, 1.5);
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