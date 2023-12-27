# awkblog

weblog implimentation by awk

## Getting Started

```shell

./bin/setup.sh
cp .env.example .env
# By default, login uses a mock server.
# If you want to use a real GitHub account, set up the GitHub OAuth App and configure your confidential information.
# https://github.com/settings/applications/new
# Authorization callback URL: http://localhost:4567/oauth-callback
# Write OAUTH_CLIENT_ID and OAUTH_CLIENT_SECRET
# vim .env
docker compose up -d
# open browser localhost:4567
```
