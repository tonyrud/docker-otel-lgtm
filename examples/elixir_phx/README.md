# Elixir Phoenix Otel Example

## Dependecies

- Docker
- watch

## Local Dev

`cd examples/elixir_phx`

Start everything

```bash
docker compose up --build
```

Now you can visit [`http://localhost:4000/rolldice`](http://localhost:4000/rolldice) from your browser

start a separate iex session

```bash
docker compose exec -it app iex
```

If you're developing and would like to restart the running app

```bash
docker compose up --build -d app
```

start a psql session

```bash
docker compose exec -it db psql -U postgres
```

Stop docker services

```bash
docker compose down
```

## TODOs

- Add metrics
- Add sampling examples
- Ecto examples with SQL statements
- Examples with db.connection errors as well. Show the SQL statment that failed on timeouts
- Make an external call via Req to see tracing across services
