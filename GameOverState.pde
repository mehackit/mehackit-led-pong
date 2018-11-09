class GameOverState implements GameState {
	GameOverState() {
	}

	public void draw() {
		if (millis() - last_end_blink > end_blink_length) {
			last_end_blink = millis();
			draw_end_box = !draw_end_box;
		}

		if (draw_end_box) {
			fill(100, 100, 10);
			rect(0, 0, width / led_amt * counter, height);
		}
	}

	public void click() {
		gameOverStarted = millis();
			lastKeyPress = millis();
			changeState(State.IDLE);
	}
}