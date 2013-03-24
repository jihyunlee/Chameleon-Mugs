
class Mug {
  int symbol_id;
  float x, y;
  color col_id;
  color col;
  Dandelion dandelion;

  public Mug(int id_, float x_, float y_) {
    symbol_id = id_;
    x = x_*width;
    y = y_*height;
    switch(symbol_id) {
     case 23: {
       col_id = color(255,0,0);
       dandelion = dandelion3; 
     } break;
     case 17: {
       col_id = color(0,255,0);
       dandelion = dandelion1; 
     } break;
     case 20: {
       col_id = color(0,0,255);
       dandelion = dandelion2; 
     } break;  
     }
     col = col_id;
  }

  void update(float x_, float y_) {
    x = x_ * width;
    y = y_ * height;
  }

  int getSymbolID() {
    return symbol_id;
  }

  void setColorID(color c) {
    col_id = c;  
  }
  
  void setColor(color c) {
    col = c;
  }
  
  void lightUp() {
    
    // send BT message with the color
    
    if(red(col) == 255) {
      dandelion.setHigh(2);
      dandelion.setHigh(6);
    }
    else {
      dandelion.setLow(2);
      dandelion.setLow(6);
    }
      
    if(green(col) == 255) {
      dandelion.setHigh(1);
      dandelion.setHigh(7);
    }
    else {
      dandelion.setLow(1);
      dandelion.setLow(7);
    }

    if(blue(col) == 255) {
      dandelion.setHigh(0);
      dandelion.setHigh(8);
    }
    else {
      dandelion.setLow(0);
      dandelion.setLow(8);
    }    
  }
}
