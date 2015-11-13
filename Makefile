PANDOC = pandoc
IFORMAT = markdown
FLAGS = --standalone --toc --toc-depth=2 --highlight-style pygments
TEMPLATE = page.tmpl
STYLE = css/style.css
PUB_SRV_HOST = "ratina.org"
PUB_SRV_USER = "root"

HTML = tutorial.html

# Check if sandbox exists. If it does, then use it instead.
ifeq ("$(wildcard $(.cabal-sandbox/))","")
	GHC=ghc -no-user-package-db -package-db .cabal-sandbox/*-packages.conf.d
else
	GHC=ghc
endif

all: $(HTML)

includes: includes.hs
	$(GHC) --make $< ; \

%.html: %.md includes
	./includes < $<  \
	| $(PANDOC) -c $(STYLE) --template $(TEMPLATE) -s -f $(IFORMAT) -t html $(FLAGS) \
	| sed '/<extensions>/r extensions.html' > $@

%.epub: %.md includes
	./includes < $< | $(PANDOC) -f $(IFORMAT) -t epub $(FLAGS) -o $@

%.pdf: %.md includes
	./includes < $< | $(PANDOC) -c -s -f $(IFORMAT) --latex-engine=xelatex $(FLAGS) -o $@

preview: all
	xdg-open $(HTML)

pub: all
	rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress tutorial.html extensions.csv extensions.html css img nav.js $(PUB_SRV_USER)@$(PUB_SRV_HOST):/var/www/pub/wiwinwlh/

clean:
	-rm $(CHAPTERS) $(HTML)
