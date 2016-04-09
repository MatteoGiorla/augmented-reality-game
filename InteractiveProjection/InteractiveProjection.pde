//PETITS CUBES
float depth = 2000;
void settings() {
  size(500, 500, P3D);
}
void setup() { 
  noStroke();
} 


void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);
  float rz = map(mouseY, 0, height, 0, PI);
  float ry = map(mouseX, 0, width, 0, PI);
  rotateZ(rz);
  rotateY(ry);
  for (int x = -2; x <= 2; x++) {
    for (int y = -2; y <= 2; y++) {
      for (int z = -2; z <= 2; z++) {
        pushMatrix(); 
        translate(100 * x, 100 * y, -100 * z); 
        box(50); 
        popMatrix();
      }
    }
  }
}
void keyPressed() {
  if (key == CODED) {
    if (key == CODED) {
      if (keyCode == UP) {
        depth -= 50;
      } else if (keyCode == DOWN) {
        depth += 50;
      }
    }
  }
}



//CUBE + SPHERE
/*
void settings() {
 size(500, 500, P3D);
 }
 void setup() {
 noStroke();
 }
 void draw() {
 background(200);
 lights(); //ajout de la lumière
 //ambient(20);
 camera(mouseX, mouseY, 450, 250, 250, 0, 0, 1, 0); //ajout de la possibilité de déplacer la "caméra"
 translate(width/2, height/2, 0);
 rotateX(PI/8);
 rotateY(PI/8);
 box(100, 80, 60);
 translate(100, 0, 0);
 sphere(50);
 }
 
 */




//SEMAINE 2?
/*
void settings() {
 size (400, 400, P2D);
 } 
 
 void draw() {
 My3DPoint eye = new My3DPoint(-100, -100, -5000);
 My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
 My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
 projectBox(eye, input3DBox).render();
 }
 void setup() {
 size(400, 400, P2D);
 }
 */

//SEMAINE 2
/*
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float[][] t = {{1, 0, 0, -eye.x}, 
    {0, 1, 0, -eye.y}, 
    {0, 0, 1, -eye.z}, 
    {0, 0, 0, 1}};
  float[][] P = {{1, 0, 0, 0}, 
    {0, 1, 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 1/-eye.z, 0}};
  float[][] tp = new float[4][4];

  for (int i = 0; i<4; ++i) {
    for (int j = 0; j<4; ++j) {
      float moyenne = 0;
      for (int k=0; k<4; ++k)
      {
        moyenne += t[i][k]*P[k][j];
      }
      tp[i][j] = moyenne;
    }
  }

  float[] xyz = {p.x, p.y, p.z, 1};

  float xp = tp[0][0]*xyz[0] + tp[0][1]*xyz[1] + tp[0][2]*xyz[2] + tp[0][3]*xyz[3];
  float yp = tp[1][0]*xyz[0] + tp[1][1]*xyz[1] + tp[1][2]*xyz[2] + tp[1][3]*xyz[3];
  My2DPoint point = new My2DPoint(xp, yp);
  return point;
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] points = new My2DPoint[box.p.length];
  for (int i=0; i < box.p.length; ++i) {
    points[i] = projectPoint(eye, box.p[i]);
  }
  My2DBox box2D = new My2DBox(points);

  return box2D;
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), -sin(angle), 0}, 
    {0, sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), 0, sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {-sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  // Complete the code!
  return(new float[][] {{cos(angle), -sin(angle), 0, 0}, 
    {sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  // Complete the code!
  return(new float[][] {{x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  // Complete the code!
  return(new float[][] {{1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}


float[] matrixProduct(float[][] a, float[] b) {
  float[] ab = new float [b.length];
  for (int i = 0; i<a.length; ++i) {
    float prov = 0;
    for (int j = 0; j<b.length; ++j) {
      prov += a[i][j]*b[j];
    }
    ab[i] = prov;
  }
  return ab;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] points = new My3DPoint[box.p.length];
  for (int i = 0; i < box.p.length; ++i) {
    float[] transitionPoints = {box.p[i].x, box.p[i].y, box.p[i].z, 1};
    points[i] = euclidian3DPoint(matrixProduct(transformMatrix, transitionPoints));
  }
  return new My3DBox(points);
}


My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}
*/