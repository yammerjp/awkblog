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
