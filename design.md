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
  - if not extending: put the "tail" at the head location in the snake buffer (conceptually)
  - if extending: add a new "head" segment
- when picking a new fruit position
  - randomly try a fruit position and "fruit lifetime"
  - if this new fruit position doesn't coincide with the snake, we're good. else keep looking

Each of the snake searches (self-intersection; fruit candidate position) can be done over a number of
cycles, by iterating over the length of the snake, generating snake positions and comparing against.
The comparisons are linear in the maximum length of the snake (which is a limiting factor).

We also need to be able to generate "all the snake segments on this line", which is a case of iterating
over the length of the snake and comparing the y position - a single line's bitmap can be generated for
the VGA output.

### Storing the snake

The snake is stored in a circular buffer, with a head and tail (naturally). The buffer is a fixed size
which limits the maximum length of the snake.

The snake module:
- has a `tail_x` and `tail_y` - `log2(width)` and `log2(height)` bits
- has `NUMSLOTS` direction offsets (buffer) 2 bits each
- has a `head` offset and a `tail` offset in the buffer `log2(NUMSLOTS)` bits

It can generate all the positions of the snake one after another, one cycle after another. It does this
by starting at `tail_x`, `tail_y` and then each cycle updating by running along the length of the snake,
from `tail` offset, wrapping around the `head` offset.

It needs to be able to move forward:
- update the `tail_x` and `tail_y` by applying the `tail` slot's direction
- increment `tail` offset, and `head` offset, and writing the new direction into the `head` slot

It needs to extend:
- increment `head` and write the new direction into the `head` slot

Vague plans of ins and outs:
- in: start iteration
- out: iteration over
- in: x and y position
- out: output is valid (x and y are a part of the snake)
- out: full (no more room!)
- in: in_x and in_y
- in: new_head (in_x and in_y should be placed in the head position)
- in: move_tail (tail should be updated)

### Drawing the screen

Assuming 512 snake slots, and 8x8 grid, we're not going to be filing the screen all that much, which
might make this game a bit easy. The 8x8 on VGA gives a play area of 80x60 (though we could restrict
to a subregion).

Either way, we get 800 cycles on VGA each line to be able to iterate over the 512 (if we do one a cycle).
We can also use the 8 frames "above" each y slice, so we could do 8*512 if needed. The result of this
operation is a bitmap of "snake/not snake" 1bpp for the 8 lines. We'd need to run this ahead of the
raster.

### Updating

We need to do up to two searches per frame:
- snake self-intersection
- new fruit location self-intersection test

We only need to do one iteration, and check both at the same time.

We can start the update at the moment we hit the last pixel of the VGA output. Or more easily on the
first line after. We get 525-480 = 45 scanlines to do this in, which is easily enough, as any one search
has to be less than 8 scanlines for the rest of the game to work.

TODOs:
- Need a source of random numbers (LFSR) for the fruit.
- Need a strategy for updating the speed and snake length.
- Consider 10x10 or 12x12 to make the gameplay area more appropriate.