class GameOverState implements GameState {
	Blink blink;

	GameOverState() {
		blink = new Blink(200);
	}

	public void draw() {

		if (blink.draw()) {
			fill(100, 100, 10);
			rect(0, 0, width / _LED_AMT * _score, height);
		}
	}

	public void click() {
		changeState(State.IDLE);
	}
}