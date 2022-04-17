#
# 	Makefile for Brett Saiki's website
#

all: deps notes
	racket tools/generate.rkt

notes:
	mkdir -p docs/papers
	git -C papers pull || git clone https://github.com/bksaiki/papers
	cp papers/folland/real-analysis.pdf \
	   papers/gamelin/complex-analysis.pdf \
	   papers/probability/probability.pdf \
	   papers/numerical-analysis/numerical-analysis.pdf \
	   docs/papers
	cp papers/computer_numbers_systems/paper.pdf docs/papers/computer-numbers.pdf
	cp papers/rewriting_blog/rewriting.pdf docs/papers/computer-rewriting.pdf

deps:
	raco pkg install --skip-installed markdown
	raco make tools/*.rkt
