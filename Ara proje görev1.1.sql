--1.Google ve Facebook için günlük harcama metriklerinin ortalama, maksimum ve minimum değerlerini ayrı ayrı göster.

WITH AllAds AS (
select fabd.ad_date, fabd.url_parameters ,fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value, 'facebook ads' as media_source
from facebook_ads_basic_daily fabd
left join facebook_adset fa on fabd.adset_id=fa.adset_id
left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id

union all

SELECT  ad_date, url_parameters, spend, impressions, reach, clicks, leads, value, 'Google Ads' as media_source
FROM google_ads_basic_daily
)
select 
ad_date, media_source,
min(coalesce(spend,0)) min_spend, avg(coalesce(spend,0)) avg_spend, max(coalesce(spend,0)) max_spend, 
min(coalesce(impressions,0)) min_impressions, avg(coalesce(impressions,0)) avg_impressions, max(coalesce(impressions,0)) max_impressions, 
min(coalesce(reach,0)) min_reach, avg(coalesce(reach,0)) avg_reach, max(coalesce(reach,0)) max_reach, 
min(coalesce(clicks,0)) min_clicks, avg(coalesce(clicks,0)) avg_clicks, max(coalesce(clicks,0)) max_clicks, 
min(coalesce(leads,0)) min_leads, avg(coalesce(leads,0)) avg_leads, max(coalesce(leads,0)) max_leads, 
min(coalesce(value,0)) min_value, avg(coalesce(value,0)) avg_value, max(coalesce(value,0)) max_value

from AllAds
group by ad_date, media_source
order by ad_date desc;