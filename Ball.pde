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

  public Ball(float d, float speed, float x) {
    this.x = x;
    this.y = height / 2.0;
    this.d = d;
    this.r = d / 2;
    this.speed = speed;

    oldXs = new ArrayList<Float>();
  }

  public Ball() {
    this(20, 10, 0);
  }

  public void draw(Player player) {
    x += speed;

    if (speed < 0 && player.checkCollision(x-r)) {
      speed = speed * -1;
      speed = speed * 1.1;
      _score++;
      sendOscMessage("hit", _score);
    } else if (x < 0) {
      changeState(State.GAME_OVER);
    } else if (x+r > width) {
      speed = speed * -1;
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
      } else {
        fill(h, s, 5 * i);
      }
      ellipse(oldX+random(-2, 2), y, d, d); 
      i++;
    }
  }
}