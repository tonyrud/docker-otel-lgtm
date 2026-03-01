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

Now you can visit [`http://localhost:4000/rolldice`](http://localhost:4000/rolldice) from your browser

## Simulate Traffic

```bash
docker compose up traffic
```


## TODOs

- Ecto examples with SQL statements
- Add metrics
- Add sampling examples
- Examples with db.connection errors as well. Show the SQL statment that failed on timeouts
- Make an external call via Req to see tracing across services
- Move to docker compose([example with full otel/lgtm and traffic generation](https://github.com/causely-oss/slow-query-lab/blob/main/docker-compose.yml))
