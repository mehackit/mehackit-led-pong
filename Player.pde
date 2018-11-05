import java.awt.event.KeyEvent;

class Player {
  final int UP = 0;
  final int DOWN = 1;
  final int STILL = 2;  
  int state = STILL;

  float x;
  float size;
  float speed;

  float fade_x;
  float original_x;
  float rot;
  float translate_y;

  Player(float size, float speed, float x) {
    this.size = size;
    this. speed = speed;
    this.x = 0;
    this.fade_x = 0;
    this.original_x = x;

    if (x > width/2) {
      this.rot = PI;
      this.translate_y = height;
    } else {
      this.rot = 0;
      this.translate_y = 0;
    }
  }

  void update() {
    switch(state) {
      case UP:
      x += speed;
      if (x > size) {
        state = DOWN;
      }
      noStroke();
      greenFill();
      pushMatrix();
      translate(original_x, translate_y);
      rotate(rot);
      rect(0, 0, x, height);
      popMatrix();
      break;

      case DOWN:
      x -= speed;
      if (x < 0) {
        state = STILL;
      }
      noStroke();
      greenFill();
      pushMatrix();
      translate(original_x, translate_y);
      rotate(rot);
      rect(0, 0, x, height);
      fade_x += speed * 1.2;
      float red_x_1 = max(x - fade_x, 0);
      float red_x_2 = min(fade_x, x);
      redFill();
      rect(red_x_1, 0, red_x_2, height); 
      popMatrix();
      break;

      default:
      break;
    }
  }

  boolean checkCollision(float x) {
    if (state == UP && this.x > x) {
      println("hit ball with bat");
      return true;
    } else {
      return false;
    }
  }

  void redFill() {
    fill(100, 100, 60);
  }

  void greenFill() {
    fill(35, 100, 60);
  }

  void hit() {
    if (state != STILL) {
      return;
    } else {
      state = UP;
    }
  }
}