# Interactive Charts UI - Using Highcharter for interactive visualizations
interactive_charts_ui <- div(
  h1("Interactive Charts"),
  p("Explore Texas county child poverty data with interactive Highcharts visualizations using cpaltemplates.", class = "lead"),
  layout_columns(
    col_widths = c(6, 6),
    card(
      card_header("Median Income vs Child Poverty"),
      highchartOutput("highchart_scatter", height = "400px")
    ),
    card(
      card_header("Poverty by Income Level & Population"),
      highchartOutput("highchart_line", height = "400px")
    ),
    card(
      card_header("Counties by Poverty Category"),
      highchartOutput("highchart_bar", height = "400px")
    ),
    card(
      card_header("Variable Correlation Matrix"),
      highchartOutput("highchart_heatmap", height = "400px")
    )
  )
)
