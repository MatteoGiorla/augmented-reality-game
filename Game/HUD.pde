class HUD {

  //le data fraction dit sur quel 1/datatfraction on veut faire apparatîre notre Hud
  final int verticalPartition;
  final int dataHeight;
  final int dataWidth;
  final float offset;
  final float dataBoxSide;
  final int textWidth;
  final int textHeight;

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
    textWidth = dataWidth/8;
    textHeight = dataHeight-(int)offset;
  }

  void setup() {
    //initialisation de la fenêtre des scores et autres donnnées de visualtion méta
    dataGraphics = createGraphics(dataWidth, dataHeight, P2D);
    textGraphics = createGraphics(textWidth, textHeight, P2D);
  }


  void drawHUD(ArrayList<PVector> arrayCyl, Mover ball) {
    //HUD DRAWING PROFESSIONAL.
    pushMatrix();
    drawData(arrayCyl, ball.location);
    drawScore(ball.score, ball.point, ball.magnitude);
    //MAGIC NUMBER; MON AMOUUUUUUUUUUUR
    translate(0, 0, depth-606);
    image(dataGraphics, 0, (verticalPartition -1)*dataHeight);
    image(textGraphics, 2*offset + dataBoxSide, (verticalPartition -1 )*dataHeight+offset/2);
    popMatrix();
  }

  void drawData(ArrayList<PVector> arrayCylinders, PVector ballLocation) { 
    dataGraphics.beginDraw();
    color c = color(230, 226, 175);
    dataGraphics.background(c);

    //top view of the plane as a 2D blue box.
    dataGraphics.stroke(0);
    dataGraphics.fill(6, 101, 130);
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

  void drawScore(float score, float point, float velocite) {
    int cRadius = 10;
    int bStroke = 3;
    int textOffsetH = textHeight/6;
    int textOffsetW = textWidth/8;
    
    textGraphics.beginDraw();
    //textGraphics.background(255);
    textGraphics.noStroke();
    textGraphics.fill(255);
    textGraphics.rect(0, 0, textWidth,textHeight, cRadius, cRadius, cRadius, cRadius);
    color c = color(230, 226, 175);
    textGraphics.fill(c);
    textGraphics.rect(bStroke, bStroke, textWidth-2*bStroke,textHeight-2*bStroke, cRadius, cRadius, cRadius, cRadius);
    textGraphics.fill(0);
    textGraphics.text("Score: "+score, textOffsetW, textOffsetH);
    textGraphics.text("Velocity: "+velocite, textOffsetW, textOffsetH+textHeight/3);
    textGraphics.text("Last Score: "+point, textOffsetW, textOffsetH+2*textHeight/3);
    textGraphics.endDraw();
  }
}