#
# 	Makefile for Brett Saiki's website
#

all: 
	raco pkg install --skip-installed markdown
	raco make tools/*.rkt
	racket tools/generate.rkt
