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

## Generate Traffic

From the root repo dir

```bash
./generate-traffic.sh
```

Or an ab traffic simulation

```bash
ab -n 100 -c 5 http://127.0.0.1:4000/rolldice
```

## TODOs

- Make the configuration better
- Send logs to grafana
- Connect logs to traces with links
- Ecto examples with SQL statements
- Examples with db.connection errors as well
