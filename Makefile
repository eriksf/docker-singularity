versions = 2.3.2 2.4.6 2.5.2 2.6.0
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
	docker build --build-arg VERSION=$@ -t singularity:$@ . \
	&& docker system prune -f

suid-test: 2.6.0
	docker run --privileged -v $$PWD:/data --rm -it singularity:$< bash -c "cd /data && bash make_image.sh $@"; \

test_images: $(versions) suid-test
	for v in $(versions); do \
		docker run --privileged -v $$PWD:/data --rm -it singularity:$$v bash -c "cd /data && bash make_image.sh $$v"; \
	done

clean:
	for v in $(versions); do \
		docker rmi singularity:$$v; \
	done
	docker system prune -f
	rm -f *img
