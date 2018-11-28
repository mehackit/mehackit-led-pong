enum State{
	IDLE(0), GAME_START(1), GAME_ON(2), GAME_OVER(3);

	private final int index;
	private GameState object;

    State(int index) {
        this.index = index;
    }
    
    public int getIndex() {
        return this.index;
    }

    public void setObject(GameState object) {
    	this.object = object;
    }

    public GameState getObject() {
    	return object;
    }
}
