.PHONY: render preview print

QMD_CODE_DIR := _static/qmd_code
QMD_RENDER_DIR := _static/qmd_render

QMD_CODE_FILES := $(wildcard $(QMD_CODE_DIR)/*.qmd)
QMD_RENDER_FILES := $(patsubst $(QMD_CODE_DIR)/%.qmd,$(QMD_RENDER_DIR)/%.qmd,$(QMD_CODE_FILES))

QMD_FILES := $(wildcard exercises/*.qmd) $(wildcard *.qmd)
HTML_FILES := $(patsubst %.qmd,_site/%.html,$(QMD_FILES))
YML_FILES := $(wildcard *.yml) $(wildcard exercises/*.yml)

$(QMD_RENDER_FILES): $(QMD_RENDER_DIR)/%.qmd: $(QMD_CODE_DIR)/%.qmd $(QMD_RENDER_DIR)/_quarto.yml
	awk '{gsub(/# <[0-9]+>/, ""); print}' $(patsubst $(QMD_RENDER_DIR)/%.qmd,$(QMD_CODE_DIR)/%.qmd,$@) > $@
	quarto render $@
	touch exercises/09-Reproducible-Research.qmd

$(HTML_FILES): %.html: $(patsubst _site/%.html,%.qmd,$@) 
	quarto render $<

render: $(QMD_RENDER_FILES) $(QMD_FILES) $(HTML_FILES) $(YML_FILES) qmd-demo.lua styles.css

preview: render
	quarto preview

print: $(QMD_CODE_FILES) $(QMD_FILES) $(YML_FILES) qmd-demo.lua styles.css
	ls -la $?