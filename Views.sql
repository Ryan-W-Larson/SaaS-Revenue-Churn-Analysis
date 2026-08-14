-- vw_monthly_metrics
CREATE OR ALTER VIEW vw_monthly_metrics
AS

WITH Revenue AS
(
    SELECT
        month,
        total_active_customers,
        new_customers,
        churned_customers,
        monthly_churn_rate_pct,      
        total_mrr,
        avg_revenue_per_customer,
        customer_acquisition_cost,
        LAG(total_mrr)
            OVER(ORDER BY month) AS Previous_MRR
    FROM monthly_revenue
)

SELECT
    month,
    total_active_customers,
    new_customers,
    churned_customers,
    monthly_churn_rate_pct,     
    total_mrr,
    Previous_MRR,
    total_mrr - Previous_MRR AS MRR_Growth,

    ROUND(
        (
            total_mrr - Previous_MRR
        )
        /
        NULLIF(Previous_MRR, 0)
        * 100,
        2
    ) AS MRR_Growth_Pct,
    
    ROUND(
    (
        total_mrr - (new_customers * avg_revenue_per_customer)
    )
    /
    NULLIF(Previous_MRR,0)
    *100,
    2
) AS Net_Revenue_Retention_Pct,
    avg_revenue_per_customer,
    customer_acquisition_cost

FROM Revenue;
GO

-- vw_clv_analysis **
CREATE OR ALTER VIEW vw_clv_analysis
AS

WITH CustomerLifetime AS
(
    SELECT
        subscription_plan,
        monthly_revenue,
        DATEDIFF(
            DAY,
            signup_date,
            ISNULL(churn_date,GETDATE())
        )/30.44
        AS Lifetime_Months
    FROM subscriptions
),
AverageCAC AS
(
    SELECT
        AVG(customer_acquisition_cost)
        AS Avg_CAC
    FROM monthly_revenue
)
SELECT
    c.subscription_plan,
    COUNT(*) AS Customers,
    ROUND(
        AVG(monthly_revenue),
        2
    ) AS Avg_MRR,
    ROUND(
        AVG(Lifetime_Months),
        2
    ) AS Avg_Lifetime_Months,
    ROUND(
        AVG(monthly_revenue)
        *
        AVG(Lifetime_Months),
        2
    ) AS Estimated_CLV,
    ROUND(
        a.Avg_CAC,
        2
    ) AS Avg_CAC,
    ROUND(
        (
            AVG(monthly_revenue)
            *
            AVG(Lifetime_Months)
        )
        /
        a.Avg_CAC,
        2
    ) AS CLV_CAC_Ratio
FROM CustomerLifetime c
CROSS JOIN AverageCAC a
GROUP BY
    c.subscription_plan,
    a.Avg_CAC;
GO