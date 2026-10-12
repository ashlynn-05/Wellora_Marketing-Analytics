-- =====================================================================
-- Scenario 2: Digital channel performance & generative AI chatbot engagement
-- Replace `your-project-id` with your own Google Cloud project ID.
-- =====================================================================

-- Build S2 Analysis Table
CREATE OR REPLACE TABLE
  `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis` AS
SELECT
  Year,
  Month,
  Device_Type,
  Channel_Type,
  VisitorType,
  -- Decode TrafficType numbers to labels
  CASE TrafficType
    WHEN 1 THEN 'Direct'
    WHEN 2 THEN 'Organic Search'
    WHEN 3 THEN 'Paid Search'
    WHEN 4 THEN 'Email'
    WHEN 5 THEN 'Display Ads'
    WHEN 6 THEN 'Social Organic'
    WHEN 7 THEN 'Social Paid'
    WHEN 8 THEN 'Referral'
    WHEN 9 THEN 'Affiliate'
    WHEN 10 THEN 'SMS'
  END AS Traffic_Source,
  Administrative_page,
  Administrative_Duration,
  Informational_page,
  Informational_Duration,
  ProductRelated_page,
  ProductRelated_Duration,
  ROUND(BounceRates, 6) AS BounceRates,
  ROUND(ExitRates, 6) AS ExitRates,
  ROUND(Conversion_Rate, 4) AS Conversion_Rate,
  Generative_AI_Chatbot_Interactions,
  `Average_Time_Spent_ GenAI_Seconds` AS Chatbot_Time_Seconds,
  -- Chatbot engagement tier
  CASE
    WHEN Generative_AI_Chatbot_Interactions = 0 THEN 'No Chatbot'
    WHEN Generative_AI_Chatbot_Interactions BETWEEN 1 AND 25 THEN 'Low (1-25)'
    WHEN Generative_AI_Chatbot_Interactions BETWEEN 26 AND 60 THEN 'Medium (26-60)'
    ELSE 'High (61-100)'
  END AS Chatbot_Tier,
  -- Binary chatbot flag
  CASE WHEN Generative_AI_Chatbot_Interactions > 0 THEN 1 ELSE 0 END AS Has_Chatbot
FROM `your-project-id.MIS384_A3.Webpage_Performance`;


-- Performance by device type
SELECT
  Device_Type,
  COUNT(*) AS Sessions,
  ROUND(AVG(Conversion_Rate) * 100, 2) AS Avg_Conversion_Pct,
  ROUND(AVG(BounceRates) * 100, 2) AS Avg_Bounce_Pct,
  ROUND(AVG(ExitRates) * 100, 2) AS Avg_Exit_Pct,
  ROUND(AVG(Generative_AI_Chatbot_Interactions), 2) AS Avg_Chatbot_Interactions
FROM `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis`
GROUP BY Device_Type
ORDER BY Avg_Conversion_Pct DESC;


-- Bounce & conversion by traffic source
SELECT
  Traffic_Source,
  COUNT(*) AS Sessions,
  ROUND(AVG(Conversion_Rate) * 100, 2) AS Avg_Conversion_Pct,
  ROUND(AVG(BounceRates) * 100, 2) AS Avg_Bounce_Pct,
  ROUND(AVG(ExitRates) * 100, 2) AS Avg_Exit_Pct
FROM `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis`
GROUP BY Traffic_Source
ORDER BY Avg_Bounce_Pct DESC;


-- Visitor type performance
SELECT
  VisitorType,
  COUNT(*) AS Sessions,
  ROUND(AVG(Conversion_Rate) * 100, 2) AS Avg_Conversion_Pct,
  ROUND(AVG(BounceRates) * 100, 2) AS Avg_Bounce_Pct,
  ROUND(AVG(ExitRates) * 100, 2) AS Avg_Exit_Pct,
  ROUND(AVG(Generative_AI_Chatbot_Interactions), 2) AS Avg_Chatbot_Interactions
FROM `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis`
GROUP BY VisitorType
ORDER BY Avg_Conversion_Pct DESC;


-- Chatbot tier vs conversion
SELECT
  Chatbot_Tier,
  COUNT(*) AS Sessions,
  ROUND(AVG(Conversion_Rate) * 100, 2) AS Avg_Conversion_Pct,
  ROUND(AVG(BounceRates) * 100, 2) AS Avg_Bounce_Pct,
  ROUND(AVG(ExitRates) * 100, 2) AS Avg_Exit_Pct,
  ROUND(AVG(Chatbot_Time_Seconds), 1) AS Avg_Time_On_Chatbot_Sec
FROM `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis`
GROUP BY Chatbot_Tier
ORDER BY
  CASE Chatbot_Tier
    WHEN 'No Chatbot' THEN 1
    WHEN 'Low (1-25)' THEN 2
    WHEN 'Medium (26-60)' THEN 3
    WHEN 'High (61-100)' THEN 4
  END;


-- Device x Visitor type conversion matrix
SELECT
  Device_Type,
  VisitorType,
  COUNT(*) AS Sessions,
  ROUND(AVG(Conversion_Rate) * 100, 2) AS Avg_Conversion_Pct,
  ROUND(AVG(BounceRates) * 100, 2) AS Avg_Bounce_Pct
FROM `your-project-id.MIS384_A3.S2_Digital_Performance_Analysis`
WHERE VisitorType != 'Other'
GROUP BY Device_Type, VisitorType
ORDER BY Device_Type, VisitorType;
