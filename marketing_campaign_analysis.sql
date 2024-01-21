--Creating a new table in PostgreSQL 16 to analyze marketing campaign data

CREATE TABLE marketing_campaigns (
    campaign_id VARCHAR(255) PRIMARY KEY,
    campaign_name VARCHAR(255),
    start_date DATE,
    end_date DATE,
    budget NUMERIC(10,2),
    channel VARCHAR(255),
    impressions INT,
    clicks INT,
    conversions INT,
    revenue NUMERIC(10,2)
);

-- Overall campaign performance

SELECT
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    SUM(revenue) AS total_revenue
FROM marketing_campaigns;

-- Campaign ROI

SELECT
    campaign_id,
    campaign_name,
    (SUM(revenue) - SUM(budget)) / SUM(budget) * 100 AS roi_percentage
FROM marketing_campaigns
GROUP BY campaign_id, campaign_name
ORDER BY roi_percentage DESC;


-- Channel performance

SELECT
    channel,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    SUM(revenue) AS total_revenue
FROM marketing_campaigns
GROUP BY channel
ORDER BY SUM(revenue) DESC;

-- Conversion rate by campaign

SELECT
    campaign_id,
    campaign_name,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    (SUM(conversions) * 100.0 / SUM(clicks)) AS conversion_rate
FROM marketing_campaigns
GROUP BY campaign_id, campaign_name
ORDER BY conversion_rate DESC;

-- Average revenue per conversion

SELECT
    campaign_id,
    campaign_name,
    (SUM(revenue) / SUM(conversions)) AS avg_revenue_per_conversion
FROM marketing_campaigns
WHERE conversions > 0
GROUP BY campaign_id, campaign_name
ORDER BY avg_revenue_per_conversion DESC;

-- Budget utilization

SELECT
    campaign_id,
    campaign_name,
    budget,
    SUM(revenue) AS total_revenue,
    (SUM(revenue) / budget) * 100 AS budget_utilization_percentage
FROM marketing_campaigns
GROUP BY campaign_id, campaign_name, budget
ORDER BY budget_utilization_percentage DESC;



