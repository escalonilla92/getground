{{ config(materialized='table') }}

with processed__referrals as (
    select
	    referral_id,
		partner_id,
		referral_created_at,
		referral_updated_at,
		company_id,
		consultant_id,
		status,
		is_outbound,
		partners_created_at,
		partner_type,
		lead_sales_contact,
		country,
		company_status_rank
	from
        {{ ref('int__referrals_partners_join') }}
	where
		referral_id is not null
)

select * from processed__referrals
