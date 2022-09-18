
run container(s) in background; stop container(s)
```bash
$ docker compose up -d --build
$ docker compose down
```

access interactive shell of running container:
```bash
$ docker compose exec infra /bin/ash
```

clean out all including dangling images and containers
```bash 
$ docker system prune -af
```

AWS has a Docker container for running AWS CLI
```bash
$ docker container run --rm -it -v ~/.aws:/root/.aws -e AWS_PROFILE=default amazon/aws-cli s3 ls
```

ensure it can run AWS CLI API calls
```bash
~/infra-app $ aws sts get-caller-identity
```

if there's more than one AWS Account, export the env for the requested *named profiled* 
```bash
~/infra-app $ export AWS_PROFILE=default
```