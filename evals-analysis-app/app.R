# Load packages used by the app
library(shiny)
library(bslib)
library(thematic)
library(tidyverse)
library(gitlink)

source("setup.R")

# Set the default theme for ggplot2 plots
ggplot2::theme_set(ggplot2::theme_minimal())

# Apply the CSS used by the Shiny app to the ggplot2 plots
thematic_shiny()


# Define the Shiny UI layout
ui <- page_sidebar(

  # Add github link
  ribbon_css("https://github.com/rstudio/demo-co/tree/main/evals-analysis-app"),

  # Set CSS theme
  theme = bs_theme(bootswatch = "darkly",
                   bg = "#222222",
                   fg = "#86C7ED",
                   success ="#86C7ED"),

  # Add title
  title = "Effectiveness of DemoCo App Free Trial by Customer Segment",

  # Add sidebar elements
  sidebar = sidebar(title = "Select a segment of data to view",
                    class ="bg-secondary",
                    selectInput("industry", "Select industries", choices = industries, selected = "", multiple  = TRUE),
                    selectInput("propensity", "Select propensities to buy", choices = propensities, selected = "", multiple  = TRUE),
                    selectInput("contract", "Select contract types", choices = contracts, selected = "", multiple  = TRUE),
                    "This app compares the effectiveness of two types of free trials, A (30-days) and B (100-days), at converting users into customers.",
                    tags$img(src = "logo.png", width = "100%", height = "auto")),

  # Layout non-sidebar elements
  layout_columns(card(card_header("Conversions over time"),
                      plotOutput("line")),
                 card(card_header("Conversion rates"),
                      plotOutput("bar")),
                 value_box(title = "Recommended Trial",
                           value = textOutput("recommended_eval"),
                           theme_color = "secondary"),
                 value_box(title = "Customers",
                           value = textOutput("number_of_customers"),
                           theme_color = "secondary"),
                 value_box(title = "Avg Spend",
                           value = textOutput("average_spend"),
                           theme_color = "secondary"),
                 card(card_header("Conversion rates by subgroup"),
                      tableOutput("table")),
                 col_widths = c(8, 4, 4, 4, 4, 12),
                 row_heights = c(4, 1.5, 3))
)

# Define the Shiny server function
server <- function(input, output) {

  # Provide default values for industry, propensity, and contract selections
  selected_industries <- reactive({
    if (is.null(input$industry)) industries else input$industry
  })

  selected_propensities <- reactive({
    if (is.null(input$propensity)) propensities else input$propensity
  })

  selected_contracts <- reactive({
    if (is.null(input$contract)) contracts else input$contract
  })

  # Filter data against selections
  filtered_expansions <- reactive({
    expansions |>
      filter(industry %in% selected_industries(),
             propensity %in% selected_propensities(),
             contract %in% selected_contracts())
  })

  # Compute conversions by month
  conversions <- reactive({
    filtered_expansions() |>
      mutate(date = floor_date(date, unit = "month")) |>
      group_by(date, evaluation) |>
      summarize(n = sum(outcome == "Won")) |>
      ungroup()
  })

  # Retrieve conversion rates for selected groups
  groups <- reactive({
    expansion_groups |>
      filter(industry %in% selected_industries(),
             propensity %in% selected_propensities(),
             contract %in% selected_contracts())
  })

  # Render text for recommended trial
  output$recommended_eval <- renderText({
    recommendation <-
      filtered_expansions() |>
      group_by(evaluation) |>
      summarise(rate = mean(outcome == "Won")) |>
      filter(rate == max(rate)) |>
      pull(evaluation)

    as.character(recommendation[1])
  })

  # Render text for number of customers
  output$number_of_customers <- renderText({
    sum(filtered_expansions()$outcome == "Won") |>
      format(big.mark = ",")
  })

  # Render text for average spend
  output$average_spend <- renderText({
      x <-
        filtered_expansions() |>
        filter(outcome == "Won") |>
        summarise(spend = round(mean(amount))) |>
        pull(spend)

      str_glue("${x}")
  })

  # Render line plot for conversions over time
  output$line <- renderPlot({
    ggplot(conversions(), aes(x = date, y = n, color = evaluation)) +
      geom_line() +
      theme(axis.title = element_blank()) +
      labs(color = "Trial Type")
  })

  # Render bar plot for conversion rates by subgroup
  output$bar <- renderPlot({
    groups() |>
      group_by(evaluation) |>
      summarise(rate = round(sum(n * success_rate) / sum(n), 2)) |>
      ggplot(aes(x = evaluation, y = rate, fill = evaluation)) +
        geom_col() +
        guides(fill = "none") +
        theme(axis.title = element_blank()) +
        scale_y_continuous(limits = c(0, 100))
  })

  # Render table for conversion rates by subgroup
  output$table <- renderTable({
    groups() |>
      select(industry, propensity, contract, evaluation, success_rate) |>
      pivot_wider(names_from = evaluation, values_from = success_rate)
  },
  digits = 0)
}

# Create the Shiny app
shinyApp(ui = ui, server = server)
