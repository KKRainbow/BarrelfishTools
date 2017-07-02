#!/bin/bash
add_suites() {
#add_suite   name       arch     plat              build_dir		target_run
add_suite    x86_64     x86_64   X86_64_Full       buildx86_64		qemu_x86_64
add_suite    vexpress   armv7    VExpressEMM-A15   buildvexpress	qemu_a15ve_4
}

DOCKER=docker
DOCKER_COMPOSE=docker-compose

DOCKER_FILE=<<EOF
FROM ubuntu:16.04
LABEL maintainer="sunsijie@buaa.edu.cn" \
	  version="1.0"

COPY ./sources.list /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y gcc g++ git build-essential make \
					   gcc-arm-linux-gnueabi g++-arm-linux-gnueabi \
					   gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
					   binutils \
					   libghc-mtl-dev libghc-ghc-mtl-dev cabal-install libghc-src-exts-dev \
					   libghc-async-dev libghc-ghc-paths-dev libghc-parsec3-dev \
					   libghc-random-dev \
					   libelf-freebsd-dev freebsd-glue libusb-1.0-0-dev curl gawk cpio

RUN cabal update && cabal install bytestring-trie
EOF

DOCKER_COMPOSE_FILE=<<EOF
version: "3"
services:
    srv:
        container_name: barrelfish
        image: "barrelfish"
        volumes:
            - ./barrelfish:/root/barrelfish
        entrypoint: /bin/bash -c "sleep 999990"
        cap_add:
            - SYS_ADMIN
EOF

SOURCES_LIST=<<EOF
deb http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse
EOF

check_sudo() {
	if [ $UID != 0 ];then
		echo Please run with sudo
		exit
	fi
}

declare -a NAMES
declare -A SUITES 
add_suite() {
	local NAME=$1
	local ARCH=$2
	local PLAT=$3
	local BUILD_DIR=$4
	local TARGET_RUN=$5
	NAMES=(${NAMES[@]} $NAME)
	SUITES[${NAME}_arch]=$ARCH
	SUITES[${NAME}_plat]=$PLAT
	SUITES[${NAME}_dir]=$BUILD_DIR
	SUITES[${NAME}_run]=$TARGET_RUN
}

print_suite() {
	echo 'please set variable "S" as one of the following suite'
	for NAME in ${NAMES[@]}
	do
		local STR="suite-name: $NAME
	arch: ${SUITES[${NAME}_arch]}
	plat: ${SUITES[${NAME}_plat]}
	build-dir: ${SUITES[${NAME}_dir]}"
		echo "$STR"
	done
}

print_help() {
	echo 'available commands:'
	echo '	make'
	echo '	hake'
	echo '	cd'
	echo '	run'
	echo '	fs'
	echo '	docker'
}

docker_run() {
	check_sudo
	CNT=`docker ps --filter=name=barrelfish -aq`
	DIR=/root/barrelfish/${BUILD_DIR}
	${DOCKER} start $CNT;
	${DOCKER} exec -it ${CNT} /bin/bash -c "(mkdir -p ${DIR};cd ${DIR};$1)"
}

declare ARCH PLAT BUILD_DIR
select_suite() {
	add_suites
	if [[ -z $S ]] || [[ -z ${NAMES[$S]} ]];then
		print_suite
		exit
	else
		ARCH=${SUITES[${S}_arch]}
		PLAT=${SUITES[${S}_plat]}
		BUILD_DIR=${SUITES[${S}_dir]}
		TARGET_RUN=${SUITES[${S}_run]}
	fi
}

find_struct() {
	local STRUCT_NAME=$1

	IFS=$'\n'
	RE='^([a-zA-Z0-9_/.]*):([[:digit:]]*):([[:print:]]*)'
	RES=$(grep -nIr --include="*.h" "struct $STRUCT_NAME {")
	FINDS=($RES)
	num=0
	declare -a FILE_LIST
	for FIND in ${FINDS[@]}; do
		if [[ $FIND =~ $RE ]]; then
			FILE_LIST[num]="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
			let num+=1
		else
			echo "No match with this string: $FIND"
		fi
	done


	if [[ ${#FILE_LIST[@]} == 1 ]]; then
		FILE_IDX=${FILE_LIST[0]}
	else	
		echo "请选择要打开的文件"
		select FILE_IDX in ${FILE_LIST[@]}; do
			break;
		done
	fi

	if [[ -n  $FILE_IDX ]]; then
		IFS=$' '
		SP=($FILE_IDX)
		LINE=${SP[1]}
		vim +$LINE +"execute \"normal zt\"" ${SP[0]}
	else
		echo 'Not found'
	fi
}

execute_target_run() {
	local TARGET_RUN=$1
	IFS=$'\n'
	cd ${BUILD_DIR}
	local CMD=(`grep -A 1 "$1 :" Makefile | sed -r 's/^\s+//g'`)
	eval "${CMD[1]}"
	cd -
	exit
}

case "$1" in
	"make" )
		select_suite
		declare -a ARGS
		if [ $# == 1 ];then
			ARGS[1]=$PLAT
		else
			ARGS=${@:2}
		fi
		docker_run "make ${ARGS[@]} -j 4"
		;;
	"hake" )
		select_suite
		docker_run "../hake/hake.sh -a ${ARCH} -s ../"
		;;
	"cd" )
		docker_run "/bin/zsh || /bin/bash"
		;;
	"run" )
		select_suite
		execute_target_run $TARGET_RUN
		;;
	"fs" )
		shift
		find_struct $@
		;;
	"docker" )
		shift
		case "$1" in
			* )
				echo NYI
				;;
		esac
		;;
	*)
		print_help
		;;
esac
