SELECT
  id,
  UPPER(name) AS name_upper
FROM {{ ref('source_data') }}
