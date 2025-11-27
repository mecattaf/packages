.PHONY: prepare qtprep goprep breakpadprep srpm prebuild

# COPR passes spec= but we use SPECFILE internally
SPECFILE ?= $(spec)
BUILDDIR := $(shell pwd)

prepare:
	dnf install --nodocs -y rpm-build rpmdevtools

qtprep: prepare
	dnf install --nodocs -y \
		gcc gcc-c++ make cmake ninja-build \
		qt6-qtbase-devel \
		qt6-qtbase-private-devel \
		qt6-qtdeclarative-devel \
		qt6-qtwayland-devel \
		qt6-qtwebengine-devel \
		qt6-qtwebchannel-devel \
		qt6-qtsvg-devel \
		pam-devel \
		pulseaudio-libs-devel \
		pipewire-devel \
		wayland-devel \
		layer-shell-qt-devel

goprep: prepare
	dnf install --nodocs -y \
		golang \
		git-core \
		rpkg \
		gzip \
		wget

breakpadprep: prepare
	dnf install --nodocs -y \
		gcc-c++ \
		gmock-devel \
		gtest-devel \
		zlib-devel

prebuild:
	@buildtype="unknown"; \
	if grep -q "Name:.*quickshell" "$(SPECFILE)"; then \
		buildtype="qt"; \
	elif grep -q "Name:.*dms" "$(SPECFILE)"; then \
		buildtype="go"; \
	elif grep -q "Name:.*breakpad" "$(SPECFILE)"; then \
		buildtype="breakpad"; \
	fi; \
	case $$buildtype in \
		"qt") $(MAKE) -f $(lastword $(MAKEFILE_LIST)) qtprep;; \
		"go") $(MAKE) -f $(lastword $(MAKEFILE_LIST)) goprep;; \
		"breakpad") $(MAKE) -f $(lastword $(MAKEFILE_LIST)) breakpadprep;; \
		*) echo "Unknown package type in $(SPECFILE)"; exit 1;; \
	esac

srpm: prepare prebuild
	cd $(dir $(SPECFILE)) && spectool -g $(notdir $(SPECFILE))
	rpmbuild -bs \
		--define "_sourcedir $(dir $(SPECFILE))" \
		--define "_specdir $(dir $(SPECFILE))" \
		--define "_builddir $(BUILDDIR)" \
		--define "_srcrpmdir $(outdir)" \
		--define "_rpmdir $(BUILDDIR)" \
		--define "_buildrootdir $(BUILDDIR)/.build" \
		$(SPECFILE)
