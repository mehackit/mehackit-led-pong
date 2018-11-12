class GameStartState implements GameState {
	Blink blink;
	float i = 0;

	GameStartState() {
		blink = new Blink(500);
	}

	public void draw() {
		if (blink.draw()) {
			fill(100, 0, 50);
			rect(0, 0, _PLAYER_SIZE, height);
			fill(100, 0, 100);
			rect(i, 0, 10, height);

			if (i==0) {
				println("osc message start line");
				sendOscMessage("start_sweep", 1);
			}

			i += 1.3;
			if (i > _PLAYER_SIZE ) {
				i = 0;
			}
		} else {
			i = 0;
		}
	}

	public void click() {
		changeState(State.GAME_ON);
	}
}