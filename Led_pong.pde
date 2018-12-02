import oscP5.*;
import netP5.*;

private OPC opc;
private OscP5 oscP5;
private NetAddress sonicPi;
private State state;

private final int _LED_AMT = 179; //60 LED per M strip
//private final int _LED_AMT = 120; //30 LED per M strip
public int _score = 0;
private final int _PLAYER_SIZE = 50;
private long lastKeyPress = 0;

public void setup() {
  colorMode(HSB, 100);
  size(1253, 100); //60 LED per M strip
  //size(1200, 100); //30 LED per M strip

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, _LED_AMT, 1, width/2, height/2, 7, 10, 0.0, false); //60 LED per M strip
  //opc.ledGrid(0, _LED_AMT, 1, width/2, height/2, 10, 10, 0.0, false); //30 LED per M strip

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