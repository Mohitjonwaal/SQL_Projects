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
SELECT Customer_ID, COUNT(Customer_ID) as count
FROM dbo.churn2
GROUP BY Customer_ID
HAVING count(Customer_ID) > 1;
```

---

### 2. Data Cleaning & Preparation

- **Null Value Handling**: Retained null values in certain columns to capture the nuances of subscription preferences.
- **Duplicate Removal**: Ensured no duplicate entries in the dataset.
- **Record Count**: Verified the total number of customers.

```sql
-- Find total number of customers
SELECT COUNT(DISTINCT Customer_ID) AS customer_count
FROM dbo.churn2;
```

---

### 3. Exploratory Data Analysis (EDA)

#### a. Revenue Loss Analysis

Maven lost 1869 customers, accounting for 17% of total revenue.

```sql
-- Calculate revenue lost to churned customers
SELECT Customer_Status, 
COUNT(Customer_ID) AS customer_count,
ROUND((SUM(Total_Revenue) * 100.0) / SUM(SUM(Total_Revenue)) OVER(), 1) AS Revenue_Percentage 
FROM dbo.churn2
GROUP BY Customer_Status;
```

#### b. Customer Tenure Analysis

42% of churned customers stayed for 6 months or less.

```sql
-- Tenure analysis for churned customers
SELECT
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END AS Tenure,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(),1) AS Churn_Percentage
FROM dbo.churn2
WHERE Customer_Status = 'Churned'
GROUP BY
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END
ORDER BY Churn_Percentage DESC;
```

#### c. High Churn Cities

San Diego had the highest churn rate (65%).

```sql
-- Identify cities with the highest churn rates
SELECT TOP 4 City,
    COUNT(Customer_ID) AS Churned,
    CEILING(COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) * 100.0 / COUNT(Customer_ID)) AS Churn_Rate
FROM dbo.churn2
GROUP BY City
HAVING COUNT(Customer_ID) > 30
AND COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) > 0
ORDER BY Churn_Rate DESC;
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

