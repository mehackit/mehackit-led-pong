class IdleState implements GameState{

	int start = 0;
	IdleState() {
	}

	public void draw() {
		float size = width / 100;
		for (int i = 0; i < 99; i++) {
			fill((start + i) % 100, 100, 100);
			noStroke();
			//rect(size * i, 0, size * i + size, height);
		}
		start = (start + 1) % 100;
	}

	public void click() {
		changeState(State.GAME_START);
	}
}
