import java.util.ArrayList;

class GameOverState implements GameState {
	private final int EXPLOSION = 0;
	private final int SCORE = 1;
	private final int HIGH_SCORE = 2;
	private final int DO_NOTHING = 2;
	private int state = DO_NOTHING;

	private Blink blink;
	private long gameOverStateStarted;
	private ArrayList<Float> oldRs;
	private float r;

	PImage im;
	float speed = 10;
	float y;
	
	private boolean animateScore = false;
	private float animateScoreCounter = 0;
	private float animateScoreIncrement = width / _LED_AMT;
	private int[] hues = {6, 11, 22, 28};
	private int highscore;


	GameOverState() {
		blink = new Blink(200);
		boolean explosion = false;
		im = loadImage("fire.jpg");
		y = height;

		String[] lines = loadStrings("/Users/otso/Dropbox (Aalto)/MediaLab/Neopixel pong/Led_pong/data/highscore.txt");
		if (lines == null) {
			println("No highscore file");
			highscore = 0;
		} else if (lines.length < 1) {
			println("Empty highscore file");
			highscore = 0;
		} else {
			highscore = Integer.parseInt(lines[0]);
			println("Highscore read: " + highscore);
		}
	}

	public void draw() {
		switch (state) {
			case EXPLOSION:
			drawExplosion();
			break;
			case SCORE:
			drawScore();
			if (millis() - gameOverStateStarted > 30000) {
				changeState(State.IDLE);
			}
			break;
			case HIGH_SCORE:
			drawHighScore();
			if (millis() - gameOverStateStarted > 30000) {
				changeState(State.IDLE);
			}
			break;
		}
	}

	public void click() {
		changeState(State.IDLE);
	}

	public void explode() {
		state = EXPLOSION;
		gameOverStateStarted = millis();
		sendOscMessage("explode", 0);
	}

	private void drawScore() {
		if (blink.draw()) {
			for (int s = 0; s < (int) animateScoreCounter; s++) {
				int h = hues[min(3, s/5)];
				fill(h, 100, min(100, 10+s*5));
				rect(s * animateScoreIncrement, 0, animateScoreIncrement, height);
			}

			if (animateScore) {
				if (animateScoreCounter < _score) {
					sendOscMessage("score", (int) animateScoreCounter);
				}
				animateScoreCounter++;
				if (animateScoreCounter >= _score) {
					animateScoreCounter = _score;
					if (_score > highscore) {
						saveHighScore();
						state = HIGH_SCORE;
						sendOscMessage("highscore", 1);
					}
				}
				animateScore = false;	
			}
		} else {
			animateScore = true;
		}
	}

	private void drawHighScore() {
		for (int s = 0; s < (int) animateScoreCounter; s++) {
			int h = hues[min(3, s/5)];
			fill(h, 100, min(100, 10+s*5));
			rect(s * animateScoreIncrement, 0, animateScoreIncrement, height);
		}

		fill(100, 0, 100);
		float x = ((int) random(0, _score)) * animateScoreIncrement;
		rect(x, 0, animateScoreIncrement, height);
	}

	private void saveHighScore() {
		println("Save new highscore");
		String h = String.valueOf(_score);
		String[] list = {h};
		saveStrings("/Users/otso/Dropbox (Aalto)/MediaLab/Neopixel pong/Led_pong/data/highscore.txt", list);
	}

	private void drawExplosion() {
		y -= speed;
		image(im, 0, y);

		if (y < -im.height + height / 2) {
			state = SCORE;
		}
	}
}