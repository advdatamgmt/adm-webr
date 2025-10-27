.PHONY: render preview print

QMD_CODE_DIR := _static/qmd_code
QMD_RENDER_DIR := _static/qmd_render

# For embedded quarto documents
QMD_CODE_FILES := $(wildcard $(QMD_CODE_DIR)/*.qmd)
QMD_RENDER_FILES := $(subst $(QMD_CODE_DIR),$(QMD_RENDER_DIR),$(QMD_CODE_FILES))
QMD_HTML_FILES := $(patsubst %.qmd,%.html,$(QMD_RENDER_FILES))

# For the overall website
QMD := $(wildcard exercises/*.qmd) $(wildcard *.qmd)
YML := $(wildcard *.yml) $(wildcard exercises/*.yml)
HTML := $(patsubst %.qmd,_site/%.html,$(QMD))

$(QMD_RENDER_DIR)/%.qmd: $(QMD_CODE_DIR)/%.qmd
	awk '{gsub(/# <[0-9]+>/, ""); print}' < $< > $@

$(QMD_HTML_FILES): %.html: %.qmd 
	quarto render $<

_site/exercises/09-Reproducible-Research.html: exercises/09-Reproducible-Research.qmd $(subst $(QMD_RENDER_DIR)/exercise.html,,$(QMD_HTML_FILES))
	quarto render $<

_site/exercises/09c-Reproducible-Research-Exercise.html: exercises/09c-Reproducible-Research-Exercise.qmd $(YML) $(QMD_RENDER_DIR)/exercise.html styles.css
	quarto render $<

_site/%.html: %.qmd $(YML) styles.css
	quarto render $<

render: $(HTML) exercises/09*.qmd $(QMD_HTML_FILES) 

preview: render
	quarto preview

print:
	@echo $(QMD_RENDER_FILES)
	@echo $(QMD_HTML_FILES)
	@echo $(QMD)
	@echo $(HTML)