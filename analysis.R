# ==============================================================================
# Employee Attrition Analysis
# ==============================================================================
# This script generates a synthetic HR dataset and performs exploratory data 
# analysis to identify drivers of attrition.
# ==============================================================================

# Load necessary libraries
# We use dplyr for data manipulation, tidyr for reshaping, and readr for I/O.
library(dplyr)
library(tidyr)
library(readr)

# Set seed for reproducibility so we get the same random data every time
set.seed(42)

# 1. GENERATE SYNTHETIC DATA ===================================================

n_employees <- 1500

# Base variables
employee_id <- 1:n_employees
department <- sample(c("Sales", "Engineering", "HR", "Marketing", "Operations"), 
                     n_employees, replace = TRUE, 
                     prob = c(0.25, 0.35, 0.10, 0.10, 0.20))
job_level <- sample(c("Junior", "Mid", "Senior", "Manager"), 
                    n_employees, replace = TRUE, 
                    prob = c(0.40, 0.35, 0.15, 0.10))

# Create a base dataframe
df <- data.frame(
  employee_id = employee_id,
  department = department,
  job_level = job_level
)

# Function to add correlated variables based on rules
df <- df %>%
  mutate(
    # Age based on job level
    age = case_when(
      job_level == "Junior" ~ round(rnorm(n(), 25, 3)),
      job_level == "Mid" ~ round(rnorm(n(), 32, 4)),
      job_level == "Senior" ~ round(rnorm(n(), 40, 5)),
      job_level == "Manager" ~ round(rnorm(n(), 45, 6))
    ),
    
    # Tenure based on age and job level
    tenure_years = case_when(
      job_level == "Junior" ~ pmax(0, round(rnorm(n(), 2, 1))),
      job_level == "Mid" ~ pmax(2, round(rnorm(n(), 5, 2))),
      job_level == "Senior" ~ pmax(5, round(rnorm(n(), 10, 3))),
      job_level == "Manager" ~ pmax(8, round(rnorm(n(), 12, 4)))
    ),
    
    # Salary based on job level and department (adding some noise)
    monthly_salary = case_when(
      job_level == "Junior" ~ 4000 + rnorm(n(), 500, 200),
      job_level == "Mid" ~ 6500 + rnorm(n(), 800, 300),
      job_level == "Senior" ~ 9500 + rnorm(n(), 1000, 400),
      job_level == "Manager" ~ 12500 + rnorm(n(), 1500, 500)
    ),
    
    # Engineers and Sales get slightly higher baseline pay
    monthly_salary = ifelse(department %in% c("Engineering", "Sales"), 
                            monthly_salary * 1.1, monthly_salary),
    monthly_salary = round(monthly_salary),
    
    # Random distance from home (skewed right)
    distance_from_home_km = round(rexp(n(), rate = 0.1) + 1),
    
    # Performance rating (1 to 5)
    performance_rating = sample(1:5, n(), replace = TRUE, prob = c(0.05, 0.10, 0.50, 0.25, 0.10)),
    
    # Overtime probability varies slightly by department
    overtime_prob = case_when(
      department == "Sales" ~ 0.4,
      department == "Engineering" ~ 0.35,
      department == "Operations" ~ 0.3,
      TRUE ~ 0.2
    ),
    overtime = ifelse(runif(n()) < overtime_prob, "Yes", "No"),
    
    # Satisfaction score (1 to 5), negatively impacted by overtime and commute
    satisfaction_score = round(3 + (performance_rating * 0.2) - 
                                 (ifelse(overtime == "Yes", 0.8, 0)) - 
                                 (distance_from_home_km * 0.02) + 
                                 rnorm(n(), 0, 0.5)),
    satisfaction_score = pmin(pmax(satisfaction_score, 1), 5), # clamp to 1-5
    
    # Work-life balance (1 to 5)
    work_life_balance = round(4 - (ifelse(overtime == "Yes", 1.5, 0)) + rnorm(n(), 0, 0.5)),
    work_life_balance = pmin(pmax(work_life_balance, 1), 5) # clamp to 1-5
  )

