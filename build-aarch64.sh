#!/bin/sh


MAKE="make"

$MAKE TARGET=arm64 TARGET_ARCH=aarch64 buildworld "$@"
