APP=$(shell basename $(shell git remote get-url origin) | cut -c -12 )
REGISTRY="ghcr.io/gitgav"
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=
TARGETARCH=

ifeq ($(OS),Windows_NT)
	TARGETOS=windows
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        TARGETARCH=amd64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            TARGETARCH=amd64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),X86)
            TARGETARCH=386
        endif
		ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
            TARGETARCH=arm64
        endif
    endif
else
	UNAME_S= $(shell uname -s)
	UNAME_M= $(shell uname -m)
	ifeq ($(UNAME_S),Linux)
		TARGETOS=linux
		ifeq ($(UNAME_M),x86_64)
			TARGETARCH=amd64
		endif
		ifeq ($(UNAME_M),i386)
			TARGETARCH=386
		endif
		ifeq ($(UNAME_M),aarch64)
			TARGETARCH=arm64
		endif
	endif
	ifeq ($(UNAME_S),Darwin)
		TARGETOS=darwin
		ifeq ($(UNAME_M),x86_64)
			TARGETARCH=amd64
		else 
			TARGETARCH=arm64
		endif
	endif
endif

format: 
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o korchi265bot -ldflags "-X="github.com/gitgav/korchi265bot/cmd.appVersion=${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o korchi265bot -ldflags "-X="github.com/gitgav/korchi265bot/cmd.appVersion=${VERSION}

macos: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o korchi265bot -ldflags "-X="github.com/gitgav/korchi265bot/cmd.appVersion=${VERSION}

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o korchi265bot -ldflags "-X="github.com/gitgav/korchi265bot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean: 
	rm -rf korchi265bot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}