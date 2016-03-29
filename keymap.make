# The MIT License (MIT)
#
# Copyright (c) 2016 Matei David, Ontario Institute for Cancer Research
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 

.SUFFIXES:
MAKEFLAGS += -r
SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

### keymap options
#
# KEYMAP_FILES
#   List of files with (key,value) pairs. Keys in later files override keys in earlier files.
#
ifndef KEYMAP_FILES
KEYMAP_FILES = \
	$(shell ! [ -r KEYS ] || echo KEYS) \
	$(shell ! [ -r KEYS.local ] || echo KEYS.local)
endif
#
# KEYMAP_PREFIX
#   Prefix for make variables holding the map.
#
ifndef KEYMAP_PREFIX
KEYMAP_PREFIX = KEYMAP
endif
#
# KEYMAP_SEPARATOR
#   Separator for keys.
#
ifndef KEYMAP_SEPARATOR
KEYMAP_SEPARATOR = |
endif

# load keymap
cat_keymap_file := "cat ${KEYMAP_FILES} | egrep -v \"^ *($$|\#)\""
$(foreach i,$(shell seq 1 $(shell eval ${cat_keymap_file} | wc -l)),\
$(eval $(shell eval ${cat_keymap_file} | awk -v prefix="${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}" 'NR==${i} { key=$$1; for(i=2;i<=NF;++i) $$(i-1)=$$i; NF-=1; print prefix key " := " $$0}')))

KEYMAP_KEY_LIST := $(patsubst ${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}%,%,$(filter ${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}%,${.VARIABLES}))

# compute prefix lists
KEYMAP_KEY_PREFIX_LIST_DELIMITED := \
$(shell eval ${cat_keymap_file} | awk -v delim="${KEYMAP_SEPARATOR}" '{n=split($$1,a,delim); p=""; for(i=1;i<=n;++i) { print p delim; p = p delim a[i];} }' | sort | uniq)
KEYMAP_KEY_PREFIX_LIST := \
$(foreach kp,${KEYMAP_KEY_PREFIX_LIST_DELIMITED},\
$(patsubst ${KEYMAP_SEPARATOR}%,%,$(patsubst %${KEYMAP_SEPARATOR},%,${kp})))

# initialize prefix lists
$(foreach kp,${KEYMAP_KEY_PREFIX_LIST_DELIMITED},$(eval $(shell { echo -n "${KEYMAP_PREFIX}${kp} := "; eval ${cat_keymap_file} | awk -v delim="${KEYMAP_SEPARATOR}" -v kp="$(patsubst ${KEYMAP_SEPARATOR}%,%,${kp})" 'BEGIN{kp_len=length(kp)} substr($$1,1,kp_len)==kp {s=substr($$1,kp_len+1); n=split(s,a,delim); print a[1];}' | sort | uniq; })))

### main exports
#
# keymap_val
#   Get value for full key.
#
keymap_val = $(${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}${1})
#
# keymap_key_list
#   List next components for partial key.
#
keymap_key_list = $($(if ${1},${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}${1}${KEYMAP_SEPARATOR},${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}))

print-%:
	@echo '$* = $($*)'

# e.g.,
# print-${KEYMAP_PREFIX}${KEYMAP_SEPARATOR}
