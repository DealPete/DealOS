.PHONY: all clean test

OCAMLBUILD      := ocamlbuild -use-ocamlfind -use-menhir -menhir "menhir --infer"

MAIN            := fortran

all:
	$(OCAMLBUILD) $(MAIN).native

clean:
	rm -f *~ .*~
	$(OCAMLBUILD) -clean

