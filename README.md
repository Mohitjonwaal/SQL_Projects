# SQL_Projects
# Customer Churn Analysis Project

## Project Overview

**Project Title**: Telecom Customer Churn Analysis\
**Database**: `dbo.churn2`\
**Tools Used**: SQL (Azure Data Studio), Tableau, Figma

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
   git clone https://github.com/your-username/telecom-churn-analysis.git
   ```
2. **Set Up the Database**: Import the dataset into your SQL environment and execute the provided SQL script.
3. **Run Queries**: Execute the SQL queries included in the `customer_churn_analysis.sql` file to analyze the data.

---

## Contact

For questions or suggestions, please reach out:

- **Email**: [your.email@example.com](mailto\:your.email@example.com)
- **GitHub**: [your-username](https://github.com/your-username)

