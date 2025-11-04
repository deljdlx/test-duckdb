{{ config(materialized='table') }}



with basePersons as (
    select
        {{ canon_address('column28','column29','column30','column31', 'column32') }} AS address,
        {{ canon_postal('column35') }} AS postalCode,
        {{ canon_city('column37') }} AS city,

        column01 as rpps,
        column02 as nationalRpps,
        column05 as gender,
        column07 as lastName,
        column08 as firstName,

        column04 as professionnalCivility,
        column09 as professionCode,
        column10 as professionName,

        column40 as phoneNumber,

        column48 as activitySectorCode,
        column49 as activitySectorName,
        column52 as roleCode,
        column53 as roleName

    from main.pro
    where column02 != 'Identifiant PP'  -- exclure la ligne d'entête
),

setFkAddresss as (
  SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(['address','postalCode','city']) }} AS address_id
  FROM basePersons
),


dedup as (
    select
        *,
        row_number() over (partition by nationalRpps order by nationalRpps) as rn
    from setFkAddresss
)


SELECT
  *,
  {{ dbt_utils.generate_surrogate_key(['nationalRpps']) }} as person_sk
FROM dedup
WHERE rn = 1

