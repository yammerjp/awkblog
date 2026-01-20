.PHONY: up log restart down db test test-template

up:
	docker compose up -d
log:
	docker compose logs -f
restart:
	docker compose restart gawk
down:
	docker compose down
db:
	docker compose exec -e PGPASSWORD=passw0rd db /bin/bash -c 'psql -U postgres -d postgres'
test:
	docker compose exec app bash -c 'cd /app && ./test/unittest.sh'
test-template:
	docker compose exec app bash -c 'cd /app && ./test/templatetest.sh'
