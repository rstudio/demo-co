library(shiny)
library(tidyverse)
library(bslib)

expansions <-
  read_csv("data/expansions.csv") |>
  mutate(evaluation = factor(evaluation, levels = c("None", "A", "B")))

expansion_groups <-
  expansions |>
  group_by(industry, icp, contract, evaluation) |>
  summarize(success_rate = round(mean(outcome == "Won")* 100),
            avg_amount = round(mean(amount)),
            avg_days = round(mean(days)),
            n = n()) |>
  ungroup()

overall_rates <-
  expansions |>
  group_by(evaluation) |>
  summarise(rate = round(mean(outcome == "Won"), 2))

rates <- structure(overall_rates$rate, names = overall_rates$evaluation)

industries <- c("Academia",
              "Energy",
              "Finance",
              "Government",
              "Healthcare",
              "Insurance",
              "Manufacturing",
              "Non-Profit",
              "Pharmaceuticals",
              "Technology")

icps <- c("High", "Medium", "Low")
contracts <- c("Monthly", "Annual")




ui <- page_sidebar(
  title = "Effectiveness of Free Evaluations by Customer Segment",
  sidebar = sidebar(title = "Select a segment of data to view",
                    selectInput("industry", "Select industries", choices = industries, selected = "", multiple  = TRUE),
                    selectInput("icp", "Select ICP type", choices = icps, selected = "", multiple  = TRUE),
                    selectInput("contract", "Select contract type", choices = contracts, selected = "", multiple  = TRUE),
                    tags$img(src = "logo.png", width = "100%", height = "auto")),
  layout_columns(card(card_header("Conversions over time"),
                      plotOutput("line")),
                 card(card_header("Conversion rates"),
                      plotOutput("bar")),
                 col_widths = c(8, 4, 4, 4, 4, 12),
                 row_heights = c(4, 1.5, 3),
                 value_box(title = "Best Eval",
                           value = textOutput("recommended_eval"),
                           theme_color = "secondary"),
                 value_box(title = "Customers",
                           value = textOutput("number_of_customers"),
                           theme_color = "secondary"),
                 value_box(title = "Avg Spend",
                           value = textOutput("average_spend"),
                           theme_color = "secondary"),
                 card(card_header("Performance by subgroup"),
                      tableOutput("table")))

)

server <- function(input, output) {

  selected_industries <- reactive({
    if (is.null(input$industry)) industries else input$industry
  })

  selected_icps <- reactive({
    if (is.null(input$icp)) icps else input$icp
  })

  selected_contracts <- reactive({
    if (is.null(input$contract)) contracts else input$contract
  })

  filtered_expansions <- reactive({
    expansions |>
      filter(industry %in% selected_industries(),
             icp %in% selected_icps(),
             contract %in% selected_contracts())
  })

  conversions <- reactive({
    filtered_expansions() |>
      mutate(date = floor_date(date, unit = "month")) |>
      group_by(date, evaluation) |>
      summarize(n = sum(outcome == "Won")) |>
      ungroup()
  })

  groups <- reactive({
    expansion_groups |>
      filter(industry %in% selected_industries(),
             icp %in% selected_icps(),
             contract %in% selected_contracts())
  })

  output$recommended_eval <- renderText({
    recommendation <-
      filtered_expansions() |>
      group_by(evaluation) |>
      summarise(rate = mean(outcome == "Won")) |>
      filter(rate == max(rate)) |>
      pull(evaluation)

    as.character(recommendation[1])
  })

  output$number_of_customers <- renderText({
    sum(filtered_expansions()$outcome == "Won") |>
      format(big.mark = ",")
  })

  output$average_spend <- renderText({
      x <-
        filtered_expansions() |>
        filter(outcome == "Won") |>
        summarise(spend = round(mean(amount))) |>
        pull(spend)

      str_glue("${x}")
  })

  output$line <- renderPlot({
    ggplot(conversions(), aes(x = date, y = n, color = evaluation)) +
      geom_line()
  })

  output$bar <- renderPlot({
    groups() |>
      group_by(evaluation) |>
      summarise(rate = round(sum(n * success_rate) / sum(n), 2)) |>
      ggplot(aes(x = evaluation, y = rate, fill = evaluation)) +
        geom_col() +
        guides(fill = "none")
  })

  output$table <- renderTable({
    groups() |>
      select(industry, icp, contract, evaluation, success_rate) |>
      pivot_wider(names_from = evaluation, values_from = success_rate)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
