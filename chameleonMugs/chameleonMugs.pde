
import TUIO.*;
TuioProcessing tuioClient;

import processing.dandelion.*;
Dandelion dandelion1, dandelion2, dandelion3;


// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

ArrayList<Mug> mugs = new ArrayList();

color col1 = color(255,0,0);
color col2 = color(0,255,0);
color col3 = color(0,0,255);

float distThreshold = 150;

void setup()
{
  size(640,480);
  noStroke();
  fill(0);
  
  loop();
  frameRate(30);
  
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  tuioClient  = new TuioProcessing(this);
  dandelion1 = new Dandelion(this, "/dev/tty.Dandelion-SPPDev");
  dandelion2 = new Dandelion(this, "/dev/tty.Dandelion-SPPDev-1");
  dandelion3 = new Dandelion(this, "/dev/tty.Dandelion-SPPDev-2");
}

void calcDist() {
  int num = mugs.size();
//  println("there are " + num + " of mugs");

  switch(num) {
    case 1: break;// stands alone    
    case 2: { // mixed color
      Mug m1 = mugs.get(0);
      Mug m2 = mugs.get(1);
      
      float d = sqrt((m1.x-m2.x)*(m1.x-m2.x) + (m1.y-m2.y)*(m1.y-m2.y)); 
      if(d < distThreshold) {
        color c = chooseColor(m1,m2);
        m1.setColor(c);
        m2.setColor(c);
      }
      else {
        m1.col = m1.col_id;
        m2.col = m2.col_id;  
      }
    } break;
    case 3: { // all together
    
      // calculate distance each other
      Mug m1 = mugs.get(0);
      Mug m2 = mugs.get(1);
      Mug m3 = mugs.get(2);
      boolean d1 = isClose(m1, m2); 
      boolean d2 = isClose(m1, m3);
      boolean d3 = isClose(m2, m3);      
         
      if((d1 | d2 | d3) == false) { // stands alone
        // unique color
      }
      else if(d1&d2&d3) { // all together
        // turn white
        // all together
        color w = color(255,255,255);
        m1.setColor(w);
        m2.setColor(w);
        m3.setColor(w);
      }
      else if((d1&d2&!d3) | (d1&d3&!d2) | (d2&d3&!d1)) {
        // turn white
        color w = color(255,255,255);
        m1.setColor(w);
        m2.setColor(w);
        m3.setColor(w);
      }
      else {
        // mixed color
        if(d1 & !d2 & !d3) {
          color c =chooseColor(m1,m2);
          if(c != color(255,255,255)) {
            m1.setColor(c);
            m2.setColor(c);
          }
        }
        else if(!d1 & d2 & !d3) {
          color c = chooseColor(m1,m3);
          if(c != color(255,255,255)) {
            m1.setColor(c);
            m3.setColor(c);
          }
        }
        else if(!d1 & !d2 & d3) {
          color c = chooseColor(m2,m3);
          if(c != color(255,255,255)) {
            m2.setColor(c);
            m3.setColor(c);
          }
        }  
      }
    } break; // end of case 3:
  }  
}

color chooseColor(Mug m1, Mug m2) {
  if((m1.col_id == col1 && m2.col_id == col2) || (m1.col_id == col2 && m2.col_id == col1)) {
    return color(255,255,0);
  }  
  else if((m1.col_id == col1 && m2.col_id == col3) || (m1.col_id == col3 && m2.col_id == col1)) {
    return color(255,0,255);
  }
  else if((m1.col_id == col2 && m2.col_id == col3) || (m1.col_id == col3 && m2.col_id == col2)) {
    return color(0,255,255);
  } 

  return color(255,255,255);
}

boolean isClose(Mug m1, Mug m2) {
  if(m1 == null || m2 == null) 
    return false;
    
  if(getDistance(m1, m2) < distThreshold)
    return true;
    
  return false;
}

float getDistance(Mug m1, Mug m2) {
//  println("getDistance() " +  sqrt((m1.x-m2.x)*(m1.x-m2.x) + (m1.y-m2.y)*(m1.y-m2.y)));
  return sqrt((m1.x-m2.x)*(m1.x-m2.x) + (m1.y-m2.y)*(m1.y-m2.y));
}

void draw() {
  if(frameCount % 10 != 0)
    return;
    
  background(255);
  textFont(font,18*scale_factor);
  
  // mug collection
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     Mug m = new Mug(tobj.getSymbolID(), tobj.getX(), tobj.getY());
     mugs.add(m);
  }  
  
  // calculate distance
  calcDist();
  
  // change color
    for (int i=0;i<mugs.size();i++) {
     Mug m = mugs.get(i);
     
     noStroke();

     fill(m.col);
     pushMatrix();
     translate(m.x,m.y);
     ellipse(0, 0, 50, 50);
     
     fill(0);
     textAlign(CENTER,CENTER);
     text(m.getSymbolID(), 0, 0);
     popMatrix();     
   } 
  
  for(Mug m: mugs) {
    m.lightUp();  
  }
  
  mugs.clear();

}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  println("[Add   ] "+ tobj.getSymbolID() + " (" + tobj.getX() + "," + tobj.getY() + ")");
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("[Remove] "+ tobj.getSymbolID());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
//  println("[Update] "+ tobj.getSymbolID() + " (" + tobj.getX() + "," + tobj.getY() + ")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) {
  redraw();
}
