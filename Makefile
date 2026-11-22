.PHONY: deps test test_file format format_check coverage

NVIM_TEST = nvim --headless --noplugin -u tests/init.lua
# markup.nvim, the UI library, at a release: its build.lua downloads the
# engine built for this platform, so no Rust is needed to test.
MARKUP_VERSION ?= v0.6.0
MARKUP = deps/markup.nvim
ROCKS = .tests/rocks
# How many test files run at once
JOBS ?= $(shell nproc 2>/dev/null || echo 2)
# How long a test file may run
TEST_TIMEOUT ?= 10m
COVERAGE_TIMEOUT ?= 20m
# The least coverage, in percent
COVERAGE_MIN ?= 75
# Patch coverage uses the same LCOV report. Override the base for a longer series.
PATCH_COVERAGE_MIN ?= 80
COVERAGE_BASE ?= HEAD^
DIFF_COVER = pipx run --spec diff-cover==11.0.4 diff-cover
PATCH_CHECK = $(DIFF_COVER) --compare-branch "$(COVERAGE_BASE)" --diff-range-notation=.. --include-untracked --fail-under=$(PATCH_COVERAGE_MIN)
# The headers of LuaJIT, to build cluacov for it
LUAJIT_INCDIR ?= /usr/include/luajit-2.1

# A checkout of markup.nvim to test against: next to this repository when it
# is there, as when working on both. Without one (as in CI), the release
# MARKUP_VERSION is cloned into deps/.
MARKUP_PATH ?= $(if $(wildcard ../markup.nvim/lua/markup),$(abspath ../markup.nvim),)
export MARKUP_PATH

# The HTML parser of tree-sitter, which problem descriptions are read with.
# Neovim does not come with it; users get it from nvim-treesitter.
HTML_PARSER_VERSION ?= v0.23.2
HTML_PARSER = deps/parsers/parser/html.so

# What the tests need: mini.test, markup.nvim with its engine, and the HTML
# parser.
deps: deps/mini.test $(if $(MARKUP_PATH),,$(MARKUP)) $(HTML_PARSER)

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
	$(PATCH_CHECK) .tests/coverage/lua.lcov || failed=1; \
	exit $$failed

deps/mini.test:
	@mkdir -p deps
	git clone --quiet --filter=blob:none https://github.com/echasnovski/mini.test $@

$(MARKUP):
	@mkdir -p deps
	git -c advice.detachedHead=false clone --quiet --filter=blob:none --branch $(MARKUP_VERSION) https://github.com/kawre/markup.nvim $@
	cd $@ && nvim -l build.lua

$(HTML_PARSER):
	@mkdir -p deps/parsers/parser
	git -c advice.detachedHead=false clone --quiet --depth 1 --branch $(HTML_PARSER_VERSION) https://github.com/tree-sitter/tree-sitter-html deps/tree-sitter-html
	cc -O2 -shared -fPIC -I deps/tree-sitter-html/src deps/tree-sitter-html/src/parser.c deps/tree-sitter-html/src/scanner.c -o $@

# LuaCov and its hook in C, in a tree of the project's own
$(ROCKS):
	luarocks --lua-version 5.1 --tree $(ROCKS) install luacov
	luarocks --lua-version 5.1 --tree $(ROCKS) install luacov-reporter-lcov
	luarocks --lua-version 5.1 --tree $(ROCKS) install cluacov LUA_INCDIR=$(LUAJIT_INCDIR)
