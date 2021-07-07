.PHONY: install_precommit test_precommit

install_precommit:
	pre-commit install

test_precommit: install_precommit
	pre-commit run --all-files
