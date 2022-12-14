{{ config(materialized='table') }}

with processed__successful_referrals as (
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
		country
	from
        {{ ref('int__referrals_partners_join') }}
    where
        company_status_rank = 1
        and status = 'successful'
		and is_outbound = 'false'
)

select * from processed__successful_referrals
