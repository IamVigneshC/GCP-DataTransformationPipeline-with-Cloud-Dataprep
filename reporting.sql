SELECT
  date,
  unique_session_id,
  fullVisitorId,
  totalTransactionRevenue1,
  -- push the entire checkout basket into an array
  ARRAY_AGG(DISTINCT v2ProductName) AS products_bought
FROM
  ecommerce.revenue_reporting
-- only include products that were actually bought
WHERE productQuantity > 0
GROUP BY 1,2,3,4
ORDER BY date DESC
