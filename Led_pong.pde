import oscP5.*;
import netP5.*;

Ball ball;
Player player;
OPC opc;

private OscP5 oscP5;
private NetAddress sonicPi;
private State state;

private final int led_amt = 120;
private final int PLAYER_SIZE = 70;
private long lastKeyPress = 0;
private long buttonIdle = 200;
private long gameOverStarted = 0;
private int counter = 0;
private long last_start_blink = 0;
private boolean draw_start_box = true;
private long start_blink_length = 200;
private long last_end_blink = 0;
private boolean draw_end_box = true;
private long end_blink_length = 200;
private boolean debugMessages = true;

public void setup() {
  colorMode(HSB, 100);
  size(1200, 100);

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, led_amt, 1, 600, height/2.0, 10, 10, 0.0, false);

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
  state.getObject().click();
}

public void changeState(State s) {
  switch (s) {
    case IDLE:
    sendOscMessage("state", State.IDLE.getIndex());
    state = s;
    break;
    case GAME_START:
    sendOscMessage("state", State.GAME_START.getIndex());
    state = s;
    break;
    case GAME_ON:
    sendOscMessage("state", State.GAME_ON.getIndex());
    counter = 0;
    ball = new Ball(100, 10, 0);
    player = new Player(PLAYER_SIZE, 10, 0);
    state = s;
    break;
    case GAME_OVER:
    sendOscMessage("state", State.GAME_OVER.getIndex());
    println(counter);
    gameOverStarted = millis();
    state = s;
    break;
  }
}

// Functions for sending the OSC messages
public void sendOscMessage(String msg, float val) {
  OscMessage toSend = new OscMessage("/" + msg);
  toSend.add(val);
  oscP5.send(toSend, sonicPi);
  if (debugMessages) println(toSend); 
}

public void sendOscMessage(String msg, int val) {
  OscMessage toSend = new OscMessage("/" + msg);
  toSend.add((int)val);
  oscP5.send(toSend, sonicPi);
  if (debugMessages) println(toSend); 
}

public void sendOscDualMessage(String msg, float val1, float val2) {
  OscMessage toSend = new OscMessage("/" + msg);
  toSend.add(val1);
  toSend.add(val2);
  oscP5.send(toSend, sonicPi);
  if (debugMessages) println(toSend); 
}