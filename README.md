# BatCAT Testbed

Testbed for the BatCAT data space.

## Requirements

* Docker installed
* a POSIX-compliant shell

All commands are executed from the repository's root directory unless stated otherwise.

## Initialize GIT Submodules

* `git submodule update --init`

## Build the Testbed

* `make`

This will:

* build an edc connector docker image
* build linkahead (server and backend components) images
* build an untus-proxy image
* build a token-service image

## Deploy the Testbed

* `cd deployment/`
* see README.md there
* `docker compose up -d`

## Tests

After deployment, you can run tests:

* `cd tests`
* see README there
* run any of the tests
    * `./test_tokens.sh`
    * `./transfer-pull.sh`
    * `./transfer-push.sh`

## License

AGPL 3.0 or later

* Copyright (C) 2025 IndiScale GmbH <info@indiscale.com>
* Copyright (C) 2025 Timm Fitschen <t.fitschen@indiscale.com>
* Copyright (C) 2025 Henrik tom Wörden
* Copyright (C) 2025 Daniel Hornung

