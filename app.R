library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(readr)
library(gt)
library(tidyr)
library(corrplot)

# Load data
df <- read_csv("data/hr_data.csv")

# Setup theme
theme_set(theme_minimal(base_size = 14) + 
          theme(panel.grid.minor = element_blank(),
                plot.title = element_text(face = "bold", size = 16)))

# Pre-compute overall metrics
overall_attr <- mean(df$attrition == "Yes")

# UI Define
ui <- page_sidebar(
  title = "HR Attrition Dashboard",
  sidebar = sidebar(
    title = "Controls",
    p("This dashboard provides insights into employee attrition drivers based on our latest HR dataset."),
    hr(),
    h5("Key Takeaways:"),
    tags$ul(
      tags$li("Sales has the highest turnover."),
      tags$li("Overtime is a massive driver of attrition."),
      tags$li("Low Work-Life Balance scores guarantee high turnover.")
    )
  ),
  
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Total Employees",
      value = nrow(df),
      theme_color = "primary",
      showcase = bsicons::bs_icon("people")
    ),
    value_box(
      title = "Overall Attrition Rate",
      value = paste0(round(overall_attr * 100, 1), "%"),
      theme_color = "danger",
      showcase = bsicons::bs_icon("door-open")
    )
  ),
  
  navset_card_tab(
    nav_panel("Department Health", 
              layout_columns(
                plotOutput("dept_plot"),
                gt_output("dept_table")
              )
    ),
    nav_panel("Attrition Drivers", 
              layout_columns(
                plotOutput("driver_plot_1"),
                plotOutput("driver_plot_2")
              )
    ),
    nav_panel("Salary & Satisfaction",
              layout_columns(
                plotOutput("salary_plot"),
                plotOutput("corr_plot")
              )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  output$dept_plot <- renderPlot({
    df_dept <- df %>%
      group_by(department) %>%
      summarize(attrition_rate = mean(attrition == "Yes"), .groups = "drop") %>%
      arrange(desc(attrition_rate))
    
    ggplot(df_dept, aes(x = reorder(department, attrition_rate), y = attrition_rate, fill = department)) +
      geom_col(show.legend = FALSE) +
      geom_text(aes(label = scales::percent(attrition_rate, accuracy = 1)), hjust = -0.2) +
      coord_flip() +
      scale_y_continuous(labels = scales::percent_format(), limits = c(0, max(df_dept$attrition_rate) * 1.2)) +
      scale_fill_brewer(palette = "Set2") +
      labs(title = "Attrition Rate by Department", x = "Department", y = "Attrition Rate")
  })
  
  output$dept_table <- render_gt({
    health_metrics <- df %>%
      group_by(department) %>%
      summarize(
        Headcount = n(),
        `Attrition Rate` = mean(attrition == "Yes"),
        `Avg Satisfaction` = mean(satisfaction_score),
        `Avg Work-Life Balance` = mean(work_life_balance),
        .groups = "drop"
      ) %>%
      arrange(desc(`Attrition Rate`))
    
    health_metrics %>%
      gt() %>%
      fmt_percent(columns = `Attrition Rate`, decimals = 1) %>%
      fmt_number(columns = c(`Avg Satisfaction`, `Avg Work-Life Balance`), decimals = 2) %>%
      tab_header(title = "Department Health Metrics") %>%
      data_color(
        columns = `Attrition Rate`,
        colors = scales::col_numeric(palette = c("white", "tomato"), domain = NULL)
      )
  })
  
  output$driver_plot_1 <- renderPlot({
    ggplot(df, aes(x = overtime, fill = attrition)) +
      geom_bar(position = "fill") +
      scale_y_continuous(labels = scales::percent) +
      scale_fill_manual(values = c("Yes" = "#e74c3c", "No" = "#bdc3c7")) +
      labs(title = "Impact of Overtime on Attrition", x = "Works Overtime?", y = "Proportion", fill = "Left Company?")
  })
  
  output$driver_plot_2 <- renderPlot({
    ggplot(df, aes(x = factor(work_life_balance), fill = attrition)) +
      geom_bar(position = "fill") +
      scale_y_continuous(labels = scales::percent) +
      scale_fill_manual(values = c("Yes" = "#e74c3c", "No" = "#bdc3c7")) +
      labs(title = "Work-Life Balance vs Attrition", x = "WLB Score (1-5)", y = "Proportion", fill = "Left Company?")
  })
  
  output$salary_plot <- renderPlot({
    ggplot(df, aes(x = job_level, y = monthly_salary, fill = attrition)) +
      geom_boxplot(alpha = 0.7) +
      scale_fill_manual(values = c("Yes" = "#e74c3c", "No" = "#2ecc71")) +
      labs(title = "Monthly Salary by Job Level & Attrition", x = "Job Level", y = "Monthly Salary ($)", fill = "Left Company?") +
      theme(legend.position = "bottom")
  })
  
  output$corr_plot <- renderPlot({
    num_vars <- df %>% select(age, tenure_years, monthly_salary, distance_from_home_km, performance_rating, satisfaction_score, work_life_balance)
    cor_mat <- cor(num_vars)
    
    corrplot(cor_mat, method = "color", type = "upper", 
             tl.col = "black", tl.srt = 45, 
             addCoef.col = "black", number.cex = 0.7,
             title = "Correlation Heatmap", mar = c(0,0,2,0))
  })
}

shinyApp(ui, server)
