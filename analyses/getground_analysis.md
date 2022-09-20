# Analysis

## Executive summary

In the following analysis I'll have a quick look at the mutliple tables provided (parnters, referrals, sales_people). 
I've found multiple limitations, edge cases and improvements we could do to the tables.

- Limitations:
    - No information regarding customers.
    - No information on referral fee amount.
    - We don't have tables with detailed information about consultants, companies and customers.

- Edge cases:
    - One of the companies has 176 referrals, the next one has only 7.
    - One of the sales representative is managing 120 partners and others only 5.

- Improvements:
    - We could add information about customers.
    - We could add detail tables for consultants, companies and customers.
    - We could add ids to sales_people table

## Exploring the source tables

First of all I had a look at all the tables to get a quick idea of what the data looked like. You can see below.

### partners data

```select * from dev.partners;```

| id | created\_at | updated\_at | partner\_type | lead\_sales\_contact |
| -- | ----------- | ----------- | ------------- | -------------------- |
| 2  | 1,60E+32    | 1,61E+32    | Agent         | Potato               |
| 3  | 1,60E+32    | 1,62E+32    | Agent         | Lion                 |
| 4  | 1,60E+32    | 1,62E+32    | Agent         | Potato               |
| 5  | 1,60E+32    | 1,61E+32    | Agent         | Lion                 |
| 6  | 1,60E+32    | 1,61E+31    | Agent         | Potato               |
| 7  | 1,60E+32    | 1,61E+32    | Agent         | Lion                 |
| 8  | 1,60E+32    | 1,61E+32    | Agent         | Lion                 |


### referrals data

```select * from dev.referrals;```

| id | created\_at | updated\_at | company\_id | partner\_id | consultant\_id | status     | is\_outbound |
| -- | ----------- | ----------- | ----------- | ----------- | -------------- | ---------- | ------------ |
| 1  | 1,60E+32    | 1,60E+32    | 385         | 4           | 4              | successful | 0            |
| 2  | 1,60E+32    | 1,60E+32    | 390         | 7           | 8              | successful | 0            |
| 3  | 1,60E+31    | 1,60E+31    | 387         | 7           | 8              | successful | 0            |
| 4  | 1,60E+32    | 1,60E+32    | 385         | 7           | 8              | successful | 0            |
| 5  | 1,60E+32    | 1,60E+32    | 331         | 8           | 9              | successful | 0            |
| 6  | 1,60E+32    | 1,60E+32    | 364         | 8           | 11             | successful | 0            |
| 7  | 1,60E+32    | 1,60E+32    | 362         | 8           | 11             | successful | 0            |

### sales_people data

```select * from dev.sales_people;```

| name   | country   |
| ------ | --------- |
| Orange | Singapore |
| Apple  | Singapore |
| Lion   | HongKong  |
| Tree   | HongKong  |
| Root   | HongKong  |
| Sky    | HongKong  |
| Cloud  | UK        |

## Table structure analysis

After having a look at the raw tables, I would like to understand how the referrals table works, and understanding referrals per partners.

```
-- understanding distribution or referrals by partner_id
select
	partner_id,
	count(company_id) as count,
	count(distinct company_id) as count_distinct
from
	dev.referrals
group by
	partner_id
order by
	count_distinct desc
```
After looking at the table below, I believe the number of referrals is not unique by company, so it seems a partner can refer the same company more than once.

| partner\_id | count | count\_distinct |
| ----------- | ----- | --------------- |
| 7           | 253   | 218             |
| 191         | 130   | 123             |
| 149         | 115   | 110             |
| 63          | 90    | 82              |
| 201         | 85    | 81              |
| 290         | 78    | 78              |
| 302         | 60    | 58              |


By looking at the results of the table below, we can see some companies being referred multiple times. Some of them with a really high number of referrals which seems to be wromg as company_id = 0. We'll check how some of this looks to have a better understanding.

```-- check referrals with more than one compay
select
	company_id,
	count(*)
from
	dev.referrals
group by
	company_id
order by
	2 desc	
```

| company\_id | count |
| ----------- | ----- |
| 0           | 176   |
| 809         | 7     |
| 1057        | 7     |
| 833         | 7     |
| 976         | 7     |
| 1107        | 7     |
| 987         | 6     |


We can see below what the referral table looks like fore company_id = 0 and company_id = 809. It seems both of them have different partners_id, different status and different consultants making the referral.

| id | created\_at | updated\_at | company\_id | partner\_id | consultant\_id | status     | is\_outbound |
| -- | ----------- | ----------- | ----------- | ----------- | -------------- | ---------- | ------------ |
| 12 | 1,60E+31    | 1,60E+32    | 0           | 6           | 7              | successful | 0            |
| 13 | 1,60E+32    | 1,60E+32    | 0           | 6           | 7              | successful | 0            |
| 15 | 1,60E+32    | 1,60E+32    | 0           | 7           | 8              | successful | 0            |
| 18 | 1,60E+32    | 1,60E+32    | 0           | 7           | 8              | pending    | 0            |
| 21 | 1,60E+32    | 1,60E+32    | 0           | 2           | 16             | successful | 0            |
| 26 | 1,60E+32    | 1,60E+32    | 0           | 10          | 17             | successful | 0            |
| 29 | 1,60E+32    | 1,60E+32    | 0           | 6           | 7              | successful | 0            |

