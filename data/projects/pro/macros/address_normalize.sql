{% macro canon_address(num, rep, type1, type2, voie, caption) -%}
NULLIF(
  TRIM(
    CONCAT_WS(' ',
      NULLIF(TRIM({{ num }}), ''),
      NULLIF(TRIM({{ rep }}), ''),
      CASE
        WHEN TRIM({{ type1 }}) = 'R' THEN 'RUE'
        WHEN TRIM({{ type1 }}) = ''  THEN NULL
        ELSE TRIM({{ type1 }})
      END,
      CASE
        WHEN TRIM({{ type1 }}) = ''
          THEN CASE
                 WHEN TRIM({{ type2 }}) = 'R' THEN 'RUE'
                 WHEN TRIM({{ type2 }}) = ''  THEN NULL
                 ELSE TRIM({{ type2 }})
               END
        ELSE NULL
      END,
      NULLIF(TRIM({{ voie }}), ''),
      NULLIF(TRIM({{ caption }}), '')
    )
  ),
  ''
)
{%- endmacro %}

{% macro canon_postal(pc) -%}
NULLIF(TRIM({{ pc }}), '')
{%- endmacro %}

{% macro canon_city(city) -%}
NULLIF(TRIM({{ city }}), '')
{%- endmacro %}

{% macro canon_caption(caption) -%}
NULLIF(TRIM({{ caption }}), '')
{%- endmacro %}

