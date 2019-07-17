all: docker-push

.PHONY: docker-build
docker-build:
	docker build -t konradkleine/icecc-scheduler:fedora29 --target scheduler .
	docker build -t konradkleine/icecc-daemon:fedora29 --target daemon .

.PHONY: docker-push
docker-push: docker-build
	docker push konradkleine/icecc-scheduler:fedora29
	docker push konradkleine/icecc-daemon:fedora29
