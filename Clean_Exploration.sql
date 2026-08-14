SELECT *
FROM subscriptions

SELECT *
FROM monthly_revenue

SELECT DISTINCT company_size
FROM subscriptions
ORDER BY company_size;

-- Updating employee ranges that were automatically converted to dates in excel
UPDATE subscriptions
SET company_size = '1-10'
WHERE company_size = '10-Jan';

UPDATE subscriptions
SET company_size = '11-50'
WHERE company_size = 'Nov-50';

SELECT company_size, COUNT(*) AS Customers
FROM subscriptions
GROUP BY company_size
ORDER BY company_size;

-- renaming 'plan' column
EXEC sp_rename 'subscriptions.plan', 'subscription_plan', 'COLUMN';





