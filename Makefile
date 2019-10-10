versions = 2.3.2 2.5.2 2.6.0 3.2.1 3.3.0 3.4.1
images = $(shell for v in $(versions); do echo "stock_$$v.simg"; done)
all: test_images

ifdef DOCKER_ID_USER
ORG = $(DOCKER_ID_USER)/
endif

.SILENT: docker
docker:
	docker info 1> /dev/null 2> /dev/null; \
	if [ ! $$? -eq 0 ]; then \
		echo "\n[ERROR] Could not communicate with docker daemon. You may need to run with sudo.\n"; \
		exit 1; \
	fi
prune:
	docker system prune -f

2.%: docker
	docker build --build-arg VERSION=$@ -t $(ORG)singularity:$@ . &> $@.log
3.%: docker
	docker build --build-arg VERSION=$@ -t $(ORG)singularity:$@ . &> $@.log
images: $(versions)
	docker system prune -f

suid-test: 2.6.0
	docker run --privileged -v $$PWD:/data --rm -it $(ORG)singularity:$< bash -c "cd /data && bash make_image.sh $@"; \

stock_%.simg: %
	docker run --privileged -v $$PWD:/data --rm -it $(ORG)singularity:$< bash -c "cd /data && bash make_image.sh $<"; \

test_images: $(images) suid-test
	mkdir $@
	cp *simg *sif $@/
	tar -czf $@.tar.gz $@
	rm -rf $@/

clean:
	for v in $(versions); do \
		docker rmi $(ORG)singularity:$$v; \
	done
	docker system prune -f
	rm -f *img
