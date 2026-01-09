# Debug version of theme switching for light/dark mode
# This approach directly uses theme_cpal() or theme_cpal_dark() based on mode
# instead of relying on thematic's automatic color inference

#' Reactive Theme Switcher for CPAL
#'
#' Returns the appropriate CPAL theme based on the current mode.
#' Use this in Shiny apps to switch between light and dark themes.
#'
#' @param mode Character: "light" or "dark" (typically from input$dark_mode_toggle)
#' @param ... Additional arguments passed to the underlying theme function
#' @return A ggplot2 theme object
#'
#' @examples
#' # In a Shiny server function:
#' output$my_plot <- renderPlot({
#'   ggplot(data, aes(x, y)) +
#'     geom_point() +
#'     theme_cpal_switch(input$dark_mode_toggle)
#' })
theme_cpal_switch <- function(mode = "light", ...) {
  if (is.null(mode) || mode == "light") {
    cpaltemplates::theme_cpal(...)
  } else {
    cpaltemplates::theme_cpal_dark(...)
  }
}

#' Reactive Theme for Shiny (Function Factory)
#'
#' Creates a reactive expression that returns the appropriate theme.
#' Call this once in your server function to create a reusable theme reactive.
#'
#' @param input The Shiny input object
#' @param toggle_id The ID of the dark mode toggle input (default: "dark_mode_toggle
#' @param ... Additional arguments passed to theme functions
#' @return A reactive expression that returns a ggplot2 theme
#'
#' @examples
#' # In server function:
#' current_theme <- make_theme_reactive(input)
#'
#' output$my_plot <- renderPlot({
#'   ggplot(data, aes(x, y)) +
#'     geom_point() +
#'     current_theme()
#' })
make_theme_reactive <- function(input, toggle_id = "dark_mode_toggle", ...) {
  shiny::reactive({
    mode <- input[[toggle_id]]
    theme_cpal_switch(mode, ...)
  })
}

# =============================================================================
# HIGHCHARTER THEME SWITCHING
# =============================================================================

#' CPAL Light Theme for Highcharter
#'
#' @return A Highcharter theme object
hc_theme_cpal_light <- function() {
  highcharter::hc_theme(
    chart = list(
      backgroundColor = "#FFFFFF",
      style = list(
        fontFamily = "Inter, Roboto, sans-serif"
      )
    ),
    title = list(
      style = list(
        color = "#004855",
        fontWeight = "bold",
        fontSize = "16px"
      )
    ),
    subtitle = list(
      style = list(
        color = "#666666",
        fontSize = "12px"
      )
    ),
    xAxis = list(
      gridLineColor = "#E8ECEE",
      lineColor = "#5C6B73",
      tickColor = "#5C6B73",
      labels = list(
        style = list(color = "#004855")
      ),
      title = list(
        style = list(color = "#555555")
      )
    ),
    yAxis = list(
      gridLineColor = "#E8ECEE",
      lineColor = "#5C6B73",
      tickColor = "#5C6B73",
      labels = list(
        style = list(color = "#444444")
      ),
      title = list(
        style = list(color = "#555555")
      )
    ),
    legend = list(
      itemStyle = list(
        color = "#222222"
      ),
      itemHoverStyle = list(
        color = "#004855"
      )
    ),
    tooltip = list(
      backgroundColor = "#FFFFFF",
      style = list(
        color = "#222222"
      )
    )
  )
}

#' CPAL Dark Theme for Highcharter
#'
#' @return A Highcharter theme object
hc_theme_cpal_dark <- function() {
  highcharter::hc_theme(
    chart = list(
      backgroundColor = "#1a1a1a",
      style = list(
        fontFamily = "Inter, Roboto, sans-serif"
      )
    ),
    title = list(
      style = list(
        color = "#f0f0f0",
        fontWeight = "bold",
        fontSize = "16px"
      )
    ),
    subtitle = list(
      style = list(
        color = "#bbbbbb",
        fontSize = "12px"
      )
    ),
    xAxis = list(
      gridLineColor = "#333333",
      lineColor = "#666666",
      tickColor = "#666666",
      labels = list(
        style = list(color = "#e0e0e0")
      ),
      title = list(
        style = list(color = "#bbbbbb")
      )
    ),
    yAxis = list(
      gridLineColor = "#333333",
      lineColor = "#666666",
      tickColor = "#666666",
      labels = list(
        style = list(color = "#999999")
      ),
      title = list(
        style = list(color = "#bbbbbb")
      )
    ),
    legend = list(
      itemStyle = list(
        color = "#f0f0f0"
      ),
      itemHoverStyle = list(
        color = "#FFFFFF"
      )
    ),
    tooltip = list(
      backgroundColor = "#2a2a2a",
      style = list(
        color = "#f0f0f0"
      )
    )
  )
}

#' Highcharter Theme Switcher for CPAL
#'
#' Returns the appropriate CPAL Highcharter theme based on the current mode.
#'
#' @param mode Character: "light" or "dark" (typically from input$dark_mode_toggle)
#' @return A Highcharter theme object
#'
#' @examples
#' # In a Shiny server function:
#' output$my_chart <- renderHighchart({
#'   hchart(data, "scatter", hcaes(x, y)) %>%
#'     hc_add_theme(hc_theme_cpal_switch(input$dark_mode_toggle))
#' })
hc_theme_cpal_switch <- function(mode = "light") {
  if (is.null(mode) || mode == "light") {
    hc_theme_cpal_light()
  } else {
    hc_theme_cpal_dark()
  }
}
