#!/usr/bin/make -f 
DEB_BUILD_GNU_TYPE ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE) 
DEB_HOST_ARCH	  ?= $(shell dpkg-architecture -qDEB_HOST_ARCH) 
DEB_HOST_ARCH_CPU  ?= $(shell dpkg-architecture -qDEB_HOST_ARCH_CPU) 
DEB_HOST_ARCH_OS   ?= $(shell dpkg-architecture -qDEB_HOST_ARCH_OS) 
DEB_HOST_GNU_TYPE  ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE) 
VERSION = $(shell dpkg-parsechangelog|sed -n 's/^Version: //p') 
DEBIAN_VERSION = $(shell echo $(VERSION)|sed -nr 's/[^:]+://; s/.*-([^-]+$)/\1/p') 
ifeq ($(DEB_BUILD_GNU_TYPE),$(DEB_HOST_GNU_TYPE)) 
confflags := --build=$(DEB_BUILD_GNU_TYPE) 
else 
confflags := --host=$(DEB_HOST_GNU_TYPE) --build=$(DEB_BUILD_GNU_TYPE) 
endif 
ifneq (,$(filter debug,$(DEB_BUILD_OPTIONS))) 
confflags += --enable-debug 
endif 
ifneq (,$(filter noopt,$(DEB_BUILD_OPTIONS))) 
confflags += --disable-optimizations --disable-mmx --disable-sse --disable-altivec 
endif 
CFLAGS := $(shell dpkg-buildflags --get CFLAGS) 
CXXFLAGS := $(shell dpkg-buildflags --get CXXFLAGS) 
# configure flags 
confflags += \ 
	CPPFLAGS="$(shell dpkg-buildflags --get CPPFLAGS)" \ 
	LDFLAGS="$(shell dpkg-buildflags --get LDFLAGS)" \ 
	--config-cache \ 
	--disable-maintainer-mode \ 
	--disable-silent-rules \ 
	--disable-update-check \ 
	--enable-fast-install \ 
	--prefix=/usr \ 
	--docdir=/usr/share/doc/vlc-nox \ 
	--libdir=/usr/lib \ 
	--sysconfdir=/etc \ 
	--with-binary-version=$(DEBIAN_VERSION) \ 
	$(NULL) 
# configure features 
confflags += \ 
	--enable-a52 \ 
	--enable-aa \ 
	--enable-bluray \ 
	--enable-bonjour \ 
	--enable-caca \ 
	--enable-chromaprint \ 
	--enable-dbus \ 
	--enable-dca \ 
	--enable-directfb \ 
	--enable-dvbpsi \ 
	--enable-dvdnav \ 
	--enable-faad \ 
	--enable-flac \ 
	--enable-fluidsynth \ 
	--enable-freerdp \ 
	--enable-freetype \ 
	--enable-fribidi \ 
	--enable-gles1 \ 
	--enable-gles2 \ 
	--enable-gnutls \ 
	--enable-jack \ 
	--enable-kate \ 
	--enable-libass \ 
	--enable-libmpeg2 \ 
	--enable-libxml2 \ 
	--enable-lirc \ 
	--enable-live555 \ 
	--enable-mad \ 
	--enable-mkv \ 
	--enable-mod \ 
	--enable-mpc \ 
	--enable-mtp \ 
	--enable-mux_ogg \ 
	--enable-ncurses \ 
	--enable-notify \ 
	--enable-ogg \ 
	--enable-opus \ 
	--enable-pulse \ 
	--enable-qt \ 
	--enable-realrtsp \ 
	--enable-samplerate \ 
	--enable-schroedinger \ 
	--enable-sdl \ 
	--enable-sftp \ 
	--enable-shine \ 
	--enable-shout \ 
	--enable-skins2 \ 
	--enable-smbclient \ 
	--enable-speex \ 
	--enable-svg \ 
	--enable-taglib \ 
	--enable-theora \ 
	--enable-twolame \ 
	--enable-upnp \ 
	--enable-vcdx \ 
	--enable-vdpau \ 
	--enable-vnc \ 
	--enable-vorbis \ 
	--enable-x264 \ 
	--enable-zvbi \ 
	--with-kde-solid=/usr/share/kde4/apps/solid/actions/ \ 
	--enable-rpi-omxil \ 
	--disable-mmal-codec \ 
	--disable-mmal-vout \ 
	$(NULL) 
