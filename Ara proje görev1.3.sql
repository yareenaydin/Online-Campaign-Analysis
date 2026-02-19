--3.Haftalık en yüksek toplam value’ya sahip kampanyayı bul (haftayı ve rekor değerini belirt).

WITH AllAds AS (
select fabd.ad_date, fc.campaign_name, fabd.url_parameters ,fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value, 'facebook ads' as media_source
from facebook_ads_basic_daily fabd
left join facebook_adset fa on fabd.adset_id=fa.adset_id
left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id

union all

SELECT  ad_date, campaign_name, url_parameters, spend, impressions, reach, clicks, leads, value, 'Google Ads' as media_source
FROM google_ads_basic_daily
)
select 
DATE_TRUNC('week', ad_date)::date as ad_week_start,
campaign_name,
sum(coalesce(value,0)) total_value

from AllAds
group by ad_week_start,campaign_name
order by total_value desc
limit(1);