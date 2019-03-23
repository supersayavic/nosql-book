.PHONY: clean

main.pdf: $(patsubst %.md,%.tex,$(wildcard content/*.md))
	latexmk -pdflatex="pplatex -c pdflatex --" -pdf -interaction=nonstopmode main.tex 2>&1 | tee latexmk_log.txt

clean:
	latexmk -C
	rm -f main.bbl main.run.xml
	
	# Remove tex files generated from markdown
	cd content; find -name "*.md" -exec basename {} .md \; | xargs -i rm -f {}.tex

content/%.tex: content/%.md
	pandoc "$<" -o "$@"
