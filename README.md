# DUckDB + dbt Test Environment

## Duckdb smoke test
```bash
docker compose exec duckdb duckdb /data/pro.duckdb -c "SELECT 'hello' as test;"
```

### Smoke validation , show row count
```bash
docker compose exec duckdb duckdb /data/pro.duckdb -c "SELECT COUNT(*) FROM pro"
```

### Show some data in JSON format
```bash
docker compose exec duckdb duckdb --json /data/pro.duckdb -c "
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

docker compose exec duckdb dbt init pro




### Launch dbt build
```bash
dbt build --project-dir /data/hello_duck
```

### Show some data
```bash
dbt show --project-dir /data/hello_duck --select greeting --limit 10
```



## Pro project

### DuckDB CSV import pro data

Assuming you have a CSV file located at `/data/in.csv`. Can be downloaded from https://annuaire.sante.fr/web/site-pro/extractions-publiques

```bash
docker compose exec duckdb duckdb /data/pro.duckdb -c "CREATE TABLE pro AS SELECT * FROM read_csv_auto(
    '/data/in.csv',
    delim='|',
    header=false,
    all_varchar=true,
    sample_size=-1,
    ignore_errors=true
);"
```

### Smoke tests pro data

```bash
docker compose exec duckdb duckdb /data/pro.duckdb -c "SELECT COUNT(*) FROM pro;"
```

```bash
docker compose exec duckdb duckdb --json /data/pro.duckdb -c "SELECT to_json(pro) FROM pro WHERE column35 IS NOT NULL LIMIT 10;" | jq
```


### Optionnal, creating dbt project (already done in this repo)

```bash
make dbtInit
# name of project: pro
```

### Launch dbt build for pro project
```bash
make dbtBuild
# select "pro" project
```

### Smoke test dbt pro model

```bash
docker compose exec duckdb duckdb --json \
    /data/pro.duckdb -c \
    "SELECT to_json(persons) FROM persons LIMIT 10;" \
    | jq
```


```bash
docker compose exec duckdb duckdb --json \
    /data/pro.duckdb -c \
    "SELECT to_json(addresses) FROM addresses \
    WHERE address IS NOT NULL LIMIT \
    50;" \
    | jq
```