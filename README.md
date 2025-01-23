# Customer Churn Analysis Project

## Project Overview

**Project Title**: Telecom Customer Churn Analysis\
**Database**: `customer_churn_analysis`\
**Tools Used**: MySQL, Tableau

This project is designed to analyze customer churn for Maven Telecom, identifying key drivers, churn profiles, and strategies for customer retention. The dataset includes customer demographics, subscription plans, account records, and revenue details. This analysis helps businesses understand customer behavior and make data-driven decisions.

---

## Objectives

1. **Understand churn patterns**: Identify key drivers of churn and build customer profiles.
2. **Revenue Impact**: Analyze revenue lost due to churned customers.
3. **Retention Strategies**: Propose actionable steps to reduce churn and improve customer retention.

---

## Project Structure

### 1. Database Setup

- **Dataset Overview**: The dataset contains customer information, subscription plans, account activity, and churn details.
- **Duplicate Check**: Verified unique customer IDs to ensure data integrity.

```sql
-- Check for duplicate Customer IDs
SELECT customer_id, count(customer_id)
FROM customer_churn
GROUP BY customer_id
HAVING count(customer_id) > 1;
```

---

### 2. Data Cleaning & Preparation

- **Null Value Handling**: Retained null values in certain columns to capture the nuances of subscription preferences.
- **Duplicate Removal**: Ensured no duplicate entries in the dataset.
- **Record Count**: Verified the total number of customers.

```sql
-- Find total number of customers
SELECT COUNT( DISTINCT(customer_id)) AS NO_OF_CUSTOMERS
FROM customer_churn;
```

---

### 3. Exploratory Data Analysis (EDA)

#### a. Revenue Loss Analysis

Maven lost 1869 customers, accounting for 17% of total revenue.

```sql
-- Calculate revenue lost to churned customers
SELECT customer_status, 
COUNT(customer_id) AS no_of_customers,
ROUND(SUM(total_revenue)*100/SUM(SUM(total_revenue)) OVER (), 1) AS revenue_percentage
FROM customer_churn
GROUP BY customer_status;
```

#### b. Customer Tenure Analysis

42% of churned customers stayed for 6 months or less.

```sql
-- Tenure analysis for churned customers
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
```

#### c. High Churn Cities

San Diego had the highest churn rate (65%).

```sql
-- Identify cities with the highest churn rates
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
```

#### d. General and Specific Reasons for Churn

```sql
-- General Reasons for Churn
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

-- Specific Reasons for Churn
SELECT churn_Category, churn_reason,
ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churn_percentage
FROM customer_churn
WHERE 
    customer_status = 'churned'
GROUP BY churn_category, churn_reason
ORDER BY churn_percentage DESC
LIMIT 5;
```
#### e. Demographic and Behavioral Analysis

This analysis examines churn rates across various demographics and behavioral factors to uncover patterns in customer churn.

1. **Churn by Gender**:

   ```sql
   SELECT 
       gender, 
       COUNT(customer_id) AS customer,
       ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) as cust_percentage
   FROM 
       customer_churn
   WHERE 
       customer_status = 'churned'
   GROUP BY gender;
   ```

2. **Churn by Dependents**:

   ```sql
   SELECT 
       CASE WHEN no_of_dependents > 0 THEN 'Has Dependents' ELSE 'No Dependents' END AS Dependents, 
       COUNT(customer_id) AS churn_cust,
       ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churned_percentage
   FROM 
       customer_churn
   WHERE 
       customer_status = 'churned'
   GROUP BY Dependents;
   ```

3. **Churn by Referrals**:

   ```sql
   SELECT 
       CASE WHEN no_of_referrals > 0 THEN 'Yes' ELSE 'No' END AS Referrals,
       ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churned_percentage
   FROM 
       customer_churn
   WHERE 
       customer_status = 'churned'
   GROUP BY Referrals;
   ```

4. **Churn by Internet Service**:

   ```sql
   SELECT 
       internet_service, 
       COUNT(customer_id) AS churn_cust,
       ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churned_percentage
   FROM 
       customer_churn
   WHERE 
       customer_status = 'churned'
   GROUP BY internet_service;
   ```

5. **Churn by Phone Service**:

   ```sql
   SELECT 
       phone_service, 
       COUNT(customer_id) AS churn_cust,
       ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY customer_status)*100,1) AS churned_percentage
   FROM 
       customer_churn
   WHERE 
       customer_status = 'churned'
   GROUP BY phone_service;
   ```

6. **Churn by Age Group**:

   ```sql
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
   ORDER BY Churn_Percentage DESC;
   ```
---

---
#### 4. Key Churn Drivers
```sql
-- What offer did churned customers have?
SELECT 	
		offer,
        ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY CUSTOMER_STATUS)*100,1) AS churned
FROM 
	customer_churn
WHERE 
	customer_status = 'churned'
GROUP BY offer
ORDER BY churned DESC;

-- b. What Internet type did churn have?

SELECT 
		internet_type,
        COUNT(customer_id) AS churned,
         ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(PARTITION BY CUSTOMER_STATUS)*100,1) AS churn_percentage
FROM customer_churn
WHERE
	customer_status = 'Churned'
GROUP BY internet_type
ORDER BY churn_percentage DESC;

-- c. What internet type did competitor churn have?

SELECT 
		internet_type,
		churn_category,
         ROUND(COUNT(customer_id)/SUM(COUNT(customer_id)) OVER()*100,1) AS churn_percentage
FROM customer_churn
WHERE customer_status = 'churned' and
	churn_category = 'Competitor'
GROUP BY internet_type, churn_category
ORDER BY churn_percentage DESC;

-- d. Did churners have premium tech support?

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

-- e. What contract were churners on?

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

```
### 5. Are high value customers at risk?
```sql
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
```
---
### 4. Key Findings

1. **Revenue Impact**: Maven lost \~\$1.7M to competitors.
2. **Customer Demographics**: 32% of churned customers are above 60 years old, 64% are single, and 94% have no dependents.
3. **Churn Drivers**:
   - 45% of churned customers left due to competitors.
   - 66% of churned customers used Fiber Optic internet.
   - 89% were on month-to-month contracts.
   - 77% did not have premium tech support.

---

### 5. Customer Retention Strategies

1. **Loyalty Programs**: Reward customers on long-term contracts with discounts or upgrades.
2. **Customer Support**: Train support staff to improve customer service quality.
3. **Premium Tech Support**: Offer this service to all customers to enhance the after-sales experience.
4. **Improve Fiber Optic Services**: Focus on quality improvements to reduce churn.
5. **Engage High-Value Customers**: Provide personalized offers and proactive communication.

---

### 6. Visualizations & Dashboards

- **Dashboard Tools**: Tableau and Figma were used to create interactive and intuitive dashboards showcasing churn trends and retention strategies.

---

### 7. How to Use

1. **Clone the Repository**:
   ```bash
   git clone [https://github.com/Mohitjonwaal/Telecome_Customer_Churn_Project.git]
   ```
2. **Set Up the Database**: Import the dataset into your SQL environment and execute the provided SQL script.
3. **Run Queries**: Execute the SQL queries included in the `customer_churn_analysis.sql` file to analyze the data.

---

## Contact

For questions or suggestions, please reach out:

- **Email**: [mohitjonwaal@gmail.com](mohitjonwaal@gmail.com)
- **GitHub**: [Mohit Jonwaal](https://github.com/Mohitjonwaal)
- **Linkedin**: [Mohit Jonwaal](https://www.linkedin.com/in/jonwaal-mohit/)


