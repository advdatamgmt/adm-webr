#!/bin/bash
podman run -it --rm -v ${PWD}/output:/output -w /output ghcr.io/r-wasm/webr:main R
