barroot=/bar
build=$barroot/buildx86_64
plat=x86_64

includes=

export C_INCLUDE_PATH="${barroot}/include:${barroot}/include/arch/x86_64:${barroot}/lib/newlib/newlib/libc/include:${barroot}/include/c:${barroot}/include/target/x86_64:${barroot}/lib/lwip/src/include/ipv4:${barroot}/lib/lwip/src/include:${build}/${plat}/include"

export CFLAGS="-std=c99 -static -U__STRICT_ANSI__ -Wstrict-prototypes -Wold-style-definition \
	-Wmissing-prototypes -fno-omit-frame-pointer -fno-builtin -nostdinc -nostdlib -U__linux__ \
	-Ulinux -Wall -Wshadow -Wmissing-declarations -Wmissing-field-initializers -Wtype-limits \
	-Wredundant-decls -m64 -mno-red-zone -fPIE -fno-stack-protector -Wno-unused-but-set-variable \
	-Wno-packed-bitfield-compat -Wno-frame-address -D__x86__ -DBARRELFISH -DBF_BINARY_PREFIX=\"\" \
	-D_WANT_IO_C99_FORMATS -DCONFIG_LAZY_THC -DCONFIG_SVM -DUSE_KALUGA_DVM -DCONFIG_INTERCONNECT_DRIVER_LMP \
	-DCONFIG_INTERCONNECT_DRIVER_UMP -DCONFIG_INTERCONNECT_DRIVER_MULTIHOP \
	-DCONFIG_INTERCONNECT_DRIVER_LOCAL -DCONFIG_FLOUNDER_BACKEND_LMP \
	-DCONFIG_FLOUNDER_BACKEND_UMP -DCONFIG_FLOUNDER_BACKEND_MULTIHOP \
	-DCONFIG_FLOUNDER_BACKEND_LOCAL -Wpointer-arith -Wuninitialized \
	-Wsign-compare -Wformat-security -Wno-pointer-sign -Wno-unused-result \
	-fno-strict-aliasing -D_FORTIFY_SOURCE=2 \
	-I${barroot}/include -I${barroot}/include/arch/x86_64 \
	-I${barroot}/lib/newlib/newlib/libc/include -I${barroot}/include/c -I${barroot}/include/target/x86_64 \
	-I${barroot}/lib/lwip/src/include/ipv4 -I${barroot}/lib/lwip/src/include -I${build}/${plat}/include"


export LIBRARY_PATH="${build}/${plat}/lib ${build}/${plat}/errors"

export LIBS="-Wl,-z,max-page-size=0x1000 -Wl,--build-id=none ${build}/${plat}/lib/crt0.o \
	${build}/${plat}/lib/crtbegin.o ${build}/${plat}/lib/libssh.a \
	${build}/${plat}/lib/libopenbsdcompat.a \
	${build}/${plat}/lib/libzlib.a ${build}/${plat}/lib/libposixcompat.a \
	${build}/${plat}/lib/libterm_server.a ${build}/${plat}/lib/libvfs.a \
	${build}/${plat}/lib/libahci.a ${build}/${plat}/lib/libmegaraid.a \
	${build}/${plat}/lib/libnfs.a ${build}/${plat}/lib/liblwip.a \
	${build}/${plat}/lib/libnet_if_raw.a ${build}/${plat}/lib/libtimer.a \
	${build}/${plat}/lib/libhashtable.a ${build}/${plat}/lib/libbarrelfish.a \
	${build}/${plat}/lib/libterm_client.a ${build}/${plat}/lib/liboctopus_parser.a \
	${build}/${plat}/errors/errno.o ${build}/${plat}/lib/libnewlib.a  \
	${build}/${plat}/lib/libcompiler-rt.a ${build}/${plat}/lib/crtend.o \
	${build}/${plat}/lib/libcollections.a"
