-- =====================================================================
-- Scenario 1: Customer retention & promotion effectiveness
-- Requires the cleaned tables from 00_data_preparation.sql.
-- Replace `your-project-id` with your own Google Cloud project ID.
-- =====================================================================

-- Build S1 Analysis Table
CREATE OR REPLACE TABLE
  `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis` AS
WITH purchase_frequency AS (
  SELECT
    Customer_ID,
    COUNT(*) AS Total_Purchases,
    SUM(Total_Cost) AS Total_Spend,
    AVG(Total_Cost) AS Avg_Spend_Per_Txn,
    SUM(Total_Items) AS Total_Items_Bought,
    SUM(Is_Refunded) AS Total_Refunds,
    ROUND(SUM(Is_Refunded) / COUNT(*), 4) AS Customer_Refund_Rate,
    CASE
      WHEN COUNT(*) = 1 THEN 'One-time Buyer'
      WHEN COUNT(*) BETWEEN 2 AND 3 THEN 'Occasional Buyer'
      ELSE 'Frequent Buyer'
    END AS Buyer_Segment
  FROM `your-project-id.MIS384_A3.Customer_Transaction_Cleaned`
  GROUP BY Customer_ID
)
SELECT
  t.Transaction_ID,
  t.Transaction_DateTime,
  t.Transaction_Date,
  t.Transaction_Year,
  t.Transaction_Month,
  t.Customer_ID,
  t.Total_Items,
  t.Total_Cost,
  t.Payment_Method,
  t.Customer_Category,
  t.Promotion,
  t.Transaction_Channel,
  t.Refund_Status,
  t.Is_Refunded,
  p.Loyalty_Program_Member,
  p.Customer_Age,
  p.Age_Band,
  p.Preferred_Device,
  f.Total_Purchases,
  f.Total_Spend,
  f.Avg_Spend_Per_Txn,
  f.Total_Items_Bought,
  f.Total_Refunds,
  f.Customer_Refund_Rate,
  f.Buyer_Segment
FROM `your-project-id.MIS384_A3.Customer_Transaction_Cleaned` t
LEFT JOIN `your-project-id.MIS384_A3.Customer_Profile_Cleaned` p
  ON t.Customer_ID = p.Customer_ID
LEFT JOIN purchase_frequency f
  ON t.Customer_ID = f.Customer_ID;


-- Verify
SELECT COUNT(*)
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`;

-- Promotions
SELECT Promotion, COUNT(*) AS n
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Promotion;

-- Buyer segments
SELECT Buyer_Segment, COUNT(DISTINCT Customer_ID) AS unique_customers
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Buyer_Segment
ORDER BY unique_customers DESC;


-- Query 1: Spending & refund rate by transaction channel
SELECT
  Transaction_Channel,
  COUNT(*) AS Total_Transactions,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(AVG(Total_Items), 2) AS Avg_Basket_Size,
  ROUND(SUM(Is_Refunded) / COUNT(*) * 100, 2) AS Refund_Rate_Pct
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Transaction_Channel
ORDER BY Avg_Spend DESC;


-- Query 2: Promotion effectiveness
SELECT
  Promotion,
  COUNT(*) AS Total_Transactions,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(AVG(Total_Items), 2) AS Avg_Basket_Size,
  ROUND(SUM(Is_Refunded) / COUNT(*) * 100, 2) AS Refund_Rate_Pct
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Promotion
ORDER BY Avg_Spend DESC;


-- Query 3: Loyalty member vs non-member comparison
SELECT
  Loyalty_Program_Member,
  COUNT(DISTINCT Customer_ID) AS Unique_Customers,
  COUNT(*) AS Total_Transactions,
  ROUND(COUNT(*) / COUNT(DISTINCT Customer_ID), 2) AS Avg_Purchase_Frequency,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(AVG(Total_Items), 2) AS Avg_Basket_Size,
  ROUND(SUM(Is_Refunded) / COUNT(*) * 100, 2) AS Refund_Rate_Pct
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
WHERE Loyalty_Program_Member IS NOT NULL
GROUP BY Loyalty_Program_Member
ORDER BY Loyalty_Program_Member;


-- Query 4: Buyer segment breakdown (the retention crisis headline)
SELECT
  Buyer_Segment,
  COUNT(DISTINCT Customer_ID) AS Unique_Customers,
  ROUND(COUNT(DISTINCT Customer_ID) / SUM(COUNT(DISTINCT Customer_ID)) OVER () * 100, 2) AS Pct_of_Base,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(AVG(Total_Purchases), 2) AS Avg_Purchases,
  ROUND(AVG(Total_Spend), 2) AS Avg_Lifetime_Spend
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Buyer_Segment
ORDER BY Avg_Purchases DESC;


-- Query 5: Refund rate & spending by customer category
SELECT
  Customer_Category,
  COUNT(DISTINCT Customer_ID) AS Unique_Customers,
  COUNT(*) AS Total_Transactions,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(SUM(Is_Refunded) / COUNT(*) * 100, 2) AS Refund_Rate_Pct
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
GROUP BY Customer_Category
ORDER BY Refund_Rate_Pct DESC;


-- Bonus query: Loyalty x Promotion
SELECT
  Loyalty_Program_Member,
  Promotion,
  COUNT(*) AS Total_Transactions,
  ROUND(AVG(Total_Cost), 2) AS Avg_Spend,
  ROUND(SUM(Is_Refunded) / COUNT(*) * 100, 2) AS Refund_Rate_Pct
FROM `your-project-id.MIS384_A3.S1_Customer_Retention_Analysis`
WHERE Loyalty_Program_Member IS NOT NULL
GROUP BY Loyalty_Program_Member, Promotion
ORDER BY Loyalty_Program_Member, Avg_Spend DESC;
