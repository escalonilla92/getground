{{ config(materialized='table') }}

with staging__partners as (
    select
        cast(id as integer) as id,
        to_timestamp(created_at / 1000000000) as created_at,
        to_timestamp(updated_at / 1000000000) as updated_at,
        cast(partner_type as varchar) as partner_type,
        cast(lead_sales_contact as varchar) as lead_sales_contact
    from
        {{ ref('partners') }}
)

select * from staging__partners
