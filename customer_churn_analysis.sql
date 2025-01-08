use customer_churn_analysis;
-- Problem statement: Maven Telecome company is loosing its customers so I hvae to find the solution
-- What are the key drivers of churn?
-- Is the company losing high value customers? If so, how can they retain them?
-- What is the ideal profile of a churned customer?
-- What steps can Maven Telecom take to reduce churn?

-- check for duplicates --

SELECT customer_id, count(customer_id)
FROM customer_churn
GROUP BY customer_id
HAVING count(customer_id) > 1;

-- checking for no. of distinct customers --

SELECT COUNT( DISTINCT(customer_id)) AS NO_OF_CUSTOMERS
FROM customer_churn;

-- How much Revenue does the company loose to churned customer;

SELECT customer_status, 
COUNT(customer_id) AS no_of_customers,
ROUND(SUM(total_revenue)*100/SUM(SUM(total_revenue)) OVER (), 1) AS revenue_percentage
FROM customer_churn
GROUP BY customer_status;

-- what is the tenure of churned customers

SELECT 
	CASE WHEN tenure_in_months <= 6 THEN '6 Months'
    WHEN tenure_in_months <= 12 THEN '1 Year'
    WHEN tenure_in_months <= 24 THEN '2 Year'
    ELSE '> 2 Years'
    END AS Tenure,
ROUND(COUNT(customer_id)*100/SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM customer_churn 
WHERE customer_status = 'Churned'
GROUP BY 
		CASE WHEN tenure_in_months <= 6 THEN '6 Months'
    WHEN tenure_in_months <= 12 THEN '1 Year'
    WHEN tenure_in_months <= 24 THEN '2 Year'
    ELSE '> 2 Years'
    END
ORDER BY churn_percentage DESC;

-- Which cities had the highest churn rates? --


SELECT 
		city,
        COUNT(customer_id) AS churned,
        ceiling(COUNT(CASE WHEN customer_status = 'churned' THEN customer_id ELSE NULL END)*100/ COUNT(customer_id)) AS churn_rate
FROM 
	customer_churn
GROUP BY city
HAVING COUNT(customer_id)>30 AND 
COUNT(CASE WHEN customer_status = 'churned' THEN customer_id ELSE NULL END) >0
ORDER BY churn_rate DESC
LIMIT 5;

-- What are the General reasons for churn --
select * from customer_churn;

SELECT 
    churn_category,
    ROUND(SUM(total_revenue), 0) AS churned_revenue,
    CEILING(COUNT(Customer_ID) / SUM(COUNT(Customer_ID)) OVER (PARTITION BY customer_status)*100) AS Churn_Percentage
FROM 
    customer_churn
WHERE 
    customer_status = 'Churned'
GROUP BY churn_category
ORDER BY churn_percentage DESC;


-- Specific reason for churn --

SELECT churn_Category, churn_reason,
ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churn_percentage
FROM customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY churn_category, churn_reason
ORDER BY churn_percentage DESC
LIMIT 5;

-- KEY CHURN DRIVERS
-- What offer did churned customer have? --


SELECT 	
		offer,
        ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY CUSTOMER_STATUS)*100,1) AS churned
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY offer
ORDER BY churned DESC;

-- What Internet type did churned have --

SELECT 
		internet_type,
        COUNT(customer_id) AS churned,
         ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY CUSTOMER_STATUS)*100,1) AS churn_percentage
FROM customer_churn
WHERE
	customer_status = 'Churned'
GROUP BY internet_type
ORDER BY churn_percentage DESC;

-- what internet type did competitor churn have--

SELECT 
		internet_type,
		churn_category,
         ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()*100,1) AS churn_percentage
FROM customer_churn
WHERE customer_status = 'churned' and
	churn_category = 'Competitor'
GROUP BY internet_type, churn_category
ORDER BY churn_percentage DESC;

-- Did churners have premium tech support --
select* from customer_churn;

