A signal generator for the [Hitachi HD44780](https://en.wikipedia.org/wiki/Hitachi_HD44780_LCD_controller) family of LCD drivers.

&copy; 2014 Ryan Muller; 
released under the MIT License.

### Purpose

This library takes high-level input and converts it to a series of pin numbers and on/off
signals appropriate for the HD44780 controller. This library does NOT send the commands
to the controller; for that, you need another library such as [`pi-gpio`](https://www.npmjs.org/package/pi-gpio).
#
Methods and implementations taken from [the datasheet](http://lcd-linux.sourceforge.net/pdfdocs/hd44780.pdf), pp. 24-25.

# HD44780

This class is a first-class [Bacon.js](https://baconjs.github.io/)
`EventStream`, so the entire [Bacon API](https://baconjs.github.io/api.html)
is available.

Note: this will output events as soon as they're
input; you'll probably need to throttle them before
sending them to a hardware device.

> **Example:**
> ```
display = new HD44780
hardware = new HardwareControllerOfSomeSort
display.bufferingThrottle(50).onValue (cmd)->
  hardware.setPinValue cmd.pin, cmd.value
```

### options

**mapping:** Maps HD44780 pins to your hardware output.
Can be a hash or a function.

> **Example:**
> ```
display = new HD44780
  mapping:
    4:  1
    5:  2
    6:  3
    7:  4
    8:  5
    9:  6
    10: 7
    11: 8
    12: 9
    13: 10
    14: 11
```

**direction:** Writing direction; can be 'left' or 'right'

**shift**: Whether to shift the display on write

**display:** Turn the display on or off

**cursor:** Show or hide the cursor

**blink:** Blink the cursor

### set(pin, value)

Set a particular HD44780 pin high or low.

### setRWMode(mode)

Switch between read and write mode.
Read mode currently does not work.

### clock()

Send a clock pulse.

### data(n, value)

Set the value of a single or multiple
data pins.

### clear()

Clear the entire display.

### home()

Scroll the display to the beginning and put
the cursor at index 0.

### scroll(dir)

Scroll the display.

### writeBits(bits)

Write the given array of on/off values
to display memory, drawing a character
onto the screen.

### writeChar(char)

Write the given character to the screen.

### HD44780.RS
Register select pin

### HD44780.RW
Read/write pin

### HD44780.CLOCK
Clock pin

### HD44780.DATA(n)
Data pins

