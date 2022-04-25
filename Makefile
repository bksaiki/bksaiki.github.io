#
# 	Makefile for Brett Saiki's website
#

all: deps notes
	racket tools/generate.rkt

notes:
	mkdir -p docs/papers
	git -C papers pull || git clone git@github.com:bksaiki/papers.git

deps:
	raco pkg install --skip-installed markdown
	raco make tools/*.rkt
