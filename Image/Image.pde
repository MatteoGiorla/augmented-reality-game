import processing.video.*;
import java.util.Collections;

PImage imgStatic; 
Capture cam;
static int threshold = 255; 
HScrollbar thresholdBar1; // add a scrollbar on the bottom of the window
HScrollbar thresholdBar2; // upper scrollbar
static float th1 = 0.5;
static float th2 = 1.0;

void settings() {
  size(800, 600);
}

void setup() {
  imgStatic = loadImage("board1.jpg"); 
  thresholdBar1 = new HScrollbar(0, 580, 800, 20); 
  thresholdBar2 = new HScrollbar(0, 555, 800, 20); 
  camera_setup();
  //noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {
  PImage img = imgStatic;
  if (cam.available() == true) {
    cam.read();
    img = cam.get();
  }
  image(img, 0, 0);
  PImage result = createImage(img.width, img.height, RGB); 

  //1. Thresholding:
  //Hue
  for (int x = 0; x < img.width * img.height; x++) {
    if ((hue(img.pixels[x]) > 90 && hue(img.pixels[x]) < 150)) { 
      result.pixels[x] = img.pixels[x];
    } else {
      result.pixels[x] = color(0); // sinon colore le pixel en noir
    }
  }
  //Brightness
  for (int i = 0; i < img.width * img.height; i++) {
    if ((brightness(img.pixels[i]) > threshold * th1) && (brightness(img.pixels[i]) < threshold * th2)) { //0.53
      result.pixels[i] = color(255);
    } else {
      result.pixels[i] = color(0);
    }
  }

  //2. Blur: 
  float[][] gaussianK = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}}; 
  result = convolute(result, gaussianK); 

  //3. Intensity thresholding:

  //4. Sobel: 
  result = sobel(result); 
  //image(result, 0, 0);

  hough(result, 15);
  /*
  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar1.update();
  thresholdBar2.update();*/
}

/* ================== CAMERA SETUP ================== */
void camera_setup() {
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}
/* ================== CONVOLUTE ================== */

PImage convolute(PImage img, float[][] kernel) {
  float weight = 0f; 
  float N = kernel.length;
  for (int x = 0; x < N; x++) {
    for (int y = 0; y < kernel[x].length; y++) {
      weight += kernel[x][y];
    }
  }
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, RGB); 

  float res;

  for (int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      res = 0; 
      for (int a = -1; a < 2; a++) {
        for (int b = -1; b < 2; b++) {
          res += brightness(img.get(x + a, y + b)) * kernel[a + 1][b + 1];
        }
      }
      res = res / weight;
      result.pixels[y * img.width + x] = color(res);
    }
  }

  return result;
} 

/* ================== SOBEL ================== */

PImage sobel(PImage img) { // intensité du blanc pas assez marquée!
  float[][] hKernel = {{0, 1, 0}, {0, 0, 0}, {0, -1, 0}};
  float[][] vKernel = {{0, 0, 0}, {1, 0, -1}, {0, 0, 0}};
  PImage result = createImage(img.width, img.height, ALPHA); 

  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0); // noir
  }

  float max = 0; 
  float [] buffer = new float[img.width * img.height];

  float N = 3; // kernel size
  for (int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      int li = 0; 
      float sum = 0;
      float sum_h = 0; 
      float sum_v = 0; 
      for (int a = (x - (int)N/2); a <= (x + (int)N/2); a++) {
        int col = 0; 
        for (int b = (y - (int)N/2); b <= (y + (int)N/2); b++) {
          sum_h += brightness(img.get(a, b)) * hKernel[li][col]; 
          sum_v += brightness(img.get(a, b)) * vKernel[li][col];
          col += 1;
        }
        li += 1;
      }
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[y * img.width + x] = sum; 
      if (sum > max) {
        max = sum;
      }
    }
  }

  for (int x = 2; x < img.width - 2; x++) {
    for (int y = 2; y < img.height - 2; y++) {
      int index = y * img.width + x; 
      if (buffer[index] > (max * 0.3)) {
        result.pixels[index] = color(255);
      } else {
        result.pixels[index] = color(0);
      }
    }
  }

  return result;
}

/* ================== HOUGH TRANSFORM ================== */


void displayAccumulator(int[] accumulator, int rDim, int phiDim) {
  //display accumulator  
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
   for (int i = 0; i < accumulator.length; i++) {
   houghImg.pixels[i] = color(min(255, accumulator[i]));
   }
   // You may want to resize the accumulator to make it easier to see:
   houghImg.resize(400, 400);
   
   houghImg.updatePixels();
   image(houghImg, 0, 0); // affiche l'image
}

void displayPlotLines(PImage edgeImg, ArrayList<Integer> candidates, int[] accumulator, int rDim, float discretizationStepsR, float discretizationStepsPhi) {
  for (Integer idx : candidates) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2); 
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
}

void hough(PImage edgeImg, int nLines) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;

  // dimension of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi); 
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

  //Fill
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        // Fill
        for (float phi = 0f; phi < Math.PI; phi += discretizationStepsPhi) {
          float r = x*cos(phi) + y*sin(phi); 
          int rInt = (int)(r / discretizationStepsR);
          rInt += (rDim - 1)/2;
          int phiInt = (int)(phi / discretizationStepsPhi);
          accumulator[((phiInt+1) * (rDim+2) + (rInt+1))] += 1;
        }
      }
    }
  }
  
  //selecting best candidates in the accumulator array
  int minVotes = 198; //purement arbitraire pour l'instant
  ArrayList<Integer> bestCandidates = selectBestCandidates(accumulator, minVotes, rDim, phiDim);
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  if(nLines < bestCandidates.size()){
    bestCandidates = new ArrayList<Integer>(bestCandidates.subList(0, nLines));
  }
  
  //display hough image
  //displayAccumulator(accumulator, rDim, phiDim);

  //plot lines
  displayPlotLines(edgeImg, bestCandidates, accumulator, rDim, discretizationStepsR, discretizationStepsPhi);
}

//will return a selection Arraylist of the indexes of the accumulator having at most "minVotes" votes.
ArrayList<Integer> selectBestCandidates(int[] accumulator, int minVotes, int rDim, int phiDim) {
  ArrayList<Integer> bests = new ArrayList<Integer>();// size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bests.add(idx);
        }
      }
    }
  }
  return bests;
}