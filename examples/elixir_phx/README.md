# Elixir Phoenix Otel Example

## Dependecies

- Docker
- watch

## Local Dev

Start Otel services

```bash
./run-lgtm.sh
```

`cd examples/elixir_phx`

Start db and phx app

```bash
./run.sh
```

psql into database service

```bash
docker compose exec -it db psql -U postgres
```

Now you can visit [`http://localhost:4000/rolldice`](http://localhost:4000/rolldice) from your browser

## Simulate Traffic

Defaults to 2s interval between requests

```bash
docker compose up traffic
```

Slower traffic interval

```bash
SLEEP_INTERVAL=10 docker compose up traffic
```

## TODOs

- Ecto examples with SQL statements
- Add metrics
- Add sampling examples
- Examples with db.connection errors as well. Show the SQL statment that failed on timeouts
- Make an external call via Req to see tracing across services
- Move to docker compose for single start all cmd
