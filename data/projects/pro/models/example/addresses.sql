{{ config(materialized='table') }}

WITH base AS (
  SELECT
    {{ canon_address(
      'column28',
      'column29',
      'column30',
      'column31',
      'column32',
      'column24'
    ) }} AS address,
    {{ canon_postal('column35') }} AS postalCode,
    {{ canon_city('column37') }} AS city,
    {{ canon_caption('column24') }} as caption

  FROM {{ source('main','pro') }}
  WHERE column02 <> 'Identifiant PP'
),
dedup AS (
  SELECT address, postalCode, city, caption
  FROM base
  GROUP BY address, postalCode, city, caption
),
keys AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['address','postalCode','city']) }} AS id,
    address, postalCode, city, caption
  FROM dedup
)
SELECT * FROM keys
