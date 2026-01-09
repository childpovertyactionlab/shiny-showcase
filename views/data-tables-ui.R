# Data Tables UI - CLAUDE: Updated for ACS child poverty data
data_tables_ui <- div(
  h1("Data Tables"),
  p("Compare different table packages with CPAL theming using Texas county child poverty data.", class = "lead"),
  layout_columns(
    col_widths = c(12, 12),
    card(
      card_header("GT Table (Static)"),
      card_body(
        p("Top 10 counties from filtered data.", class = "small text-muted"),
        gt_output("gt_table")
      )
    ),
    card(
      card_header("GT Table (Interactive)"),
      card_body(
        p("All filtered counties with pagination and search.", class = "small text-muted"),
        gt_output("gt_table_interactive")
      )
    ),
    card(
      card_header("Reactable (CPAL Themed)"),
      card_body(
        p("Searchable, filterable table with sticky column.", class = "small text-muted"),
        reactableOutput("reactable_table")
      )
    ),
    card(
      card_header("Summary Statistics"),
      card_body(
        p("Summary of ACS poverty and income variables.", class = "small text-muted"),
        verbatimTextOutput("summary_stats")
      )
    )
  )
)
