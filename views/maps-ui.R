# Maps UI - CLAUDE: Updated to reflect ACS child poverty data
maps_ui <- div(
  h1("Maps"),
  p("Interactive choropleth maps of Texas counties using ACS child poverty data.", class = "lead"),
  layout_columns(
    col_widths = c(6, 6),
    card(
      card_header("Texas Counties - Child Poverty Rate"),
      card_body(
        p("Color indicates child poverty rate (%). Darker colors = higher poverty.", class = "small text-muted"),
        mapboxglOutput("us_states_map", height = "450px")
      )
    ),
    card(
      card_header("Texas Counties - Median Household Income"),
      card_body(
        p("Color indicates median household income. Darker colors = higher income.", class = "small text-muted"),
        mapboxglOutput("texas_counties_map", height = "450px")
      )
    )
  )
)