# Reasons for disabling features: 
# decklink -> not in Debian 
# dxva2 -> Windows only 
# fdkaac -> in Debian non-free 
# gnomevfs -> poorly maintained 
# goom -> not in Debian 
# libtar -> security issue (#737534) 
# mfx -> currently not supported on Linux 
# opencv -> developer plugin not required by end users 
# projectm -> broken 
# sndio -> not in Debian 
# svgdev -> libcairo2-dev is not new enough 
# telx -> incompatible with zvbi 
# vpx -> not needed when having libavcodec 
# vsxu -> not in Debian 
# wasapi -> Windows only 
confflags += \ 
	--disable-decklink \ 
	--disable-dxva2 \ 
	--disable-fdkaac \ 
	--disable-gnomevfs \ 
	--disable-goom \ 
	--disable-libtar \ 
	--disable-mfx \ 
	--disable-opencv \ 
	--disable-projectm \ 
	--disable-sndio \ 
	--disable-svgdec \ 
	--disable-telx \ 
	--disable-vpx \ 
	--disable-vsxu \ 
	--disable-wasapi \ 
	$(NULL) 
# Linux specific flags 
ifeq ($(DEB_HOST_ARCH_OS),linux) 
# omxil should be enabled on all systems, but libomxil-bellagio does 
# not build on kfreebsd and hurd (currently). 
# V4L2 is disabled on kFreeBSD due to a build failure. 
confflags += \ 
	--enable-alsa \ 
	--enable-atmo \ 
	--enable-dc1394 \ 
	--enable-dv1394 \ 
	--enable-linsys \ 
	--enable-omxil \ 
	--enable-udev \ 
	--enable-v4l2 \ 
	$(NULL) 
else 
confflags += \ 
	--disable-alsa \ 
	--disable-atmo \ 
	--disable-dc1394 \ 
	--disable-dv1394 \ 
	--disable-linsys \ 
	--disable-omxil \ 
	--disable-udev \ 
	--disable-v4l2 \ 
	$(NULL) 
removeplugins += \ 
	alsa \ 
	libatmo \ 
	libdc1394 \ 
	libdtv \ 
	libdvb \ 
	libdv1394 \ 
	libfb \ 
	libomxil \ 
	linsys \ 
	libudev \ 
	libv4l2 \ 
	$(NULL) 
endif 
# Linux and kFreeBSD specific flags (disabled on Hurd) 
ifeq (,$(filter-out linux kfreebsd,$(DEB_HOST_ARCH_OS))) 
confflags += --enable-libva --enable-vcd 
else 
confflags += --disable-libva --disable-vcd 
removeplugins += cdda libvaapi vcd 
endif 
# kFreeBSD specific flags 
ifeq (,$(filter-out kfreebsd,$(DEB_HOST_ARCH_OS))) 
confflags += --enable-oss 
else 
# Note: Use ALSA on Linux instead of OSS. 
#	   Ubuntu has disabled OSS support in their Linux kernel. 
confflags += --disable-oss 
removeplugins += oss 
endif 
# Linux amd64 and i386 specific flags 
ifeq (,$(filter-out amd64 i386,$(DEB_HOST_ARCH))) 
confflags += --enable-crystalhd 
else 
confflags += --disable-crystalhd 
removeplugins += libcrystalhd 
endif 
# amd64 and i386 specific optimizations 
ifeq (,$(filter-out amd64 i386,$(DEB_HOST_ARCH_CPU))) 
confflags += --enable-mmx --enable-sse 
else 
confflags += --disable-mmx --disable-sse 
removeplugins += mmx sse2 
endif 
# ARM specific optimizations 
ifeq (,$(filter-out armhf,$(DEB_HOST_ARCH_CPU))) 
confflags += --enable-neon 
else 
confflags += --disable-neon 
removeplugins += neon 
endif 
# PowerPC specific optimizations (excluding powerpcspe) 
ifeq (,$(filter-out powerpc,$(DEB_HOST_ARCH_CPU))$(filter powerpcspe,$(DEB_HOST_ARCH))) 
confflags += --enable-altivec 
else 
confflags += --disable-altivec 
removeplugins += altivec 
endif 
# PowerPCSPE specific optimizations 
ifeq (,$(filter-out powerpcspe,$(DEB_HOST_ARCH))) 
CFLAGS += -mtune=8548 
CXXFLAGS += -mtune=8548 
endif 
confflags += \ 
	CFLAGS="$(CFLAGS)" \ 
	CXXFLAGS="$(CXXFLAGS)" \ 
	$(NULL) 
