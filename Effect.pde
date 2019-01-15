class Effect {
  PApplet parent;
  PGraphics pg;
  boolean show;
  int w;
  int h;
  
  PGraphics scale;
  OpenCV ocv;
  int sw;
  int sh;
  int sFactor;
  static final float CALIBRATION_FACTOR = 1; // calibrate shadow on human

  int delay = 250;
  int removalRate = 1;
  int rectFillColor = 20;
  int rectFillOpacity = 10;
  ArrayList<KSkeleton> skeletons;
  
  int brLvl = 0; 
  float contrastLvl = 1; 
  int blurVal = 4; 
  int thr = 128; 
  float polyFactor = 3.5; 
  float subDivStepSz = 30;
  float subdivLnLgt = 20; 
  
  Effect(PApplet _parent, int _w, int _h, int _sw, int _sh, int _s) {
    parent = _parent;
    pg = createGraphics(_w, _h, P2D);
    show = false;
    w = _w;
    h = _h; 
    sw = _sw;
    sh = _sh;
    sFactor = _s;
    scale = createGraphics(_sw, _sh, P2D);
    ocv = new OpenCV(_parent, _sw, _sh); 
  }

  
  void getSkeleton() {
    skeletons = kinect.getSkeleton3d();
    for (int i = 0; i < skeletons.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletons.get(i);
      if (skeleton.isTracked()) {
        KJoint[] joints = skeleton.getJoints();
        PVector xyRight = new PVector(joints[KinectPV2.JointType_HandRight].getX(), joints[KinectPV2.JointType_HandRight].getY());
        float mappedLeftY = map(xyRight.y, 1, -1.5, 0, screenHeight); // pos kinect -> 0
        setSpikes(mappedLeftY);
      }
    }
  }
  
  //Map Spikes on y-axis
  void setSpikes(float ly) {
    ly = map(ly, screenHeight - 500, 0, 0, 1);
    subdivLnLgt = ly * random(150, 500);
  }
  
  void display() {
    getSkeleton();
    bodyTrackImg = kinect.getBodyTrackImage();
    PImage flipImage = mirror(bodyTrackImg);
    
    scale.beginDraw();
    scale.image(flipImage, 0, 0, sw , sh);
    scale.endDraw();
    
    ocv.loadImage(scale);
    ocv.brightness(brLvl); 
    ocv.contrast(contrastLvl); 
    ocv.blur(blurVal); 
    ocv.threshold(thr); 
    ocv.invert(); 
    
    ArrayList<Contour> contours = ocv.findContours(true, true);
    
    pg.beginDraw();
    pg.fill(rectFillColor, rectFillOpacity);
    pg.rect(0, 0, w, h);

    if (contours.size() > 0) {
      for (Contour c : contours) 
      {
        c.setPolygonApproximationFactor(polyFactor);
        Contour poly = c.getPolygonApproximation();
    
        ArrayList<PVector> polyPts = poly.getPoints(); 

        pg.beginShape();
        
        for (int i = 0; i < polyPts.size (); i++)
        {
          PVector pvec1 = polyPts.get(i); 
          PVector pvec2;
          if (i == polyPts.size() - 1) {
            pvec2 = polyPts.get(0);
          } else {
            pvec2 = polyPts.get(i+1);
          } 
          
          Vec2D pt1 = new Vec2D(pvec1.x * scaleFactor * CALIBRATION_FACTOR + 100, pvec1.y * scaleFactor * CALIBRATION_FACTOR);
          Vec2D pt2 = new Vec2D(pvec2.x * scaleFactor * CALIBRATION_FACTOR + 100, pvec2.y * scaleFactor * CALIBRATION_FACTOR);
          subdivideLn(pt1, pt2, true, subDivStepSz, subdivLnLgt);
        }

        pg.endShape(CLOSE);
      }
    }
    
    pg.endDraw();
  }
 
    void subdivideLn(Vec2D startPt, Vec2D endPt, boolean setStep, float stepSzOrSubDivCnt, float subLnLgt)
  {
    Vec2D dif = endPt.sub(startPt); 
    
    float d = dif.magnitude();

    float stepSz; 
    int subDivCnt; 
    if (setStep) 
    {
      stepSz = stepSzOrSubDivCnt;
      subDivCnt = int(d / stepSz); 
    } else
    {
      subDivCnt = int(stepSzOrSubDivCnt);
      stepSz = d / subDivCnt; 
    }
  
    Vec2D nrm = dif.copy(); 
    nrm.normalize(); 
    
    pg.stroke(180, random(80, 218), 120, random(10, 70));  //spikes color, 60 op 
    pg.strokeWeight(random(4));
    
    for (int i = 0; i < subDivCnt + 1; i++)
    {
      Vec2D subDivPt = nrm.copy(); 
      subDivPt.scaleSelf(stepSz * i); 
      subDivPt.addSelf(startPt); 
      Vec2D wingPt1 = nrm.copy(); 
      wingPt1.rotate(PI/2); 
      wingPt1.scaleSelf(subLnLgt);
      Vec2D wingPt2 = wingPt1.copy(); 
      wingPt2.rotate(PI);
      wingPt1.addSelf(subDivPt); 
      wingPt2.addSelf(subDivPt);
      pg.line(wingPt1.x, wingPt1.y, wingPt2.x, wingPt2.y);
    }
  }
  
  PImage mirror(PImage img) 
  {
    PImage flippedImg = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.pixels.length; i++)
    {
      int x = i % img.width;  
      int y = i / img.width; 
      int xNew = img.width - x - 1; 
      int indexNew = y * img.width + xNew;
      flippedImg.pixels[indexNew] = img.pixels[i]; 
      
    }
    return flippedImg; 
  }
  
}
