import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.util.ArrayList; 
import java.util.ArrayList; 
import java.net.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Led_pong extends PApplet {




private OPC opc;
private OscP5 oscP5;
private NetAddress sonicPi;
private State state;

private final int _LED_AMT = 179;
public int _score = 0;
private final int _PLAYER_SIZE = 50;
private long lastKeyPress = 0;

public void setup() {
  colorMode(HSB, 100);
  

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, _LED_AMT, 1, width/2, height/2, 7, 10, 0.0f, false);

  oscP5 = new OscP5(this, 8000);
  sonicPi = new NetAddress("127.0.0.1", 4559);

  State.IDLE.setObject(new IdleState());
  State.GAME_START.setObject(new GameStartState());
  State.GAME_ON.setObject(new GameOnState());
  State.GAME_OVER.setObject(new GameOverState());

  state = State.IDLE;
}

public void draw() {
  background(0);

  state.getObject().draw();
}

public void keyPressed() {
  if (key == ' ') {
    long now = millis();
    if (now - lastKeyPress > 300) {
      lastKeyPress = now;
      state.getObject().click();
    }
  }
}

public void changeState(State s) {
  state = s;
  sendOscMessage("state", state.getIndex());
  lastKeyPress = millis();

  switch (state) {
    case GAME_START:
    State.GAME_ON.setObject(new GameOnState());
    State.GAME_OVER.setObject(new GameOverState());
    _score = 0;
    break;
    case GAME_OVER:
    GameOverState gs = (GameOverState) State.GAME_OVER.getObject();
    gs.explode();
    break;
    case GAME_ON:
    sendOscMessage("go", 1);
    break;
  }
}

public void sendOscMessage(String msg, int val) {
  OscMessage toSend = new OscMessage("/" + msg);
  toSend.add((int)val);
  oscP5.send(toSend, sonicPi);
}


class Ball {
  private final int TRAIL_SIZE = 10;
  private float x;
  private float y;
  private float speed;
  private float d;
  private float r;
  private ArrayList<Float> oldXs;
  private float h = 0;
  private float s = 50;
  private Obstacle obstacle;

  public Ball(float d, float speed, float x) {
    this.x = x;
    this.y = height / 2.0f;
    this.d = d;
    this.r = d / 2;
    this.speed = speed;

    oldXs = new ArrayList<Float>();

    obstacle = new Obstacle();
  }

  public Ball() {
    this(14, 10, 0);
  }

  public void draw(Player player) {
    obstacle.draw();
    x += speed;

    if (speed < 0 && player.checkCollision(x-r)) {
      println("bounce");
      speed = speed * -1;
      speed = _score < 10 ? speed * 1.1f : speed * 1.02f;
      _score++;
      sendOscMessage("hit", _score);
    } else if (x < 0) {
      println("game over");
      changeState(State.GAME_OVER);
    } else if (x+r > width) {
      speed = -abs(speed);
      println("change direction");
    }

    if (obstacle.checkCollision(x, r)) {
      speed = speed * -1;
      obstacle.explode();
    }

    oldXs.add(x);
    if (oldXs.size() > TRAIL_SIZE) {
      oldXs.remove(0);
    }

    h = (h + 1) % 100;
    s = 50 + (s + 1) % 50;

    int i = 0;
    noStroke();
    for (Float oldX : oldXs) {
      if (i==TRAIL_SIZE-1) {
        fill(0, 0, 100);
        ellipse(oldX+random(-2, 2), y, d, d); 
      } else if (i > TRAIL_SIZE - 3) {
        fill(h, s, 100);
        ellipse(oldX+random(-2, 2), y, speed*2, speed*2); 
      } else {
        fill(h, s, 6 * i);
        ellipse(oldX+random(-2, 2), y, speed*2, speed*2); 
      }
      
      i++;
    }
  }
}
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

	private String filepath;


	GameOverState() {
		blink = new Blink(200);
		boolean explosion = false;
		im = loadImage("fire.jpg");
		y = height;
		filepath = dataPath("") + "/highscore.txt";

		String[] lines = loadStrings(filepath);
		if (lines == null) {
			println("No highscore file, let's create one");
			PrintWriter output = createWriter(filepath); 
			output.flush();
			output.close();
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
		saveStrings(filepath, list);
	}

	private void drawExplosion() {
		y -= speed;
		image(im, 0, y);

		if (y < -im.height + height / 2) {
			state = SCORE;
		}
	}
}
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

			i += 1.3f;
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
public interface GameState {
	public void draw();
	public void click();
}
class IdleState implements GameState{

