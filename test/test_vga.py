import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

VGA_CLOCK_FREQ = 12.125 * 1000 * 1000
NS_PER_CLOCK = int(1_000_000_000 / VGA_CLOCK_FREQ)


async def reset(dut):
    dut.reset.value = 1
    await ClockCycles(dut.clk, 1)
    dut.reset.value = 0
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_reset(dut):
    clock = Clock(dut.clk, NS_PER_CLOCK, units="ns")
    await cocotb.start(clock.start())

    await reset(dut)
    assert dut.pos_x == 0
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 1


@cocotb.test()
async def test_increments_x(dut):
    clock = Clock(dut.clk, NS_PER_CLOCK, units="ns")
    await cocotb.start(clock.start())

    await reset(dut)
    await ClockCycles(dut.clk, 100)
    assert dut.pos_x == 100
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 1


@cocotb.test()
async def test_vga_hblank_one_line(dut):
    clock = Clock(dut.clk, NS_PER_CLOCK, units="ns")
    await cocotb.start(clock.start())
    await reset(dut)

    # last pixel on the line
    await ClockCycles(dut.clk, 639)
    assert dut.pos_x == 639
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 1

    # first pixel of the front porch
    await ClockCycles(dut.clk, 1)
    assert dut.pos_x == 640
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 0

    # Just before the end of the front porch
    await ClockCycles(dut.clk, 15)
    assert dut.pos_x == 655
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 0

    # During the sync pulse
    await ClockCycles(dut.clk, 1)
    assert dut.pos_x == 656
    assert dut.pos_y == 0
    assert dut.hsync == 1
    assert dut.vsync == 0
    assert dut.display_on == 0

    # Last clock of the sync pulse
    await ClockCycles(dut.clk, 95)
    assert dut.pos_x == 751
    assert dut.pos_y == 0
    assert dut.hsync == 1
    assert dut.vsync == 0
    assert dut.display_on == 0

    # first cycle back porch...
    await ClockCycles(dut.clk, 1)
    assert dut.pos_x == 752
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 0

    # last cycle back porch...
    await ClockCycles(dut.clk, 47)
    assert dut.pos_x == 799
    assert dut.pos_y == 0
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 0

    # first of next line
    await ClockCycles(dut.clk, 1)
    assert dut.pos_x == 0
    assert dut.pos_y == 1
    assert dut.hsync == 0
    assert dut.vsync == 0
    assert dut.display_on == 1