SELECT
		premium_tech_support,
        COUNT(customer_id) as churned,
        ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()*100,1) AS churn_percentage
FROM 	
		customer_churn
WHERE 	
	customer_status = 'churned'
GROUP BY premium_tech_support
ORDER BY churned DESC, churn_percentage DESC;

-- What contract were churner on?

select* from customer_churn;

SELECT 
	contract,
    COUNT(customer_id) as churned,
	ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()*100,1) AS churn_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY contract
ORDER BY churned DESC, churn_percentage DESC;

-- Are high value customers at risk?

SELECT 
	CASE WHEN (num_conditions >= 3) THEN 'High Risk'
    WHEN num_conditions = 2 THEN 'Medium Risk'
    ELSE 'Low Risk'
    END AS risk_level,
    COUNT(customer_id) AS num_customers,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()*100,1) AS cust_percentage,
    num_conditions
FROM
	(SELECT customer_id,
			SUM( CASE WHEN offer = 'offer E' OR offer = 'None' THEN 1 ELSE 0 END) +
            SUM(CASE WHEN internet_type = 'fiber optic' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN premium_tech_support = 'No' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN contract = 'Month-to-Month' THEN 1 ELSE 0 END) AS num_conditions
	FROM 
		customer_churn
	WHERE 
		tenure_in_months > 6 AND
        monthly_charges > 70 AND
        customer_status = 'Stayed' AND
        no_of_referrals >0 
	GROUP BY 
			customer_id
	HAVING
			SUM( CASE WHEN offer = 'offer E' OR offer = 'None' THEN 1 ELSE 0 END) +
            SUM(CASE WHEN internet_type = 'fiber optic' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN premium_tech_support = 'No' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN contract = 'Month-to-Month' THEN 1 ELSE 0 END) >=1 
            ) AS subqurey
GROUP BY 
risk_level, num_conditions;

-- churned categroy by gender --
SELECT * FROM customer_churn;

SELECT 
	gender, 
    COUNT(customer_id) AS customer,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as cust_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY gender;

-- churned category on the basis of no_of_dependents --


SELECT 
	 CASE WHEN no_of_dependents> 0 THEN 'Has Dependents' Else 'No Dependents' 
     END AS Dependents, 
    COUNT(customer_id) AS churn_cust,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as churned_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY dependents;

-- did the churned customer give referrals

SELECT 
	CASE WHEN no_of_referrals >0 THEN 'Yes' ELSE 'No'
    END AS Referrals,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as churned_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY Referrals;

-- do churner have internet service --
select * from customer_churn;

SELECT 
	internet_service, 
    COUNT(customer_id) AS churn_cust,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as churned_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY internet_service;

-- do churner have phone service --
SELECT 
	phone_service, 
    COUNT(customer_id) AS churn_cust,
    ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as churned_percentage
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY phone_service;


-- HOW old were churners?
SELECT  
    CASE
        WHEN Age <= 30 THEN '19 - 30 yrs'
        WHEN Age <= 40 THEN '31 - 40 yrs'
        WHEN Age <= 50 THEN '41 - 50 yrs'
        WHEN Age <= 60 THEN '51 - 60 yrs'
        ELSE  '> 60 yrs'
    END AS Age,
    ROUND(COUNT(Customer_ID) * 100 / SUM(COUNT(Customer_ID)) OVER(), 1) AS Churn_Percentage
FROM 
   customer_Churn
WHERE
    Customer_Status = 'Churned'
GROUP BY
    CASE
        WHEN Age <= 30 THEN '19 - 30 yrs'
        WHEN Age <= 40 THEN '31 - 40 yrs'
        WHEN Age <= 50 THEN '41 - 50 yrs'
        WHEN Age <= 60 THEN '51 - 60 yrs'
        ELSE  '> 60 yrs'
    END
ORDER BY
Churn_Percentage DESC;	