--5. En uzun kesintisiz gösterime sahip adset_name’i (Google + Facebook) ve süresini gösteren sorgu
WITH AllAds AS (
    SELECT
        fabd.ad_date,
        fa.adset_name
    FROM facebook_ads_basic_daily fabd
    LEFT JOIN facebook_adset fa ON fabd.adset_id = fa.adset_id
    WHERE impressions > 0
    UNION ALL
    SELECT
        ad_date,
        adset_name
    FROM google_ads_basic_daily
    WHERE impressions > 0
),
DistinctAds AS (
    SELECT DISTINCT adset_name, ad_date
    FROM AllAds
),
ordered AS (
    SELECT
        adset_name,
        ad_date,
--iki gün arasında fark alabilmek için öncelikle prev_date sütunu oluşturalım: 
        
        LAG(ad_date) OVER (PARTITION BY adset_name ORDER BY ad_date) AS prev_date
    FROM DistinctAds
),
streaks AS (
    SELECT
        adset_name,
        ad_date,
--ad_date ile prev_date arasında 1 gün varsa bunlar ardışık günlerdir, aşağıdaki SUM formülünde etkisiz olması için bunlara sıfır diyelim:
        
        CASE
            WHEN prev_date IS NULL THEN 1
            WHEN ad_date - prev_date = 1 THEN 0
            ELSE 1
        END AS is_new_group
    FROM ordered
),
grouped AS (
    SELECT
        adset_name,
        ad_date,
--Gün farklarını (is_new_group) toplayan bir streak_id sütunu oluşturmalıyız 
--(sıfırlar yani ardışıklar toplamada etkisiz olacağı için her bir streak_id kesintisiz süreyi verir) :
        
        SUM(is_new_group) OVER (PARTITION BY adset_name ORDER BY ad_date) AS streak_id
    FROM streaks
)

SELECT
    adset_name, streak_id,
     MIN(ad_date) AS streak_start,
     MAX(ad_date) AS streak_end,
    (MAX(ad_date) - MIN(ad_date) +1) AS duration
    --COUNT(*) AS duration şeklinde de satır sayısı ile bulabilirdik (streak_id yi group bya aldığımız için)
FROM grouped
GROUP BY adset_name, streak_id
ORDER BY duration desc
limit(1);