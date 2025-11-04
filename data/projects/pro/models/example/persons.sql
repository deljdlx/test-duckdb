{{ config(materialized='table') }}



with basePersons as (
    select
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


),


dedup as (
    select
        *,
        row_number() over (partition by nationalRpps order by nationalRpps) as rn
    from basePersons
)


SELECT
  *,
  {{ dbt_utils.generate_surrogate_key(['nationalRpps']) }} as person_sk
FROM dedup
WHERE rn = 1

