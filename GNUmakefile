ifeq ($(wildcard Makefile),)
$(sort $(MAKECMDGOALS) all): Makefile
	make $(MAKECMDGOALS)

Makefile: Makefile.PL
	perl Makefile.PL
	test -e Makefile

else
include Makefile
endif
