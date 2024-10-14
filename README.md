# awkblog

awkblog is an AWK-based blogging platform that demonstrates AWK's capability to build full-fledged web applications. It features GitHub OAuth, Markdown support, and optional S3 image hosting, showcasing that AWK can be used for more than just text processing.

<div style="text-align: center;">
    <img src="static/assets/awkblog-icon.png" height="200" alt="awkblog logo">
</div>

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


## Features

- Blog platform built entirely with AWK
- GitHub OAuth authentication
- Markdown support for posts
- Custom CSS styling for each blog
- RSS feed generation
- Image uploads to S3 (optional)
- Multi-user support

## Architecture

awkblog is a web application written primarily in AWK, with some shell scripting for setup and management. It uses:

- AWK for the core application logic and request handling
- PostgreSQL for data storage
- Nginx for reverse proxy
- Docker for containerization and easy deployment
- GitHub OAuth for authentication
- Amazon S3 for image storage (optional)

## Configuration

The main configuration is done through environment variables. Copy `.env.example` to `.env` and adjust the values as needed:

- `OAUTH_CLIENT_ID`, `OAUTH_CLIENT_SECRET`, and `OAUTH_CALLBACK_URL`: GitHub OAuth configuration
- `GITHUB_LOGIN_SERVER`: The URL of the GitHub login server for GitHub OAuth
- `GITHUB_API_SERVER`: The URL of the GitHub API server for GitHub OAuth
- `AWKBLOG_HOSTNAME`: The public URL of your awkblog instance
- `AWKBLOG_WORKERS`: The number of request handler processes
- `NOT_USE_AWS_S3`: If you don't want to use AWS S3 for image uploads, set this to `1`
- `AWS_*` and `S3_*`: Amazon S3 configuration (if using S3 for image uploads)
- `AWKBLOG_LANG`: The language of the blog. Currently, only `en` (English) and `ja` (Japanese) are supported.

## Development

To set up a development environment:

1. Clone the repository
2. Run `./bin/setup.sh` to install dependencies
3. Copy `.env.example` to `.env` and configure as needed
4. Run `docker compose up -d` to start the development environment
5. Access the application at `http://localhost:4567`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

