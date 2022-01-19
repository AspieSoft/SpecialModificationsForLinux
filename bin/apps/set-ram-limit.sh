#!/bin/bash

sysMemory=$(grep MemTotal /proc/meminfo | sed -r 's/[^0-9]//g')
ulimit -Sv $((sysMemory - 200000))
