extension = material-shell@papyelgringo
extension_tool = gnome-extensions

.PHONY: schemas compile build_prod build_tasks update_git update install disable enable dist

schemas:
	cp -r schemas dist
	glib-compile-schemas dist/schemas/

sass: dist/style-dark-theme.css dist/style-light-theme.css dist/style-primary-theme.css

dist/style-dark-theme.css: dist src/styles/dark-theme.scss
	npx sass --no-source-map src/styles/dark-theme.scss dist/style-dark-theme.css

dist/style-light-theme.css: dist src/styles/light-theme.scss
	npx sass --no-source-map src/styles/light-theme.scss dist/style-light-theme.css

dist/style-primary-theme.css: dist src/styles/primary-theme.scss
	npx sass --no-source-map src/styles/primary-theme.scss dist/style-primary-theme.css

dist:
	rm -rf dist
	mkdir dist

disable:
	$(extension_tool) disable $(extension)

enable:
	$(extension_tool) enable $(extension)

npm_dependencies:
	npm install

zip_dist:
	rm -f dist.zip
	cd dist && zip -r ../dist.zip *

build_prod: npm_dependencies compile zip_dist

clean:
	rm -rf build

compile: dist schemas sass
	npx tsc
	npx tsc scripts/transpile.ts --outDir build && node build/transpile.js
	npm run rollup-extension && npm run rollup-prefs
	sed "s/{put_commit_there}/$(shell git rev-parse --short HEAD)/" metadata.json > dist/metadata.json
	cp -r assets dist/assets

update_git:
	git pull --ff-only

update: update_git install

install:
	./scripts/install.py
