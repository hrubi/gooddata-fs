.PHONY: list

OS := $(shell uname)
ifeq ($(OS),Darwin)
	# Mac specific
	LINKER_TOOL = otool -L
else
	# Linux specific
	LINKER_TOOL = ldd
endif

all: build test strip upx stats size deps outdated doc dot

install_deps:
		cargo install cargo-count
		cargo install cargo-graph
		cargo install cargo-multi
		cargo install cargo-outdated

build: build-debug build-release

build-debug:
		cargo build

build-release:
		cargo build --release

clean: clean-debug clean-release

clean-debug:
		cargo clean

clean-release:
		cargo clean --release

deps: deps-debug deps-release

deps-debug: build-debug
		${LINKER_TOOL} ./target/debug/gooddata-fs

deps-release: build-release
		${LINKER_TOOL} ./target/release/gooddata-fs

doc:
		cargo doc

dot:
		cargo graph \
			--optional-line-style dashed \
			--optional-line-color red \
			--optional-shape box \
			--build-shape diamond \
			--build-color green \
			--build-line-color orange \
			> doc/deps/cargo-count.dot

		dot -Tpng > doc/deps/rainbow-graph.png doc/deps/cargo-count.dot

list:
		@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

outdated:
		cargo outdated

rebuild: rebuild-debug rebuild-release

rebuild-debug: clean-debug build-debug

rebuild-release: clean-release build-release

size-debug:
		ls -lah ./target/debug/gooddata-fs

size-release:
		ls -lah ./target/release/gooddata-fs

size: size-debug size-release

stats:
		cargo count --separator , --unsafe-statistics

strip:
		strip ./target/release/gooddata-fs

test:
		cargo test

update:
		cargo multi update

upx:
		upx -fq --ultra-brute --best -o ./bin/gooddata-fs ./target/release/gooddata-fs

watch:
		cargo watch
