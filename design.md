## Minimal verilog snake game design

Snake is a simple game, made famous by an old cellphone vendor. The snake moves around on a grid,
trying to eat a randomly places fruit. If it gets the fruit, it grows in length and/or starts
moving faster. The fruit random changes position if the snake doesn't get to it in time. The game
is over if the snake crashes into its own body.

## This game

Designed for a direct-to-VGA output, this version tries to be super minimal. It would be easy to
"just" make a CPU and then write normal code, and use a bit-mapped screen. But where's the fun in
that?

## In depth design

We need four inputs for up/down/left/right. The game play only needs to update on a vblank every X
vblanks (where X starts out like 60 or so and reduces as the difficulty increases).

We assume the screen is going to be subdivided into cells (e.g. 8x8) and the cell is the unit of the
snake or fruit's position and movement. Positions are in cell units (though the VGA output might use
the "remainder" for higher definition e.g. on the fruit).

On an update:

- we update the current direction of the snake based on inputs, leaving it the same if nothing's pressed
- we calculate the new position of the head of the snake
- if the snake's new head position coincides with the fruit:
  - increment the score
  - pick a new fruit position*
  - (maybe) decrease the frame count between updates (ie make things go faster)
  - (maybe) grow the snake
- if the snake's new head position coincides with any other part of the snake it's game over
- we need to move the snake:
  - add a new "head" in the direction of the snake's motion
  - if not extending: remove the last segment of the snake (its tail)
- when picking a new fruit position
  - randomly try a fruit position and "fruit lifetime"
  - if this new fruit position doesn't coincide with the snake, we're good. else keep looking

With a bit-mapped screen, the checks for the snake (self-intersection; fruit candidate position) require
a single look up and non-zero check in RAM. In order to fit into my prototype FPGA board, I need to phrase
this lookup as an actual RAM with a single-cycle delay, which complicates things a little on the output for VGA
(we will need to delay the VGA signals by a clock cycle to match the RAM output).

The screen size is 80x60 (with 8x8 cells) - multiplying by either 80 is easy though.

### The snake

The snake uses the bitmapped screen as its buffer for storing and updating.

The snake module:
- has a `tail_x` and `tail_y` - `log2(width)` and `log2(height)` bits
- has a `head_x` and `head_y` - `log2(width)` and `log2(height)` bits
- has a `snake_dir` of 2 bits

To move or extend:
- update `head_x` and `head_y` by applying the `snake_dir` and then writing the appropriate `3'b1DD` direction to the bitmapped screen.
- If not extending, update the `tail_x` and `tail_y` by looking at the screen buffer at `tail_x`, `tail_y` and inferring the direction. It then erases the screen buffer at that location.

Some care needs to be taken to ensure only one device uses the RAM at a time. Multi-porting seems like overkill?

### Drawing the screen

Using the bitmap to draw the appropriate coloured sections is somewhat straightforward, however accessing the
bitmap RAM is a one-cycle delay. We either need to "pre-empt" and look one location ahead, or we delay the VGA
signals a single clock.

### Updating

A state machine will need to be used. At the end of the picture we have lots of time to run an update
state machine to do all we need to do before going in to "the VGA output needs the RAM" mode.

We get 525-480 = 45 scanlines to do this in, which is easily enough.

TODOs:
- Need a source of random numbers (LFSR) for the fruit.
- Need a strategy for updating the speed and snake length.
- Consider 10x10 or 12x12 to make the gameplay area more appropriate (and save RAM)
