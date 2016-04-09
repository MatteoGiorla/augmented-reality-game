void settings() {
  size(1000, 1000, P2D);
}
void setup () {
}
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
 //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  
  /*//ajouté pour voir
  //rotated around y
  float[][] transform42 = rotateYMatrix(PI/9);
  input3DBox = transformBox(input3DBox, transform42);
  projectBox(eye, input3DBox).render();*/
  
  
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

//Fonctions de transformations

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0, -sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), sin(angle), 0, 0}, 
    {-sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {{x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

//fonctions qui appliquent les transformations

float[] matrixProduct(float[][] a, float[] b) {
  float[] result = new float[b.length];
  for (int i = 0; i < a.length; ++i) {
    float moyenne = 0;
    for (int k= 0; k < b.length; ++k) {
      moyenne = moyenne + a[i][k]*b[k];
    }
    result[i] = moyenne;
  }
  return result;
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

//fonctions de projections

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  int lengthP = box.p.length; 
  My2DPoint[] twoDPoints = new My2DPoint[lengthP];
  for (int i = 0; i < lengthP; ++i) {
    twoDPoints[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(twoDPoints);
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float[][] P = { {1, 0, 0, -eye.x}, 
    {0, 1, 0, -eye.y}, 
    {0, 0, 1, -eye.z}, 
    {0, 0, 0, 1} };
  float[][] T = { {1, 0, 0, 0}, 
    {0, 1, 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 1/(-eye.z), 0} }; 

  float[][] PT = new float[4][4];
  for (int i = 0; i < P.length; ++i) {
    for (int j = 0; j < T.length; ++j) {
      float moyenne = 0;
      for (int k= 0; k < PT.length; ++k) {
        moyenne = moyenne + P[i][k]*T[k][j];
      }
      PT[i][j] = moyenne;
    }
  }
  float xP = PT[0][0]*p.x + PT[0][1]*p.y + PT[0][2]*p.z + PT[0][3]; 
  float yP = PT[1][0]*p.x + PT[1][1]*p.y + PT[1][2]*p.z + PT[1][3];
  return new My2DPoint(xP, yP);
}