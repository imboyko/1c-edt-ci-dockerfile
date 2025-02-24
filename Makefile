PLATFORM_IMAGE_NAME := 1c-platform
PLATFORM_IMAGE_TAG = $(PLATFORM_IMAGE_NAME):$(PLATFORM_VERSION)

EDT_IMAGE_NAME := 1c-edt
EDT_IMAGE_TAG  := $(EDT_IMAGE_NAME):$(EDT_VERSION)

.PHONY: 1c-image edt-image

all: 1c-image edt-image

1c-image: 1cplatform.zip
ifdef PLATFORM_VERSION
	@docker build $(BUILD_OPTIONS) -t $(PLATFORM_IMAGE_TAG) --build-arg PLATFORM_VERSION=$(PLATFORM_VERSION) --file Dockerfile-1c .
else
	$(error PLATFORM_VERSION is undefined)
endif

edt-image: 1cedt.tar.gz
ifndef EDT_VERSION
	$(error EDT_VERSION is undefined)
endif
ifndef EDT_BUILD
	$(error EDT_BUILD is undefined)
endif
	@docker build $(BUILD_OPTIONS) -t $(EDT_IMAGE_TAG) --build-arg EDT_VERSION=$(EDT_VERSION) --build-arg EDT_BUILD=$(EDT_BUILD) --file Dockerfile-edt .

