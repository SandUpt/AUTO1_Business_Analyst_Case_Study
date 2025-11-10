-- AUTO1 Business Case: Key SQL

-- KPIs (overall)
SELECT
  COUNT(*) AS total_cars,
  SUM(CASE WHEN car_sold_on_date IS NOT NULL THEN 1 ELSE 0 END) AS sold_cars,
  ROUND(100.0 * SUM(CASE WHEN car_sold_on_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS sell_through_rate_pct,
  ROUND(AVG(julianday(car_sold_on_date) - julianday(first_online_date)), 1) AS avg_days_to_sell
FROM inventory
WHERE car_sold_on_date IS NOT NULL;

-- Unsold age buckets (parameterized snapshot)
-- Bind :snapshot_date from your BI tool if needed
WITH params AS (SELECT :snapshot_date AS snapshot_date)
SELECT
  CASE
    WHEN julianday(snapshot_date) - julianday(first_online_date) < 30 THEN '<30 days'
    WHEN julianday(snapshot_date) - julianday(first_online_date) < 60 THEN '30-59 days'
    WHEN julianday(snapshot_date) - julianday(first_online_date) < 90 THEN '60-89 days'
    ELSE '90+ days'
  END AS age_bucket,
  COUNT(*) AS car_count,
  ROUND(SUM(buy_price)/1000000.0, 2) AS total_value_million
FROM inventory, params
WHERE car_sold_on_date IS NULL
GROUP BY age_bucket
ORDER BY 1;

-- Reusable view (manufacturer x fuel)
CREATE VIEW v_inventory_metrics AS
SELECT
  manufacturer,
  fuel_type,
  COUNT(*) AS total_listed,
  SUM(CASE WHEN car_sold_on_date IS NOT NULL THEN 1 ELSE 0 END) AS sold_cars,
  ROUND(100.0 * SUM(CASE WHEN car_sold_on_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS sell_through_rate_pct,
  ROUND(AVG(julianday(car_sold_on_date) - julianday(first_online_date)), 1) AS avg_days_to_sell
FROM inventory
GROUP BY manufacturer, fuel_type;
