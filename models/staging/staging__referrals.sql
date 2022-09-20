{{ config(materialized='table') }}

with staging__referrals as (
    select
        cast(id as integer) as id,
        to_timestamp(created_at / 1000000000) as created_at,
        to_timestamp(updated_at / 1000000000) as updated_at,
        cast(company_id as varchar) as company_id,
        cast(partner_id as int) as partner_id,
        cast(consultant_id as int) as consultant_id,
        cast(status as varchar) as status,
        cast(is_outbound as boolean) as is_outbound
    from
        {{ ref('referrals') }}
)

select * from staging__referrals
