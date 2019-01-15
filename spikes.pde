/**
* Effect with spikes around body contours with Kinect xBox One input.
* Spikes script by Katerina Labrou
* Artistic collaboration with Maria Vlachostergiou
*
* Adaptation of "Hairy CV Blobs" script by Tassos Kanellos + Anna Laskari
*
* MIT License
* Copyright (c) 2018 Katerina Labrou
*/

import KinectPV2.*;
import gab.opencv.*;
import toxi.geom.*;

KinectPV2 kinect;
OpenCV opencv;

//1/SET SCREEN RESOLUTION
int screenWidth = 1920;
int screenHeight = 1080;

//2/SET FRAMERATE
int fps = 30; 

//3/SET KINECT THRESHOLD, in mm 
int kinectMinThreashold = 600; 
int kinectMaxThreashold = 4000; 

//4/SET CONTOUR RESOLUTION (2 > 4 > 16 ..)
int scaleFactor = 2;  // power of 2
int scaleWidth = screenWidth / scaleFactor;
int scaleHeight =  screenHeight / scaleFactor;

PImage bodyTrackImg;  
Effect spikes;

void settings () {
  size(screenWidth, screenHeight, P3D);
}

void setup () {
  background(255);
  kinectSetup();
  log("Kinect finished!");
  opencv = new OpenCV(this, screenWidth, screenHeight);
  //Wait a few seconds for kinect and osc initialization
  delay(3000);             
  log("App started!");
  frameRate(fps);  
  spikes = new Effect(this, screenWidth, screenHeight, scaleWidth, scaleHeight, scaleFactor);
}

void draw () {
  spikes.display();
}

void log(String msg) {
  println();
  println("[*] Msg: " + msg);
  println();
}

void kinectSetup() {
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  kinect.enablePointCloud(true);
  kinect.setLowThresholdPC(kinectMinThreashold);
  kinect.setHighThresholdPC(kinectMaxThreashold);
  kinect.enableDepthImg(true);
  kinect.enableSkeleton3DMap(true);
  kinect.enableBodyTrackImg(true);
  kinect.init();
}
