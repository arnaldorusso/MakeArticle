PY=python
ASCIIDOC=asciidoc
ASCIIDOCTOR=asciidoctor
ASCIIDOCBIB=asciidoc-bib
DBLATEX=dblatex
PANDOC=pandoc
UNOCONV=unoconv

#STSTYLE=apa
STSTYLE=elsevier-harvard

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/article
INPUTFILE=$(INPUTDIR)/text.adoc
OUTPUTDIR=$(INPUTDIR)/output
CONFFILE=$(BASEDIR)/print.css

help:
	@echo 'Makefile for thesis written in AsciiDoc			    '
	@echo '								    '
	@echo 'Usage:							    '
	@echo '   make bib [optional style]	(re)generate the text with'
	@echo '   		bib included. See more information	    '
	@echo ' 		https://github.com/citation-style-language/styles'
	@echo '   make clean			remove the generated files  '
	@echo '   make article [optional file]	generate text output      '
	@echo '   make raw			generate html output'
	@echo '   make pdf			generate pdf file           '
	@echo '   make tex			generate a .tex file	    '
	@echo '   make doc			generate a .docx file       '
	@echo '   make doc2adoc		convert a .docx back to output.adoc'

bib:
ifdef STYLE
	cd $(INPUTDIR) && \
	$(ASCIIDOCBIB) -s $(STYLE) -n $(INPUTFILE) && \
	mv text-ref.adoc $(OUTPUTDIR)
else
	cd $(INPUTDIR) && \
	$(ASCIIDOCBIB) -s $(STSTYLE) -n $(INPUTFILE) && \
	mv text-ref.adoc $(OUTPUTDIR)
endif

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -f $(OUTPUTDIR)/*.*

%.html: %.adoc
	cd $(OUTPUTDIR) && \
	cp $< $(CURDIR) && \
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $<

article:
ifdef FILENAME
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $(FILENAME)
else
	cd $(OUTPUTDIR) && \
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) text-ref.adoc
endif

raw:
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $(INPUTDIR)/text.adoc
	mv $(INPUTDIR)/text.html $(OUTPUTDIR)

pdf:
	cd $(OUTPUTDIR) && \
	$(ASCIIDOCTOR) -b docbook5 text-ref.adoc && \
	$(DBLATEX) -T db2latex text-ref.xml

tex:
	cd $(OUTPUTDIR) && \
	$(ASCIIDOCTOR) -b docbook5 text-ref.adoc && \
   	$(DBLATEX) -T db2latex -t tex text-ref.xml

doc:
	cd $(OUTPUTDIR) &&\
	$(PANDOC) -o text-ref.docx text-ref.html

doc2adoc:
	cd $(OUTPUTDIR) &&\
	rm text-ref.html &&\
	$(UNOCONV) -f html text-ref.docx &&\
	$(PANDOC) -f html -t asciidoc text-ref.html -o converted.adoc

.PHONY: bib clean html article raw pdf tex doc doc2adoc
