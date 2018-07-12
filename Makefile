versions = 2.3.2 2.4.6 2.5.2
all: $(versions)

.SILENT: docker
docker:
	docker info 1> /dev/null 2> /dev/null; \
	if [ ! $$? -eq 0 ]; then \
		echo "\n[ERROR] Could not communicate with docker daemon. You may need to run with sudo.\n"; \
		exit 1; \
	fi
prune:
	docker system prune -f

2.%: docker prune
	docker build --build-arg VERSION=$@ -t gzynda/singularity:$@ . \
	&& docker push gzynda/singularity:$@ \
	&& docker system prune -f

test_images: $(versions)
	for v in $(versions); do
