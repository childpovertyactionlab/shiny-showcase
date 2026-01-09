# Comprehensive CPAL Shiny Dashboard Template
# Author: Generated for CPAL template showcase
# Dataset: American Community Survey - Texas County Child Poverty Data

# Load required libraries
library(shiny)
library(shinyjs)
library(bslib)
library(bsicons)
library(ggplot2)
library(highcharter)
library(dplyr)
library(tidyr)
library(scales)
library(shinyWidgets)
library(DT)
library(reactable)
library(gt)
library(mapgl)
library(sf)
library(thematic)
library(cpaltemplates)  # CPAL branding, themes, and templates

# Set environment variables (CPAL public demo token - replace with your own for production)
Sys.setenv(MAPBOX_PUBLIC_TOKEN = "pk.eyJ1IjoiY3BhbGFuYWx5dGljcyIsImEiOiJjbHg5ODAwMGUxaTRtMmpwdGNscms3ZnJmIn0.D6yaemYNkijMo1naveeLbw")

# Disable Shiny development mode to suppress popup warnings (e.g., GT shared ID warnings)
# The GT package's opt_interactive() creates both input and output bindings by design
options(shiny.devmode = FALSE)

# NOTE: Font setup moved to server function for faster initial load

# Load cached ACS data for Texas counties (non-spatial only at startup)
# Spatial data is lazy-loaded when Maps section is accessed
# Run data-raw/fetch_acs_data.R to regenerate these files
message("Loading cached ACS data...")
tx_counties_df <- readRDS("data/tx_counties_poverty_df.rds")
message("Data loaded: ", nrow(tx_counties_df), " Texas counties")

# Spatial data path for lazy loading
spatial_data_path <- "data/tx_counties_poverty.rds"

# Define UI
ui <- page_sidebar(
  # App Title and Mode switcher
  title = source("views/header-ui.R")$value,
  theme = cpal_dashboard_theme(),

  # Collapsible Sidebar Navigation
  sidebar = source("views/sidebar-ui.R")$value,

  # Enable shinyjs for UI interactions
  useShinyjs(),

  # Loading overlay (shown during initialization, hidden by server)
  div(
    id = "loading_overlay",
    class = "loading-overlay",
    style = "position: fixed; top: 0; left: 0; width: 100%; height: 100%;
             background: rgba(255,255,255,0.9); z-index: 9999;
             display: flex; justify-content: center; align-items: center;
             flex-direction: column;",
    div(
      class = "spinner-border text-primary",
      role = "status",
      style = "width: 3rem; height: 3rem;"
    ),
    p("Loading application...", class = "mt-3 text-muted", style = "font-size: 1.1rem;")
  ),

  # Main Content Area
  div(
    id = "main_content",

    # Input Components Section
    conditionalPanel(condition = "output.current_section == 'inputs'", source("views/input-components-ui.R")$value),

    # Interactive Charts Section
    conditionalPanel(condition = "output.current_section == 'charts'", source("views/interactive-charts-ui.R")$value),

    # Static Charts Section
    conditionalPanel(condition = "output.current_section == 'static_charts'", source("views/static-charts-ui.R")$value),

    # Data Tables Section
    conditionalPanel(condition = "output.current_section == 'tables'", source("views/data-tables-ui.R")$value),

    # Typography Section (unchanged)
    conditionalPanel(condition = "output.current_section == 'typography'", source("views/typography-ui.R")$value),

    # Advanced Features Section
    conditionalPanel(condition = "output.current_section == 'advanced'", source("views/advanced-features-ui.R")$value),

    # Maps Section
    conditionalPanel(condition = "output.current_section == 'maps'", source("views/maps-ui.R")$value),
  )
)

