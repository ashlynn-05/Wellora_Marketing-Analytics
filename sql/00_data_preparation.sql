-- =====================================================================
-- Wellora Health Marketing Analytics: Data preparation
-- Cleans the raw transaction and customer profile tables.
-- Replace `your-project-id` with your own Google Cloud project ID.
-- =====================================================================

-- Clean Transaction Table
CREATE OR REPLACE TABLE
  `your-project-id.MIS384_A3.Customer_Transaction_Cleaned` AS
SELECT
  -- Assign surrogate IDs to transactions with a missing Transaction_ID
  CASE
    WHEN Transaction_ID IS NULL
      THEN CAST(ROW_NUMBER() OVER (ORDER BY Date) + 9999999 AS INT64)
    ELSE CAST(Transaction_ID AS INT64)
  END AS Transaction_ID,
  CAST(Date AS DATETIME) AS Transaction_DateTime,
  DATE(Date) AS Transaction_Date,
  EXTRACT(YEAR FROM Date) AS Transaction_Year,
  EXTRACT(MONTH FROM Date) AS Transaction_Month,
  Customer_ID,
  Total_Items,
  ROUND(Total_Cost, 2) AS Total_Cost,
  Payment_Method,
  Customer_Category,
  -- Handle both true NULL and the string "None"
  CASE
    WHEN Promotion IS NULL OR TRIM(Promotion) = 'None' OR TRIM(Promotion) = ''
      THEN 'No Promotion'
    ELSE Promotion
  END AS Promotion,
  Transaction_Channel,
  Refund_Status,
  CASE WHEN Refund_Status = 'No Refund' THEN 0 ELSE 1 END AS Is_Refunded
FROM `your-project-id.MIS384_A3.Customer_Transaction`;


-- Clean Profile Table
CREATE OR REPLACE TABLE
  `your-project-id.MIS384_A3.Customer_Profile_Cleaned` AS
SELECT
  Customer_ID,
  CASE
    WHEN CAST(Loyalty_Program_Member AS STRING) = 'true' THEN 'Yes'
    WHEN CAST(Loyalty_Program_Member AS STRING) = 'false' THEN 'No'
    ELSE CAST(Loyalty_Program_Member AS STRING)
  END AS Loyalty_Program_Member,
  Customer_Age,
  CASE
    WHEN Customer_Age < 25 THEN 'Under 25'
    WHEN Customer_Age BETWEEN 25 AND 39 THEN '25–39'
    WHEN Customer_Age BETWEEN 40 AND 59 THEN '40–59'
    ELSE '60+'
  END AS Age_Band,
  Preferred_Device,
  Preferred_Browser,
  Chatbot_Opt_In_Status,
  Data_Sharing_Consent,
  GDPR_Compliance_Status,
  Pseudonymization_Status,
  Data_Protection_Rating,
  Consent_Timestamp,
  Bias_Alert_Flag,
  Chatbot_Interactions,
  Unauthorized_Access_Attempts
FROM `your-project-id.MIS384_A3.Customer_Profile`;
