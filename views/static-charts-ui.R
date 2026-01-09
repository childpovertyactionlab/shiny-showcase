# Static Charts UI - CLAUDE: Updated for ACS child poverty data
static_charts_ui <- div(
  h1("Static Charts"),
  p("Texas county child poverty visualizations using ggplot2 with theme_cpal().", class = "lead"),
  layout_columns(
    col_widths = c(6, 6),
    card(
      card_header("Income vs Child Poverty Rate"),
      plotOutput("ggplot_scatter", height = "400px")
    ),
    card(
      card_header("Poverty by Income Level"),
      plotOutput("ggplot_line", height = "400px")
    ),
    card(
      card_header("Counties by Poverty Category"),
      plotOutput("ggplot_bar", height = "400px")
    ),
    card(
      card_header("Variable Correlation Matrix"),
      plotOutput("ggplot_heatmap", height = "400px")
    )
  )
)
