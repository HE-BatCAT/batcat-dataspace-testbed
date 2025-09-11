build: .init build-edc-connector build-token-service build-linkahead build-untus-proxy

### BUILD IMAGES
build-untus-proxy:
	$(MAKE) -C untus-proxy

build-linkahead:
	$(MAKE) -C linkahead

build-token-service:
	$(MAKE) -C token-service

build-edc-connector:
	$(MAKE) -C edc

init: .init
	git submodule update --init --recursive

.init:
	touch .init
