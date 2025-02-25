PLATFORM_IMAGE_NAME := 1c-platform
PLATFORM_IMAGE_TAG = $(PLATFORM_IMAGE_NAME):$(PLATFORM_VERSION)

EDT_IMAGE_NAME := 1c-edt
EDT_IMAGE_TAG  := $(EDT_IMAGE_NAME):$(subst +,_,$(EDT_VERSION))

.PHONY: 1c-image edt-image

all: 1c-image edt-image

1c-image: 1cplatform.zip
ifdef PLATFORM_VERSION
	@docker build $(BUILD_OPTIONS) -t $(PLATFORM_IMAGE_TAG) --build-arg PLATFORM_VERSION=$(PLATFORM_VERSION) --file 1c-platform.Dockerfile .
else
	$(error PLATFORM_VERSION is undefined)
endif

edt-image: 1cedt.tar.gz
ifndef EDT_VERSION
	$(error EDT_VERSION is undefined)
else
	@docker build $(BUILD_OPTIONS) -t $(EDT_IMAGE_TAG) --build-arg EDT_VERSION=$(EDT_VERSION) --build-arg EDT_BUILD=$(EDT_BUILD) --file 1c-edt.Dockerfile .
endif
