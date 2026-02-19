--2.Toplam ROMI (Google ve Facebook dahil) açısından en yüksek 5 günü sırala (azalan şekilde tarih ve değer).

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
ad_date,
---1 * COALESCE(SUM(value), 0) / SUM(spend) AS romi --DIVISION BY ZERO HATASI GELİYOR.
CASE WHEN SUM(spend) > 0 THEN SUM(value) / SUM(spend)::numeric ELSE 0 end as ROMI

from AllAds
group by ad_date
order by ROMI desc
limit(5);