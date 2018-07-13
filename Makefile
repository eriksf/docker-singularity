versions = 2.3.2 2.5.2
all: test_images

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
	docker build --build-arg VERSION=$@ -t gzynda/singularity:$@ . \
	&& docker push gzynda/singularity:$@ \
	&& docker system prune -f

test_images: $(versions)
	for v in $(versions); do \
		docker run --privileged -v $$PWD:/data --rm -it gzynda/singularity:$$v bash -c "cd /data && bash make_image.sh $$v"; \
	done
