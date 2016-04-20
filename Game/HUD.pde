class HUD {

  //le data fraction dit sur quel 1/datatfraction on veut faire apparatîre notre Hud
  final int verticalPartition;
  final int dataHeight;
  final int dataWidth;
  final float offset;
  final float dataBoxSide;

  /*déclaration des différents "canevas" à afficher sur l'HUD, dans l'ordre :
      -La fenètre globale du Hud avec son plateau 2D
      -la boite des données textuelles (score etc...)
   */
  PGraphics dataGraphics;
  PGraphics textGraphics;

  HUD(int verticalPartition, int windowWidth, int windowHeight) {
    this.verticalPartition = verticalPartition;
    dataHeight = windowHeight/verticalPartition;
    dataWidth = windowWidth;
    offset = dataHeight/9;
    dataBoxSide = dataHeight - 2*offset;
  }

  void setup() {
    //initialisation de la fenêtre des scores et autres donnnées de visualtion méta
    dataGraphics = createGraphics(dataWidth, dataHeight, P2D);
    textGraphics = createGraphics(dataWidth/7, dataHeight-(int)offset, P2D);
  }


  void drawHUD(ArrayList<PVector> arrayCyl, Mover ball) {
    //HUD DRAWING PROFESSIONAL.
    pushMatrix();
    drawData(arrayCyl, ball.location);
    drawScore(ball.score);
    //MAGIC NUMBER; MON AMOUUUUUUUUUUUR
    translate(0, 0, depth-606);
    image(dataGraphics, 0, (verticalPartition -1)*dataHeight);
    image(textGraphics, 2*offset + dataBoxSide, (verticalPartition -1 )*dataHeight+offset/2);
    popMatrix();
  }

  void drawData(ArrayList<PVector> arrayCylinders, PVector ballLocation) { 
    dataGraphics.beginDraw();
    color c = color(255, 204, 0);
    dataGraphics.background(c);

    //top view of the plane as a 2D blue box.
    dataGraphics.stroke(0);
    dataGraphics.fill(150, 150, 255);
    dataGraphics.rect(offset, offset, dataBoxSide, dataBoxSide);
    
    //puting the coordinate system to the center of blue box and drawing the ball
    float dataBallX = map(ballLocation.x, -boxWidth/2, boxHeight/2, offset, dataBoxSide+offset);
    float dataBallY = map(ballLocation.z, -boxHeight/2, boxHeight/2, offset, dataBoxSide+offset);
    float dataRadius = map(2*ballRadius, 0, boxHeight, 0, dataBoxSide);
    dataGraphics.fill(241, 54, 26);
    dataGraphics.noStroke();
    dataGraphics.ellipse(dataBallX, dataBallY, dataRadius, dataRadius);
    
    //drawing the cylinders.
    for (int i = 0; i < arrayCylinders.size(); ++i) {
      float dataCylX = map(arrayCylinders.get(i).x, -boxWidth/2, boxHeight/2, offset, dataBoxSide+offset);
      float dataCylY = map(arrayCylinders.get(i).y, -boxHeight/2, boxHeight/2, offset, dataBoxSide+offset);
      float dataCylR = map(cylinderBaseSize*2, 0, boxHeight, 0, dataBoxSide);
      dataGraphics.fill(243);
      dataGraphics.ellipse(dataCylX, dataCylY, dataCylR, dataCylR);
    }  
    dataGraphics.endDraw();
  }

  void drawScore(float score) {
    textGraphics.beginDraw();
    color c = color(255, 255, 0);
    textGraphics.background(c);
    textGraphics.stroke(245);
    textGraphics.textSize(12);
    textGraphics.fill(12);
    textGraphics.text("Score: "+score, 10, 30);
    textGraphics.endDraw();
  }
}