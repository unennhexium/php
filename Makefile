# This file is intended to simplify local image building
# and isn`t involved in automatic CI builds with GitHub Actions

parse_env_file = \
	cat $(1) | \
	sed -e '/\S/s/^/--build-arg /' | \
	tr '\n' ' ' | \
	sed -e 's/ \+/ /g'

build-dev: Dockerfile .env.build.dev
	echo "$(BUILD_ARGS)"
	docker build $(BUILD_ARGS) --tag unennhexium/php:dev - < Dockerfile
BUILD_ARGS = $(shell $(call parse_env_file, .env.build.dev))

build-prod: Dockerfile .env.build.prod
	echo "$(BUILD_ARGS)"
	docker build $(BUILD_ARGS) --tag unennhexium/php:prod --tag unennhexium/php:latest - < Dockerfile
BUILD_ARGS = $(shell $(call parse_env_file, .env.build.prod))

clean:
	docker unennhexium/php:dev
	docker unennhexium/php:prod
	docker unennhexium/php:latest
