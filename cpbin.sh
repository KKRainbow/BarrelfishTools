#!/bin/bash
root=/home/sunsijie/image/barrelfish/myroot
barrelfish=/home/sunsijie/image/barrelfish
build=buildx86_64
plat=x86_64

list=("bash zsh make gcc ld as readelf objdump objcopy ls ar ld strip nm cc stty /usr/lib/gcc/x86_64-pc-linux-gnu/7.1.1/cc1 rm")
list=("$list crti.o crt1.o crtn.o /usr/lib/libgcc_s.so /usr/lib/libc.so /usr/lib/libgcc_s.so.1 /usr/lib/ld-linux-x86-64.so.2 /usr/lib/libc_nonshared.a")
list=("$list sh cat chmod sed touch mv grep mkdir tr cmp expr ln cp tail sort sleep uname uniq awk")
cpbin() {
	targetbin=$root/usr/bin/`basename $1`
	echo 'copying executable '$1 ' to' $targetbin
	if [ -f $targetbin ];then
		return
	fi
	cp $1 $targetbin
	if [ -x $1 ];then
		for lib in `ldd $1`;do
			if !(echo $lib|grep ^/ > /dev/null);then
				continue
			fi
			dir=`dirname $lib`
			filename=`basename $lib`
			fullpath=$root$dir
			mkdir -p $fullpath
			cp $lib $fullpath/$filename -u
		done
	fi
}

cpdir() {
	target=$root/`dirname $1` 

	echo 'copying file '$item ' to' $target

	if [ -f $target ];then
		return
	fi
	mkdir -p $root/`dirname $1`
	cp $1 $target -Lr
}

cpbarrelfish() {
	bar_root=/bar
	inc_list=("include lib/newlib/newlib/libc/include lib/lwip/src/include/ipv4 lib/lwip/src/include ${build}/${plat}/include")
	lib_list=("${build}/${plat}/lib ${build}/${plat}/errors ${build}/${plat}/usr/drivers/megaraid")
	total=("$inc_list $lib_list")
	for item in $total;do
		echo "copying barrelfish files $barrelfish/$item"
		targetdir=$root/$bar_root/`dirname $item`
		mkdir -p $targetdir
		cp $barrelfish/$item $targetdir -ruL
	done
}

prepare() {
	mkdir -p $root/usr/bin
	for item in $list;do
		origin=$item
		if [ ! -f $origin ];then
			item=`which $item 2>/dev/null`
		else
			item=$origin
		fi
		if [ -z $item ];then
			wheres="$(whereis $origin)"
			wheres=($wheres)
			item=${wheres[1]}
		fi
		if [[ -x $item ]] && (file $item | grep executable > /dev/null);then
			cpbin $item
		else
			cpdir $item
		fi
	done
	cpdir /usr/lib/gcc/x86_64-pc-linux-gnu/7.1.1/
	ln -srf $root/usr/bin $root/bin

	cpbarrelfish
}
prepare
sudo chroot $root /usr/bin/zsh 
