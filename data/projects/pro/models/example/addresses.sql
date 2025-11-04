{{ config(materialized='table') }}

WITH base AS (
  SELECT
    {{ canon_address('column28','column29','column30','column31','column32') }} AS address,
    {{ canon_postal('column35') }} AS postalCode,
    {{ canon_city('column37') }} AS city
  FROM {{ source('main','pro') }}
  WHERE column02 <> 'Identifiant PP'
),
dedup AS (
  SELECT address, postalCode, city
  FROM base
  GROUP BY address, postalCode, city
),
keys AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['address','postalCode','city']) }} AS id,
    address, postalCode, city
  FROM dedup
)
SELECT * FROM keys
