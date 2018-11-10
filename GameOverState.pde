import java.util.ArrayList;

class GameOverState implements GameState {
	private final int EXPLOSION = 0;
	private final int SCORE = 1;
	private final int HIGH_SCORE = 2;
	private final int DO_NOTHING = 2;
	private int state = DO_NOTHING;

	private Blink blink;
	private ArrayList<Float> oldRs;
	private float r;

	private boolean explosionRising;
	private int jitterCounter;
	
	private boolean drawScore = false;
	private float drawScoreCounter = 0;
	private float drawScoreIncrement = width / _LED_AMT;
	private int[] hues = {6, 11, 22, 28};
	private int highscore;
	private long lastExplostion;


	GameOverState() {
		blink = new Blink(200);
		boolean explosion = false;

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
			if (millis() - lastExplostion > 20000) {
				changeState(State.IDLE);
			}
			break;
			case HIGH_SCORE:
			drawHighScore();
			if (millis() - lastExplostion > 20000) {
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
		oldRs = new ArrayList<Float>();
		float r = 0;
		explosionRising = true;
		jitterCounter = 0;
		lastExplostion = millis();
	}

	private void drawScore() {
		if (blink.draw()) {
			for (int s = 0; s < (int) drawScoreCounter; s++) {
				int h = hues[min(3, s/5)];
				fill(h, 100, min(100, 10+s*5));
				rect(s * drawScoreIncrement, 0, drawScoreIncrement, height);
			}

			if (drawScore) {
				drawScoreCounter++;
				if (drawScoreCounter >= _score) {
					drawScoreCounter = _score;
					if (_score > highscore) {
						saveHighScore();
						state = HIGH_SCORE;
					}
				}
				drawScore = false;	
			}
		} else {
			drawScore = true;
		}
	}

	private void drawHighScore() {
		for (int s = 0; s < (int) drawScoreCounter; s++) {
				int h = hues[min(3, s/5)];
				fill(h, 100, min(100, 10+s*5));
				rect(s * drawScoreIncrement, 0, drawScoreIncrement, height);
			}

		fill(100, 0, 100);
		float x = ((int) random(0, _score)) * drawScoreIncrement;
		rect(x, 0, drawScoreIncrement, height);
	}

	private void saveHighScore() {
		println("Save new highscore");
		String h = String.valueOf(_score);
		String[] list = {h};
		saveStrings("/Users/otso/Dropbox (Aalto)/MediaLab/Neopixel pong/Led_pong/data/highscore.txt", list);
	}

	private void drawExplosion() {
		if (r > 200) {
			explosionRising = false;
		}

		if (explosionRising) {
			r += 100;
		} else {
			r -= 100;
			if (r > 100 && r < 1000 && jitterCounter < 1) {
				if (random(100) > 70) {
					explosionRising = true;
					jitterCounter++;
				}
			}
		}

		if (r < 0) {
			state = SCORE;
			drawScoreCounter = 0;
		}

		oldRs.add(r);
		if (oldRs.size() > 20) {
			oldRs.remove(0);
		}

		int i = 0;
		noStroke();
		for (Float oldR : oldRs) {
			noStroke();
			fill(100, 100, 5 * i);
			ellipse(0, height/2, oldR, oldR);	
			i++;
		}
	}
}