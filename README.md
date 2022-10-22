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

Run the following to append to whatever file your Bash aliases are set (.bashrc, .bash_profile, .bash_aliases) and then reload the file with `source` to start using the _docker aliases_ from your terminal:
```bash
cat <<-EOF >> ~/.bash_aliases

alias dup='docker compose -f docker-compose.yml --env-file .env up -d'
alias dex='docker compose exec infra /bin/ash'
alias ddown='docker compose down'
alias dclean='docker system prune -af'
EOF

source ~/.bash_aliases
```

[Different Ways to Create and Use Bash Aliases in Linux](https://www.tecmint.com/create-and-use-bash-aliases-in-linux/)

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