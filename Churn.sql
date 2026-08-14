-- Overall Churn Rate
WITH CustomerChurn AS
(
    SELECT
        customer_id,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    COUNT(*) - SUM(Churn_Flag) AS Active_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn;

-- Churn by Plan
WITH CustomerChurn AS
(
    SELECT
        subscription_plan,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    subscription_plan,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn
GROUP BY subscription_plan
ORDER BY Churn_Rate_Percent DESC;

-- Churn by Billing Cycle
WITH CustomerChurn AS
(
    SELECT
        billing_cycle,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    billing_cycle,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn
GROUP BY billing_cycle
ORDER BY Churn_Rate_Percent DESC;

-- Churn by Company Size
WITH CustomerChurn AS
(
    SELECT
        company_size,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    company_size,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn
GROUP BY company_size
ORDER BY Churn_Rate_Percent DESC;

-- Monthly Churn Trend
WITH CustomerChurn AS
(
    SELECT
        churn_date,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    YEAR(churn_date) AS Churn_Year,
    MONTH(churn_date) AS Churn_Month,
    SUM(Churn_Flag) AS Customers_Churned
FROM CustomerChurn
GROUP BY
    YEAR(churn_date),
    MONTH(churn_date)
ORDER BY
    Churn_Year,
    Churn_Month;

-- Quarterly Churn
WITH CustomerChurn AS
(
    SELECT
        churn_date,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    YEAR(churn_date) AS Churn_Year,
    DATEPART(QUARTER, churn_date) AS Quarter,
    SUM(Churn_Flag) AS Customers_Churned
FROM CustomerChurn
GROUP BY
    YEAR(churn_date),
    DATEPART(QUARTER, churn_date)
ORDER BY
    Churn_Year,
    Quarter;

-- Yearly Churn
WITH CustomerChurn AS
(
    SELECT
        churn_date,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    YEAR(churn_date) AS Churn_Year,
    SUM(Churn_Flag) AS Customers_Churned
FROM CustomerChurn
GROUP BY YEAR(churn_date)
ORDER BY Churn_Year;

-- Churn by Industry
WITH CustomerChurn AS
(
    SELECT
        industry,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    industry,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn
GROUP BY industry
ORDER BY Churn_Rate_Percent DESC;

-- Churn by Acquisition Channel
WITH CustomerChurn AS
(
    SELECT
        acquisition_channel,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    acquisition_channel,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag) / COUNT(*),
        2
    ) AS Churn_Rate_Percent
FROM CustomerChurn
GROUP BY acquisition_channel
ORDER BY Churn_Rate_Percent DESC;

-- Churn Reason
WITH CustomerChurn AS
(
    SELECT
        churn_reason,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    churn_reason,
    COUNT(*) AS Total_Customers,
    SUM(Churn_Flag) AS Churned_Customers
FROM CustomerChurn
WHERE Churn_Flag = 1
GROUP BY churn_reason
ORDER BY Churned_Customers DESC;

-- NPS analysis
WITH CustomerChurn AS
(
    SELECT
        nps_score,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    Churn_Flag,
    AVG(nps_score) AS Average_NPS,
    MIN(nps_score) AS Lowest_NPS,
    MAX(nps_score) AS Highest_NPS
FROM CustomerChurn
GROUP BY Churn_Flag;

-- Support Tickets
WITH CustomerChurn AS
(
    SELECT
        support_tickets_12mo,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    Churn_Flag,
    AVG(support_tickets_12mo) AS Avg_Tickets,
    MAX(support_tickets_12mo) AS Max_Tickets
FROM CustomerChurn
GROUP BY Churn_Flag;

-- WITH CustomerChurn AS
(
    SELECT
        feature_usage_percent,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    Churn_Flag,
    AVG(feature_usage_percent) AS Avg_Feature_Usage
FROM CustomerChurn
GROUP BY Churn_Flag;

-- Upgraded vs not upgraded
WITH CustomerChurn AS
(
    SELECT
        upgraded,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    CASE
        WHEN upgraded = 1 THEN 'Upgraded'
        ELSE 'Not Upgraded'
    END AS Upgrade_Status,
    COUNT(*) AS Customers,
    SUM(Churn_Flag) AS Churned_Customers,
    ROUND(
        100.0 * SUM(Churn_Flag)/COUNT(*),
        2
    ) AS Churn_Rate
FROM CustomerChurn
GROUP BY upgraded
ORDER BY Churn_Rate DESC;

-- Churn Reasons by Subscription Plan
WITH CustomerMetrics AS
(
    SELECT
        subscription_plan,
        churn_reason,
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag
    FROM subscriptions
)

SELECT
    subscription_plan,
    churn_reason,
    COUNT(*) AS Customers
FROM CustomerMetrics
WHERE Churn_Flag = 1
GROUP BY
    subscription_plan,
    churn_reason
ORDER BY
    subscription_plan,
    Customers DESC;

-- Customer health metric analysis
WITH CustomerMetrics AS
(
    SELECT
        CASE WHEN churned = 1 THEN 1 ELSE 0 END AS Churn_Flag,
        monthly_revenue,
        seats,
        support_tickets_12mo,
        nps_score,
        feature_usage_pct
    FROM subscriptions
)
SELECT
    CASE
        WHEN Churn_Flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS Customer_Status,
    COUNT(*) AS Customers,
    AVG(monthly_revenue) AS Avg_MRR,
    AVG(seats) AS Avg_Seats,
    AVG(support_tickets_12mo) AS Avg_Support_Tickets,
    AVG(nps_score) AS Avg_NPS,
    AVG(feature_usage_pct) AS Avg_Feature_Usage
FROM CustomerMetrics
GROUP BY Churn_Flag;