{# This test ensures that partners are conserved after aggregating in the processed__partners table#}

with input_value as (
    select
        count(id) as input_value
    from
        {{ ref('staging__referrals') }}
),

output_value as (
    select
        count(referral_id) as output_value
    from
        {{ ref('processed__referrals') }}
),

input_output_joined as (
    select
        round(input_value.input_value) as input_value,
        round(output_value.output_value) as output_value
    from
        input_value
    cross join
        output_value
),

referrals_conserved as (
    select
        *
    from
        input_output_joined
    where
        abs(input_value/output_value) <= 0.99999 or
        abs(input_value/output_value) >= 1.00001
)

select * from referrals_conserved