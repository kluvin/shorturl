.PHONY: dev release test

dev:
	@mix run --no-halt

release:
	flyctl deploy

test:
	@mix test
