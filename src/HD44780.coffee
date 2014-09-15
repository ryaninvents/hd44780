# A signal generator for the [Hitachi HD44780](https://en.wikipedia.org/wiki/Hitachi_HD44780_LCD_controller) family of LCD drivers.
#
# &copy; 2014 Ryan Muller; 
# released under the MIT License.

# ### Purpose

# This library takes high-level input and converts it to a series of pin numbers and on/off
# signals appropriate for the HD44780 controller. This library does NOT send the commands
# to the controller; for that, you need another library such as [`pi-gpio`](https://www.npmjs.org/package/pi-gpio).
#
# Methods and implementations taken from [the datasheet](http://lcd-linux.sourceforge.net/pdfdocs/hd44780.pdf), pp. 24-25.

Bacon = require 'baconjs'
_ = require 'lodash'

# # HD44780

# This class is a first-class [Bacon.js](https://baconjs.github.io/)
# `EventStream`, so the entire [Bacon API](https://baconjs.github.io/api.html)
# is available.
class HD44780 extends Bacon.Bus

# Note: this will output events as soon as they're
# input; you'll probably need to throttle them before
# sending them to a hardware device.
#
# > **Example:**
# > ```
# display = new HD44780
# hardware = new HardwareControllerOfSomeSort
# display.bufferingThrottle(50).onValue (cmd)->
#   hardware.setPinValue cmd.pin, cmd.value
# ```

# ### options
  constructor: (opt) ->
# **mapping:** Maps HD44780 pins to your hardware output.
# Can be a hash or a function.
#
# > **Example:**
# > ```
# display = new HD44780
#   mapping:
#     4:  1
#     5:  2
#     6:  3
#     7:  4
#     8:  5
#     9:  6
#     10: 7
#     11: 8
#     12: 9
#     13: 10
#     14: 11
# ```
    @mapping = opt?.mapping or _.identity
    if _.isPlainObject(@mapping)
      map = @mapping
      @mapping = (pinIn) -> map[pinIn]
# **direction:** Writing direction; can be 'left' or 'right'
    @direction   = opt?.direction or 'right'
# **shift**: Whether to shift the display on write
    @shift       = opt?.shift or off
# **display:** Turn the display on or off
    @display     = opt?.display or on
# **cursor:** Show or hide the cursor
    @cursor      = opt?.cursor or off
# **blink:** Blink the cursor
    @cursorBlink = opt?.cursorBlink or off

# ### set(pin, value)
#
# Set a particular HD44780 pin high or low.
  set: (pin, value) ->
    @push {pin:@mapping(pin), value:value}
#
# ### setRWMode(mode)
#
# Switch between read and write mode.
# Read mode currently does not work.
  setRWMode: (mode) ->
    switch mode
      when 'r', 'read'
        @set HD44780.RW, on
      when 'w', 'write'
        @set HD44780.RW, off

# ### clock()
#
# Send a clock pulse.
  clock: ->
    @set HD44780.CLOCK, on
    @set HD44780.CLOCK_PIN, off

# ### data(n, value)
#
# Set the value of a single or multiple
# data pins.
  data: (n, value) ->
    if _.isArray n
      _.each n, (n)=>@data n, value
    else if _.isPlainObject n
      _.mapObject n, (value, n)=>@data n, value
    else
      @set HD44780.DATA(n), value

# ### clear()
#
# Clear the entire display.
  clear: ->
    @data [1..7], off
    @data 0, on
    @clock()

# ### home()
#
# Scroll the display to the beginning and put
# the cursor at index 0.
  home: ->
    @data [1..6], off
    @data 1, on
    @clock()

# ### scroll(dir)
#
# Scroll the display.
  scroll: (dir) ->
    dir ?= 'r'
    @data [5..7], off
    @data 3, dir in ['r','right']
    @clock()

# ### writeBits(bits)
#
# Write the given array of on/off values
# to display memory, drawing a character
# onto the screen.
  writeBits: (bits) ->
    if bits.length > 8
      throw new Error '`writeBits` requires an array of at most 8 items'
    @set HD44780.RS, on
    _.forEach bits, (bit, i) =>
      @data i, bit

# ### writeChar(char)
#
# Write the given character to the screen.
  writeChar: (char) ->
    n = char.charCodeAt 0
    bits = _.map [0..7], (i) -> (1<<i) & n
    @writeBits bits


# ### HD44780.RS
# Register select pin
HD44780.RS = 4
# ### HD44780.RW
# Read/write pin
HD44780.RW = 5
# ### HD44780.CLOCK
# Clock pin
HD44780.CLOCK = 6
# ### HD44780.DATA(n)
# Data pins
HD44780.DATA = (n) ->
        if 0 <= n <= 7
          n+7
        else
          throw new Error 'HD44780 data pin number must be between 0 and 7'

module.exports = HD44780
