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

int w = 640;
int h = 480;

PImage testImage;
int rectW = 150;
int rectH = 150;

int currentLabel = 0;
boolean trained = false;

int numClasses = 2;

TreeMap<Double, HashMap> sortedClassesSnapshot;
TreeMap<Double, HashMap> sortedClasses;

PImage defaultImage;

boolean activeMode = false;

PGraphics activeDisplay;
PImage imageToClassify;

boolean activeModeAllowed = true;

import psvm.*;
SVM model;

void setup() {
  opencv = new OpenCV(this, 50, 50);
  classifier = new Libsvm(this);
  classifier.setNumFeatures(1728);
  video = new Capture(this, w/2, h/2, "FaceTime HD Camera", 30);
  video.start();
  
  model = new SVM(this);
  model.loadModel("classifier.txt", 1728);
  size(750, 600);
  
  trainingSamples = new ArrayList<Sample>();

  classImages = new ArrayList<ArrayList<PImage>>();
  for (int i = 0; i < numClasses; i++) {
    classImages.add(new ArrayList<PImage>());
  }

  testImage = createImage(50, 50, RGB);
  defaultImage = createImage(50, 50, RGB);
  for (int i = 0; i < defaultImage.pixels.length; i++) {
    defaultImage.pixels[i] = color(0, 255, 0);
  }

  imageToClassify = createImage(rectW, rectH, RGB);
  activeDisplay = createGraphics(400, 300);
  control = new ControlP5(this);
}

void draw() {
  background(0);
  image(video, 0, 0);
  noFill();
  stroke(255, 0, 0);
  strokeWeight(5);
  rect(video.width - rectW - (video.width - rectW)/2, video.height - rectH - (video.height - rectH)/2, rectW, rectH);
  testImage.copy(video, video.width - rectW - (video.width - rectW)/2, video.height - rectH - (video.height - rectH)/2, rectW, rectH, 0, 0, 50, 50);

  if (trained) {
    double[] confidence = new double[numClasses];
    double prediction = classifier.predict( new Sample(gradientsForImage(testImage )), confidence);
    text("label: " + prediction, w/2+70, 60);
  }

  text("(a)dd label to: " + currentLabel, 10, h/2 + 20);
  text("(t)rain", 10, h/2+40);

  image(testImage, w/2+ 10, 0);
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
