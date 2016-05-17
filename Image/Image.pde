PImage img; 
static int threshold = 255; 
HScrollbar thresholdBar1; // add a scrollbar on the bottom of the window
HScrollbar thresholdBar2; // upper scrollbar

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg"); 
  thresholdBar1 = new HScrollbar(0, 580, 800, 20); 
  thresholdBar2 = new HScrollbar(0, 555, 800, 20); 
  //noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {
  background(color(0, 0, 0)); // white background

  PImage result = createImage(width, height, RGB); 
  // 1. Thresholding:
  for (int i = 0; i < img.width * img.height; i++) {
   if(brightness(img.pixels[i]) >= threshold * 0.53) { //0.53
     result.pixels[i] = color(255,255,255); 
     }
  }
 
  // il faudrait modifier updatePixel ou un truc du genre (commentaire assistant)
  /*for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      if (hue(img.get(x, y)) <= (threshold * thresholdBar2.getPos()) && hue(img.get(x, y)) >= (threshold * thresholdBar1.getPos())) { 
        result.set(x, y, result.get(x, y));
      } else {
        result.set(x, y, color(0)); // sinon colore le pixel en noir
      }
    }
  }*/
  
  //2. Blur: 
  float[][] gaussianK = {{9,12,9}, {12,15,12}, {9,12,9}}; 
  result = convolute(result, gaussianK); 
  //3. Intensity thresholding:
  
  //4. Sobel: 
  PImage finalImage = sobel(result); 
  image(finalImage, 0,0); 

  //image(finalImage, 0, 0); 
  //float[][] k = {{9,12,9},{12,15,12},{9,12,9}}; 
  //PImage res = sobel(img); 
  //image(res, 0, 0); 

  //hough(finalImage);
   
  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar1.update();
  thresholdBar2.update();
}

/* ================== CONVOLUTE ================== */

PImage convolute(PImage img, float[][] kernel) { // devrait être correct. 
  //float[][] kernel = {{0,1,0}, {0,0,0}, {0,-1,0}};
  float N = kernel.length; // kernel size
  float weight = 0f; 
  for (int x = 0; x < kernel.length; x++) {
    for (int y = 0; y < kernel[0].length; y++) {
      weight += kernel[x][y];
    }
  }
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA); 
  for (int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      int li = 0; 
      float res = 0; 
      for (int a = (x - (int)N/2); a <= (x + (int)N/2); a++) {
        int col = 0; 
        for (int b = (y - (int)N/2); b <= (y + (int)N/2); b++) {
          res += brightness(img.get(a, b)) * kernel[li][col];
          col += 1;
        }
        li += 1;
      }
      res = res / weight;
      result.pixels[y * img.width + x] = color(res);
    }
  }
  /*PImage result = createImage(img.width, img.height, ALPHA); 
  for (int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      int li = 0; 
      float sum = 0;
      for (int a = (x - (int)N/2); a <= (x + (int)N/2); a++) {
        int col = 0; 
        for (int b = (y - (int)N/2); b <= (y + (int)N/2); b++) {
          sum += brightness(img.get(a, b)) * kernel[li][col]; 
          col += 1;
        }
        li += 1;
      }
      sum = sqrt(pow(sum, 2)); 
      result.pixels[y * img.width + x] = color(sum);
    }
  }*/

  return result;
} 

/* ================== SOBEL ================== */

PImage convoluteSobel(PImage img) { // devrait être correct. 
  float[][] hKernel= {{0, 1, 0}, {0, 0, 0}, {0, -1, 0}};
  float[][] vKernel= {{0, 0, 0}, {1, 0, -1}, {0, 0, 0}}; 

  float N = 3; // kernel size
  float max = 0f; 
  // create a greyscale image (type: ALPHA) for output
  float [] buffer = new float[img.width * img.height];
  PImage result = createImage(img.width, img.height, ALPHA); 
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

  // implement here the double convolution
  result = convoluteSobel(img);


  /*for (int y = 2; y < img.height - 2; y++) {
   for (int x = 2; x < img.width - 2; x++) {
   if(buffer[y * img.width + x] > (int)(max * 0.3f)) {
   result.pixels[y * img.width + x] = color(255); 
   } else { 
   result.pixels[y * img.width + x] = color(0); 
   }
   }
   }*/
  return result;
}

/* ================== HOUGH TRANSFORM ================== */

void hough(PImage edgeImg) {
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
/*
  //display accumulator  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(700, 700);

  houghImg.updatePixels();
  image(houghImg, 0, 0); // affiche l'image
  */
  
  //plot lines
  
  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      //Cartesian equation of a line: 
      //y = ax + b
      //in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      //=> y = 0 : 
      //x = r / cos(phi)
      //=> x = 0 : 
      //y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
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