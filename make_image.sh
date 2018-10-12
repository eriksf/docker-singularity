function makeimg() {
	IMG=${2}_${1}.simg
	size=128
	[ -e $IMG ] && rm -f $IMG
	case $1 in
	2.3.2)
		singularity create -s $size -F ${IMG}
		singularity bootstrap ${IMG} sys.def
		;;
	2.4.6)
		singularity create -s $size -F ${IMG}
		singularity bootstrap ${IMG} sys.def
		;;
	2.5.2)
		singularity build ${IMG} sys.def
		;;	
	2.6.0)
		singularity build ${IMG} sys.def
		;;	
	test)
		singularity build ${IMG} sys.def
		;;	
	*)
		exit 1
		;;
	esac
	[ -e sys.def ] && rm sys.def
}

if [ "$1" == "suid-test" ]; then
	cat << "EOF" > sys.def
BootStrap: docker
From: ubuntu:xenial
%post
	apt-get update
	apt-get install -y gcc
	cat << "EOC" > /bin/suid_test.c
#include <stdio.h>
#include <unistd.h>

int main () {
  int real = getuid();
  int euid = geteuid();
  printf("The REAL UID =: %d\n", real);
  printf("The EFFECTIVE UID =: %d\n", euid);
}
EOC
	gcc -o /bin/suid_test /bin/suid_test.c
	rm /bin/suid_test.c
	chmod 4755 /bin/suid_test
	ls -lh /bin/suid_test
	suid_test
%runscript
	exec /bin/suid_test
EOF
	makeimg test suid
	rm -rf /root/.singularity
	exit 0
fi

cat << EOF > sys.def
BootStrap: docker
From: ubuntu:xenial
%post
	mkdir /scratch /work /home1 /gpfs /corral-repl /corral-tacc /data
%runscript
	echo "good singularity $1 testing image"
EOF

makeimg $1 tacc-mounts
rm -rf /root/.singularity

cat << EOF > sys.def
BootStrap: docker
From: ubuntu:xenial
%post
%runscript
	echo "bad singularity $1 testing image"
EOF

makeimg $1 stock
rm -rf /root/.singularity
