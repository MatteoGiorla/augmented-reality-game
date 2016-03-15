float depth = 2000;
float speed = 1.0;
float rxSaved = 0.0;
float rzSaved = 0.0;
float mouseXSaved = 0.0;
float mouseYSaved = 0.0;
float rxImmobile = 0.0;
float rzImmobile = 0.0;

void settings() {
  size(1000, 700, P3D);
}

void setup () {
  noStroke();
}

void draw() {
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);
  background(200);
  if (mousePressed == true) {
    float mouseXmapped;
    float mouseYmapped;
    if (mouseY > height) {
      mouseYmapped = height;
    } else if (mouseY<0) {
      mouseYmapped = 0;
    } else {
      mouseYmapped=mouseY;
    }
    if (mouseX > width) {
      mouseXmapped = width;
    } else if (mouseX<0) {
      mouseXmapped = 0;
    } else {
      mouseXmapped=mouseX;
    }

    float rx = map(mouseXmapped - mouseXSaved + width/2, 0, width, (-PI/3), PI/3)*speed;
    float rz = map(mouseYmapped - mouseYSaved + height/2, 0, height, (-PI/3), PI/3)*speed;
    rotateX(rx);
    rotateZ(rz);
    rxSaved = rx;
    rzSaved = rz;
    /*
    if(rxSaved > PI/3){
      rxSaved=PI/3;
    }
    else if(rxSaved < -PI/3){
      rxSaved = -PI/3;
    }
    if(rzSaved > PI/3){
      rzSaved=PI/3;
    }
    else if(rzSaved < -PI/3){
      rzSaved = -PI/3;
    }
    */
    rxImmobile = rxSaved;
    rzImmobile = rzSaved;
  }
  else{
    mouseXSaved = mouseX;
    mouseYSaved = mouseY;
    rotateX(rxImmobile);
    rotateZ(rzImmobile);
  }
  box(1000, 50, 1000);
}

void mouseWheel(MouseEvent event) {
  float wheelCount;
  wheelCount = event.getCount();
  if (wheelCount>1.5) {
    speed = 1.5;
  } else if (wheelCount <0.2) {
    speed = 0.2;
  } else {
    speed = wheelCount;
  }
}

float bound(float toBound, float lowerBound, float upperBound){
	if(toBound > upperBound){
		return upperBound;
	}else if(toBound < lowerBound){
		return lowerBound;
	}else{
		return toBound;
	}
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}