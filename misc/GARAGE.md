# Garage S3 (Local Development)

S3-compatible object storage for local development.

## .env Configuration

```bash
# Port numbers
GARAGE_S3_PORT=3900
GARAGE_RPC_PORT=3901
GARAGE_WEB_PORT=3902
GARAGE_ADMIN_PORT=3903
S3_PROXY_PORT=3904

# To enable S3: remove or comment out NOT_USE_AWS_S3=1
# NOT_USE_AWS_S3=1

# Fixed credentials for development
AWS_ACCESS_KEY_ID=GK0123456789abcdef01234567
AWS_SECRET_ACCESS_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
AWS_BUCKET=awkblog-images
AWS_REGION=garage
S3_BUCKET_ENDPOINT=http://localhost:3900/awkblog-images
S3_ASSET_HOST=http://localhost:3904
```

Note: If you change port numbers, update `S3_BUCKET_ENDPOINT` and `S3_ASSET_HOST` accordingly.

## Initial Setup

```bash
# 1. Start containers
docker compose up -d

# 2. Get Node ID
docker compose exec garage /garage status

# 3. Configure layout (replace <NODE_ID> with the ID from step 2)
docker compose exec garage /garage layout assign -z dc1 -c 1G <NODE_ID>
docker compose exec garage /garage layout apply --version 1

# 4. Create key and bucket
docker compose exec garage /garage key import --yes -n awkblog-key \
  GK0123456789abcdef01234567 \
  0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
docker compose exec garage /garage bucket create awkblog-images
docker compose exec garage /garage bucket allow --read --write --owner awkblog-images --key awkblog-key
docker compose exec garage /garage bucket website --allow awkblog-images

# 5. Configure CORS (requires aws-cli on host, adjust port if changed)
AWS_ACCESS_KEY_ID=GK0123456789abcdef01234567 \
AWS_SECRET_ACCESS_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \
aws --endpoint-url http://localhost:3900 s3api put-bucket-cors \
  --bucket awkblog-images \
  --cors-configuration '{"CORSRules":[{"AllowedOrigins":["*"],"AllowedMethods":["GET","PUT","POST"],"AllowedHeaders":["*"]}]}'

# 6. Comment out NOT_USE_AWS_S3=1 in .env and restart app
docker compose up -d --force-recreate app
```

## Useful Commands

```bash
docker compose exec garage /garage status       # Cluster status
docker compose exec garage /garage bucket list  # List buckets
docker compose exec garage /garage key list     # List keys
```
