import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

_WIDTH = 80
_HEIGHT = 60


@cocotb.test()
async def test_read_and_write_simple(dut):
    clock = Clock(dut.clk, 10, units="us")
    await cocotb.start(clock.start())
    dut.x.value = 0
    dut.y.value = 0
    dut.write_enable.value = 0
    dut.write_value.value = 0
    await ClockCycles(dut.clk, 5)
    assert not dut.out.value.is_resolvable  # all the RAM is still uninitialised

    dut.x.value = 0
    dut.y.value = 0
    dut.write_enable.value = 1
    dut.write_value.value = 0b010
    await ClockCycles(dut.clk, 1)
    await Timer(1, units="ns")  # TODO why needed
    assert dut.out.value.integer == 0b010

    dut.x.value = 0
    dut.y.value = 0
    dut.write_enable.value = 0
    await ClockCycles(dut.clk, 1)
    await Timer(1, units="ns")  # TODO why needed
    assert dut.out.value.integer == 0b010

    dut.x.value = 1
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)
    await Timer(1, units="ns")  # TODO why needed
    assert not dut.out.value.is_resolvable  # this byte of RAM is still uninitialised

    dut.x.value = 0
    dut.y.value = 1
    await ClockCycles(dut.clk, 1)
    await Timer(1, units="ns")  # TODO why needed
    assert not dut.out.value.is_resolvable  # this byte of RAM is still uninitialised


@cocotb.test()
async def test_read_and_write_random_access(dut):
    clock = Clock(dut.clk, 10, units="us")
    await cocotb.start(clock.start())
    dut.write_enable.value = 1
    written = {}
    for y in range(0, _HEIGHT):
        for x in range(0, _WIDTH):
            dut.x.value = x
            dut.y.value = y
            rand_val = random.randint(0, 7)
            dut.write_value.value = rand_val
            written[(x, y)] = rand_val
            await ClockCycles(dut.clk, 1)
    dut.write_enable.value = 0
    for y in range(0, _HEIGHT):
        for x in range(0, _WIDTH):
            dut.x.value = x
            dut.y.value = y
            dut.write_value.value = rand_val
            await ClockCycles(dut.clk, 1)
            await Timer(10, units="ns")  # TODO why needed??
            # print(x, y, dut.out.value.integer, written[(x,y)])
            assert dut.out.value.integer == written[(x, y)]
