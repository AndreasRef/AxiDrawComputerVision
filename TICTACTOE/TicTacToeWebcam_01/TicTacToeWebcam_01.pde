import processing.video.*;
import controlP5.*;

import gab.opencv.*;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Scalar;
import org.opencv.core.TermCriteria;

import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfPoint;

import org.opencv.objdetect.HOGDescriptor;

import org.opencv.core.Size;
import org.opencv.core.Scalar;
import org.opencv.core.Core;

import java.util.Map;
import java.util.Arrays;
import java.util.TreeMap;
import java.util.Collection;

Libsvm classifier;
OpenCV opencv;

Capture video;
ControlP5 control;

ArrayList<ArrayList<PImage>> classImages;
ArrayList<Sample> trainingSamples;

PImage testImage;
int rectW;
int rectH;

int currentLabel = 0;
boolean trained = false;

int numClasses = 3;

TreeMap<Double, HashMap> sortedClassesSnapshot;
TreeMap<Double, HashMap> sortedClasses;

PGraphics drawingCanvas;

boolean activeModeAllowed = true;

String[] categories = {"intet", "kryds", "bolle"};

//String[] cellPredictions

import psvm.*;
SVM model;

void setup() {
  size(640, 480);
  opencv = new OpenCV(this, 50, 50);
  classifier = new Libsvm(this);
  classifier.setNumFeatures(1728);
  //video = new Capture(this, w/2, h/2, "FaceTime HD Camera", 30);
  //video.start();
  
  model = new SVM(this);
  model.loadModel("classifier.txt", 1728);
  
  trainingSamples = new ArrayList<Sample>();

  classImages = new ArrayList<ArrayList<PImage>>();
  for (int i = 0; i < numClasses; i++) {
    classImages.add(new ArrayList<PImage>());
  }
  
  drawingCanvas = createGraphics(width/2, height/2);
  drawingCanvas.beginDraw();
  drawingCanvas.background(255);
  drawingCanvas.endDraw();
  
  rectW = drawingCanvas.width/3;
  rectH = drawingCanvas.height/3;
  
  testImage = createImage(50, 50, RGB);
  
  classifier.load("classifier.txt");
  trained = true;
  println("classifier loaded");
}

void draw() {
  background(0);
  drawingCanvas.beginDraw();
  drawingCanvas.fill(0);
  if (mousePressed) drawingCanvas.ellipse(mouseX, mouseY, 15, 15);
  drawingCanvas.endDraw();
  image(drawingCanvas, 0, 0);
  
  //image(video, 0, 0);
  noFill();
  stroke(255, 0, 0);
  strokeWeight(5);
  //rect(drawingCanvas.width - rectW - (drawingCanvas.width - rectW)/2, drawingCanvas.height - rectH - (drawingCanvas.height - rectH)/2, rectW, rectH);
  rect(2*drawingCanvas.width/3, 2*drawingCanvas.height/3, rectW, rectH);
  testImage.copy(drawingCanvas, drawingCanvas.width - rectW - (drawingCanvas.width - rectW)/2, drawingCanvas.height - rectH - (drawingCanvas.height - rectH)/2, rectW, rectH, 0, 0, 50, 50);
  
  //Tic-Tac-Toe grid
  pushStyle();
  noFill();
  stroke(255,0,0);
  strokeWeight(1);
  for (int x = 0; x<3; x++) {
    for (int y = 0; y<3; y++) {
      rect(x*drawingCanvas.width/3, y*drawingCanvas.height/3, drawingCanvas.width/3, drawingCanvas.height/3);
      if (trained) {
        testImage.copy(drawingCanvas, x*drawingCanvas.width/3, y*drawingCanvas.height/3, drawingCanvas.width/3, drawingCanvas.height/3, 0, 0, 50, 50);
        //testImage.copy(drawingCanvas,(int) x*drawingCanvas.width/3,(int) y*drawingCanvas.height/3,(int) drawingCanvas.width/3,(int) drawingCanvas.height/3, rectW, rectH, 0, 0, 50, 50);
        String output = "";
        double[] confidence = new double[numClasses];
        double prediction = classifier.predict( new Sample(gradientsForImage(testImage )), confidence);
        output = categories[(int)prediction];
        text (output, x*drawingCanvas.width/3+5, y*drawingCanvas.height/3+15);
      }
    }
  }
  popStyle();
   
  fill(0,255,0);
  if (trained) {
    double[] confidence = new double[numClasses];
    double prediction = classifier.predict( new Sample(gradientsForImage(testImage )), confidence);
    
    text("prediction: " + categories[(int)prediction], 10, height/2 + 60);
  }
  
  text("(a)dd label to: " + categories[currentLabel], 10, height/2 + 20);
  text("(t)rain", 10, height/2+40);
  image(testImage, width-50, 0);
}

void keyPressed() {
  if (keyCode == RIGHT) {
    currentLabel++;
    if (currentLabel == numClasses) {
      currentLabel = 0;
    }
  }
  if (keyCode == LEFT) {
    currentLabel--;
    if (currentLabel < 0) {
      currentLabel = numClasses-1;
    }
  }

  if (key == 'a') {
    classifier.addTrainingSample( new Sample(gradientsForImage( testImage, currentLabel ), currentLabel) );
    drawingCanvas.beginDraw();
    drawingCanvas.background(255);
    drawingCanvas.endDraw();
  }

  if (key == 't') {
    classifier.train();
    trained = true;
  }
  
  if (key == 's') {
    classifier.save("classifier.txt");
    println("classifier saved");
  }
  
  if (key == 'l') {
    classifier.load("classifier.txt");
    trained = true;
    println("classifier loaded");
  }
  
  if (key == 'r') {
    classifier.reset();
    println("classifier reset");
  }
  
  if (key == 'c') {
    drawingCanvas.beginDraw();
    drawingCanvas.background(255);
    drawingCanvas.endDraw();
  }
}

void captureEvent(Capture c) {
  c.read();
}

float[] gradientsForImage(PImage img, int label) {
  img.resize(50, 50);
  img.updatePixels();
  PImage labeledImage = createImage(50, 50, RGB);
  labeledImage.copy(img, 0, 0, 50, 50, 0, 0, 50, 50);
  labeledImage.updatePixels();
  classImages.get(label).add(labeledImage);
  return gradientsForImage(img);
}

float[] gradientsForImage(PImage img) {
  // resize the images to a consistent size:
  opencv.loadImage(img);

  Mat angleMat, gradMat;
  Size winSize = new Size(40, 24);
  Size blockSize = new Size(8, 8);
  Size blockStride = new Size(16, 16);
  Size cellSize = new Size(2, 2);
  int nBins = 9;
  Size winStride = new Size(16, 16);
  Size padding = new Size(0, 0);

  HOGDescriptor descriptor = new HOGDescriptor(winSize, blockSize, blockStride, cellSize, nBins);

  MatOfFloat descriptors = new MatOfFloat();
  MatOfPoint locations = new MatOfPoint();
  descriptor.compute(opencv.getGray(), descriptors, winStride, padding, locations);

  return descriptors.toArray();
}
