class Obstacle {
	private final int OFF = 0;
	private final int ON = 1;
	private final int EXPLODING = 2;
	private int state;

	long lastSpawn;
	float x;
	float r = 50;

	Obstacle () {
		x = random(width / 2, width);
		state = OFF;
		lastSpawn = millis();
	}

	public void draw() {
		switch (state) {
			case OFF:
			long now = millis();
			if (now - lastSpawn > 5000 && _score > 1) {
				if (random(100) > 100 - _score) {
					lastSpawn = now;
					x = random(width / 2, width);
					state = ON;
				}
			}
			break;
			case ON:
			fill(100, 100, 100);
			ellipse(x, height/2, r, r);
			break;
			case EXPLODING:
			state = OFF;
			break;	
		}
	}

	public boolean checkCollision(float ballX, float ballR) {
		if (state == ON ) {
			if ((ballX + ballR > x - r && ballX - ballR < x + r) || (ballX - ballR < x + r && ballX + ballR > x - r)) {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	public void explode() {
		state = EXPLODING;
	}
}