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
  background(color(0,0,0)); // white background
  PImage result = createImage(width, height, RGB); 
  /*for (int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i]) >= threshold * thresholdBar1.getPos()) {
      result.pixels[i] = color(255,255,255); 
  }
  }*/
  
  /*for (int i = 0; i < img.width * img.height; i++) {
    println(color(hue(img.pixels[i])) +">="+ threshold +"*"+ thresholdBar1.getPos());
    if(color(hue(img.pixels[i])) >= threshold * thresholdBar1.getPos() || color(hue(img.pixels[i])) <= threshold * thresholdBar2.getPos()) {
      print("bonjour"); 
      result.pixels[i] = img.pixels[i];
    } else {
      result.pixels[i] = color(255, 255, 255); 
    }
  }*/
  // il faudrait modifier updatePixel ou un truc du genre (commentaire assistant)
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      if (hue(img.get(x,y)) <= (threshold * thresholdBar2.getPos()) && hue(img.get(x,y)) >= (threshold * thresholdBar1.getPos())) { 
        result.set(x,y,img.get(x,y));
      } else {
        result.set(x,y,color(0)); // sinon colore le pixel en noir
      }
    }
  }
  
  //image(result, 0, 0); //première partie 
  
  image(sobel(img), 0, 0); 
  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar1.update();
  thresholdBar2.update();
}

PImage convolute(PImage img, float[][] kernel) { // pas certain de cette méthode.
  //float[][] kernel = {{0,1,0}, {0,0,0}, {0,-1,0}};
  float N = 3; // kernel size
  float weight = 1.f;
  // create a greyscale image (type: ALPHA) for output
  float res = 0; 
  PImage result = createImage(img.width, img.height, ALPHA); 
  for (int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      // multiply intensities for pixels in the range
      /*float res = 0; 
      int a = x - (int)N/2; 
      //int b = y - (int)N/2; 
      int li = 0; 
      while(a <= (x + N/2)) {
        int b = y - (int)N/2; 
        int col = 0; 
        while(b <= (y + N/2)) {
          res += brightness(img.get(a,b)) * kernel[li][col];
      //result.pixels[y * img.widht + x] =
      b += 1; 
      col += 1;
    }
    a += 1; 
    li += 1; 
  }*/
  int li = 0; 
  for (int a = (x - (int)N/2); a <= (x + (int)N/2); a++) {
    int col = 0; 
    for (int b = (y - (int)N/2); b <= (y + (int)N/2); b++) {
      res += brightness(img.get(a,b)) * kernel[li][col];
      col += 1; 
    }
    li += 1; 
  }
    
  res = res / weight;
  result.pixels[y * img.width + x] = color(res);
    }
  }
  
  return result; 
} 

PImage sobel(PImage img) {
  float[][] hKernel= {{0,1,0}, {0,0,0},{0,-1,0}};
  float[][] vKernel= {{0,0,0}, {1,0,-1}, {0,0,0}}; 
  PImage result = createImage(img.width, img.height, ALPHA); 
  
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0); // noir
  }
  
  float max = 0; 
  float [] buffer = new float[img.width * img.height];
  
  // implement here the double convolution
  PImage inter = convolute(result, hKernel);
  result = convolute(inter, vKernel); 
  
  for (int y = 2; y < img.height - 2; y++) {
    for (int x = 2; x < img.width - 2; x++) {
      if(buffer[y * img.width + x] > (int)(max * 0.3f)) {
        result.pixels[y * img.width + x] = color(255); 
      } else { 
        result.pixels[y * img.width + x] = color(0); 
      }
    }
  }
  return result; 
}