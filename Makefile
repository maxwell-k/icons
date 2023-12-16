# Makefile
# Copyright 2023 Keith Maxwell
# SPDX-License-Identifier: MPL-2.0

.PHONY: all clean c1
.PRECIOUS: svg/%.svg

all: \
  png/document.png \
  png/folder-python.png \
  png/folder-vm.png \
  png/onedrive.png \
  png/pypi.png \
  png/targz.png \
  png/template.png \
  png/zip.png \


c1:
	lxc init ubuntu:22.04 c1 \
	&& lxc config device add c1 shared disk source=$(PWD) path=/srv shift=true \
	&& lxc start c1 \
	&& lxc exec c1 -- apt update \
	&& lxc exec c1 -- apt install --yes inkscape

.cache/vscode-material-icon-theme-4.32.0.tar.gz:
	mkdir --parents $(shell dirname $@)
	curl --location --output $@ https://github.com/PKief/vscode-material-icon-theme/archive/refs/tags/v4.32.0.tar.gz
	tar -C .cache -xvf $@

.cache/vscode-material-icon-theme-4.32.0: .cache/vscode-material-icon-theme-4.32.0.tar.gz

.cache/Humanity-0.4.6.tar.gz:
	mkdir --parents $(shell dirname $@)
	curl --location --output $@ https://launchpad.net/humanity/0.4/0.4/+download/Humanity%5B0.4.6%5D.tar.gz
	tar -C .cache -xvf $@

.cache/Humanity: .cache/Humanity-0.4.6.tar.gz

png/%.png: svg/%.svg
	mkdir --parents png
	lxc exec c1 -- dbus-run-session inkscape \
	  --export-width=512 --export-filename=/srv/$@ /srv/$<

svg/%.svg: .cache/vscode-material-icon-theme-4.32.0
	mkdir --parents svg
	cp $</icons/$(notdir $@) $@

svg/pypi.svg:
	mkdir --parents svg
	curl --output $@ https://pypi.org/static/images/logo-small.2a411bc6.svg

svg/onedrive.svg:
	mkdir --parents svg
	curl --output $@ \
		https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg

svg/targz.svg: .cache/Humanity
	mkdir --parents svg
	cp $</mimes/48/application-x-compressed-tar.svg $@

clean:
	rm -rf .cache png svg
