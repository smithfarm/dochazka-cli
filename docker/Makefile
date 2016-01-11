TARGETS := \
	openSUSE_13.2 \
	openSUSE_Leap_42.1 \
	openSUSE_Tumbleweed

VERSION := $(shell (cd ../.. ; perl version.plx))

.PHONY: all
all: $(TARGETS)

openSUSE_13.2:
	cp Dockerfile.in Dockerfile
	sed -i 's/BASE_IMAGE/opensuse:13.2/' Dockerfile
	sed -i 's/BUILD_TARGET/openSUSE_13.2/' Dockerfile
	docker build --no-cache -t dochazka/cli-13.2:$(VERSION) .
	docker tag -f dochazka/cli-13.2:$(VERSION) dochazka/cli-13.2:latest
	docker push dochazka/cli-13.2:$(VERSION)
	docker push dochazka/cli-13.2:latest

openSUSE_Leap_42.1:
	cp Dockerfile.in Dockerfile
	sed -i 's/BASE_IMAGE/opensuse:42.1/' Dockerfile
	sed -i 's/BUILD_TARGET/openSUSE_Leap_42.1/' Dockerfile
	docker build --no-cache -t dochazka/cli-42.1:$(VERSION) .
	docker tag -f dochazka/cli-42.1:$(VERSION) dochazka/cli-42.1:latest
	docker push dochazka/cli-42.1:$(VERSION)
	docker push dochazka/cli-42.1:latest

openSUSE_Tumbleweed:
	cp Dockerfile.in Dockerfile
	sed -i 's/BASE_IMAGE/opensuse:tumbleweed/' Dockerfile
	sed -i 's/BUILD_TARGET/openSUSE_Tumbleweed/' Dockerfile
	docker build --no-cache -t dochazka/cli-tumbleweed:$(VERSION) .
	docker tag -f dochazka/cli-tumbleweed:$(VERSION) dochazka/cli-tumbleweed:latest
	docker push dochazka/cli-tumbleweed:$(VERSION)
	docker push dochazka/cli-tumbleweed:latest
