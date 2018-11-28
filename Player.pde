class Player {
  final int UP = 0;
  final int DOWN = 1;
  final int STILL = 2;  
  int state = STILL;

  float x;
  float size;
  float speed;

  Player(float size, float speed, float x) {
    this.size = size;
    this. speed = speed;
    this.x = 0;
  }

  Player() {
    this(_PLAYER_SIZE, 8, 0);
  }

  void draw() {
    switch(state) {
      case UP:
        x += speed;
        if (x > size) {
          state = DOWN;
        }
        noStroke();
        greenFill();
        rect(0, 0, x, height);
        break;

      case DOWN:
        x -= speed;
        if (x < 0) {
          state = STILL;
        }
        noStroke();
        redFill();
        rect(0, 0, x, height);
        break;
    }
  }

  boolean checkCollision(float x) {
    if (state == UP && this.x > x) {
      return true;
    } else {
      return false;
    }
  }

  void redFill() {
    fill(100, 100, 60);
  }

  void greenFill() {
    fill(35, 100, 100);
  }

  void hit() {
    if (state != STILL) {
      return;
    } else {
      state = UP;
    }
  }
}