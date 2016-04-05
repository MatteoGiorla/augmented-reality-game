
    float cylinderBaseSize = 50;
    float cylinderHeight = 50;
    int cylinderResolution = 40;
    PShape openCylinder = new PShape();
    void settings() {
      size(400, 400, P3D);
}
    void setup() {
      float angle;
      float[] x = new float[cylinderResolution + 1];
      float[] y = new float[cylinderResolution + 1];
      //get the x and y position on a circle for all the sides
      for(int i = 0; i < x.length; i++) {
        angle = (TWO_PI / cylinderResolution) * i;
        x[i] = sin(angle) * cylinderBaseSize;
        y[i] = cos(angle) * cylinderBaseSize;
      }
      openCylinder = createShape();
        openCylinder.beginShape(TRIANGLE);
        //dessine le "couvercle"
        for(int a = 0; a < x.length; a++){
          openCylinder.vertex(x[a], y[a], cylinderHeight);
          if(a + 1 >= x.length){
            openCylinder.vertex(x[0], y[0], cylinderHeight);
          } else {
          openCylinder.vertex(x[a+1], y[a+1], cylinderHeight); 
          }
          openCylinder.vertex(0, 0, cylinderHeight); 
        }
        //dessine le "bottom"
        for(int b = 0; b < x.length; b++){
          openCylinder.vertex(x[b], y[b], 0);
          if(b + 1 >= x.length){
            openCylinder.vertex(x[0], y[0], 0);
          } else {
          openCylinder.vertex(x[b+1], y[b+1], 0); 
          }
          openCylinder.vertex(0, 0, 0); 
        }
      //openCylinder.endShape();
      
      //openCylinder.beginShape(QUAD_STRIP);
        //draw the border of the cylinder
        for(int c = 0; c < x.length; c++) {
          openCylinder.vertex(x[c], y[c] , 0);
          openCylinder.vertex(x[c], y[c], cylinderHeight);
        }
        openCylinder.endShape();
      }

    void draw() {
        background(255);
        translate(mouseX, mouseY, 0); 
        shape(openCylinder);
    }