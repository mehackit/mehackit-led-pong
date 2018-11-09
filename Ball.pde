class Ball {
  float x;
  float y;
  float speed;
  float d;
  float r;

  float noise_x = 0;

  Ball(float d, float speed, float x) {
    this.x = x;
    this.y = height / 2.0;
    this.d = d;
    this.r = d / 2.0 + 2;
    this.speed = speed;
  }

  void update(Player player) {
    x += speed;

    if (speed < 0 && player.checkCollision(x)) {
      speed = speed * -1;
      accelerate();
      counter++;
      sendOscMessage("hit", counter);
      println("player collision");
    } else if (x < -r) {
      println("game over " + x + " < 0");
      changeState(State.GAME_OVER);
    } else if (x > width) {
      speed = speed * -1;
      println("ball change direction at other end");
    } else {
      //println("else...");
    }
  }

  void accelerate() {
    speed = speed * 1.1;
    println(speed);
  }
  void draw() {
    noStroke();
    fill(noise(noise_x) * 100.0, noise(noise_x + 100) * 100.0, 100);
    noise_x += 0.01;
    ellipse(x, y, r, r);
  }
}