%: 
	dh $@ --parallel --with autoreconf 
override_dh_autoreconf: 
	dh_autoreconf --as-needed 
override_dh_auto_clean: 
	rm -f debian/vlc.install debian/vlc-nox.install 
	dh_auto_clean 
override_dh_auto_configure: 
	dh_auto_configure -- $(confflags) 
override_dh_auto_test: 
ifeq (,$(filter nocheck,$(DEB_BUILD_OPTIONS))) 
ifeq ($(DEB_BUILD_GNU_TYPE),$(DEB_HOST_GNU_TYPE)) 
	# Check which plugins were built and whether they load properly. 
	@if test $( id -u ) -eq 0 ; then \ 
	   echo "Not runing the test as you are compiling as root"; \ 
	   echo "Use 'dpkg-buildpackage -rfakeroot' rather than 'fakeroot dpkg-buildpackage'"; \ 
	else \ 
	   command="./vlc -vvv --ignore-config --no-plugins-cache --list --no-color"; \ 
	   echo "${command}"; ${command} ; \ 
	fi 
endif 
endif 
override_dh_install: 
	# Remove disabled plugins 
	sed "/\($(shell echo $(removeplugins) | sed 's/ /\\|/g')\)_/d" debian/vlc.install.in > debian/vlc.install 
	sed "/\($(shell echo $(removeplugins) | sed 's/ /\\|/g')\)_/d" debian/vlc-nox.install.in > debian/vlc-nox.install 
	# Clean up libtool crap 
	find debian/tmp -name '*.la' -delete 
	# Remove useless stuff 
	ln -sf /usr/share/fonts/truetype/freefont/FreeSans.ttf debian/tmp/usr/share/vlc/skins2/fonts/FreeSans.ttf 
	ln -sf /usr/share/fonts/truetype/freefont/FreeMonoBold.ttf debian/tmp/usr/share/vlc/skins2/fonts/FreeSansBold.ttf 
	rm -f debian/tmp/usr/share/man/man1/vlc-config.1 
	# Remove additional license files 
	find debian/tmp -name LICENSE -delete 
	# Install stuff 
	dh_install --fail-missing 
ifeq ($(DEB_BUILD_GNU_TYPE), $(DEB_HOST_GNU_TYPE)) 
	# Check that we did not install a plugin linked with libX11 or 
	# libxcb in vlc-nox 
	BORKED=no; \ 
	LD_LIBRARY_PATH="debian/libvlccore8/usr/lib:debian/libvlc5/usr/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH:-}"; \ 
	for file in $(find debian/vlc-nox/usr/lib/vlc -name '*.so'); do \ 
		if ldd -r $file | egrep -q -e 'libX11\.so' -e 'libxcb\.so'; then \ 
			BORKED=yes; \ 
			echo $file depends on libX11 or libxcb; \ 
		fi; \ 
	done; \ 
	if test "$BORKED" = yes; then exit 1; fi 
endif 
	$(if $(shell dpkg-vendor --is Ubuntu && echo true),dh_install -pvlc-nox debian/source_vlc.py usr/share/apport/package-hooks/) 
	dh_buildinfo -p vlc-nox 
override_dh_strip: 
	dh_strip --dbg-package=vlc-dbg 
override_dh_installdocs: 
	dh_installdocs -p vlc-data 
	dh_installdocs -p vlc-nox 
override_dh_installchangelogs: 
	dh_installchangelogs ChangeLog -p vlc-data 
	dh_installchangelogs ChangeLog -p vlc-nox 
override_dh_makeshlibs: 
	dh_makeshlibs -Xusr/lib/vlc/libvlc_vdpau 
override_dh_builddeb: 
	dh_builddeb -- -Zxz 

