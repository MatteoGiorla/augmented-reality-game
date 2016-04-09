//variables relatives à la balle.
static PVector gravityForce;
static PVector velocity;
static PVector friction;
static float frictionMagnitude;
static PVector location;
static PVector veloThreshold;

//enum servant à représenter les directions.
enum direction{
    UP,
    DOWN,
    RIGHT,
    LEFT,
}

//Constantes du programe.
final static  float ballRadius = 50;
final static float gravityConstant = 1; //une trop grand force gravitationnelle n'est pas super non plus.
final static float mu = 0.22; //ceci représente le coefficient de frottement du chêne savonné. Parce qu'à la fin du projet je veux que notre plaque soit du bois de chêne savonné.
final static float normalForce = 1;
final static float BLACK = 0;

class Mover {

  Mover() {
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    location = new PVector(0, -(ballRadius + Game.boxThick/2), 0); // position de base pour que la sphère soit sur le plateau.
    friction = new PVector(0, 0, 0);
    frictionMagnitude = normalForce * mu;
    veloThreshold = new PVector(0.3,0.0,3);
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
    
    //controle les collisions avec les cylindres et entre les bords
    checkEdges();
    checkCylinderCollision();
    
    //appliquer la velocité à la position 
    location.add(velocity);
  }

  void checkEdges() {
    //Check bord gauche
    if (location.x + ballRadius > boxWidth/2) {
      if(isStopped(velocity.x, veloThreshold.x)){
        if(facingToward(gravityForce.x, direction.LEFT)){
          velocity.x = 0;
        }
      }else{
        velocity.x = -velocity.x;
      }
    }
     
    //check bord droit
    if(location.x - ballRadius < -boxWidth/2){
      if(isStopped(velocity.x, veloThreshold.x)){
        if(facingToward(gravityForce.x, direction.RIGHT)){
          velocity.x = 0;
        }
      }else{
        velocity.x = -velocity.x;
      }
    }
    
    //check bord du bas
    if (location.z + ballRadius > boxHeight/2) {
      if(isStopped(velocity.z, veloThreshold.z)){
        if(facingToward(gravityForce.z, direction.DOWN)){
          velocity.z = 0;
        }
      }else{
        velocity.z = -velocity.z;
      }
    }
     
    //check bord du haut
    if(location.z - ballRadius < -boxHeight/2){
      if(isStopped(velocity.z, veloThreshold.z)){
        if(facingToward(gravityForce.z, direction.UP)){
          velocity.z = 0;
        }
      }else{
        velocity.z = -velocity.z;
      }
    }
  }
  
  
  //indique si la coordonnées de la vélocité est en dessous d'un certan seuil, donc que l'objet ne devrait plus bouger dans cette direction.
  boolean isStopped(float veloCoord, float thresCoord){
    return (abs(veloCoord) < thresCoord);
  }
  
  //dit dans quelle direction est tourné le plateau.
  boolean facingToward(float gravity, direction DIR){
    switch(DIR){
      case UP: return (gravity < 0);
      case DOWN: return (gravity >= 0);
      case LEFT: return (gravity < 0);
      case RIGHT: return (gravity >= 0);
      default: return false;
    }
  }
  
  //version de update qui se contente uniquement d'afficher la balle immobile dans le mode SHIFT.
  void updateSHIFT() {
    pushMatrix();
    display(BLACK);
    popMatrix();
  }

  // affiche la balle dans le jeu selon la couleur désirée.
  void display(float ballColor) {
    translate(location.x, location.y, location.z); 
    noStroke();
    fill(ballColor);
    sphere(ballRadius);
  }

  void checkCylinderCollision() {
    for (int i = 0; i < arrayCyl.size(); i++) {
      boolean velocityAdapted = false;
      if ((abs(location.x - arrayCyl.get(i).x) <= ballRadius + (cylinderBaseSize / 2))  && (abs(location.z - arrayCyl.get(i).y) <= ballRadius+(cylinderBaseSize/2)) && !velocityAdapted) {
        //créer vecteur normal
        PVector velocity2D = new PVector(velocity.x, velocity.z);
        PVector normalCyl = new PVector(location.x - arrayCyl.get(i).x, location.z - arrayCyl.get(i).y).normalize();
        PVector newVelocity = velocity2D.sub(normalCyl.mult((velocity2D.dot(normalCyl))*(2.0)));
        
        velocity = new PVector(newVelocity.x, 0.0, newVelocity.y);
        velocityAdapted = true;
      }
    }
  }
}