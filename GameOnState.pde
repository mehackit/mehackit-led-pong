class GameOnState implements GameState {
	GameOnState() {
	}

	public void draw() {
		player.update();
		ball.update(player);
		ball.draw();
	}

	public void click() {
		player.hit();
	}
}