#
# 	Makefile for Brett Saiki's website
#

all: 
	raco make tools/*.rkt
	racket tools/generate.rkt