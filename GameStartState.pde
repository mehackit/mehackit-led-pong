class GameStartState implements GameState {
	GameStartState() {
	}

	public void draw() {
		if (millis() - last_start_blink > start_blink_length) {
			last_start_blink = millis();
			draw_start_box = !draw_start_box;
		}

		if (draw_start_box) {
			fill(100, 0, 100);
			rect(0, 0, PLAYER_SIZE, height);
		}
	}

	public void click() {
		changeState(State.GAME_ON);
	}
}