# Docker

```bash
# preview configs
$ docker compose -f docker-compose.yml --env-file .env config

# build image, if none exists, and run container(s) in the background in detached mode
$ docker compose -f docker-compose.yml --env-file .env up -d

# stop and removes container(s), and networks attached
$ docker compose down
```

access interactive shell of running container for selected Docker Compose service:
```bash
$ docker compose exec infra /bin/ash
```

clean out all, including dangling and unreferenced images, stopped containers, and networks
```bash 
$ docker system prune -af
```

Run the following to append to whatever file your Bash aliases are set (.bashrc, .bash_profile, .bash_aliases) and then reload the file with `source` to start using the _docker aliases_ from your terminal:
```bash
cat <<-EOF >> ~/.bash_aliases

alias dlist='docker ps -a'
alias dup='docker compose -f docker-compose.yml --env-file .env up -d'
alias ddown='docker compose down'
alias dshell='docker compose exec infra /bin/ash'
alias dclean='docker system prune -af'

EOF

source ~/.bash_aliases
```

[Different Ways to Create and Use Bash Aliases in Linux](https://www.tecmint.com/create-and-use-bash-aliases-in-linux/)


# AWS Environment Variables

Docker set the Environment Variables required for building and deploying. But secrets cannot be persisted this way as it will unnecessarily expose them on the image layers when the image is built. 

Assuming that your default AWS Profile is for the correct AWS Account, run the following to set the environment variables for your AWS credentials. Run `aws configure list` to check what AWS profile is displayed.

```
export AWS_PROFILE=default
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile ${AWS_PROFILE})
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile ${AWS_PROFILE})
```

[What is the best way to pass AWS credentials to a Docker container? | Stack Overflow](https://stackoverflow.com/questions/36354423/what-is-the-best-way-to-pass-aws-credentials-to-a-docker-container)


# settings.json

In Visual Studio Code/Codium, set Makefile settings for tabs and not spaces. Press `Ctrl+Shift+P` to bring up Command Palette. Type _"open settings"_ and select `Open User Settings (JSON)`. Add the following block to the JSON file that opens up:
```javascript
{
  // ...
  "[makefile]": {
    "editor.tabSize": 4,
    "editor.insertSpaces": false,
    "editor.useTabStops": true
  },
  // ...
}
```

# global gitignore

add to _global gitignore_ file to remove Git tracking for the current repo directory 

```bash
cat <<-EOF >> ~/.gitignore_global

# packing automation files
/.dockerignore
/.env
/docker-compose.yml
/Dockerfile
/Makefile
/packer-init.pkr.hcl

EOF
```

[Configuring ignored files for all repositories on your computer | GitHub docs](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)