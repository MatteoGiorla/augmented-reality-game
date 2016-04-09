//variables relatives à la balle.
static PVector gravityForce;
static PVector velocity;
static PVector friction;
static float frictionMagnitude;
static PVector location;

static final  float ballRadius = 50;

//Constantes du programe.
final static float gravityConstant = 0.81; //une trop grand force gravitationnelle n'est pas super non plus.
final static float mu = 0.16; //ceci représente le coefficient de frottement du chêne savonné. Parce qu'à la fin du projet je veux que notre plaque soit du bois de chêne savonné.
final static float normalForce = 1;

class Mover {

  Mover() {
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    location = new PVector(0, -(ballRadius + Game.boxThick/2), 0); // position de base pour que la sphère soit sur le plateau.
    friction = new PVector(0, 0, 0);
    frictionMagnitude = normalForce * mu;
  }


  //recalcule toutes les composantes phyisques qui régissent le déplacement et la position de la balle.
  void update() {

    //friction
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    //gravity
    gravityForce.x = sin(angleZ) * gravityConstant;
    gravityForce.z = sin(angleX) * gravityConstant;

    velocity.add(friction);
    velocity.add(gravityForce);

    //appliquer la velocité à la position 
    location.add(velocity);
  }

  void checkEdges() {
    if (location.x + ballRadius > boxWidth/2 || location.x - ballRadius < -boxWidth/2) {
      velocity.x = -velocity.x;
    }
    if (location.z + ballRadius > boxHeight/2 || location.z - ballRadius < -boxHeight/2) {
      velocity.z = -velocity.z;
    }
  }

  void updateSHIFT() {
    pushMatrix();
    translate(location.x, location.y, location.z); 
    stroke(0);
    sphere(ballRadius);
    popMatrix();
  }

  // affiche la balle dans le jeu
  void display() {
    translate(location.x, location.y, location.z); 
    noStroke();
    sphere(ballRadius);
  }

  void checkCylinderCollision() {
    for (int i = 0; i < arrayCyl.size(); i++) {
      println("Cylindre : " + arrayCyl.get(i).x + "   " + arrayCyl.get(i).y + "balle : " + location.x + "    " + location.z);
      println("Distance : " + (location.x - arrayCyl.get(i).x) + "    "  + (location.z - arrayCyl.get(i).y));
      boolean velocityAdapted = false;
      if ((abs(location.x - arrayCyl.get(i).x) <= ballRadius + (cylinderBaseSize / 2))  && (abs(location.z - arrayCyl.get(i).y) <= ballRadius+(cylinderBaseSize/2)) && !velocityAdapted) {
        //créer vecteur normal
        PVector velocity2D = new PVector(velocity.x, velocity.z);
        PVector normalCyl = new PVector(location.x - arrayCyl.get(i).x, location.z - arrayCyl.get(i).y).normalize();
        PVector newVelocity = velocity2D.sub(normalCyl.mult((velocity2D.dot(normalCyl))*(2.0)));
        
        velocity = new PVector(newVelocity.x, 0.0, newVelocity.y);
        println("Vitesse : " + velocity);
        velocityAdapted = true;

      }
    }
  }
}