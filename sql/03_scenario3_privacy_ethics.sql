-- =====================================================================
-- Scenario 3: Ethical AI, privacy & customer trust
-- Replace `your-project-id` with your own Google Cloud project ID.
-- =====================================================================

-- Build S3 Analysis Table
CREATE OR REPLACE TABLE
  `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis` AS
SELECT
  Customer_ID,
  Loyalty_Program_Member,
  Customer_Age,
  CASE
    WHEN Customer_Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Customer_Age BETWEEN 26 AND 39 THEN '26-39'
    WHEN Customer_Age BETWEEN 40 AND 59 THEN '40-59'
    ELSE '60-70'
  END AS Age_Band,
  Preferred_Device,
  Preferred_Browser,
  Chatbot_Opt_In_Status,
  Data_Sharing_Consent,
  GDPR_Compliance_Status,
  Pseudonymization_Status,
  Data_Protection_Rating,
  -- Consent timestamp: NULL means no consent ever given
  CASE
    WHEN Consent_Timestamp IS NULL THEN 'No Consent Recorded'
    ELSE 'Consent Recorded'
  END AS Consent_Status,
  Bias_Alert_Flag,
  Chatbot_Interactions,
  Unauthorized_Access_Attempts,
  -- Risk tier based on unauthorized access attempts
  CASE
    WHEN Unauthorized_Access_Attempts = 0 THEN 'No Risk'
    WHEN Unauthorized_Access_Attempts BETWEEN 1 AND 2 THEN 'Low Risk'
    WHEN Unauthorized_Access_Attempts = 3 THEN 'Medium Risk'
    ELSE 'High Risk (4-5)'
  END AS Security_Risk_Tier,
  -- Data protection band
  CASE
    WHEN Data_Protection_Rating < 0.25 THEN 'Low (0-0.25)'
    WHEN Data_Protection_Rating < 0.5 THEN 'Medium-Low (0.25-0.5)'
    WHEN Data_Protection_Rating < 0.75 THEN 'Medium-High (0.5-0.75)'
    ELSE 'High (0.75-1.0)'
  END AS Protection_Band,
  -- Fully compliant flag (all 4 privacy measures = Yes)
  CASE
    WHEN Chatbot_Opt_In_Status = TRUE
      AND Data_Sharing_Consent = TRUE
      AND GDPR_Compliance_Status = TRUE
      AND Pseudonymization_Status = TRUE
      THEN 'Fully Compliant'
    ELSE 'Not Fully Compliant'
  END AS Full_Compliance_Status
FROM `your-project-id.MIS384_A3.Customer_Profile`;


-- Query 1: Consent & opt-in overview (12,735 customers in the profile table)
SELECT
  Privacy_Metric,
  Customers_Yes,
  ROUND(Customers_Yes / 12735 * 100, 2) AS Pct_Yes,
  12735 - Customers_Yes AS Customers_No,
  ROUND((12735 - Customers_Yes) / 12735 * 100, 2) AS Pct_No
FROM (
  SELECT
    COUNTIF(Chatbot_Opt_In_Status = TRUE) AS Chatbot_Opt_In,
    COUNTIF(Data_Sharing_Consent = TRUE) AS Data_Sharing_Consent,
    COUNTIF(GDPR_Compliance_Status = TRUE) AS GDPR_Compliance,
    COUNTIF(Pseudonymization_Status = TRUE) AS Pseudonymization,
    COUNTIF(Consent_Status = 'Consent Recorded') AS Consent_Timestamp
  FROM `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis`
)
UNPIVOT (Customers_Yes FOR Privacy_Metric IN (
  Chatbot_Opt_In,
  Data_Sharing_Consent,
  GDPR_Compliance,
  Pseudonymization,
  Consent_Timestamp
))
ORDER BY Pct_Yes DESC;


-- Query 2: Security risk tier distribution
SELECT
  Security_Risk_Tier,
  COUNT(*) AS Customers,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS Pct_of_Base,
  ROUND(AVG(Data_Protection_Rating), 3) AS Avg_Protection_Rating,
  ROUND(COUNTIF(Bias_Alert_Flag = TRUE) / COUNT(*) * 100, 2) AS Bias_Alert_Rate_Pct
FROM `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis`
GROUP BY Security_Risk_Tier
ORDER BY
  CASE Security_Risk_Tier
    WHEN 'No Risk' THEN 1
    WHEN 'Low Risk' THEN 2
    WHEN 'Medium Risk' THEN 3
    WHEN 'High Risk (4-5)' THEN 4
  END;


-- Query 3: Bias alert by GDPR and loyalty
SELECT
  GDPR_Compliance_Status,
  Loyalty_Program_Member,
  COUNT(*) AS Customers,
  ROUND(COUNTIF(Bias_Alert_Flag = TRUE) / COUNT(*) * 100, 2) AS Bias_Alert_Rate_Pct,
  ROUND(AVG(Unauthorized_Access_Attempts), 2) AS Avg_Unauth_Attempts,
  ROUND(AVG(Data_Protection_Rating), 3) AS Avg_Protection_Rating
FROM `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis`
GROUP BY GDPR_Compliance_Status, Loyalty_Program_Member
ORDER BY GDPR_Compliance_Status, Loyalty_Program_Member;


-- Query 4: Full compliance breakdown
SELECT
  Full_Compliance_Status,
  COUNT(*) AS Customers,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS Pct_of_Base,
  ROUND(AVG(Data_Protection_Rating), 3) AS Avg_Protection_Rating,
  ROUND(AVG(Unauthorized_Access_Attempts), 2) AS Avg_Unauth_Attempts,
  ROUND(COUNTIF(Bias_Alert_Flag = TRUE) / COUNT(*) * 100, 2) AS Bias_Alert_Rate_Pct
FROM `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis`
GROUP BY Full_Compliance_Status;


-- Query 5: Opt-in rates by age band
SELECT
  Age_Band,
  COUNT(*) AS Customers,
  ROUND(COUNTIF(Chatbot_Opt_In_Status = TRUE) / COUNT(*) * 100, 2) AS Chatbot_OptIn_Pct,
  ROUND(COUNTIF(Data_Sharing_Consent = TRUE) / COUNT(*) * 100, 2) AS DataSharing_Pct,
  ROUND(COUNTIF(GDPR_Compliance_Status = TRUE) / COUNT(*) * 100, 2) AS GDPR_Pct,
  ROUND(AVG(Unauthorized_Access_Attempts), 2) AS Avg_Unauth_Attempts
FROM `your-project-id.MIS384_A3.S3_Privacy_Ethics_Analysis`
GROUP BY Age_Band
ORDER BY Age_Band;
