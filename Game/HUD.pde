class HUD {

  final int verticalPartition;
  final int dataHeight;
  final int dataWidth;
  final float offset;
  final float dataBoxSide;
  final int textWidth;
  final int textHeight;
  final int barWidth;
  final int barHeight;
  ArrayList<PVector> ballLocationHistory;
  int miniBox = 5;
  final int miniOffset = 1;
  /*déclaration des différents "canevas" à afficher sur l'HUD, dans l'ordre :
   -La fenètre globale du Hud avec son plateau 2D
   -la boite des données textuelles (score etc...)
   */
  public ArrayList<Integer> scoreChart;
  
  PGraphics dataGraphics;
  PGraphics textGraphics;
  PGraphics barChartGraphics;

  HUD(int verticalPartition, int windowWidth, int windowHeight) {
    this.verticalPartition = verticalPartition;
    dataHeight = windowHeight/verticalPartition;
    dataWidth = windowWidth;
    offset = dataHeight/9;
    dataBoxSide = dataHeight - 2*offset;
    textWidth = dataWidth/7;
    textHeight = dataHeight-(int)offset;
    barWidth = windowWidth - (int) (4*offset + dataBoxSide + textWidth);
    barHeight = dataHeight- (int)(2.5*offset);
    ballLocationHistory = new ArrayList();
    scoreChart = new ArrayList<Integer>();
    scoreChart.add(1);
    scoreChart.add(2);
    scoreChart.add(3);
    scoreChart.add(21);
    
  }

  void setup() {
    //initialisation de la fenêtre des scores et autres donnnées de visualtion méta
    dataGraphics = createGraphics(dataWidth, dataHeight, P2D);
    textGraphics = createGraphics(textWidth, textHeight, P2D);
    barChartGraphics = createGraphics(barWidth, barHeight, P2D);
  }


  void drawHUD(ArrayList<PVector> arrayCyl, Mover ball) {
    //HUD DRAWING PROFESSIONAL.
    pushMatrix();
    drawData(arrayCyl, ball.location);
    drawScore(ball.score, ball.point, ball.magnitude);
    drawBarChart();
    //MAGIC NUMBER; MON AMOUUUUUUUUUUUR
    translate(0, 0, depth-606);
    image(dataGraphics, 0, (verticalPartition -1)*dataHeight);
    image(textGraphics, 2*offset + dataBoxSide, (verticalPartition -1 )*dataHeight+offset/2);
    image(barChartGraphics, 3*offset + dataBoxSide + textWidth, ((verticalPartition-1)*dataHeight)+offset/2);
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
    ballLocationHistory.add(new PVector(dataBallX, dataBallY));
    for (int i=0; i<ballLocationHistory.size(); ++i) {
      dataGraphics.fill(200, 200, 255, 10);
      dataGraphics.noStroke();
      dataGraphics.ellipse(ballLocationHistory.get(i).x, ballLocationHistory.get(i).y, dataRadius, dataRadius);
    }
    dataGraphics.fill(241, 54, 26);
    dataGraphics.noStroke();
    dataGraphics.ellipse(dataBallX, dataBallY, dataRadius, dataRadius);
    
    //drawing the cylinders.
    dataGraphics.stroke(9);
    for (int i = 0; i < arrayCylinders.size(); ++i) {
      float dataCylX = map(arrayCylinders.get(i).x, -boxWidth/2, boxHeight/2, offset, dataBoxSide+offset);
      float dataCylY = map(arrayCylinders.get(i).y, -boxHeight/2, boxHeight/2, offset, dataBoxSide+offset);
      float dataCylR = map(cylinderBaseSize*2, 0, boxHeight, 0, dataBoxSide);
      dataGraphics.fill(255,255,0);
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
    textGraphics.noStroke();
    textGraphics.fill(255);
    textGraphics.rect(0, 0, textWidth, textHeight, cRadius, cRadius, cRadius, cRadius);
    color c = color(230, 226, 175);
    textGraphics.fill(c);
    textGraphics.rect(bStroke, bStroke, textWidth-2*bStroke, textHeight-2*bStroke, cRadius, cRadius, cRadius, cRadius);
    textGraphics.fill(0);
    textGraphics.text("Score: "+score, textOffsetW, textOffsetH);
    textGraphics.text("Velocity: "+velocite, textOffsetW, textOffsetH+textHeight/3);
    textGraphics.text("Last Score: "+point, textOffsetW, textOffsetH+2*textHeight/3);
    textGraphics.endDraw();  
  }
  
  void addABar(float score){
    int toAdd = (int)map(score, -1000, 1000, -21, 21);
    if(toAdd > 0){
      scoreChart.add(toAdd);
      println(toAdd);
    }
  }
  
  
  //va s'occuper de faire apparaître une bar à l'endroit locaX indiqué.
  void displayTower(int nmbrBox, int locaX, int boxWidth, int offset){
    int x = (locaX)*(miniBox+offset);
    for(int j = 1; j <= nmbrBox; ++j){
      barChartGraphics.fill(6, 101, 130);
      barChartGraphics.noStroke();
      barChartGraphics.rect(x, barHeight-(j*(boxWidth+offset)) , boxWidth, miniBox);
    }
  }
  
  void drawBarChart(){
    barChartGraphics.beginDraw();
    barChartGraphics.background(255, 255, 175);
    for(int i = 0; i < scoreChart.size(); ++i){
      displayTower(scoreChart.get(i), i, miniBox, miniOffset);
    }
    barChartGraphics.endDraw();
  }
}