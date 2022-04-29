#
# 	Makefile for Brett Saiki's website
#

default: web

all: papers web;

papers:
	mkdir -p docs/papers
	git -C papers pull || git clone git@github.com:bksaiki/papers.git

web: deps
	racket tools/generate.rkt

deps:
	raco pkg install --skip-installed markdown
	raco make tools/*.rkt

.PHONY: papers web deps
