.SUFFIXES:
MAKEFLAGS += -r
SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# load the keymap
KEYMAP_FILES = SAMPLE_KEYS
include ${ROOT_DIR}/keymap.make

.PHONY: all
all:
	@echo "URL of human reference: $(call keymap_val,reference|human|url)"
	@echo "Datasets: $(call keymap_key_list,dataset)"
