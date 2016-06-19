import processing.video.*;
import java.util.*;


public class ImageProcessing {

  PImage imgStatic;
  PImage accumulatorResult;
  PImage sobelResult;
  Capture cam;
  HScrollbar thresholdBar1; // add a scrollbar on the bottom of the window
  HScrollbar thresholdBar2; // upper scrollbar
  float th1 = 0.5;
  float th2 = 1.0;
  
  QuadGraph graph = new QuadGraph();
  List<int[]> quadsForRot;
  TwoDThreeD twoDthreeD;

  //constructeur professionel
  ImageProcessing() {
  };

  PVector processingImage(PImage img, int img_width, int img_height) {
    println(img);
    twoDthreeD = new TwoDThreeD(img_width, img_height);

    //1. Thresholding:
    //Saturation
    PImage satuResult = saturationFilter(img);

    //Hue
    PImage hueResult = hueFilter(satuResult); 

    //Brightness
    PImage brightResult = brightFilter(hueResult);

    //2. Blur: 
    float[][] gaussianK = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}}; 
    PImage convResult = convolute(brightResult, gaussianK);

    //3. Intensity thresholding: (Maybe not)


    //4. Sobel: 
    PImage result = sobel(convResult);
    sobelResult = result;

    //Hough
    ArrayList<PVector> houghArray = hough(result, 4);
    ArrayList<PVector> intersections = getIntersections(houghArray);

    //Quads
    quadsForRot = graph.build(houghArray, img_width, img_height);
    return getRotation(quadsForRot);
  }


  /* ================== FILTERS ================== */

  PImage hueFilter(PImage image) {
    PImage result = createImage(image.width, image.height, RGB);
    for (int x = 0; x < image.width * image.height; x++) {
      if ((hue(image.pixels[x]) > 34 && hue(image.pixels[x]) < 138)) { 
        result.pixels[x] = image.pixels[x];
      } else {
        result.pixels[x] = color(0); // sinon colore le pixel en noir
      }
    }
    return result;
  }

  PImage brightFilter(PImage image) {
    PImage result = createImage(image.width, image.height, RGB);
    for (int i = 0; i < image.width * image.height; i++) {
      if ((brightness(image.pixels[i]) > 30) && (brightness(image.pixels[i]) < 150)) { //0.53
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }
    return result;
  }

  PImage saturationFilter(PImage image) {
    PImage result = createImage(image.width, image.height, RGB);
    for (int i = 0; i < image.width * image.height; i++) {
      if ((saturation(image.pixels[i]) > 100)) {
        result.pixels[i] = image.pixels[i];
      } else {
        result.pixels[i] = color(0);
      }
    }
    return result;
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
      // cam = new Capture(this, cameras[0]);
      //cam.start();
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
        int li = 0; 
        res = 0; 
        for (int a = (x - (int)N/2); a <= (x + (int)N/2); a++) {
          int col = 0; 
          for (int b = (y - (int)N/2); b <= (y + (int)N/2); b++) {
            res += brightness(img.get(a, b)) * kernel[li][col];
            col += 1;
          }
          li += 1;
          res = res / weight;
          result.pixels[y * img.width + x] = color(res);
        }
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
    houghImg.resize(600, 600);

    houghImg.updatePixels();
    accumulatorResult = houghImg;
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
  void precomputeSinCos(float[] tabSin, float[] tabCos, float discretizationStepsPhi) {
    float ang = 0;
    for (int accPhi = 0; accPhi < tabSin.length; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang));
      tabCos[accPhi] = (float) (Math.cos(ang));
    }
  }


  ArrayList<PVector> hough(PImage edgeImg, int nLines) {

    ArrayList<PVector> detectedLines = new ArrayList<PVector>();

    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;

    // dimension of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi); 
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    // Tableau possédant les valeurs de Cosinus et Sinus précalculées.
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];

    precomputeSinCos(tabSin, tabCos, discretizationStepsPhi);

    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

    //Fill
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // Fill
          for (int phi = 0; phi < phiDim; ++phi) {
            float r = x*tabCos[phi] + y*tabSin[phi];
            int rInt = (int)(r / discretizationStepsR);
            rInt += (rDim - 1)/2;
            accumulator[((phi+1) * (rDim+2) + (rInt+1))] += 1;
          }
        }
      }
    }

    //selecting best candidates in the accumulator array
    int minVotes = 198; //purement arbitraire pour l'instant
    ArrayList<Integer> bestCandidates = selectBestCandidates(accumulator, minVotes, rDim, phiDim);
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    if (nLines < bestCandidates.size()) {
      bestCandidates = new ArrayList<Integer>(bestCandidates.subList(0, nLines));
    }

    //display hough image
    displayAccumulator(accumulator, rDim, phiDim);

    //plot lines
    displayPlotLines(edgeImg, bestCandidates, accumulator, rDim, discretizationStepsR, discretizationStepsPhi);

    for (Integer idx : bestCandidates) {
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;

      detectedLines.add(new PVector(r, phi));
    }

    return detectedLines;
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


  ArrayList<PVector> getIntersections(List<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to ’intersections’
        float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
        float x = (line2.x*sin(line1.y) - line1.x * sin(line2.y))/d;
        float y = (- line2.x*cos(line1.y) + line1.x * cos(line2.y))/d;

        intersections.add(new PVector(x, y));

        // draw the intersection 
        fill(255, 128, 0); 
        ellipse(x, y, 10, 10);
      }
    }
    return intersections;
  }

  PVector getRotation(List<int[]> quadsForRot) {
    if(quadsForRot.size() != 0){
    PVector vector = new PVector(quadsForRot.get(0)[0], quadsForRot.get(0)[1]);
    PVector vector1 = new PVector(quadsForRot.get(0)[1], quadsForRot.get(0)[2]);
    PVector vector2 = new PVector(quadsForRot.get(0)[2], quadsForRot.get(0)[3]);
    PVector vector3 = new PVector(quadsForRot.get(0)[3], quadsForRot.get(0)[0]);

    List<PVector> list = new ArrayList<PVector>();
    list.add(vector);
    list.add(vector1);
    list.add(vector2);
    list.add(vector3);
    
    return twoDthreeD.get3DRotations(graph.sortCorners(list));
    }
    else{
      return new PVector(0, 0);
    }
  }
}