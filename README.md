# Employee Attrition & HR Analytics Report

An HR analytics project in R that analyzes employee records to understand why people leave an organization. It answers five key questions about attrition and presents the findings as a clean, executive-style HTML report built with R Markdown.

## Problem Statement

Organizations often react to attrition only after valuable employees have already resigned. HR teams hold plenty of data (salary, satisfaction, overtime, tenure, department) but rarely analyze it in a structured way, so retention strategies end up generic instead of targeted. This project identifies which factors drive employee turnover and which departments are most at risk.

## Business Questions Answered

1. What is the overall attrition rate, and how does it vary by department and job level?
2. Do overtime or work-life balance correlate with attrition?
3. Is there a salary gap between employees who stayed and those who left?
4. Does tenure affect attrition risk (are new hires or veterans more likely to leave)?
5. Which department has the healthiest vs. most at-risk workforce?

## Tech Stack

| Purpose | Tool |
|---|---|
| Language | R |
| Data wrangling | `dplyr`, `tidyr` |
| Visualization | `ggplot2` (bar charts, boxplots, correlation heatmap) |
| Tables | `gt` / `kableExtra` |
| Reporting | R Markdown (`rmarkdown`, `knitr`) |

## Project Structure

```
hr-attrition-analysis/
├── data/
│   └── hr_data.csv               # Synthetic dataset (~1,500 employees)
├── analysis.R                    # Data cleaning and analysis script
├── hr_attrition_report.Rmd       # R Markdown report source
├── hr_attrition_report.html      # Final knitted report
├── screenshots/                  # Report screenshots
└── README.md
```

## Dataset

The dataset is synthetic, with ~1,500 employee records.

| Column | Description |
|---|---|
| `employee_id` | Unique employee ID |
| `department` | Sales, Engineering, HR, Marketing, Operations |
| `job_level` | Junior, Mid, Senior, Manager |
| `age` | Employee age |
| `tenure_years` | Years at the company |
| `monthly_salary` | Monthly salary |
| `satisfaction_score` | Job satisfaction (1-5) |
| `work_life_balance` | Work-life balance rating (1-5) |
| `overtime` | Yes / No |
| `distance_from_home_km` | Commute distance |
| `performance_rating` | Performance rating (1-5) |
| `attrition` | Whether the employee left (Yes / No) |

Built-in patterns: low satisfaction, overtime, and long commutes raise attrition, while high salary and strong performance lower it. Sales has naturally higher turnover, and noise keeps the data realistic.

## How to Run

**1. Install the required packages** (run once in R):

```r
install.packages(c("tidyverse", "gt", "kableExtra", "corrplot", "rmarkdown", "knitr"))
```

**2. Run the analysis script:**

```r
source("analysis.R")
```

**3. Knit the report:**

```r
rmarkdown::render("hr_attrition_report.Rmd")
```

Open `hr_attrition_report.html` in your browser to view the result.

## Report Contents

- **Executive Summary:** headline findings in a few sentences
- **Attrition Overview:** overall rate and breakdown by job level
- **Department Deep Dive:** attrition by department, healthiest vs. most at-risk teams
- **Drivers of Attrition:** overtime, work-life balance, and tenure effects
- **Salary & Satisfaction Analysis:** boxplots comparing employees who stayed vs. left
- **Recommendations:** retention actions based on the analysis

## Key Findings

> Fill this in after you knit the report, using your real numbers. Example format:
> - The overall attrition rate is XX%, highest in the Sales department.
> - Employees working overtime are X times more likely to leave.
> - Employees who left had lower average salary and satisfaction.
> - Attrition is highest in the first X years of tenure.

## Screenshots

> Add your report screenshots here, e.g.:
> `![Attrition by Department](screenshots/attrition_by_department.png)`
> `![Salary Boxplot](screenshots/salary_boxplot.png)`

## Recommendations

- Reduce mandatory overtime in high-attrition departments.
- Review compensation for roles where leavers earned noticeably less.
- Strengthen onboarding and support for employees in their early tenure.
- Run satisfaction check-ins in the departments with the highest risk.

## Skills Demonstrated

- Data cleaning and transformation with `dplyr`
- Exploratory data analysis and correlation analysis
- Data visualization with `ggplot2` (boxplots, heatmaps, bar charts)
- Translating data into HR and business recommendations
- Reproducible reporting with R Markdown

## Author

**sanjeev-collab-81**
GitHub: [@sanjeev-collab-81](https://github.com/sanjeev-collab-81)
