void settings() {
  size(1000, 1000, P2D);
}
void setup () {
}
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(1000, 300, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  //rotated around x 
  float[][] transform1 = rotateXMatrix(PI/8); 
  input3DBox = transformBox(input3DBox, transform1); 
  projectBox(eye, input3DBox).render();
  //rotated and translated 
  float[][] transform2 = translationMatrix(200, 200, 0); 
  input3DBox = transformBox(input3DBox, transform2); 
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled 
  float[][] transform3 = scaleMatrix(2, 2, 2); 
  input3DBox = transformBox(input3DBox, transform3); 
  projectBox(eye, input3DBox).render();
}


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