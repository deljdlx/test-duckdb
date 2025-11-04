-- models/staging/stg_pro.sql
with base as (
    select
        column02 as id,
        column05 as gender,
        column07 as lastName,
        column08 as firstName
    from main.pro
    where column02 != 'Identifiant PP'  -- exclure la ligne d'entête
),

dedup as (
    select
        *,
        row_number() over (partition by id order by id) as rn
    from base
)

select
    id,
    gender,
    lastName,
    firstName
from dedup
where rn = 1
