
PACKAGES+=" libjpeg"
hset libjpeg url "http://www.ijg.org/files/jpegsrc.v7.tar.gz"

PACKAGES+=" libpng"
hset libpng url "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.42.tar.bz2"
hset libpng depends "zlib"

PACKAGES+=" libfreetype"
hset libfreetype url "http://download.savannah.gnu.org/releases/freetype/freetype-2.3.12.tar.bz2"

install-libfreetype() {
	install-generic
	sed -i -e "s|prefix=/usr|prefix=$STAGING_USR|" \
		-e "s|/include|/include/freetype2|" \
		$STAGING_USR/bin/freetype-config
}

PACKAGES+=" font-bitstream-vera"
hset font-bitstream-vera url "http://ftp.gnome.org/pub/GNOME/sources/ttf-bitstream-vera/1.10/ttf-bitstream-vera-1.10.tar.bz2"
hset font-bitstream-vera depends "libfontconfig"
hset font-bitstream-vera phases "deploy"

deploy-font-bitstream-vera() {
	local path="$ROOTFS"/usr/share/fonts/truetype/ttf-bitstream-vera
	mkdir -p $path
	cp *.ttf "$path"/
}

PACKAGES+=" libfontconfig"
hset libfontconfig url "http://www.fontconfig.org/release/fontconfig-2.8.0.tar.gz"
hset libfontconfig depends "libexpat libfreetype"

configure-libfontconfig-local() {
	export LDFLAGS="$LDFLAGS_RLINK"
	autoreconf;libtoolize;automake --add-missing
	configure-generic-local \
		--with-arch=$TARGET_FULL_ARCH \
		--disable-docs  \
		--with-freetype-config="$STAGING_USR/bin/freetype-config"
	# fixes cross compilation
	sed -i -e 's:^CFLAGS = -.*$:CFLAGS =:g' \
		fc-case/Makefile \
		fc-cache/Makefile \
		fc-lang/Makefile \
		fc-glyphname/Makefile \
		fc-arch/Makefile
	export LDFLAGS="$LDFLAGS_BASE"
}
configure-libfontconfig() {
	configure configure-libfontconfig-local
}

compile-libfontconfig() {
	export LDFLAGS="$LDFLAGS_RLINK -lfreetype -lz -lexpat"
	compile-generic V=1
	export LDFLAGS="$LDFLAGS_BASE"
}
deploy-libfontconfig-local() {
	cp "$STAGING_USR"/bin/fc-* \
		"$ROOTFS"/usr/bin/
	rsync -av \
		"$STAGING_USR"/etc/fonts \
		"$ROOTFS"/usr/etc/ \
			&>> "$LOGFILE" 
}
deploy-libfontconfig() {
	deploy deploy-libfontconfig-local
}

PACKAGES+=" libpixman"
hset libpixman url "http://xorg.freedesktop.org/archive/individual/lib/pixman-0.17.6.tar.bz2"

configure-libpixman() {
	local extras=""
	if [ "$TARGET_ARCH" == "arm" ]; then
		# won't work in thumb
		export CFLAGS="${CFLAGS//-mthumb[^-]/-marm }"
		extras+=" --disable-arm-simd --disable-arm-neon"	
	fi
	configure-generic \
		--disable-gtk "$extras"
	export CFLAGS="$TARGET_CFLAGS"
}

PACKAGES+=" libts"
hset libts url "http://download2.berlios.de/tslib/tslib-1.0.tar.bz2"

configure-libts-local() {
	export CFLAGS="$TARGET_CFLAGS -U_FORTIFY_SOURCE" # due to open() problem
	configure-generic-local \
		--disable-linear-h2200 \
		--disable-ucb1x00 \
		--disable-corgi \
		--disable-collie \
		--disable-h3600 \
		--disable-mk712 \
		--disable-arctic2
	export CFLAGS="$TARGET_CFLAGS"
	sed -i -e 's:^#define malloc rpl_malloc:// #define malloc rpl_malloc:g' config.h
}
configure-libts() {
	configure configure-libts-local
}
deploy-libts() {
	ROOTFS_PLUGINS+="$STAGING_USR/lib/ts:"
	deploy-generic
}
#
PACKAGES+=" libim-loaders"
hset libim-loaders url "http://ignum.dl.sourceforge.net/project/enlightenment/imlib2-src/1.4.3/imlib2_loaders-1.4.3.tar.bz2"

PACKAGES+=" libim"
hset libim url "http://ignum.dl.sourceforge.net/project/enlightenment/imlib2-src/1.4.3/imlib2-1.4.3.tar.bz2"
hset libim depends "libpng libjpeg"

configure-libim() {
	configure-generic --without-x
}
deploy-libim() {
	ROOTFS_PLUGINS+="$STAGING_USR/lib/imlib2:"
}

PACKAGES+=" fbgrab"
hset fbgrab url "http://hem.bredband.net/gmogmo/fbgrab/fbgrab-1.0.tar.gz"
hset fbgrab depends "libpng"
hset fbgrab destdir "$STAGING_USR"

deploy-fbgrab() {
	deploy cp "$STAGING_USR"/bin/fbgrab "$ROOTFS"/bin/
}
