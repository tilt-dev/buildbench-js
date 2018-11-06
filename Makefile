.PHONY: naive cachedeps cacheobjs cacheobjs-base tailybuild tailybuild-base profile clean

define inject-nonce
  sed -i -e 's/"nonce": .*$$/"nonce": "$(shell date)",/' package.json
endef

define reset-nonce
  sed -i -e 's/nonce = .*$$/nonce = "date",/' package.json
endef

profile:
	python3 profile.py

naked:
	$(call inject-nonce)
	npm install .

naive:
	$(call inject-nonce)
	docker build -t windmill.build/buildbench-js/naive -f Dockerfile.naive .
	docker run --rm -it windmill.build/buildbench-js/naive

buildkit:
	$(call inject-nonce)
	DOCKER_BUILDKIT=1 docker build -t windmill.build/buildbench-js/buildkit -f Dockerfile.buildkit .
	docker run --rm -it windmill.build/buildbench-js/buildkit

cachemount:
	$(call inject-nonce)
	DOCKER_BUILDKIT=1 docker build -t windmill.build/buildbench-js/cachemount -f Dockerfile.cachemount .
	docker run --rm -it windmill.build/buildbench-js/cachemount

cachedir-base:
	if [ "$(shell docker images windmill.build/buildbench-js/cachedir-base -q)" = "" ]; then \
		docker build -t windmill.build/buildbench-js/cachedir-base -f Dockerfile.cachedir --target=dir-cache .; \
	fi;

cachedir: cachedir-base
	$(call inject-nonce)
	docker build --build-arg baseImage=windmill.build/buildbench-js/cachedir-base \
               -t windmill.build/buildbench-js/cachedir \
               -f Dockerfile.cachedir .
	docker run --rm -it windmill.build/buildbench-js/cachedir

cachedircopy-base:
	if [ "$(shell docker images windmill.build/buildbench-js/cachedircopy-base -q)" = "" ]; then \
		docker build -t windmill.build/buildbench-js/cachedircopy-base -f Dockerfile.cachedircopy --target=dir-cache .; \
	fi;

cachedircopy: cachedircopy-base
	$(call inject-nonce)
	docker build --build-arg copyImage=windmill.build/buildbench-js/cachedircopy-base \
               -t windmill.build/buildbench-js/cachedircopy \
               -f Dockerfile.cachedircopy .
	docker run --rm -it windmill.build/buildbench-js/cachedircopy

cachedirbuildkit-base:
	if [ "$(shell docker images windmill.build/buildbench-js/cachedirbuildkit-base -q)" = "" ]; then \
		docker build -t windmill.build/buildbench-js/cachedirbuildkit-base -f Dockerfile.cachedirbuildkit --target=dir-cache .; \
	fi;

cachedirbuildkit: cachedirbuildkit-base
	$(call inject-nonce)
	DOCKER_BUILDKIT=1 docker build --build-arg baseImage=windmill.build/buildbench-js/cachedirbuildkit-base \
               -t windmill.build/buildbench-js/cachedirbuildkit \
               -f Dockerfile.cachedirbuildkit .
	docker run --rm -it windmill.build/buildbench-js/cachedirbuildkit

tailybuild-base:
	if [ "$(shell docker ps --filter=name=tailybuild -q)" = "" ]; then \
		docker build -t windmill.build/buildbench-js/tailybuild-base -f Dockerfile.tailybuild .; \
    docker run --name tailybuild -d windmill.build/buildbench-js/tailybuild-base; \
	fi;

tailybuild: tailybuild-base
	$(call inject-nonce)
	docker cp package.json tailybuild:/app/package.json
	docker exec -it tailybuild npm install .

clean:
	$(call reset-nonce)
	rm -fR node_modules
	docker kill tailybuild && docker rm tailybuild || exit 0
	docker rmi -f $(shell docker image ls --filter=reference=windmill.build/buildbench-js/* -q) || exit 0
