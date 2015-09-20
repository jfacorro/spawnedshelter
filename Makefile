SRC_DIR = src
BUILD_DIR = build
IMG_DIR = img
NODE_BIN_PATH = ./node_modules/.bin

SERVER = $(NODE_BIN_PATH)/browser-sync start --reload-delay 500 --files $(BUILD_DIR) --server $(BUILD_DIR) --port 8000
POSTCSS = $(NODE_BIN_PATH)/postcss --use autoprefixer
LINTER_HTML = $(NODE_BIN_PATH)/htmlhint
LINTER_CSS = $(NODE_BIN_PATH)/csslint
PANDOC = pandoc
STALK = stalk -w 1 make
STYLUS = stylus

STYLE_STYL = style.styl
STYLE_CSS = style.css

CONTENT_TEMPL = content.tmpl
CONTENT_MD = content.md
INDEX_HTML = index.html

default: compile

deps:
	cabal install pandoc
	npm install

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf $(BUILD_DIR)/.git

favicon:
	cp favicon $(BUILD_DIR)
	convert favicon.png  -bordercolor white -border 0 (-clone 0 -resize 16x16) (-clone 0 -resize 32x32) (-clone 0 -resize 48x48) (-clone 0 -resize 64x64) -delete 0 -alpha off -colors 256 $(BUILD_DIR)favicon.ico

compile:
	mkdir -p $(BUILD_DIR)
	cp -R $(IMG_DIR) $(BUILD_DIR)
	$(STYLUS) $(SRC_DIR)/$(STYLE_STYL) -o $(BUILD_DIR)/$(STYLE_CSS)
	$(POSTCSS) $(BUILD_DIR)/$(STYLE_CSS) > $(BUILD_DIR)/$(STYLE_CSS).prefixed
	mv $(BUILD_DIR)/$(STYLE_CSS).prefixed $(BUILD_DIR)/$(STYLE_CSS)
	$(PANDOC) --section-divs --toc --toc-depth=2 --template $(SRC_DIR)/$(CONTENT_TEMPL) -t html5 $(SRC_DIR)/$(CONTENT_MD) > $(BUILD_DIR)/$(INDEX_HTML)

dev: compile
	$(STALK) $(SRC_DIR)&
	$(SERVER)

lint: compile
	$(LINTER_HTML) $(BUILD_DIR)/*.html
	$(LINTER_CSS) $(BUILD_DIR)/*.css

publish: clean compile
	cd $(BUILD_DIR) && \
	echo "spawnedshelter.com" > CNAME && \
	git init && \
	git remote add gh-pages git@github.com:unbalancedparentheses/spawnedshelter.git && \
	git add . && \
	git commit -m 'Update website' && \
	git push -f gh-pages master:gh-pages
	echo "check http://spawnedshelter.com/"
