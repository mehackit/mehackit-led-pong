Ball ball;
Player player_1;
OPC opc;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress sonicPi;
OscMessage osc_game_on = new OscMessage("/game_on");

final int led_amt = 120;

final int IDLE = 0;
final int GAME_START = 1;
final int GAME_ON = 2;
final int GAME_OVER = 3; 
int state = IDLE;

final int PLAYER_SIZE = 70;

long lastKeyPress = 0;
long buttonIdle = 200;
long gameOverStarted = 0;
int counter = 0;

long last_start_blink = 0;
boolean draw_start_box = true;
long start_blink_length = 200;

long last_end_blink = 0;
boolean draw_end_box = true;
long end_blink_length = 200;

void setup() {
  colorMode(HSB, 100);
  size(1200, 100);

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, led_amt, 1, 600, height/2.0, 10, 10, 0.0, false);

  oscP5 = new OscP5(this, 8000);
  sonicPi = new NetAddress("127.0.0.1", 4559);
}

void draw() {
  background(0);

  switch (state) {
    case IDLE:
    idle();
    break;
    case GAME_START:
    game_start();
    break;
    case GAME_ON:
    game_on();
    break;
    case GAME_OVER:
    game_over();
    break;
    default:
    break;
  }
}

void idle() {
  noStroke();
  fill(noise(frameCount/30.0) * 100.0, noise(frameCount/30.0 + 100) * 100.0, 100);
  ellipse(noise(frameCount/100.0)*width, height/2, 30, 30);

  if (keyPressed && millis() - lastKeyPress > buttonIdle) {
    lastKeyPress = millis();
    changeState(GAME_START);
  }
}

void game_start() {
  if (millis() - last_start_blink > start_blink_length) {
    last_start_blink = millis();
    draw_start_box = !draw_start_box;
  }

  if (draw_start_box) {
    fill(100, 0, 100);
    rect(0, 0, PLAYER_SIZE, height);
  }

  if (keyPressed && millis() - lastKeyPress > buttonIdle) {
    lastKeyPress = millis();
    changeState(GAME_ON);
  }
}

void game_on() {
  player_1.update();
  ball.update(player_1);
  ball.draw();

  if (keyPressed && millis() - lastKeyPress > buttonIdle) {
    OscMessage strike = new OscMessage("/strike ");
    oscP5.send(strike, sonicPi); 

    lastKeyPress = millis();
    player_1.hit();
  }
}

void game_over() {
  if (millis() - last_end_blink > end_blink_length) {
    last_end_blink = millis();
    draw_end_box = !draw_end_box;
  }

  if (draw_end_box) {
    fill(100, 100, 10);
    rect(0, 0, width / led_amt * counter, height);
  }

  if ((keyPressed && millis() - lastKeyPress > buttonIdle * 10) || millis() - gameOverStarted > 10000) {
    gameOverStarted = millis();
    lastKeyPress = millis();
    changeState(IDLE);
  }
}

void changeState(int s) {
  switch (s) {
    case IDLE:
    osc_game_on.add(0);
    oscP5.send(osc_game_on, sonicPi); 
    state = s;
    break;
    case GAME_START:
    osc_game_on.add(0);
    oscP5.send(osc_game_on, sonicPi); 
    state = s;
    break;
    case GAME_ON:
    osc_game_on.add(1);
    oscP5.send(osc_game_on, sonicPi); 

    counter = 0;
    ball = new Ball(100, 10, 0);
    player_1 = new Player(PLAYER_SIZE, 10, 0);
    state = s;
    break;
    case GAME_OVER:
    osc_game_on.add(0);
    oscP5.send(osc_game_on, sonicPi); 

    println(counter);
    gameOverStarted = millis();
    state = s;
    break;
  }
}