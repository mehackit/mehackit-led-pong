class IdleState implements GameState{

	IdleState() {
	}

	public void draw() {
		noStroke();
		fill(noise(frameCount/30.0) * 100.0, noise(frameCount/30.0 + 100) * 100.0, 100);
		ellipse(noise(frameCount/100.0)*width, height/2, 30, 30);
	}

	public void click() {
		changeState(State.GAME_START);
	}
}