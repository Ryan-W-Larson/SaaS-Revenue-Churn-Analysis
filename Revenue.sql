SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'monthly_revenue';

SELECT *
FROM monthly_revenue;

-- Monthly MRR
SELECT
    month,
    total_mrr
FROM monthly_revenue
ORDER BY month;

-- MRR Growth MoM 
WITH MRR AS
(
    SELECT
        month,
        total_mrr,
        LAG(total_mrr) OVER (ORDER BY month) AS Previous_Month_MRR
    FROM monthly_revenue
)
SELECT
    month,
    total_mrr,
    Previous_Month_MRR,
    total_mrr - Previous_Month_MRR AS MRR_Growth,
    ROUND(
        (total_mrr - Previous_Month_MRR)
        / NULLIF(Previous_Month_MRR, 0) * 100,
        2
    ) AS MRR_Growth_Pct
FROM MRR
ORDER BY month;

-- Active Customers
SELECT
    month,
    total_active_customers
FROM monthly_revenue
ORDER BY month;

-- Avg Rev per customer **
SELECT
    month,
    total_active_customers,
    new_customers,
    churned_customers,
    CONVERT(INT, new_customers) -
    CONVERT(INT, churned_customers) AS Net_New_Customers
FROM monthly_revenue
ORDER BY month;

-- Customer Acquisition Cost (CAC)
SELECT
    month,
    customer_acquisition_cost
FROM monthly_revenue
ORDER BY month;

-- Customer Growth **
SELECT
    month,
    total_active_customers,
    new_customers,
    churned_customers,
    new_customers - churned_customers
        AS Net_New_Customers
FROM monthly_revenue
ORDER BY month;

-- New MRR
SELECT
    YEAR(signup_date) AS signup_year,
    MONTH(signup_date) AS signup_month,
    SUM(monthly_revenue) AS New_MRR
FROM subscriptions
GROUP BY
    YEAR(signup_date),
    MONTH(signup_date)
ORDER BY
    signup_year,
    signup_month;

-- Churned MRR
SELECT
    YEAR(churn_date) AS churn_year,
    MONTH(churn_date) AS churn_month,
    SUM(monthly_revenue) AS Churned_MRR
FROM subscriptions
WHERE churned = 1
GROUP BY
    YEAR(churn_date),
    MONTH(churn_date)
ORDER BY
    churn_year,
    churn_month;

-- Avg customer lifespan (30.44 has been used as avg number of days in a month over a year 365.25/12)
WITH CustomerLifetime AS
(
    SELECT
        subscription_plan,
        DATEDIFF(DAY, signup_date, churn_date) AS Lifetime_Days
    FROM subscriptions
    WHERE churned = 1
)

SELECT
    subscription_plan,
    COUNT(*) AS Churned_Customers,
    ROUND(AVG(CAST(Lifetime_Days AS FLOAT)), 1) AS Avg_Lifetime_Days,
    ROUND(AVG(CAST(Lifetime_Days AS FLOAT)) / 30.44, 1) AS Avg_Lifetime_Months
FROM CustomerLifetime
GROUP BY subscription_plan
ORDER BY Avg_Lifetime_Months DESC;

-- Avg MRR by plan
SELECT
    subscription_plan,
    COUNT(*) AS Customers,
    ROUND(AVG(monthly_revenue), 2) AS Avg_MRR
FROM subscriptions
GROUP BY subscription_plan
ORDER BY Avg_MRR DESC;

-- CLV by plan
WITH CustomerLifetime AS
(
    SELECT
        subscription_plan,
        monthly_revenue,
        CASE
            WHEN churned = 1
                THEN DATEDIFF(DAY, signup_date, churn_date)
            ELSE DATEDIFF(DAY, signup_date, GETDATE())
        END / 30.44 AS Lifetime_Months
    FROM subscriptions
),
AverageCAC AS
(
    SELECT
        AVG(customer_acquisition_cost) AS Avg_CAC
    FROM monthly_revenue
)
SELECT
    cl.subscription_plan,
    COUNT(*) AS Customers,
    ROUND(AVG(cl.monthly_revenue),2) AS Avg_MRR,
    ROUND(AVG(cl.Lifetime_Months),2) AS Avg_Lifetime_Months,
    ROUND(
        AVG(cl.monthly_revenue) *
        AVG(cl.Lifetime_Months),
        2
    ) AS Estimated_CLV,
    ROUND(ac.Avg_CAC,2) AS Avg_CAC,
    ROUND(
        (
            AVG(cl.monthly_revenue) *
            AVG(cl.Lifetime_Months)
        ) / ac.Avg_CAC,
        2
    ) AS CLV_CAC_Ratio
FROM CustomerLifetime cl
CROSS JOIN AverageCAC ac
GROUP BY
    cl.subscription_plan,
    ac.Avg_CAC
ORDER BY
    Estimated_CLV DESC;

-- CLV:CAC Ratio
WITH CustomerLifetime AS
(
    SELECT
        subscription_plan,
        monthly_revenue,
        CASE
            WHEN churned = 1
                THEN DATEDIFF(DAY, signup_date, churn_date)
            ELSE DATEDIFF(DAY, signup_date, GETDATE())
        END / 30.44 AS Lifetime_Months
    FROM subscriptions
),
AverageCAC AS
(
    SELECT
        AVG(customer_acquisition_cost) AS Avg_CAC
    FROM monthly_revenue
)
SELECT
    cl.subscription_plan,
        ROUND(
        AVG(cl.monthly_revenue) *
        AVG(cl.Lifetime_Months),
        2
    ) AS Estimated_CLV,
    ROUND(ac.Avg_CAC,2) AS Avg_CAC,
    ROUND(
        (
            AVG(cl.monthly_revenue) *
            AVG(cl.Lifetime_Months)
        ) / ac.Avg_CAC,
        2
    ) AS CLV_CAC_Ratio
FROM CustomerLifetime cl
CROSS JOIN AverageCAC ac
GROUP BY
    cl.subscription_plan,
    ac.Avg_CAC
ORDER BY
    Estimated_CLV DESC;

