class GameOnState implements GameState {
	private Ball ball;
	private Player player;

	GameOnState() {
		this.ball = new Ball();
		this.player = new Player();
	}

	public void draw() {
		ball.draw(player);
		player.draw();
	}

	public void click() {
		player.hit();
	}
}
