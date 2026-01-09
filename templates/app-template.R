# CPAL Shiny App Template
# A minimal starting point for CPAL-branded Shiny applications
#
# Setup Instructions:
# 1. Copy this file to your new project as app.R
# 2. Run use_cpal_brand() to copy _brand.yml to your project
# 3. Copy templates/header-template.R to views/header-ui.R
# 4. Copy templates/loading-spinner-template.R to R/loading-spinner.R
# 5. Place CPAL logo in www/images/CPAL_Logo_OneColor.png
# 6. Modify as needed for your project

# ============================================================================
# LOAD PACKAGES
# ============================================================================

library(shiny)
library(shinyjs)
library(bslib)
library(bsicons)
library(ggplot2)
library(dplyr)
library(thematic)
library(cpaltemplates)

# Optional packages (uncomment as needed):
# library(shinyWidgets)  # Enhanced input widgets
# library(gt)            # Publication-ready tables
# library(reactable)     # Interactive tables
# library(DT)            # DataTables
# library(highcharter)   # Interactive charts
# library(mapgl)         # Mapbox maps
# library(sf)            # Spatial data

# ============================================================================
# CONFIGURATION
# ============================================================================

# Suppress Shiny dev mode popups (e.g., GT shared ID warnings)
options(shiny.devmode = FALSE)

# Environment variables (use .env file for sensitive tokens in production)
# Sys.setenv(MY_API_TOKEN = "your-token-here")

# Source helper files
source("R/loading-spinner.R")

# ============================================================================
# LOAD DATA
# ============================================================================

# Option 1: Load from local files
# your_data <- readRDS("data/your_data.rds")

# Option 2: Connect to database (e.g., Databricks)
# con <- DBI::dbConnect(...)
# your_data <- DBI::dbGetQuery(con, "SELECT * FROM your_table")

# Sample data for template demo (replace with your data)
sample_data <- data.frame(
  category = rep(LETTERS[1:4], each = 25),
  value = c(rnorm(25, 10, 2), rnorm(25, 15, 3),
            rnorm(25, 12, 2.5), rnorm(25, 18, 4)),
  group = sample(c("Group 1", "Group 2"), 100, replace = TRUE)
)

# ============================================================================
# USER INTERFACE
# ============================================================================

ui <- page_sidebar(
  # Header with logo and dark mode toggle
  title = source("views/header-ui.R")$value,

  # Apply CPAL dashboard theme (reads from _brand.yml)
  theme = cpal_dashboard_theme(),

  # Sidebar navigation/filters
  sidebar = sidebar(
    title = "Filters",

    # Add your filter inputs here
    selectInput(
      "category_filter",
      "Category:",
      choices = c("All", LETTERS[1:4]),
      selected = "All"
    ),

    sliderInput(
      "value_range",
      "Value Range:",
      min = 0,
      max = 30,
      value = c(0, 30)
    ),

    hr(),

    # Action buttons
    actionButton("apply_filters", "Apply Filters", class = "btn-primary w-100"),
    actionButton("reset_filters", "Reset", class = "btn-outline-secondary w-100 mt-2")
  ),

  # Enable shinyjs for UI interactions
  useShinyjs(),

  # Loading overlay (shows during initialization)
  loading_overlay_ui(message = "Loading application..."),

  # -------------------------------------------------------------------------
  # MAIN CONTENT AREA
  # -------------------------------------------------------------------------

  # Page title
  h1("Dashboard Title"),
  p("Dashboard description or instructions.", class = "lead text-muted"),

  # Content layout using bslib cards
  layout_columns(
    col_widths = c(6, 6),

    # Chart 1
    card(
      card_header("Chart Title 1"),
      card_body(
        plotOutput("chart1", height = "300px")
      )
    ),

    # Chart 2
    card(
      card_header("Chart Title 2"),
      card_body(
        plotOutput("chart2", height = "300px")
      )
    )
  ),

  # Additional content row
  layout_columns(
    col_widths = 12,

    card(
      card_header("Data Table"),
      card_body(
        # Add your table output here
        # gt_output("my_table")
        p("Table content goes here")
      )
    )
  )
)

# ============================================================================
# SERVER LOGIC
# ============================================================================

server <- function(input, output, session) {

  # --------------------------------------------------------------------------
  # INITIALIZATION
  # --------------------------------------------------------------------------

  # Enable thematic for auto dark/light mode in ggplot2
  thematic::thematic_on()

  # Setup loading overlay (hides after fonts load)
  setup_loading_overlay(session, setup_fonts = TRUE)

  # --------------------------------------------------------------------------
  # REACTIVE DATA
  # --------------------------------------------------------------------------

  filtered_data <- reactive({
    data <- sample_data

    # Apply filters
    if (input$category_filter != "All") {
      data <- data %>% filter(category == input$category_filter)
    }

    data <- data %>%
      filter(value >= input$value_range[1],
             value <= input$value_range[2])

    data
  })

  # --------------------------------------------------------------------------
  # OUTPUTS
  # --------------------------------------------------------------------------

  # Chart 1: Bar chart
  output$chart1 <- renderPlot({
    filtered_data() %>%
      count(category) %>%
      ggplot(aes(x = category, y = n, fill = category)) +
      geom_col() +
      scale_fill_cpal_d() +
      labs(
        title = "Count by Category",
        x = NULL,
        y = "Count"
      ) +
      theme_cpal_auto() +
      theme(legend.position = "none")
  })

  # Chart 2: Box plot
  output$chart2 <- renderPlot({
    ggplot(filtered_data(), aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.8) +
      scale_fill_cpal_d() +
      labs(
        title = "Value Distribution by Group",
        x = NULL,
        y = "Value"
      ) +
      theme_cpal_auto() +
      theme(legend.position = "none")
  })

  # --------------------------------------------------------------------------
  # EVENT HANDLERS
  # --------------------------------------------------------------------------

  # Reset filters
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "category_filter", selected = "All")
    updateSliderInput(session, "value_range", value = c(0, 30))
    showNotification("Filters reset!", type = "message", duration = 2)
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
