{{ config(materialized='table') }}

with int__referrals_partners_join as (
	select
		referrals.id as referral_id,
		partners.id as partner_id,
		referrals.created_at as referral_created_at,
		referrals.updated_at as referral_updated_at,
		referrals.company_id,
		referrals.consultant_id,
		referrals.status,
		referrals.is_outbound,
		partners.created_at as partners_created_at,
		partners.partner_type,
		partners.lead_sales_contact,
		sales_people.country,
		rank() over(partition by referrals.company_id, referrals.status, is_outbound order by referrals.created_at) as company_status_rank		
	from
		{{ ref('staging__partners') }} as partners
	left join
		{{ ref('staging__referrals') }} as referrals
		on
			partners.id = referrals.partner_id
	left join
		{{ ref('staging__sales_people') }} as sales_people
		on
			partners.lead_sales_contact = sales_people.name
)

select * from int__referrals_partners_join
