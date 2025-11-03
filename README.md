# DUckDB + dbt Test Environment

## Duckdb smoke test
```bash
docker compose exec duckdb duckdb /data/pro.raw.duckdb -c "SELECT 'hello' as test;"
```

## DuckDB CSV import test

```bash
docker compose exec duckdb duckdb /data/pro.raw.duckdb -c "CREATE TABLE pro AS SELECT * FROM read_csv_auto(
    '/data/in.csv',
    delim='|',
    header=false,
    all_varchar=true,
    sample_size=-1,
    ignore_errors=true
);"
```


### Smoke validation , show row count
```bash
docker compose exec duckdb duckdb /data/pro.raw.duckdb -c "SELECT COUNT(*) FROM pro"
```

### Show some data in JSON format
```bash
docker compose exec duckdb duckdb --json /data/pro.raw.duckdb -c "
    SELECT to_json(pro) FROM pro LIMIT 2;
" | jq
```

___

# DBT

## Initialize dbt project

```bash
cd /data
dbt init hello_duck

```


### Launch dbt build
```bash
dbt build --project-dir /data/hello_duck
```

### Show some data
```bash
dbt show --project-dir /data/hello_duck --select greeting --limit 10
```

