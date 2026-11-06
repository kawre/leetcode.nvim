# Run the UI tests. Expects markup.nvim next to this repository, or at `$MARKUP_PATH`.
test:
	nvim --headless --noplugin -u tests/init.lua -c "lua MiniTest.run()"
