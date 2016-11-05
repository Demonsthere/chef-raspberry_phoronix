# docker_vlc

## Description

This cookbooks is desinged to run in a local docker container, supplied by the Dockerfile. This container is build from the ARMv7 version of Debian, however a qemu binary-bridge is added to the image, which allows it to be run on the x86 architecture.

What this means, you can build software for the ARM (like the Raspberry Pi) inside a container on Your x86 machine. 

## VLC compilation

in the cookbook I download the dependencies for VLC, and add specific compilation rules to it, that enable Hardware Acceleration, which is needed on the Pi. The result of the compilation is a ready to use .deb package, that can be suplied to the Pi.
