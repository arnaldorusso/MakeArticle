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
INPUTFILE=$(BASEDIR)/text.adoc
OUTPUTDIR=$(BASEDIR)/output
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
	$(ASCIIDOCBIB) -s $(STYLE) -n $(INPUTFILE) && \
	mv text-ref.adoc $(OUTPUTDIR)
else
	$(ASCIIDOCBIB) -s $(STSTYLE) -n $(INPUTFILE) && \
	mv text-ref.adoc $(OUTPUTDIR)
endif

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -f $(OUTPUTDIR)/*.*

#html: text.html
#%.html: %.adoc
#	cp $< $(OUTPUTDIR)
#	cd $(OUTPUTDIR) && \
#	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $<

article: text.html
%.html: %.adoc
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $<
	mv $@ $(OUTPUTDIR)

raw:
	$(ASCIIDOCTOR) -a stylesheet=$(CONFFILE) $(INPUTDIR)/text.adoc
	mv $(INPUTDIR)/text.html $(OUTPUTDIR)

xml: text.xml
%.xml: %.adoc
	$(ASCIIDOCTOR) -b dockbook5 $< && \
	mv $@ $(OUTPUTDIR)

pdf:
	cd $(OUTPUTDIR) && \
	$(ASCIIDOCTOR) -b docbook5 text-ref.adoc && \
	$(DBLATEX) -T db2latex text-ref.xml

#pdf: xml text-ref.xml
#%.pdf: %.xml
#	cd $(OUTPUTDIR) && \
#	$(DBLATEX) -T db2latex $<

tex:
	cd $(OUTPUTDIR) && \
	$(ASCIIDOCTOR) -b docbook5 text-ref.adoc && \
   	$(DBLATEX) -T db2latex -t tex text-ref.xml

doc:
%.html: %.docx
	cd $(OUTPUTDIR) &&\
	$(PANDOC) -o output.docx $<

doc2adoc:
	cd $(OUTPUTDIR) &&\
	rm text-ref.html &&\
	$(UNOCONV) -f html text-ref.docx &&\
	$(PANDOC) -f html -t asciidoc text-ref.html -o converted.adoc

.PHONY: bib clean html article raw xml pdf tex doc doc2adoc
