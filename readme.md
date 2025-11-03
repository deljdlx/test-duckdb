
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

```bash
docker compose exec duckdb duckdb /data/pro.raw.duckdb -c "SELECT COUNT(*) FROM pro"
```

```bash
docker compose exec duckdb duckdb --json /data/pro.raw.duckdb -c "
    SELECT to_json(pro) FROM pro LIMIT 2;
"
```




bash docker compose run --rm duckdb

docker compose exec duckdb duckdb /data/pro.raw.duckdb -c "SELECT 'hello' as test;"


CREATE TABLE demo AS SELECT * FROM range(5);