| id  | created\_at | updated\_at | company\_id | partner\_id | consultant\_id | status     | is\_outbound |
| --- | ----------- | ----------- | ----------- | ----------- | -------------- | ---------- | ------------ |
| 446 | 1,61E+32    | 1,61E+32    | 809         | 7           | 8              | successful | 0            |
| 447 | 1,61E+32    | 1,61E+32    | 809         | 52          | 83             | successful | 0            |
| 450 | 1,61E+32    | 1,61E+32    | 809         | 7           | 8              | successful | 0            |
| 482 | 1,61E+32    | 1,61E+32    | 809         | 52          | 83             | successful | 0            |
| 735 | 1,61E+32    | 1,61E+32    | 809         | 63          | 129            | pending    | 1            |
| 736 | 1,61E+32    | 1,61E+32    | 809         | 191         | 266            | pending    | 1            |
| 737 | 1,61E+32    | 1,61E+32    | 809         | 290         | 351            | pending    | 1            |

I've have a quick look at how the different partners are distrubuted by sales agent. I found the distribution to be very diverse with some agents having 120 partners assigned and others only 5.

```
-- understanding distribution of company per sales agent
select
	lead_sales_contact,
	count(id) as count
from
	dev.partners
group by
	lead_sales_contact
order by
	count desc
```	

| lead\_sales\_contact | count    |
| -------------------- | -------- |
| Root                 | 1,20E+02 |
| Potato               | 1,09E+02 |
| Lion                 | 4,60E+01 |
| Daisy                | 4,60E+01 |
| Apple                | 4,30E+01 |
| Sky                  | 3,70E+01 |
| Tree                 | 3,60E+01 |
| Leaf                 | 33       |
| Cloud                | 20       |
| Horiz                | 18       |
| Tulip                | 5        |
| 0                    | 5        |
| Fig                  | 4        |


## Conclusion

Based of what we are seeing here we can see in the referral table a company_id can be referred by multiplee companies. As we don't have any information by customer I'm assuming this could be different partners recommending multiple persons, but the same company.

based on the following statement: "Referrals are on a company level: a customer who signs up for five companies counts as five referrals. Five customers in one company count as one referral." I'm assuming we should only consider one referral per company_id, so I will only consider the first succesful referral per company_id in the final processed tables to be the referral for which we should pay a fee.

We can see multiple limitations in the 3 tables above:
    - No information regarding customer, only company_id, but not customer_id in the referral table.
    - No information on referral fee amount.
    - No id on sales_people table
    - No sales_people_id in partner table to join to sales_people table.
    - sales_people table is missing at least the details of one sales person `potato`.
    - The is a 0 in some of the lead_sales_contact in the partners table.
    - We don't have tables with information about consultants, companies and customers.

We could improve this by:
    - adding more information about customers.
    - Add detail tables for consultants, companies and customers.
    - Add ids to sales_people table.
    - Update sales_people table to capture all sales peoples in the partners table.
    - Add referral fee in the referral table.

## Processed Tables

Based on the analysis above and in order to have some clear data that we can use for analysis I've created three mart tables:

- `processed__inbound_referrals`: In this table we can find all the information for referrals. I've joined this table to partners and sales to get all the available information.
    - columns:
        - `referral_id:`id for referrals
        - `partner_id:` partner id from the referral partner
        - `referral_created_at:` time referral was created
        - `referral_updated_at` time when the referral status went from `pending` to either `disinterested` or `successful`
        - `company_id:` company id from the referred company
        - `consultant_id:` id from the referral consultant in the partner
        - `status:` current status of the referral
        - `is_outbound:` whether referral is outbound or inbound
        - `partner_created_at:` Time the partner was created
        - `partner_type:` Partner type
        - `lead_sales_contact:` Our sales person responsible for the account
        - `country:` The country where the sales person is based

    
    
- `processed__partners`: This table provides information at a partner level, and we can find mutiple metrics per partner as the number of inbound referrals, number of sucessful_inbound referrals and more.
    - columns:
        - `partner_id:` partner id from the referral partner
        - `partner_created_at:` Time the partner was created
        - `partner_type`: Partner type
        - `lead_sales_contact:` Our sales person responsible for the account
        - `country:` The country where the sales person is based
        - `total_inbound_referrals:` Total number of inbound referrals
        - `successful_inbound_referrals:` Total number of successful inbound referrals
        - `successful_inbound_first_referrals:` Total number of successful inbound referrals that are the first one for a company
        - `total_inbound_referrals_last_30_days:` Total number of inbound referrals in the last 30 days
        - `successful_inbound_referrals_last_30_days:` Total number of successful inbound referrals in the last 30 days
        - `successful_inbound_first_referrals_last_30_days:` Total number of successful inbound referrals that are the first one for a company in the last 30 days

- `processed__successful_inbound_referrals`: This table has all the information about the succesful inbound referrals. I've only considered a succesful inbound referral as the first succesful inbound referral per company_id, as I assumed we could only had one referral per company_id.
    columns:
        - `referral_id:`id for referrals
        - `partner_id:` partner id from the referral partner
        - `referral_created_at:` time referral was created
        - `referral_updated_at` time when the referral status went from `pending` to either `disinterested` or `successful`
        - `company_id:` company id from the referred company
        - `consultant_id:` id from the referral consultant in the partner
        - `status:` current status of the referral
        - `is_outbound:` whether referral is outbound or inbound
        - `partner_created_at:` Time the partner was created
        - `partner_type:` Partner type
        - `lead_sales_contact:` Our sales person responsible for the account
        - `country:` The country where the sales person is based
