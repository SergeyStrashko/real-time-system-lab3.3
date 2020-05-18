Simulator ga;
String task;

int numOfCoeffs = 4;
int populationSize = numOfCoeffs;
int[] result = {0};

void setup() {
  ga = new Simulator(numOfCoeffs, populationSize, (int)random(0, 80));
  ga.setUpParents();
  task = ga.getTask();
  
  fullScreen();
  orientation(LANDSCAPE); 
  show();
}

void show() {
  background(150);
  int textSize = (height > width) ? (int)(width*0.10) : (int)(height*0.10);
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(textSize);
  text("Genetic alrorithm", width/2, height*0.10);
  text("Settings", width*0.25, height*0.35);
  text("Results", width*0.75, height*0.35);
  
  textSize = (height > width) ? (int)(width*0.05) : (int)(height*0.05);
  textSize(textSize);
  textAlign(LEFT, CENTER);
  text("Num of coeffs:\t" + numOfCoeffs, width*0.05, height*0.6);
  
  textSize = (height > width) ? (int)(width*0.04) : (int)(height*0.04);
  textSize(textSize);
  textAlign(CENTER, CENTER);
  text(task, width/2, height*0.25); 
  text(Arrays.toString(result), width*0.75, height*0.70);
  
  line(0, height*0.15, width, height*0.15);
  line(0, height*0.30, width, height*0.30);
  line(width/2, height*0.3, width/2, height);
  line(0, height*0.42, width, height*0.42);
  
  fill(200);
  rectMode(CORNERS);
  rect(0, height*0.75, width/2, height);
  textSize = (height > width) ? (int)(width*0.10) : (int)(height*0.10);
  textSize(textSize);
  fill(15);
  text("REFRESH", width*0.25, height*0.875);
}

void draw() {
  show();
  
  if (result.length == 1) {
    result = ga.run();
  } else {
    if (mousePressed) {
      if(mouseX > 0 && mouseX < width/2 && mouseY > height*0.875) {
        result = new int[1];
        numOfCoeffs = 4;
        populationSize = numOfCoeffs;
        
        ga = new Simulator(numOfCoeffs, populationSize, (int)random(50, 100));
        ga.setUpParents();
        task = ga.getTask();
        show();
      }
    }
  }
}
