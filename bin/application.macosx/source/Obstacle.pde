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
			if (now - lastSpawn > 2000 && _score > 1) {
				if (random(100) > 90 - _score) {
					lastSpawn = now;
					x = random(width / 2, width-r);
					state = ON;
					sendOscMessage("spawn", 0);
				}
			}
			break;
			case ON:
			fill(100, 100, 60);
			rect(x, 0, r, height);
			fill(100, 100, 100);
			rect(x+random(40), 0, 10, height);
			break;
			case EXPLODING:
			state = OFF;
			break;	
		}
	}

	public boolean checkCollision(float ballX, float ballR) {
		if (state == ON ) {
			if ((ballX > x  && ballX < x + r) || (ballX < x + r && ballX > x)) {
				sendOscMessage("break", 0);
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
