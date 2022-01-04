#!/bin/bash

iverilog -Wall -g2012 -o out core_tb.sv && vvp out
