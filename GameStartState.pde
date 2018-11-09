class GameStartState implements GameState {
	Blink blink;

	GameStartState() {
		blink = new Blink(500);
	}

	public void draw() {
		if (blink.draw()) {
			fill(100, 0, 100);
			rect(0, 0, _PLAYER_SIZE, height);
		}
	}

	public void click() {
		changeState(State.GAME_ON);
	}
}