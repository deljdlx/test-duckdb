{{ config(materialized='table') }}

with baseAddress as (
    select
        TRIM(CONCAT(
            -- Numéro Voie (coord. structure)
            TRIM(column28),
            if(TRIM(column28) != '', ' ', ''),

            -- Indice répétition voie (coord. structure)
            TRIM(column29),
            if(TRIM(column29) != '', ' ', ''),


            -- Libellé type de voie (coord. structure)
            if(TRIM(column30) == 'R', 'RUE', TRIM(column30)),
            if(TRIM(column30) != '', ' ', ''),


            -- Libellé type de voie (coord. structure)
            if(TRIM(column30) == '',
                if(TRIM(column31) == 'R', 'RUE', TRIM(column31)),
                ''
            ),
            if(TRIM(column31) != '', ' ', ''),

            -- Libellé Voie (coord. structure)
            TRIM(column32)
        )) as address,
        column35 as postalCode,
        column37 as city
    from main.pro
    where column02 != 'Identifiant PP'  -- exclure la ligne d'entête
),

normalizeRue as (
    select
        -- regex ' R ' to ' RUE '
        regexp_replace(address, ' R ', ' RUE ') as address,
        postalCode,
        city
    from baseAddress
),

setAddressNullWhenEmpty as (
    select
        case when address = '' then null else address end as address,
        case when postalCode = '' then null else postalCode end as postalCode,
        case when city = '' then null else city end as city
    from normalizeRue
),

dedup as (
    select
        *,
        row_number() over (partition by address, postalCode, city order by address) as rn
    FROM setAddressNullWhenEmpty
),


generateId as (
    select
        {{ dbt_utils.generate_surrogate_key(['address', 'postalCode', 'city']) }} as id,
        address,
        postalCode,
        city
    from dedup
    where rn = 1
)

select
    id,
    address,
    postalCode,
    city
from generateId

