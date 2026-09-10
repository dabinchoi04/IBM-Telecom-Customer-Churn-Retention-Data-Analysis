
-- ============================================================
-- IBM Telecom Customer Churn & Retention
-- SQL Business Analysis
-- ============================================================
-- Source table: telco_churn
--
-- Churn definition:
--   Churn Value = 1  -> Churned
--   Churn Value = 0  -> Retained
--
-- This SQL file focuses on descriptive business analysis.
-- Churn Reason is used only for historical churn analysis and
-- should NOT be used later as a predictive model feature.
-- ============================================================


-- 1. What are the overall churn KPIs?
SELECT
    COUNT(*) AS total_customers,
    SUM("Churn Value") AS churned_customers,
    COUNT(*) - SUM("Churn Value") AS retained_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges,
    ROUND(AVG("Total Charges"), 2) AS avg_total_charges,
    ROUND(AVG(CLTV), 2) AS avg_cltv
FROM telco_churn;


-- 2. How does churn vary by contract type?
SELECT
    Contract,
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges,
    ROUND(AVG(CLTV), 2) AS avg_cltv
FROM telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- 3. How does churn vary across tenure groups?
WITH tenure_groups AS (
    SELECT
        *,
        CASE
            WHEN "Tenure Months" <= 6 THEN '0-6 months'
            WHEN "Tenure Months" <= 12 THEN '7-12 months'
            WHEN "Tenure Months" <= 24 THEN '13-24 months'
            WHEN "Tenure Months" <= 48 THEN '25-48 months'
            ELSE '49+ months'
        END AS tenure_group
    FROM telco_churn
)
SELECT
    tenure_group,
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges,
    ROUND(AVG(CLTV), 2) AS avg_cltv
FROM tenure_groups
GROUP BY tenure_group
ORDER BY
    CASE tenure_group
        WHEN '0-6 months' THEN 1
        WHEN '7-12 months' THEN 2
        WHEN '13-24 months' THEN 3
        WHEN '25-48 months' THEN 4
        WHEN '49+ months' THEN 5
    END;


-- 4. How does churn vary by internet service?
SELECT
    "Internet Service",
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY "Internet Service"
ORDER BY churn_rate_pct DESC;


-- 5. Which payment methods have the highest churn?
SELECT
    "Payment Method",
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY "Payment Method"
ORDER BY churn_rate_pct DESC;


-- 6. How do monthly charges differ between churned and retained customers?
SELECT
    CASE
        WHEN "Churn Value" = 1 THEN 'Churned'
        ELSE 'Retained'
    END AS customer_status,
    COUNT(*) AS customers,
    ROUND(AVG("Monthly Charges"), 2) AS avg_monthly_charges,
    ROUND(AVG("Total Charges"), 2) AS avg_total_charges,
    ROUND(AVG("Tenure Months"), 2) AS avg_tenure_months,
    ROUND(AVG(CLTV), 2) AS avg_cltv
FROM telco_churn
GROUP BY "Churn Value"
ORDER BY "Churn Value" DESC;


-- 7. How does churn vary by paperless billing?
SELECT
    "Paperless Billing",
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct
FROM telco_churn
GROUP BY "Paperless Billing"
ORDER BY churn_rate_pct DESC;


-- 8. How does churn vary across selected demographic groups?
SELECT
    "Senior Citizen",
    Partner,
    Dependents,
    COUNT(*) AS customers,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(CLTV), 2) AS avg_cltv
FROM telco_churn
GROUP BY "Senior Citizen", Partner, Dependents
HAVING COUNT(*) >= 30
ORDER BY churn_rate_pct DESC;


-- 9. Which service features are associated with different churn rates?
WITH service_long AS (
    SELECT 'Online Security' AS service, "Online Security" AS service_status, "Churn Value" AS churn_value
    FROM telco_churn

    UNION ALL
    SELECT 'Online Backup', "Online Backup", "Churn Value"
    FROM telco_churn

    UNION ALL
    SELECT 'Device Protection', "Device Protection", "Churn Value"
    FROM telco_churn

    UNION ALL
    SELECT 'Tech Support', "Tech Support", "Churn Value"
    FROM telco_churn

    UNION ALL
    SELECT 'Streaming TV', "Streaming TV", "Churn Value"
    FROM telco_churn

    UNION ALL
    SELECT 'Streaming Movies', "Streaming Movies", "Churn Value"
    FROM telco_churn
)
SELECT
    service,
    service_status,
    COUNT(*) AS customers,
    SUM(churn_value) AS churned_customers,
    ROUND(100.0 * SUM(churn_value) / COUNT(*), 2) AS churn_rate_pct
FROM service_long
GROUP BY service, service_status
ORDER BY service, churn_rate_pct DESC;


-- 10. How does churn differ across CLTV quartiles?
WITH cltv_ranked AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY CLTV) AS cltv_quartile
    FROM telco_churn
)
SELECT
    cltv_quartile,
    COUNT(*) AS customers,
    MIN(CLTV) AS min_cltv,
    MAX(CLTV) AS max_cltv,
    ROUND(AVG(CLTV), 2) AS avg_cltv,
    SUM("Churn Value") AS churned_customers,
    ROUND(100.0 * SUM("Churn Value") / COUNT(*), 2) AS churn_rate_pct
FROM cltv_ranked
GROUP BY cltv_quartile
ORDER BY cltv_quartile;


-- 11. What are the most common historical churn reasons?
SELECT
    "Churn Reason",
    COUNT(*) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM telco_churn WHERE "Churn Value" = 1),
        2
    ) AS pct_of_churned_customers
FROM telco_churn
WHERE "Churn Value" = 1
  AND "Churn Reason" IS NOT NULL
GROUP BY "Churn Reason"
ORDER BY churned_customers DESC;


-- 12. What are the most common churn-reason categories?
WITH categorized_reasons AS (
    SELECT
        CASE
            WHEN "Churn Reason" LIKE 'Competitor%' THEN 'Competitor'
            WHEN "Churn Reason" IN (
                'Attitude of support person',
                'Attitude of service provider',
                'Lack of self-service on Website'
            ) THEN 'Customer Service'
            WHEN "Churn Reason" IN (
                'Network reliability',
                'Product dissatisfaction',
                'Service dissatisfaction',
                'Limited range of services',
                'Poor expertise of online support',
                'Poor expertise of phone support'
            ) THEN 'Product / Service'
            WHEN "Churn Reason" IN (
                'Price too high',
                'Extra data charges',
                'Long distance charges'
            ) THEN 'Price / Charges'
            WHEN "Churn Reason" IN (
                'Moved',
                'Deceased'
            ) THEN 'External / Unavoidable'
            ELSE 'Other'
        END AS churn_reason_category
    FROM telco_churn
    WHERE "Churn Value" = 1
      AND "Churn Reason" IS NOT NULL
)
SELECT
    churn_reason_category,
    COUNT(*) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM categorized_reasons),
        2
    ) AS pct_of_churned_customers
FROM categorized_reasons
GROUP BY churn_reason_category
ORDER BY churned_customers DESC;


-- 13. Which historical churned customers represented the highest lost CLTV?
SELECT
    CustomerID,
    City,
    Contract,
    "Tenure Months",
    "Monthly Charges",
    "Total Charges",
    CLTV,
    "Churn Reason"
FROM telco_churn
WHERE "Churn Value" = 1
ORDER BY CLTV DESC
LIMIT 20;
