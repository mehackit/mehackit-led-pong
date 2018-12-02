class IdleState implements GameState{
	long last = 0;
	float interval = 10;
	float start = 0;
	float bX = 0;
	float sX = 0;

	IdleState() {
	}

	public void draw() {
		float size = width / 100;
		for (float i = 0; i < 99; i+=0.5) {
			fill((start + i) % 100, 100, 20.0 + noise(i/10, bX) * 80.0);
			noStroke();
			rect(size * i, 0, size * i + size, height);
		}
		bX += 0.01;
		long now = millis();
		interval = 1 + noise(sX) * 50;
		sX += 0.01;
		if (now - last > interval) {
			last = now;
			start = (start < 100) ? start + 0.5 : 0;
		}
	}

	public void click() {
		changeState(State.GAME_START);
	}
}