Trent's quick play with creating a Docker container for a Lambda function
that includes the Elastic APM Lambda extension and Node.js APM agent
for instrumentation.

# Usage

1. Get the repo:

    ```
    git clone git@github:trentm/lambdock.git
    cd lambdock
    ```

2. Configure the environment variables you will use for locally running the
   docker container for dev/testing. At a minimum, set `ELASTIC_APM_LAMBDA_APM_SERVER`
   and `ELASTIC_APM_SECRET_TOKEN`.

    ```
    cp run.env.template run.env
    vi run.env
    ```

3. Build the "lambdock" Docker image: it downloads published builds of the extension
   and APM agent and adds them to the base `amazon/aws-lambda-nodejs:16` AWS Lambda image.
   See [the Dockerfile](./Dockerfile).

    ```
    make build
    ```

4. Run the container locally to simulate running an instance of your function, and invoke it:

    ```
    make run
    ```

    Then in another terminal invoke it by calling the Lambda API:

    ```
    make invoke
    ```

    We expect:
    - A ["hi from lambdock"](./index.js) response from the invocation.
    - Log output from the Lambda Runtime and extension something like:

        ```
        ...
        START RequestId: caa147d9-7805-482c-beba-86f231e197ff Version: $LATEST
        {"log.level":"warn","@timestamp":"2022-05-31T22:47:13.382Z","log.origin":{"file.name":"extension/process_env.go","file.line":70},"message":"Could not read ELASTIC_APM_DATA_RECEIVER_TIMEOUT_SECONDS, defaulting to 15: strconv.Atoi: parsing \"\": invalid syntax","ecs.version":"1.6.0"}
        {"log.level":"warn","@timestamp":"2022-05-31T22:47:13.382Z","log.origin":{"file.name":"extension/process_env.go","file.line":76},"message":"Could not read ELASTIC_APM_DATA_FORWARDER_TIMEOUT_SECONDS, defaulting to 3
        NODE_OPTIONS=--require=elastic-apm-node/start.js
        : strconv.Atoi: parsing \"\": invalid syntax","ecs.version":"1.6.0"}
        {"log.level":"warn","@timestamp":"2022-05-31T22:47:13.382Z","log.origin":{"file.name":"extension/process_env.go","file.line":88},"message":"Could not read ELASTIC_APM_LOG_LEVEL, defaulting to info","ecs.version":"1.6.0"}
        31 May 2022 22:47:13,383 [INFO] (rapid) External agent apm-lambda-extension (f7de9e2c-fd19-4fbd-9c80-a44ef9078b55) registered, subscribed to [INVOKE SHUTDOWN]
        {"log.level":"info","@timestamp":"2022-05-31T22:47:13.384Z","log.origin":{"file.name":"extension/http_server.go","file.line":49},"message":"Extension listening for apm data on :8200","ecs.version":"1.6.0"}
        {"log.level":"warn","@timestamp":"2022-05-31T22:47:13.389Z","log.origin":{"file.name":"apm-lambda-extension/main.go","file.line":103},"message":"Error while subscribing to the Logs API: listen tcp: lookup sandbox on 192.168.65.5:53: no such host","ecs.version":"1.6.0"}
        {"log.level":"info","@timestamp":"2022-05-31T22:47:13.389Z","log.origin":{"file.name":"apm-lambda-extension/main.go","file.line":113},"message":"Waiting for next event...","ecs.version":"1.6.0"}
        {"log.level":"info","@timestamp":"2022-05-31T22:47:13.943Z","log.origin":{"file.name":"apm-lambda-extension/main.go","file.line":113},"message":"Waiting for next event...","ecs.version":"1.6.0"}
        END RequestId: caa147d9-7805-482c-beba-86f231e197ff
        REPORT RequestId: caa147d9-7805-482c-beba-86f231e197ff	Init Duration: 0.27 ms	Duration: 564.88 ms	Billed Duration: 565 ms	Memory Size: 3008 MB	Max Memory Used: 3008 MB
        ```
    - A transaction in your APM UI.


Pushing this Docker to Amazon ECR and creating a real Lambda function with it is an exercise for the reader. :)


# Future work

When we have published Docker images for the extension and [Node.js APM agent](https://github.com/elastic/apm-agent-nodejs/pull/2742), then the Dockerfile can be vastly improved to something like:

```Dockerfile
FROM amazon/aws-lambda-nodejs:16
COPY --from=public.ecr.aws/elastic/apm-agent-nodejs:latest /opt/nodejs/ /opt/nodejs/
COPY --from=public.ecr.aws/elastic/apm-lambda-extension:latest /opt/extensions/ /opt/extensions/
COPY package.json index.js ./
CMD [ "index.handler" ]
```

