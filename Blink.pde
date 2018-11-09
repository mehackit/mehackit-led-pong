class Blink{
	private long interval;
	private long lastChange;
	private boolean state;

	Blink(long interval) {
		this.interval = interval;
		this.lastChange = 0;
		state = false;
	}

	public boolean draw() {
		long now = millis();
		if (now - lastChange > interval) {
			lastChange = now;
			state = !state;
		}
		return state;
	}
}