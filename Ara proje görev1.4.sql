--4.Aylık bazda en büyük erişim (reach) artışı yaşayan kampanyayı belirle.

WITH AllAds AS (
select fabd.ad_date, fc.campaign_name, fabd.url_parameters ,fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value, 'facebook ads' as media_source
from facebook_ads_basic_daily fabd
left join facebook_adset fa on fabd.adset_id=fa.adset_id
left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id

union all

SELECT  ad_date, campaign_name, url_parameters, spend, impressions, reach, clicks, leads, value, 'Google Ads' as media_source
FROM google_ads_basic_daily
),

AllAds2 as (
select 
DATE_TRUNC('month', ad_date)::date as ad_month_start,
campaign_name,
sum(coalesce(reach,0)) as total_reach
from AllAds
group by ad_month_start,campaign_name
)

select 
ad_month_start, campaign_name, total_reach, 
case when LAG(total_reach,1,0) OVER (PARTITION BY campaign_name ORDER BY ad_month_start)=0 then 0 
	else total_reach-LAG(total_reach,1,0) OVER (PARTITION BY campaign_name ORDER BY ad_month_start) end as reach_change,

case when LAG(total_reach,1,0) OVER (PARTITION BY campaign_name ORDER BY ad_month_start)=0 then 0 
	else ROUND(((total_reach-LAG(total_reach,1,0) OVER (PARTITION BY campaign_name ORDER BY ad_month_start)))*100/
LAG(total_reach,1,0) OVER (PARTITION BY campaign_name ORDER BY ad_month_start),2) end AS reach_change_percent

from AllAds2
group by ad_month_start, campaign_name, total_reach
order by reach_change desc
limit(1);