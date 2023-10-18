# awkblog

weblog implimentation by awk

## Getting Started

```shell
cp .env.example .env
cp .env_postgres.example .env_postgres
# GitHub Oauth App Setup
#   https://github.com/settings/applications/new
#   Authorization callback URL: http://localhost:4567/oauth-callback
# Write OAUTH_CLIENT_ID and OAUTH_CLIENT_SECRET
vim .env
docker compose up -d
# open browser localhost:4567
```
