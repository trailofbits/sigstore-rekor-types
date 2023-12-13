SHELL := /bin/bash

PY_MODULE := rekor_types

ALL_PY_SRCS := $(shell find $(PY_MODULE) -name '*.py')

# Optionally overriden by the user, if they're using a virtual environment manager.
VENV ?= env

# On Windows, venv scripts/shims are under `Scripts` instead of `bin`.
VENV_BIN := $(VENV)/bin
ifeq ($(OS),Windows_NT)
	VENV_BIN := $(VENV)/Scripts
endif

# Optionally overridden by the user in the `release` target.
BUMP_ARGS :=

# Optionally overridden by the user/CI, to limit the installation to a specific
# subset of development dependencies.
INSTALL_EXTRA := dev

.PHONY: all
all:
	@echo "Run my targets individually!"

.PHONY: dev
dev: $(VENV)/pyvenv.cfg

$(VENV)/pyvenv.cfg: pyproject.toml
	# Create our Python 3 virtual environment
	python3 -m venv env
	$(VENV_BIN)/python -m pip install --upgrade pip
	$(VENV_BIN)/python -m pip install -e .[$(INSTALL_EXTRA)]

.PHONY: lint
lint: $(VENV)/pyvenv.cfg
	. $(VENV_BIN)/activate && \
		black --preview --check $(ALL_PY_SRCS) && \
		ruff $(ALL_PY_SRCS) && \
		mypy $(PY_MODULE)

.PHONY: reformat
reformat:
	. $(VENV_BIN)/activate && \
		black --preview $(ALL_PY_SRCS) && \
		ruff --fix $(ALL_PY_SRCS)

.PHONY: doc
doc: $(VENV)/pyvenv.cfg
	. $(VENV_BIN)/activate && \
		pdoc -o html $(PY_MODULE)

.PHONY: package
package: $(VENV)/pyvenv.cfg
	. $(VENV_BIN)/activate && \
		python3 -m build

.PHONY: edit
edit:
	$(EDITOR) $(ALL_PY_SRCS)
