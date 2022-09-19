with staging__sales_people as (
    select
        cast(name as varchar) as name,
        cast(country as varchar) as country
    from
        {{ ref('referrals') }}
)

select * from staging__sales_people

