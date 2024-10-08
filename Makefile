#
#	Builds any remaining part of the website
#  	that Jekyll / GitHub can't handle
#

PAPERS = papers/computer_numbers_systems \
		 papers/construction_of_numbers \
		 papers/folland-real-analysis \
		 papers/gamelin \
		 papers/hungerford-abstract-algebra \
		 papers/numerical-analysis \
		 papers/probability \
		 papers/rewriting_blog

make: $(PAPERS)

clean:
	rm -r papers

papers/%: papers-repo/%
	mkdir -p $@
	cp -r $?/*.pdf $@

.PHONY: papers clean