	int start = 0;
	IdleState() {
	}

	public void draw() {
		float size = width / 100;
		for (int i = 0; i < 99; i++) {
			fill((start + i) % 100, 100, 100);
			noStroke();
			//rect(size * i, 0, size * i + size, height);
		}
		start = (start + 1) % 100;
	}

	public void click() {
		changeState(State.GAME_START);
	}
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC
{
  Socket socket;
  OutputStream output;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f),
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing,
        angle, zigzag && (i % 2) == 1);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = 0;          // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = 0;          // Length high byte
    packet[3] = 5;          // Length low byte
    packet[4] = 0x00;       // System ID high byte
    packet[5] = 0x01;       // System ID low byte
    packet[6] = 0x00;       // Command ID high byte
    packet[7] = 0x02;       // Command ID low byte
    packet[8] = firmwareConfig;

    try {
      output.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = 0;          // Channel (reserved)
    header[1] = (byte)0xFF; // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);
    header[3] = (byte)(packetLen & 0xFF);
    header[4] = 0x00;       // System ID high byte
    header[5] = 0x01;       // System ID low byte
    header[6] = 0x00;       // Command ID high byte
    header[7] = 0x01;       // Command ID low byte

    try {
      output.write(header);
      output.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
 
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = 0;  // Channel
      packetData[1] = 0;  // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);
      packetData[3] = (byte)(numBytes & 0xFF);
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = null;
  }

  public void connect()
  {
    // Try to connect to the OPC server. This normally happens automatically in draw()
    try {
      socket = new Socket(host, port);
      socket.setTcpNoDelay(true);
      output = socket.getOutputStream();
      println("Connected to OPC server");
    } catch (ConnectException e) {
      dispose();
    } catch (IOException e) {
      dispose();
    }
    
    sendColorCorrectionPacket();
    sendFirmwareConfigPacket();
  }
}
class Obstacle {
	private final int OFF = 0;
	private final int ON = 1;
	private final int EXPLODING = 2;
	private int state;

	long lastSpawn;
	float x;
	float r = 50;

	Obstacle () {
		x = random(width / 2, width);
		state = OFF;
		lastSpawn = millis();
	}

	public void draw() {
		switch (state) {
			case OFF:
			long now = millis();
			if (now - lastSpawn > 2000 && _score > 1) {
				if (random(100) > 90 - _score) {
					lastSpawn = now;
					x = random(width / 2, width-r);
					state = ON;
					sendOscMessage("spawn", 0);
				}
			}
			break;
			case ON:
			fill(100, 100, 60);
			rect(x, 0, r, height);
			fill(100, 100, 100);
			rect(x+random(40), 0, 10, height);
			break;
			case EXPLODING:
			state = OFF;
			break;	
		}
	}

	public boolean checkCollision(float ballX, float ballR) {
		if (state == ON ) {
			if ((ballX > x  && ballX < x + r) || (ballX < x + r && ballX > x)) {
				sendOscMessage("break", 0);
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	public void explode() {
		state = EXPLODING;
	}
}
class Player {
  final int UP = 0;
  final int DOWN = 1;
  final int STILL = 2;  
  int state = STILL;

  float x;
  float size;
  float speed;

  Player(float size, float speed, float x) {
    this.size = size;
    this. speed = speed;
    this.x = 0;
  }

  Player() {
    this(_PLAYER_SIZE, 8, 0);
  }

  public void draw() {
    switch(state) {
      case UP:
        x += speed;
        if (x > size) {
          state = DOWN;
        }
        noStroke();
        greenFill();
        rect(0, 0, x, height);
        break;

      case DOWN:
        x -= speed;
        if (x < 0) {
          state = STILL;
        }
        noStroke();
        redFill();
        rect(0, 0, x, height);
        break;
    }
  }

  public boolean checkCollision(float x) {
    if (state == UP && this.x > x) {
      return true;
    } else {
      return false;
    }
  }

  public void redFill() {
    fill(100, 100, 60);
  }

  public void greenFill() {
    fill(35, 100, 100);
  }

  public void hit() {
    if (state != STILL) {
      return;
    } else {
      state = UP;
    }
  }
}
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
  public void settings() {  size(1253, 100); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "Led_pong" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
