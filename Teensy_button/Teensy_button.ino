#include <Bounce.h>
Bounce button = Bounce(2, 100);

void setup() {
  pinMode(2, INPUT_PULLUP);
}

void loop() {
  button.update();

  if (button.fallingEdge()) {
    Keyboard.press(KEY_SPACE);
    delay(50);
    Keyboard.release(KEY_SPACE);
  }
}
