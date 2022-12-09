#!/bin/bash

# From https://misha.brukman.net/blog/2019/08/configuring-evoluent-verticalmouse-4-on-linux/

id=$1

while true; do
  clear

  # Be sure to use the device id produced by the output of `xinput list`!
  xinput query-state $id

  # Alternatively, you can use the full device name:
  #     xinput query-state "Kingsis Peripherals Evoluent VerticalMouse 4"
  # will work as well.

  sleep 1
done
