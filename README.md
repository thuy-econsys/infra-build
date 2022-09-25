# Docker

```bash
# preview configs
$ docker compose -f docker-compose.yml --env-file .env config

# build image, if none exists, and run container(s) in the background in detached mode
$ docker compose -f docker-compose.yml --env-file .env up -d

# stops container(s)
$ docker compose stop

# stop and removes container(s), and networks attached
$ docker compose down
```

access interactive shell of running container of selected Docker Compose service:
```bash
$ docker compose exec infra /bin/ash
```

clean out all, including dangling and unreferenced images, stopped containers, and networks
```bash 
$ docker system prune -af
```

AWS has a Docker container for running AWS CLI:
```bash
$ docker container run --rm -it -v ~/.aws:/root/.aws -e AWS_PROFILE=default amazon/aws-cli s3 ls
```
