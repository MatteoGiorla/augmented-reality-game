
static int windowHeight = 1250;
static int windowWidth = 700;

//variable de la caméra.
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

//variables relatives au mode SHIFT
static boolean shiftKeyPressed = false;
static ArrayList<PVector> arrayCyl = new ArrayList(); 

//variables relatives au cylindre
static float cylinderBaseSize = 100;
static float cylinderHeight = 150;
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
  cylinder.beginShape(QUAD_STRIP);
  
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
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);

  if (!shiftKeyPressed) {
    //on fixe la caméra en face du plateau puis on déplace le plateau correctement au centre de la fenêtre.
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
    translate(width/2, height/2, 0);
    
    //fonction qui s'occupe de pivoter le plateau.
    rotationGestion();  
    fill(255);
    stroke(0);
    box(boxWidth, boxThick, boxHeight);

    //cylinder
    for (int i = 0; i < arrayCyl.size(); ++i) {
      pushMatrix();
      cylinder.setFill(color(255, 204, 0));
      //println("x: "+arrayCyl.get(i).x+"y:"+ arrayCyl.get(i).y);
      translate(arrayCyl.get(i).x, -2*boxThick-cylinderHeight/2, arrayCyl.get(i).y);
      shape(cylinder);
      popMatrix();
    }

    mover.update(); 
    mover.display();
  }

  //SHIFT
  else if (shiftKeyPressed) {
    float cameraDistance = -height*2;
    camera(width/2, cameraDistance, 1, width/2, height/2, 0, 0, 1, 0);
    translate(width/2, height/2, 0);
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
    float cylXConstr = constrain(cylX, -boxWidth/2, boxWidth/2);
    float cylYConstr = constrain(cylY, -boxHeight/2, boxHeight/2);
    translate(cylXConstr , -2*boxThick, cylYConstr);
    cylinder.setFill(color(255, 204, 0));
    shape(cylinder);

    //fixation du cylindre.
    if (cylinderKeyPressed) {
     float x = cylXConstr; 
     float y = cylYConstr; 
     PVector v1 = new PVector(x, y); 
     arrayCyl.add(v1);
     cylinderKeyPressed = false;
     }
  }
}

//fonction qui s'occupe de tourner le plateau sur l'axe des X et des Y en fonction de l'utilisation de la souris en mode "CLICK"
void rotationGestion(){
  if (mousePressed == true) {
      float rz = map(mouseX - constrain(mouseXSaved, 0, width) + width/2, 0, width, (-PI/3), PI/3)*speed;
      float rx = map(mouseY - constrain(mouseYSaved, 0, height) + height/2, 0, height, (-PI/3), PI/3)*speed;
      angleX = constrain(rx + rxImmobile, -PI/3, PI/3);
      angleZ = constrain(rz + rzImmobile, -PI/3, PI/3);
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
}

void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  speed = constrain(speed * map(wheelCount*30, -100, 100, 0.2, 1.5), 0.2, 1.5);
}


// méthode permettant de gérer la profondeur de champ à l'aide de touches up et down du clavier. 
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
  cylinderKeyPressed = false;
}

void mouseClicked() {
  cylinderKeyPressed = true;
}