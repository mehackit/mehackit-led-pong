import java.util.ArrayList;

class Ball {
  private final int TRAIL_SIZE = 10;
  private float x;
  private float y;
  private float speed;
  private float d;
  private float r;
  private ArrayList<Float> oldXs;
  private float h = 0;
  private float s = 50;
  private Obstacle obstacle;

  public Ball(float d, float speed, float x) {
    this.x = x;
    this.y = height / 2.0;
    this.d = d;
    this.r = d / 2;
    this.speed = speed;

    oldXs = new ArrayList<Float>();

    obstacle = new Obstacle();
  }

  public Ball() {
    this(20, 10, 0);
  }

  public void draw(Player player) {
    obstacle.draw();
    x += speed;

    if (speed < 0 && player.checkCollision(x-r)) {
      println("bounce");
      speed = speed * -1;
      speed = _score < 10 ? speed * 1.1 : speed * 1.02;
      _score++;
      sendOscMessage("hit", _score);
    } else if (x < 0) {
      println("game over");
      changeState(State.GAME_OVER);
    } else if (x+r > width) {
      speed = -abs(speed);
      println("change direction");
    }

    if (obstacle.checkCollision(x, r)) {
      speed = speed * -1;
      obstacle.explode();
    }

    oldXs.add(x);
    if (oldXs.size() > TRAIL_SIZE) {
      oldXs.remove(0);
    }

    h = (h + 1) % 100;
    s = 50 + (s + 1) % 50;

    int i = 0;
    noStroke();
    for (Float oldX : oldXs) {
      if (i==TRAIL_SIZE-1) {
        fill(0, 0, 100);
      } else if (i > TRAIL_SIZE - 3) {
        fill(h, s, 100);
      } else {
        fill(h, s, 6 * i);
      }
      ellipse(oldX+random(-2, 2), y, d, d); 
      i++;
    }
  }
}