# Define Server
server <- function(input, output, session) {

  # Turn on thematic global theming before defining plots
  thematic::thematic_on()

  # One-time initialization (fonts, etc.) - runs after UI is ready
  session$onFlushed(function() {
    # Setup CPAL Google Fonts (deferred to not block UI load)
    setup_cpal_google_fonts()

    # Hide loading overlay after initialization
    shinyjs::hide("loading_overlay", anim = TRUE, animType = "fade")
  }, once = TRUE)

  # Lazy-loaded spatial data for maps (only loads when maps section is accessed)
  spatial_data_loaded <- reactiveVal(FALSE)
  tx_counties_sf_lazy <- reactiveVal(NULL)

  # Load spatial data on first access to maps section
  observeEvent(input$show_maps, {
    if (!spatial_data_loaded()) {
      showNotification("Loading map data...", id = "map_loading", duration = NULL)
      tx_counties_sf_lazy(readRDS(spatial_data_path))
      spatial_data_loaded(TRUE)
      removeNotification("map_loading")
    }
  }, ignoreInit = TRUE)

  # Navigation state
  values <- reactiveValues(current_section = "inputs")

  # Create a reactive value for current section that can be used in conditionalPanel
  output$current_section <- reactive({
    values$current_section
  })
  outputOptions(output, "current_section", suspendWhenHidden = FALSE)

  # Navigation event handlers
  observeEvent(input$show_inputs, {
    values$current_section <- "inputs"
  })

  observeEvent(input$show_charts, {
    values$current_section <- "charts"
  })

  observeEvent(input$show_static_charts, {
    values$current_section <- "static_charts"
  })

  observeEvent(input$show_tables, {
    values$current_section <- "tables"
  })

  observeEvent(input$show_typography, {
    values$current_section <- "typography"
  })

  observeEvent(input$show_advanced, {
    values$current_section <- "advanced"
  })

  observeEvent(input$show_maps, {
    values$current_section <- "maps"
  })

  # Reactive data filtering - CLAUDE: Updated for ACS child poverty data
  filtered_data <- reactive({
    data <- tx_counties_df

    # Apply filters from input components section
    if (!is.null(input$poverty_range)) {
      data <- data %>% filter(
        child_poverty_rate >= input$poverty_range[1] &
        child_poverty_rate <= input$poverty_range[2]
      )
    }

    if (!is.null(input$income_threshold)) {
      data <- data %>% filter(median_household_income <= input$income_threshold)
    }

    if (!is.null(input$pop_category_select) && length(input$pop_category_select) > 0) {
      data <- data %>% filter(pop_category %in% input$pop_category_select)
    }

    if (!is.null(input$income_category_select) && length(input$income_category_select) > 0) {
      data <- data %>% filter(income_category %in% input$income_category_select)
    }

    if (!is.null(input$poverty_category_select) && length(input$poverty_category_select) > 0) {
      data <- data %>% filter(poverty_category %in% input$poverty_category_select)
    }

    return(data)
  })

  # Filtered spatial data for maps (uses lazy-loaded data)
  filtered_spatial_data <- reactive({
    # Return NULL if spatial data not yet loaded
    req(tx_counties_sf_lazy())
    data <- tx_counties_sf_lazy()

    if (!is.null(input$poverty_range)) {
      data <- data %>% filter(
        child_poverty_rate >= input$poverty_range[1] &
        child_poverty_rate <= input$poverty_range[2]
      )
    }

    if (!is.null(input$income_threshold)) {
      data <- data %>% filter(median_household_income <= input$income_threshold)
    }

    if (!is.null(input$pop_category_select) && length(input$pop_category_select) > 0) {
      data <- data %>% filter(pop_category %in% input$pop_category_select)
    }

    if (!is.null(input$income_category_select) && length(input$income_category_select) > 0) {
      data <- data %>% filter(income_category %in% input$income_category_select)
    }

    if (!is.null(input$poverty_category_select) && length(input$poverty_category_select) > 0) {
      data <- data %>% filter(poverty_category %in% input$poverty_category_select)
    }

    return(data)
  })

  # Main plot (Input Components section) - CLAUDE: Updated for ACS data
  output$main_plot <- renderPlot({
   data <- filtered_data()

    if(nrow(data) == 0) {
      return(ggplot() +
              theme_cpal() +
              labs(title = "No data matches current filters"))
    }

    p <- switch(
      input$chart_type,
      "scatter" = ggplot(data, aes(x = median_household_income / 1000, y = child_poverty_rate)) +
        geom_point(
          aes(color = pop_category),
          size = input$point_size,
          alpha = input$transparency
        ) +
        scale_color_cpal_d() +
        labs(
          x = "Median Household Income ($1000s)",
          y = "Child Poverty Rate (%)",
          color = "Population Size"
        ),
      "box" = ggplot(data, aes(x = income_category, y = child_poverty_rate)) +
        geom_boxplot(aes(fill = income_category), alpha = 0.7) +
        scale_fill_cpal_d() +
        labs(x = "Income Category", y = "Child Poverty Rate (%)", fill = "Income") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)),
      "hist" = ggplot(data, aes(x = child_poverty_rate)) +
        geom_histogram(
          bins = 20,
          fill = cpal_get_primary_color(),
          color = "white"
        ) +
        labs(x = "Child Poverty Rate (%)", y = "Number of Counties")
    )

    # Add trend line if requested for scatter plot
    if (input$chart_type == "scatter" && input$show_trend) {
      p <- p + geom_smooth(method = "lm",
                           se = TRUE)
    }

    # Apply CPAL theme with title and caption
    p + labs(title = input$chart_title,
           caption = input$chart_notes) +
    theme_cpal_auto() +
    theme(
      plot.title = element_text(hjust = 0.5),
      legend.position = "bottom"
    )
  })


  # Value boxes - CLAUDE: Updated for ACS child poverty data
  output$avg_poverty_rate <- renderText({
    paste0(round(mean(filtered_data()$child_poverty_rate, na.rm = TRUE), 1), "%")
  })

  output$total_counties <- renderText({
    nrow(filtered_data())
  })

  output$total_children_poverty <- renderText({
    scales::comma(sum(filtered_data()$children_in_poverty, na.rm = TRUE))
  })

  output$avg_median_income <- renderText({
    paste0("$", scales::comma(round(mean(filtered_data()$median_household_income, na.rm = TRUE), 0)))
  })

  # Interactive Charts (Highcharter) - Using CPAL colors
  # Define CPAL color palette for population categories
  cpal_colors <- c(
    unname(cpal_get_color("deep_teal")),
    unname(cpal_get_color("coral")),
    unname(cpal_get_color("sage")),
    unname(cpal_get_color("gold"))
  )

  output$highchart_scatter <- renderHighchart({
    data <- filtered_data()

    if (nrow(data) == 0) {
      return(
        highchart() %>%
          hc_title(text = "No data matches current filters")
      )
    }

    # Ensure pop_category is a factor with correct order for consistent colors
    data <- data %>%
      mutate(pop_category = factor(pop_category,
        levels = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)")))

    # Create scatter plot with highcharter
    hchart(
      data,
      "scatter",
      hcaes(x = median_household_income / 1000, y = child_poverty_rate, group = pop_category)
    ) %>%
      hc_colors(cpal_colors) %>%
      hc_title(text = "Median Income vs Child Poverty Rate") %>%
      hc_subtitle(text = "Texas Counties by Population Size") %>%
      hc_xAxis(
        title = list(text = "Median Household Income ($1000s)"),
        labels = list(format = "${value}k")
      ) %>%
      hc_yAxis(
        title = list(text = "Child Poverty Rate (%)"),
        labels = list(format = "{value}%")
      ) %>%
      hc_tooltip(
        pointFormat = "<b>{point.county_name}</b><br/>
                       Income: ${point.median_household_income:,.0f}<br/>
                       Child Poverty: {point.child_poverty_rate:.1f}%<br/>
                       Population: {point.total_population:,.0f}"
      ) %>%
      hc_legend(
        enabled = TRUE,
        layout = "horizontal",
        align = "center",
        verticalAlign = "bottom"
      ) %>%
      hc_plotOptions(
        scatter = list(
          marker = list(radius = 5),
          opacity = 0.8
        )
      )
  })

  output$highchart_line <- renderHighchart({
    # Group by income category and calculate average poverty rate
    data <- filtered_data() %>%
      mutate(
        income_bin = cut(median_household_income,
          breaks = c(0, 35000, 50000, 75000, Inf),
          labels = c("<$35k", "$35-50k", "$50-75k", "$75k+"),
          include.lowest = TRUE),
        pop_category = factor(pop_category,
          levels = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)"))
      ) %>%
      filter(!is.na(income_bin)) %>%
      group_by(pop_category, income_bin, .drop = FALSE) %>%
      summarise(
        avg_poverty = mean(child_poverty_rate, na.rm = TRUE),
        count = n(),
        .groups = "drop"
      ) %>%
      filter(count >= 1, !is.na(avg_poverty))

    if (nrow(data) == 0) {
      return(
        highchart() %>%
          hc_title(text = "No data matches current filters")
      )
    }

    # Create line chart with highcharter
    hchart(
      data,
      "line",
      hcaes(x = income_bin, y = avg_poverty, group = pop_category)
    ) %>%
      hc_colors(cpal_colors) %>%
      hc_title(text = "Child Poverty by Income Level") %>%
      hc_subtitle(text = "Average rate by county population size") %>%
      hc_xAxis(
        title = list(text = "Median Income Category"),
        categories = c("<$35k", "$35-50k", "$50-75k", "$75k+")
      ) %>%
      hc_yAxis(
        title = list(text = "Average Child Poverty Rate (%)"),
        labels = list(format = "{value}%")
      ) %>%
      hc_tooltip(
        pointFormat = "<b>{series.name}</b><br/>
                       Income: {point.income_bin}<br/>
                       Avg Poverty: {point.avg_poverty:.1f}%<br/>
                       Counties: {point.count}"
      ) %>%
      hc_legend(
        enabled = TRUE,
        layout = "horizontal",
        align = "center",
        verticalAlign = "bottom"
      ) %>%
      hc_plotOptions(
        line = list(
          marker = list(enabled = TRUE, radius = 5),
          lineWidth = 2
        )
      )
  })

  output$highchart_bar <- renderHighchart({
    data <- filtered_data() %>%
      group_by(poverty_category) %>%
      summarise(
        avg_poverty = round(mean(child_poverty_rate), 1),
        count = n(),
        total_children = sum(children_in_poverty, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(poverty_category = factor(poverty_category,
        levels = c("Very Low (<10%)", "Low (10-15%)", "Moderate (15-20%)", "High (20-30%)", "Very High (30%+)"))) %>%
      arrange(poverty_category)

    if (nrow(data) == 0) {
      return(
        highchart() %>%
          hc_title(text = "No data matches current filters")
      )
    }

    # Define colors for bar chart (5 poverty categories)
    bar_colors <- c(
      unname(cpal_get_color("sage")),
      unname(cpal_get_color("deep_teal")),
      unname(cpal_get_color("gold")),
      unname(cpal_get_color("coral")),
      unname(cpal_get_color("plum"))
    )

    # Add color column directly to data for proper colorByPoint mapping
    data <- data %>%
      mutate(color = bar_colors[as.numeric(poverty_category)])

    # Create bar chart with highcharter
    hchart(
      data,
      "column",
      hcaes(x = poverty_category, y = count)
    ) %>%
      hc_title(text = "Texas Counties by Child Poverty Level") %>%
      hc_subtitle(text = "Distribution across poverty categories") %>%
      hc_xAxis(
        title = list(text = "Poverty Category"),
        categories = levels(data$poverty_category)
      ) %>%
      hc_yAxis(
        title = list(text = "Number of Counties")
      ) %>%
      hc_tooltip(
        pointFormat = "<b>{point.poverty_category}</b><br/>
                       Counties: {point.count}<br/>
                       Avg Rate: {point.avg_poverty}%<br/>
                       Children in Poverty: {point.total_children:,.0f}"
      ) %>%
      hc_legend(enabled = FALSE) %>%
      hc_plotOptions(
        column = list(
          dataLabels = list(
            enabled = TRUE,
            format = "{point.y}"
          ),
          colorByPoint = TRUE,
          colors = bar_colors
        )
      )
  })

  output$highchart_heatmap <- renderHighchart({
    if (nrow(filtered_data()) == 0) {
      return(
        highchart() %>%
          hc_title(text = "No data matches current filters")
      )
    }

    # Create correlation matrix for ACS variables
    cor_data <- filtered_data() %>%
      select(
        `Child Poverty` = child_poverty_rate,
        `Poverty Rate` = poverty_rate,
        `Median Income` = median_household_income,
        `Population` = total_population,
        `Children` = total_children
      ) %>%
      cor(use = "complete.obs")

    # Get variable names
    vars <- colnames(cor_data)

    # Convert correlation matrix to format needed by highcharter heatmap
    # Format: list of [x_index, y_index, value]
    heatmap_data <- list()
    for (i in seq_along(vars)) {
      for (j in seq_along(vars)) {
        heatmap_data <- append(heatmap_data, list(list(i - 1, j - 1, round(cor_data[i, j], 2))))
      }
    }

    # Create heatmap with highcharter
    highchart() %>%
      hc_chart(type = "heatmap") %>%
      hc_title(text = "Variable Correlation Matrix") %>%
      hc_subtitle(text = "Texas County Demographics") %>%
      hc_xAxis(
        categories = vars,
        title = list(text = NULL),
        labels = list(rotation = -45)
      ) %>%
      hc_yAxis(
        categories = vars,
        title = list(text = NULL),
        reversed = TRUE
      ) %>%
      hc_colorAxis(
        min = -1,
        max = 1,
        stops = list(
          list(0, unname(cpal_get_color("coral"))),
          list(0.5, "#FFFFFF"),
          list(1, unname(cpal_get_color("deep_teal")))
        )
      ) %>%
      hc_legend(
        align = "right",
        layout = "vertical",
        verticalAlign = "middle"
      ) %>%
      hc_tooltip(
        formatter = JS(
          "function() {
            return '<b>' + this.series.xAxis.categories[this.point.x] +
                   ' vs ' + this.series.yAxis.categories[this.point.y] + '</b><br>' +
                   'Correlation: ' + this.point.value;
          }"
        )
      ) %>%
      hc_add_series(
        name = "Correlation",
        data = heatmap_data,
        dataLabels = list(
          enabled = TRUE,
          color = "#000000",
          style = list(fontWeight = "bold", textOutline = "none")
        ),
        borderWidth = 1,
        borderColor = "#FFFFFF"
      )
  })

  # Static Charts (ggplot2) - Using theme_cpal_auto() for thematic dark mode support

  output$ggplot_scatter <- renderPlot({
    data <- filtered_data() %>%
      # Ensure pop_category is a factor with correct order for consistent colors
      mutate(pop_category = factor(pop_category,
        levels = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)")))

    ggplot(data, aes(
      x = median_household_income / 1000,
      y = child_poverty_rate,
      color = pop_category,
      fill = pop_category
    )) +
      geom_point(size = 3, alpha = 0.8) +
      geom_smooth(method = "lm", se = TRUE, alpha = 0.2) +
      scale_color_cpal_d(drop = FALSE) +
      scale_fill_cpal_d(drop = FALSE) +
      scale_x_continuous(labels = scales::dollar_format(suffix = "k")) +
      labs(
        title = "Income vs Child Poverty Rate",
        subtitle = paste0("Texas Counties by Population Size (n=", nrow(data), ")"),
        x = "Median Household Income",
        y = "Child Poverty Rate (%)",
        color = "Population"
      ) +
      theme_cpal_auto()
  })

  output$ggplot_line <- renderPlot({
    data <- filtered_data() %>%
      mutate(
        income_bin = cut(median_household_income,
          breaks = c(0, 35000, 50000, 75000, Inf),
          labels = c("<$35k", "$35-50k", "$50-75k", "$75k+"),
          include.lowest = TRUE),
        pop_category = factor(pop_category,
          levels = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)"))
      ) %>%
      filter(!is.na(income_bin)) %>%
      group_by(pop_category, income_bin, .drop = FALSE) %>%
      summarise(avg_poverty = mean(child_poverty_rate, na.rm = TRUE),
                count = n(),
                .groups = "drop") %>%
      filter(count >= 1, !is.na(avg_poverty))

    # Check if we have enough points to draw lines
    has_multiple_points <- data %>%
      group_by(pop_category) %>%
      summarise(n = n()) %>%
      filter(n > 1) %>%
      nrow() > 0

    p <- ggplot(data, aes(
      x = income_bin,
      y = avg_poverty,
      color = pop_category,
      group = pop_category
    ))

    if (has_multiple_points) {
      p <- p + geom_line(linewidth = 1.2)
    }

    p +
      geom_point(size = 4) +
      scale_color_cpal_d(drop = FALSE) +
      labs(
        title = "Child Poverty by Income Level",
        subtitle = "Average rate by county population size",
        x = "Median Income Category",
        y = "Average Child Poverty Rate (%)",
        color = "Population"
      ) +
      theme_cpal_auto()
  })

  output$ggplot_bar <- renderPlot({
    data <- filtered_data() %>%
      group_by(poverty_category) %>%
      summarise(
        count = n(),
        avg_rate = mean(child_poverty_rate),
        .groups = "drop"
      ) %>%
      mutate(poverty_category = factor(poverty_category,
        levels = c("Very Low (<10%)", "Low (10-15%)", "Moderate (15-20%)", "High (20-30%)", "Very High (30%+)")))

    ggplot(data, aes(x = poverty_category, y = count, fill = poverty_category)) +
      geom_col(alpha = 0.9) +
      geom_text(aes(label = count), vjust = -0.5, fontface = "bold", size = 5) +
      scale_fill_cpal_d(drop = FALSE) +
      labs(
        title = "Texas Counties by Child Poverty Level",
        subtitle = paste0("Distribution across poverty categories (n=", sum(data$count), " counties)"),
        x = "Poverty Category",
        y = "Number of Counties"
      ) +
      theme_cpal_auto() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none"
      )
  })

  output$ggplot_heatmap <- renderPlot({
    # Create correlation matrix for ACS variables
    cor_data <- filtered_data() %>%
      select(
        `Child Poverty` = child_poverty_rate,
        `Poverty Rate` = poverty_rate,
        `Median Income` = median_household_income,
        `Population` = total_population,
        `Children` = total_children
      ) %>%
      cor(use = "complete.obs")

    # Convert to long format
    cor_long <- cor_data %>%
      as.data.frame() %>%
      tibble::rownames_to_column("var1") %>%
      tidyr::pivot_longer(-var1, names_to = "var2", values_to = "correlation")

    ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
      geom_tile(color = "white") +
      geom_text(aes(label = round(correlation, 2)),
                size = 5,
                fontface = "bold") +
      scale_fill_gradient2(
        low = cpal_get_color("coral"),
        mid = "white",
        high = cpal_get_color("deep_teal"),
        midpoint = 0,
        limits = c(-1, 1)
      ) +
      labs(
        title = "Variable Correlation Matrix",
        subtitle = "Texas County Demographics",
        x = "",
        y = "",
        fill = "Correlation"
      ) +
      theme_cpal_auto() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.key.height = unit(1.5, "cm"),
        legend.key.width = unit(0.8, "cm"),
        legend.position = "right"
      )
  })

  # Tables with CPAL theming - CLAUDE: Updated for ACS child poverty data
  output$gt_table <- render_gt({
    filtered_data() %>%
      select(county_name, child_poverty_rate, poverty_rate,
             median_household_income, total_population, poverty_category) %>%
      slice_head(n = 10) %>%
      cpal_table_gt(title = "Top 10 Texas Counties (Filtered Data)",
                    subtitle = "Sorted by original dataset order") %>%
      cols_label(
        county_name = "County",
        child_poverty_rate = "Child Poverty Rate (%)",
        poverty_rate = "Overall Poverty Rate (%)",
        median_household_income = "Median Income",
        total_population = "Population",
        poverty_category = "Poverty Level"
      ) %>%
      fmt_number(columns = child_poverty_rate, decimals = 1) %>%
      fmt_number(columns = poverty_rate, decimals = 1) %>%
      fmt_currency(columns = median_household_income, decimals = 0) %>%
      fmt_number(columns = total_population, use_seps = TRUE, decimals = 0)
  })

    # CLAUDE: Updated for ACS child poverty data with interactive features
    output$gt_table_interactive <- render_gt({
    filtered_data() %>%
      select(county_name, child_poverty_rate, poverty_rate,
             median_household_income, total_children, children_in_poverty,
             total_population, income_category, poverty_category) %>%
      cpal_table_gt(title = "All Texas Counties (Filtered Data)",
                    subtitle = "Interactive table with pagination and search") %>%
      cols_label(
        county_name = "County",
        child_poverty_rate = "Child Poverty %",
        poverty_rate = "Poverty %",
        median_household_income = "Median Income",
        total_children = "Children",
        children_in_poverty = "Children in Poverty",
        total_population = "Population",
        income_category = "Income Level",
        poverty_category = "Poverty Level"
      ) %>%
      fmt_number(columns = c(child_poverty_rate, poverty_rate), decimals = 1) %>%
      fmt_currency(columns = median_household_income, decimals = 0) %>%
      fmt_number(columns = c(total_children, children_in_poverty, total_population),
                 use_seps = TRUE, decimals = 0) %>%
      opt_interactive(
        use_pagination = TRUE,
        use_page_size_select = TRUE,
        page_size_default = 10,
        use_search = TRUE
      ) %>%
      opt_row_striping()
  })

  # CLAUDE: Updated for ACS child poverty data
  output$reactable_table <- renderReactable({
    filtered_data() %>%
      select(county_name, child_poverty_rate, median_household_income,
             total_population, pop_category, poverty_category) %>%
      cpal_table_reactable(
        searchable = TRUE,
        pagination = TRUE,
        filterable = TRUE,
        striped = TRUE,
        highlight = TRUE,
        columns = list(
          county_name = colDef(name = "County", sticky = "left", minWidth = 150),
          child_poverty_rate = colDef(
            name = "Child Poverty %",
            format = colFormat(digits = 1)
          ),
          median_household_income = colDef(
            name = "Median Income",
            format = colFormat(prefix = "$", separators = TRUE, digits = 0)
          ),
          total_population = colDef(
            name = "Population",
            format = colFormat(separators = TRUE, digits = 0)
          ),
          pop_category = colDef(name = "Size Category"),
          poverty_category = colDef(name = "Poverty Level")
        )
      )
  })

  # CLAUDE: Updated for ACS child poverty data
  output$dt_table <- DT::renderDataTable({
    DT::datatable(
      filtered_data() %>%
        select(county_name, child_poverty_rate, poverty_rate,
               median_household_income, total_population, total_children,
               children_in_poverty, pop_category, income_category, poverty_category),
      options = list(
        pageLength = 15,
        scrollX = TRUE,
        search = list(regex = TRUE, caseInsensitive = TRUE)
      ),
      filter = "top",
      rownames = FALSE,
      colnames = c("County", "Child Poverty %", "Poverty %", "Median Income",
                   "Population", "Children", "Children in Poverty",
                   "Size Category", "Income Category", "Poverty Level")
    ) %>%
      DT::formatRound(columns = c("child_poverty_rate", "poverty_rate"), digits = 1) %>%
      DT::formatCurrency(columns = "median_household_income", digits = 0) %>%
      DT::formatRound(columns = c("total_population", "total_children", "children_in_poverty"), digits = 0)
  })

  # Summary statistics - CLAUDE: Updated for ACS child poverty data
  output$summary_stats <- renderPrint({
    summary(filtered_data() %>%
              select(child_poverty_rate, poverty_rate, median_household_income,
                     total_population, total_children, children_in_poverty))
  })

  # Advanced Features - Event Handlers
  observeEvent(input$show_notification, {
    showNotification("This is a sample notification message!",
                     type = "message",
                     duration = NULL)
  })

  observeEvent(input$notif_default, {
    showNotification("Default notification", duration = NULL)
  })

  observeEvent(input$notif_error, {
    showNotification("Error notification",
                     type = "error",
                     duration = NULL)
  })

  observeEvent(input$notif_warning, {
    showNotification("Warning notification",
                     type = "warning",
                     duration = NULL)
  })

  observeEvent(input$notif_message, {
    showNotification("Message notification",
                     type = "message",
                     duration = NULL)
  })

  observeEvent(input$sweet_success, {
    sendSweetAlert(
      session = session,
      title = "Success!",
      text = "Your operation completed successfully.",
      type = "success",
      btn_colors = "#007A8C"
    )
  })

  observeEvent(input$sweet_confirm, {
    confirmSweetAlert(
      session = session,
      inputId = "confirm_action",
      title = "Are you sure?",
      text = "This action cannot be undone.",
      type = "warning",
      showCancelButton = TRUE,
      confirmButtonText = "Yes, proceed",
      cancelButtonText = "Cancel",
      btn_colors = c("", "#007A8C")
    )
  })

  observeEvent(input$show_loading, {
    showNotification("Loading...",
                     id = "loading",
                     duration = NULL,
                     type = "default")
    Sys.sleep(2) # Simulate loading
    removeNotification("loading")
    showNotification("Loading complete!", type = "message", duration = 2)
  })

  observeEvent(input$update_progress, {
    updateProgressBar(session, "demo_progress1", value = sample(1:100, 1))
    updateProgressBar(session, "demo_progress2", value = sample(1:100, 1))
  })

  observeEvent(input$update_progress_advanced, {
    updateProgressBar(session, "progress1", value = sample(1:100, 1))
    updateProgressBar(session, "progress2", value = sample(1:100, 1))
  })

  # CLAUDE: Updated for ACS child poverty data
  observeEvent(input$reset_inputs, {
    updateSliderInput(session, "poverty_range", value = c(0, 60))
    updateSliderInput(session, "income_threshold", value = 150000)
    updateSelectInput(session, "pop_category_select",
                      selected = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)"))
    updateSelectInput(session, "income_category_select",
                      selected = c("High Income ($75k+)", "Middle Income ($50-75k)",
                                   "Lower Middle ($35-50k)", "Low Income (<$35k)"))
    updateCheckboxGroupInput(session, "poverty_category_select",
                             selected = c("Very Low (<10%)", "Low (10-15%)", "Moderate (15-20%)",
                                          "High (20-30%)", "Very High (30%+)"))
    updateCheckboxInput(session, "show_trend", value = TRUE)
    updateRadioButtons(session, "chart_type", selected = "scatter")
    updateTextInput(session, "chart_title", value = "Texas County Child Poverty Analysis")
    showNotification("All inputs have been reset!", type = "message")
  })

  # Modal dialogs
  observeEvent(input$show_modal, {
    showModal(
      modalDialog(
        title = "Modal Dialog Example",
        "This is a modal dialog. You can include any content here, including inputs and outputs.",
        br(),
        br(),
        "Modal dialogs are useful for:",
        tags$ul(
          tags$li("Collecting additional user input"),
          tags$li("Displaying detailed information"),
          tags$li("Confirming actions")
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("modal_ok", "OK", class = "btn-primary")
        )
      )
    )
  })

  observeEvent(input$show_modal_form, {
    showModal(
      modalDialog(
        title = "Form Modal Example",
        textInput("modal_name", "Name:"),
        selectInput(
          "modal_category",
          "Category:",
          choices = c("Category A", "Category B", "Category C")
        ),
        textAreaInput("modal_notes", "Notes:", rows = 3),
        footer = tagList(
          modalButton("Close"),
          actionButton("modal_submit", "Submit", class = "btn-primary")
        )
      )
    )
  })

  observeEvent(input$modal_ok, {
    removeModal()
    showNotification("Modal closed with OK", type = "message")
  })

  observeEvent(input$modal_submit, {
    removeModal()
    showNotification("Form submitted successfully", type = "success")
  })

  # Collapsible card
  observeEvent(input$collapse_card, {
    shinyjs::toggle("card_body", anim = TRUE)
  })

  # Maps - CLAUDE: Updated to use ACS child poverty data with choropleth
  output$us_states_map <- renderMapboxgl({
    # Texas overview map with child poverty data
    map_data <- filtered_spatial_data()

    mapboxgl(
      center = c(-99.9018, 31.9686),
      zoom = 5,
      pitch = 0
    ) %>%
      add_navigation_control() %>%
      add_fill_layer(
        id = "counties_fill",
        source = map_data,
        fill_color = interpolate(
          column = "child_poverty_rate",
          values = c(0, 15, 30, 50),
          stops = c(
            unname(cpal_get_color("sage")),
            unname(cpal_get_color("gold")),
            unname(cpal_get_color("coral")),
            unname(cpal_get_color("deep_teal"))
          ),
          na_color = "#CCCCCC"
        ),
        fill_opacity = 0.7,
        tooltip = "county_name",
        hover_options = list(
          fill_color = unname(cpal_get_color("deep_teal")),
          fill_opacity = 1
        )
      ) %>%
      add_line_layer(
        id = "counties_outline",
        source = map_data,
        line_color = "#FFFFFF",
        line_width = 0.5
      )
  })

  output$texas_counties_map <- renderMapboxgl({
    # Detailed Texas counties map with median income
    map_data <- filtered_spatial_data()

    mapboxgl(
      center = c(-99.9018, 31.9686),
      zoom = 5.5,
      pitch = 0
    ) %>%
      add_navigation_control() %>%
      add_fill_layer(
        id = "counties_income",
        source = map_data,
        fill_color = interpolate(
          column = "median_household_income",
          values = c(25000, 50000, 75000, 100000),
          stops = c(
            unname(cpal_get_color("coral")),
            unname(cpal_get_color("gold")),
            unname(cpal_get_color("sage")),
            unname(cpal_get_color("deep_teal"))
          ),
          na_color = "#CCCCCC"
        ),
        fill_opacity = 0.7,
        tooltip = "county_name",
        hover_options = list(
          fill_color = unname(cpal_get_color("deep_teal")),
          fill_opacity = 1
        )
      ) %>%
      add_line_layer(
        id = "counties_outline",
        source = map_data,
        line_color = "#FFFFFF",
        line_width = 0.5
      )
  })

  # Download handler - CLAUDE: Updated for ACS child poverty data
  output$download_report <- downloadHandler(
    filename = function() {
      paste("texas_child_poverty_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