# Calculate Attrition probability
# Higher chance if: low satisfaction, high overtime, high commute. 
# Lower chance if: high salary for job level, high performance.
# Baseline higher in Sales.
df <- df %>%
  mutate(
    attrition_score = 
      (5 - satisfaction_score) * 1.5 + 
      (5 - work_life_balance) * 1.0 + 
      ifelse(overtime == "Yes", 2, 0) + 
      (distance_from_home_km * 0.05) - 
      (monthly_salary / 5000) - 
      (performance_rating * 0.5) +
      ifelse(department == "Sales", 1.5, 0) +
      rnorm(n(), 0, 2), # Random noise
    
    # Convert score to Yes/No (top ~20% leave)
    attrition_prob = ecdf(attrition_score)(attrition_score),
    attrition = ifelse(attrition_prob > 0.80, "Yes", "No")
  ) %>%
  # Remove helper columns
  select(-overtime_prob, -attrition_score, -attrition_prob)

# Ensure the data directory exists
if (!dir.exists("data")) {
  dir.create("data")
}

# Save dataset to CSV
write_csv(df, "data/hr_data.csv")
cat("Data generated successfully and saved to 'data/hr_data.csv'\n")

# 2. EXPLORATORY DATA ANALYSIS =================================================

cat("\n--- Exploratory Data Analysis ---\n\n")

# Question 1: What's the overall attrition rate, and how does it vary by department and job level?
overall_attrition <- mean(df$attrition == "Yes")
cat(sprintf("Overall Attrition Rate: %.1f%%\n", overall_attrition * 100))

dept_attrition <- df %>%
  group_by(department) %>%
  summarize(attrition_rate = mean(attrition == "Yes") * 100, .groups = "drop") %>%
  arrange(desc(attrition_rate))
cat("\nAttrition by Department (%):\n")
print(dept_attrition)

# Question 2: Does overtime or work-life balance correlate with attrition?
ot_attrition <- df %>%
  group_by(overtime) %>%
  summarize(attrition_rate = mean(attrition == "Yes") * 100, .groups = "drop")
cat("\nAttrition by Overtime Status (%):\n")
print(ot_attrition)

wlb_attrition <- df %>%
  group_by(work_life_balance) %>%
  summarize(attrition_rate = mean(attrition == "Yes") * 100, .groups = "drop")
cat("\nAttrition by Work-Life Balance Score (1-5):\n")
print(wlb_attrition)

# Question 3: Is there a salary gap between employees who stayed vs. left?
salary_gap <- df %>%
  group_by(job_level, attrition) %>%
  summarize(avg_salary = mean(monthly_salary), .groups = "drop") %>%
  pivot_wider(names_from = attrition, values_from = avg_salary, names_prefix = "Stayed_") %>%
  rename(Stayed = Stayed_No, Left = Stayed_Yes) %>%
  mutate(Gap = Stayed - Left)
cat("\nSalary Gap by Job Level (Stayed vs. Left):\n")
print(salary_gap)

# Question 4: Does tenure affect attrition risk?
tenure_attrition <- df %>%
  mutate(tenure_group = case_when(
    tenure_years < 2 ~ "< 2 Years (New Hires)",
    tenure_years <= 5 ~ "2-5 Years",
    tenure_years <= 10 ~ "6-10 Years",
    TRUE ~ "10+ Years (Veterans)"
  )) %>%
  group_by(tenure_group) %>%
  summarize(attrition_rate = mean(attrition == "Yes") * 100, n = n(), .groups = "drop")
cat("\nAttrition by Tenure Group (%):\n")
print(tenure_attrition)

# Question 5: Which department has the healthiest vs. most at-risk workforce?
# We define "health" via high satisfaction, low attrition, and good work-life balance
health_metrics <- df %>%
  group_by(department) %>%
  summarize(
    attrition_rate = mean(attrition == "Yes") * 100,
    avg_satisfaction = mean(satisfaction_score),
    avg_wlb = mean(work_life_balance),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_satisfaction))
cat("\nDepartment Health Metrics:\n")
print(health_metrics)

cat("\nAnalysis script completed.\n")
