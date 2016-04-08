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


  void update() {

    translate(location.x, location.y, location.z); 
    sphere(ballRadius);
    
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
  }

  void checkEdges() {
    if (location.x + ballRadius > boxWidth/2 || location.x - ballRadius < -boxWidth/2) {
      velocity.x = -velocity.x;
    }
    if (location.z + ballRadius > boxHeight/2 || location.z - ballRadius < -boxHeight/2) {
      velocity.z = -velocity.z;
    }
  }
  
    void display() {
    location.add(velocity);
  }
  
  void checkCylinderCollision(){
    for(int i = 0; i < arrayCyl.size(); i++) {
      if(location.dist(arrayCyl.get(i)) <= ballRadius + (cylinderBaseSize / 2)) { // cette ligne est fausse il faut inclure les rayons. 
        //créer vecteur normal
        PVector normalCyl = new PVector(location.x - arrayCyl.get(i).x, location.y - arrayCyl.get(i).y);
        //float insideMul = velocity.dot(normalCyl);
        PVector newVelocity = velocity.sub(normalCyl.mult((velocity.dot(normalCyl)) * 2.0));
        velocity = newVelocity;
      }
    }
  }
}