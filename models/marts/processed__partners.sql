{{ config(materialized='table') }}

with processed__partners as (
    select
        partner_id,
        partners_created_at,
        partner_type,
        lead_sales_contact,
        country,
        count(
            case
                when 
                    is_outbound = False
                    then referral_id
            end
        ) as total_inbound_referrals,
        count(
            case
                when 
                    is_outbound = False
                    and status = 'successful'
                    then referral_id
            end
        ) as successful_inbound_referrals,
        count(
            case
                when 
                    is_outbound = False
                    and company_status_rank = 1
                    and status = 'successful'
                    then referral_id
            end 
        ) as successful_inbound_first_referrals,
        count(
            case
                when 
                    is_outbound = False
                    and {{datediff('referral_created_at', var('case_current_date'), 'day')}} < 30
                    then referral_id
            end
        ) as total_inbound_referrals_last_30_days,
        count (
            case
                when 
                    is_outbound = False
                    and status = 'successful'
                    and {{datediff('referral_created_at', var('case_current_date'), 'day')}} < 30
                    then referral_id
            end
        ) as successful_inbound_referrals_last_30_days,
        count (
            case
                when 
                    is_outbound = False
                    and company_status_rank = 1
                    and status = 'successful'
                    and {{datediff('referral_created_at', var('case_current_date'), 'day')}} < 30
                    then referral_id
            end
        ) as successful_inbound_first_referrals_last_30_days
    from
        {{ ref('int__referrals_partners_join') }}
    group by
        partner_id,
        partners_created_at,
        partner_type,
        lead_sales_contact,
        country
)

select * from processed__partners
