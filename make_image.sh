function makeimg() {
	IMG=${2}_${1}.img
	[ -e $IMG ] && rm -f $IMG
	case $1 in
	2.3.2)
		singularity create -s 100 -F ${IMG}
		singularity bootstrap ${IMG} sys.def
		;;
	2.4.6)
		singularity create -s 100 -F ${IMG}
		singularity bootstrap ${IMG} sys.def
		;;
	2.5.2)
		singularity build ${IMG} sys.def
		;;	
	*)
		exit 1
		;;
	esac
	[ -e sys.def ] && rm sys.def
}

cat << EOF > sys.def
BootStrap: docker
From: alpine
%post
	mkdir /scratch /work /home1 /gpfs /corral-repl /corral-tacc /data
%runscript
	echo "good singularity $1 testing image"
EOF

makeimg $1 good

cat << EOF > sys.def
BootStrap: docker
From: alpine
%post
%runscript
	echo "good singularity $1 testing image"
EOF

makeimg $1 bad
