.PHONY: deps test test_file format format_check coverage

NVIM_TEST = nvim --headless --noplugin -u tests/init.lua
# markup.nvim, the UI library, at a release: its build.lua downloads the
# engine built for this platform, so no Rust is needed to test.
MARKUP_VERSION ?= v0.2.0
MARKUP = deps/markup.nvim
ROCKS = .tests/rocks
# How many test files run at once
JOBS ?= $(shell nproc 2>/dev/null || echo 2)
# How long a test file may run
TEST_TIMEOUT ?= 10m
COVERAGE_TIMEOUT ?= 20m
# The least coverage, in percent
COVERAGE_MIN ?= 75
# The headers of LuaJIT, to build cluacov for it
LUAJIT_INCDIR ?= /usr/include/luajit-2.1

# A checkout of markup.nvim to test against: next to this repository when it
# is there, as when working on both. Without one (as in CI), the release
# MARKUP_VERSION is cloned into deps/.
MARKUP_PATH ?= $(if $(wildcard ../markup.nvim/lua/markup),$(abspath ../markup.nvim),)
export MARKUP_PATH

# What the tests need: mini.test and markup.nvim with its engine.
deps: deps/mini.test $(if $(MARKUP_PATH),,$(MARKUP))

# Run the tests, every file at once on every core, with a progress bar
test: deps
	@scripts/run_tests.sh $(JOBS) $(TEST_TIMEOUT) $(NVIM_TEST)

# Run one test file: make test_file FILE=tests/test_menu.lua
test_file: deps
	$(NVIM_TEST) -c "lua MiniTest.run_file('$(FILE)')"

# Format the Lua in place
format:
	stylua lua tests scripts

# Fail when anything is not formatted
format_check:
	stylua --check lua tests scripts

# Lua coverage of the tests, as LCOV in .tests/coverage/lua.lcov
coverage: deps $(ROCKS)
	rm -f .tests/coverage/luacov.stats.*
	@mkdir -p .tests/coverage
	@failed=0; COVERAGE=1 scripts/run_tests.sh $(JOBS) $(COVERAGE_TIMEOUT) $(NVIM_TEST) || failed=1; \
	COVERAGE_MIN=$(COVERAGE_MIN) nvim -l scripts/coverage.lua || failed=1; \
	exit $$failed

deps/mini.test:
	@mkdir -p deps
	git clone --quiet --filter=blob:none https://github.com/echasnovski/mini.test $@

$(MARKUP):
	@mkdir -p deps
	git -c advice.detachedHead=false clone --quiet --filter=blob:none --branch $(MARKUP_VERSION) https://github.com/kawre/markup.nvim $@
	cd $@ && nvim -l build.lua

# LuaCov and its hook in C, in a tree of the project's own
$(ROCKS):
	luarocks --lua-version 5.1 --tree $(ROCKS) install luacov
	luarocks --lua-version 5.1 --tree $(ROCKS) install luacov-reporter-lcov
	luarocks --lua-version 5.1 --tree $(ROCKS) install cluacov LUA_INCDIR=$(LUAJIT_INCDIR)
