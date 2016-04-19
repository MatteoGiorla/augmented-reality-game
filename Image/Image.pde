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
  
  //image(result, 0, 0); 
  image(convolute(img), 0, 0); 
  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar1.update();
  thresholdBar2.update();
}

PImage convolute(PImage img) {
  float[][] kernel = {{0,0,0}, {0,2,0}, {0,0,0}};
  float N = 3; // kernel size
  float weight = 1.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA); 
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      // multiply intensities for pixels in the range
      float res = 0; 
      int a = x - (int)N/2; 
      int b = y - (int)N/2; 
      while(a <= (x + N/2)) {
        while(b <= (y + N/2)) {
          res += brightness(img.get(a,b)) * weight;
      //result.pixels[y * img.widht + x] =
      b += 1; 
    }
    a += 1; 
  }
  res = res / weight;
  result.pixels[y * img.width + x] = color(res);
    }
  }
  
  return result; 
} 