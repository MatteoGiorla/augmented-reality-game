static int windowHeight = 700;
static int windowWidth = 1250;

//variable de la caméra.
static float depth = 2000;

//variables relatives au plateau et son déplacement.
static float mouseXSaved = 0.0;
static float mouseYSaved = 0.0;
static float rxImmobile = 0.0;
static float rzImmobile = 0.0;
static float angleX = 0.0;
static float angleZ = 0.0;
static float speed = 1.0;
static final float boxColor = 255;
static final float boxWidth = 1500; // valeur qui s'étend sur l'axe des x
static final float boxThick =  50; // valeur qui s'étend sur l'axe des y
static final float boxHeight = 1500; // valeur qui s'étend sur l'axe des z

//classe qui s'occupe de la balle
Mover mover = new Mover();


//variables de la fenêtre des datas.
PGraphics dataGraphics;

//le data fraction dit sur quel 1/datatfraction on veut faire apparatîre notre Hud
final int dataFraction = 5;
final int dataHeight = windowHeight/dataFraction;
final int dataWidth = windowWidth;
final float offset = dataHeight/9;
final float dataBoxSide = dataHeight - 2*offset;
PGraphics textGraphics;

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
  size(windowWidth, windowHeight, P3D);
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

  //on construit les vertices du sommet
  baseCylinderConstr(x, y, cylinderHeight);
  //on construit les vertices de la base
  baseCylinderConstr(x, y, 0);

  for (int j = 0; j < x.length; j++) {
    cylinder.vertex(x[j], 0, y[j]);
    cylinder.vertex(x[j], cylinderHeight, y[j]);
  }
  cylinder.endShape();

  //initialisation de la fenêtre des scores et autres donnnées de visualtion méta
  dataGraphics = createGraphics(dataWidth, dataHeight, P2D);
  textGraphics = createGraphics(dataWidth/7, dataHeight-(int)offset, P2D);
  
}

//relie les points du cercle de la base et du sommet du cylindre.
void baseCylinderConstr(float[] vertDotsX, float[] vertDotsY, float cylHeight) {
  for (int i = 0; i < vertDotsX.length; ++i) {
    cylinder.vertex(vertDotsX[i], cylHeight, vertDotsY[i]);
    if (i + 1 >= vertDotsX.length) {
      cylinder.vertex(vertDotsX[0], cylHeight, vertDotsY[0]);
    } else {
      cylinder.vertex(vertDotsX[i+1], cylHeight, vertDotsY[i+1]);
    }
    cylinder.vertex(0, cylHeight, 0);
  }
}

void drawData() { 
  dataGraphics.beginDraw();
  color c = color(255, 204, 0);
  dataGraphics.background(c);
  
  //top view of the plane as a 2D blue box.
  dataGraphics.stroke(0);
  dataGraphics.fill(150, 150, 255);
  dataGraphics.rect(offset, offset, dataBoxSide, dataBoxSide);
  //puting the coordinate system to the center of blue box
  float dataBallX = map(mover.location.x,-boxWidth/2, boxHeight/2, offset, dataBoxSide+offset);
  float dataBallY = map(mover.location.z,-boxHeight/2, boxHeight/2, offset, dataBoxSide+offset);
  float dataRadius = map(2*ballRadius, 0, boxHeight, 0, dataBoxSide);
  dataGraphics.fill(241,54,26);
  dataGraphics.noStroke();
  dataGraphics.ellipse(dataBallX, dataBallY, dataRadius, dataRadius);
  for(int i = 0; i < arrayCyl.size(); ++i){
    drawDataCyl(i);
  }  
  dataGraphics.endDraw();
}

//TODO : écrire le score et dessiner la bordure en blanc
void drawScore(){
  textGraphics.beginDraw();
  color c = color(255, 255, 0);
  textGraphics.background(c);
  textGraphics.stroke(245);
  textGraphics.textSize(12);
  textGraphics.fill(12);
  textGraphics.text("Score: "+mover.score, 10, 30);
  textGraphics.endDraw();
}

void drawDataCyl(int cylNumber){
  float dataCylX = map(arrayCyl.get(cylNumber).x,-boxWidth/2, boxHeight/2, offset, dataBoxSide+offset);
  float dataCylY = map(arrayCyl.get(cylNumber).y,-boxHeight/2, boxHeight/2, offset, dataBoxSide+offset);
  float dataCylR = map(cylinderBaseSize*2, 0, boxHeight, 0, dataBoxSide);
  dataGraphics.fill(243);
  dataGraphics.ellipse(dataCylX, dataCylY, dataCylR, dataCylR);
  
}

void draw() {
  background(235);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  
  
  //HUD DRAWING PROFESSIONAL.
  pushMatrix();
  drawData();
  drawScore();
  //MAGIC NUMBER; MON AMOUUUUUUUUUUUR
  translate(0, 0, depth-606);
  image(dataGraphics, 0, (dataFraction -1)*dataHeight);
  image(textGraphics, 2*offset + dataBoxSide, (dataFraction -1 )*dataHeight+offset/2);
  popMatrix();

  if (!shiftKeyPressed) {
    //on fixe la caméra en face du plateau puis on déplace le plateau correctement au centre de la fenêtre.
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
    translate(width/2, height/2, 0);

    //pivoter le plateau.
    rotationGestion(); 

    //box
    boxSpawner();

    //cylindres
    cylinderSpawner(cylinderHeight/2);

    //ball
    mover.update(); 
    mover.display(boxColor);
  }
  //SHIFT MODE
  else if (shiftKeyPressed) {
    //la caméra est cette fois ci fixée au sommet du plateau
    float cameraDistance = -height*2;
    camera(width/2, cameraDistance, 1, width/2, height/2, 0, 0, 1, 0);
    translate(width/2, height/2, 0);

    //box
    boxSpawner();

    //ball
    mover.updateSHIFT();

    //cylindres
    cylinderSpawner(0);

    //cf Cédric.
    float cylX = map(mouseX, 0, width, -(boxWidth/2 + abs(cameraDistance)*0.675), (boxWidth/2 + abs(cameraDistance)*0.675));
    float cylY = map(mouseY, 0, height, -(boxHeight/2 + abs(cameraDistance)*0.15), (boxHeight/2 + abs(cameraDistance)*0.15));
    float cylXConstr = constrain(cylX, -boxWidth/2, boxWidth/2);
    float cylYConstr = constrain(cylY, -boxHeight/2, boxHeight/2);
    translate(cylXConstr, -2*boxThick, cylYConstr);
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
//puis de sauvegarder cette inclinaison lorsqu'il n'y a pas de clicks
void rotationGestion() {
  if (mousePressed) {
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

//fonction qui affiche le plateau
void boxSpawner() {
  fill(boxColor);
  stroke(0);
  box(boxWidth, boxThick, boxHeight);
}

//fonction qui affiche les cylindres sur le plateau. la valeur yOffset permet d'influencer le placement vertical des cylindres selon le mode.
void cylinderSpawner(float yOffset) {
  for (int i = 0; i < arrayCyl.size(); i++) {
    pushMatrix();
    cylinder.setFill(color(255, 204, 0));
    translate(arrayCyl.get(i).x, -2*boxThick-yOffset, arrayCyl.get(i).y);
    shape(cylinder);
    popMatrix();
  }
}

//On gère ici la speed du plateau.
void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  speed = constrain(speed * map(wheelCount*30, -100, 100, 0.2, 1.5), 0.2, 1.5);
}

// ici on gère la profondeur de champ à l'aide de touches up et down du clavier, et on regarde également si SHIFT est activé.  
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