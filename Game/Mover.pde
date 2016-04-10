//enum servant à représenter les directions.
enum direction{
    UP,
    DOWN,
    RIGHT,
    LEFT,
}

//Constantes du programe.
final static  float ballRadius = 50;
final static float gravityConstant = 0.81; //une trop grand force gravitationnelle n'est pas super non plus.
final static float mu = 0.2; //ceci représente le coefficient de frottement du chêne savonné. Parce qu'à la fin du projet je veux que notre plaque soit du bois de chêne savonné.
final static float normalForce = 1;
final static float BLACK = 0;
final static float threshold = (1.5*PI*gravityConstant)/(1+mu); //j'ai mis PI juste pour la beauté de la chose (et parce que 3 était apparament un bon facteur) 
//ATTENTION ! Trouver le bon threshold est compliqué et est fortement dépendant de la gravityConstant ainsi que du mu. 1.5*PI*gravityConstant/(1+mu)
// se trouve être un bon threshold pour les valeurs de 0.81 pour la gravité et 0.2 pour mu. Une fonction donnant automatiquement le threshold
//idéal en fonction de mu et gravityConstant existe probablement, mais après quelques tentatives de recherches empiriques, j'ai abandonné.
//  en gros une telle fontion devrait être proportionnel à la gravityConstante, et être inversement proportionnel à 1+mu.

class Mover {

 PVector gravityForce;
 PVector velocity;
 PVector friction;
 float frictionMagnitude;
 PVector location;
 PVector veloThreshold;

  Mover() {
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    location = new PVector(0, -(ballRadius + Game.boxThick/2), 0); // position de base pour que la sphère soit sur le plateau.
    friction = new PVector(0, 0, 0);
    frictionMagnitude = normalForce * mu;
    
    veloThreshold = new PVector(threshold,0.0,threshold);
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
    int downBall = floor(location.z + ballRadius)+1;
    int rightBall = floor(location.x + ballRadius)+1;
    int upBall = floor(location.z - ballRadius)+1;
    int leftBall = floor(location.x -ballRadius)+1;
    
    //check bord du bas
    if ( downBall >= boxHeight/2) {
      if(isStopped(velocity.z, veloThreshold.z)){
        //println("stoppedDOWN");
        if(facingToward(gravityForce.z, direction.DOWN)){
          velocity.z = 0;
        }
      }else{
        velocity.z = -velocity.z;
      }
    }
     
    //check bord du haut
    if( upBall <= -boxHeight/2){
      if(isStopped(velocity.z, veloThreshold.z)){
        //println("stoppedUP");
        if(facingToward(gravityForce.z, direction.UP)){
          velocity.z = 0;
        }
      }else{
        velocity.z = -velocity.z;
      }
    }
    
    //threshold pas suffisant dans les x ?????
    if (rightBall >= boxWidth/2) {
      if(isStopped(velocity.x, veloThreshold.x)){
        //println("stoppedRIGHT");
        if(facingToward(gravityForce.x, direction.RIGHT)){
          velocity.x = 0;
        }
      }else{
        velocity.x = -velocity.x;
      }
    }
     
    //check bord de gauche
    if(leftBall <= -boxWidth/2){
      if(isStopped(velocity.x, veloThreshold.x)){
        if(facingToward(gravityForce.x, direction.LEFT)){
          //println("stoppedLEFT");
          velocity.x = 0;
        }
      }else{
        velocity.x = -velocity.x;
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