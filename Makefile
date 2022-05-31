.PHONY: build
build:
	docker build -t lambdock .

.PHONY: run
run:
	docker run --env-file ./run.env -p 9000:8080 lambdock:latest

.PHONY: invoke
invoke:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
