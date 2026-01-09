# Note: ACS child poverty data (tx_counties_df) is prepared in app.R and available globally

# Input Components UI
input_components_ui <- div(
  h1("Input Components Showcase"),
  p(
    "Explore the full range of input widgets available in Shiny and shinyWidgets packages.",
    class = "lead"
  ),
  layout_columns(
    col_widths = c(6, 6),

    # Input Widgets Showcase in Tabbed Interface
    card(
      card_header("Input Widgets with Package Information"),
      style = "height: 80vh;",

      # Tabbed interface for different input categories
      tabsetPanel(
        id = "input_tabs",
        type = "tabs",

        # Basic Shiny Inputs Tab
        tabPanel(
          "Basic Shiny",
          div(
            class = "overflow-auto p-3",

            # Basic Shiny Sliders
            # CLAUDE: Updated to use ACS child poverty data instead of mtcars
            div(
              class = "mb-5",
              h5("Slider Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Function: "),
                tags$code("sliderInput()"),
                class = "small text-muted mb-3"
              ),
              sliderInput(
                "poverty_range",
                "Child Poverty Rate % (Range Slider)",
                min = 0,
                max = 60,
                value = c(0, 60),
                step = 1
              ),
              sliderInput(
                "income_threshold",
                "Median Income Threshold (Single Value)",
                min = 20000,
                max = 150000,
                value = 150000,
                step = 5000,
                pre = "$"
              ),
              sliderInput(
                "transparency",
                "Transparency (Standard Slider)",
                value = 0.8,
                min = 0,
                max = 1,
                step = 0.1
              )
            ),

            # Basic Shiny Select Inputs
            # CLAUDE: Updated to use ACS child poverty data categories
            div(
              class = "mb-5",
              h5("Select Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Functions: "),
                tags$code("selectInput(), selectizeInput()"),
                class = "small text-muted mb-3"
              ),
              selectInput(
                "pop_category_select",
                "Population Category (Basic Multi-Select)",
                choices = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)"),
                selected = c("Large (500k+)", "Medium (100-500k)", "Small (25-100k)", "Rural (<25k)"),
                multiple = TRUE
              ),
              selectizeInput(
                "income_category_select",
                "Income Category (Selectize with Placeholder)",
                choices = c("High Income ($75k+)", "Middle Income ($50-75k)", "Lower Middle ($35-50k)", "Low Income (<$35k)"),
                selected = c("High Income ($75k+)", "Middle Income ($50-75k)", "Lower Middle ($35-50k)", "Low Income (<$35k)"),
                multiple = TRUE,
                options = list(placeholder = "Select income categories...")
              )
            ),

            # Basic Shiny Checkboxes
            # CLAUDE: Updated to use ACS child poverty data categories
            div(
              class = "mb-5",
              h5("Checkbox Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Functions: "),
                tags$code("checkboxInput(), checkboxGroupInput()"),
                class = "small text-muted mb-3"
              ),
              checkboxInput("show_trend", "Show trend line (Single Checkbox)", value = TRUE),
              checkboxGroupInput(
                "poverty_category_select",
                "Poverty Level (Checkbox Group)",
                choices = list(
                  "Very High (30%+)" = "Very High (30%+)",
                  "High (20-30%)" = "High (20-30%)",
                  "Moderate (15-20%)" = "Moderate (15-20%)",
                  "Low (10-15%)" = "Low (10-15%)",
                  "Very Low (<10%)" = "Very Low (<10%)"
                ),
                selected = c("Very High (30%+)", "High (20-30%)", "Moderate (15-20%)", "Low (10-15%)", "Very Low (<10%)")
              )
            ),

            # Basic Shiny Radio Buttons
            div(
              class = "mb-5",
              h5("Radio Button Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Function: "),
                tags$code("radioButtons()"),
                class = "small text-muted mb-3"
              ),
              radioButtons(
                "chart_type",
                "Chart Type (Basic Radio):",
                choices = list(
                  "Scatter" = "scatter",
                  "Box Plot" = "box",
                  "Histogram" = "hist"
                ),
                selected = "scatter"
              )
            ),

            # Basic Shiny Text Inputs
            div(
              class = "mb-5",
              h5("Text Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Functions: "),
                tags$code("textInput(), textAreaInput(), numericInput()"),
                class = "small text-muted mb-3"
              ),
              textInput("chart_title", "Chart Title (Text Input):", value = "Texas County Child Poverty Analysis"),
              textAreaInput(
                "chart_notes",
                "Chart Notes (Text Area)",
                value = "Data from American Community Survey (ACS)",
                rows = 3
              ),
              numericInput(
                "point_size",
                "Point Size (Numeric Input)",
                value = 3,
                min = 1,
                max = 10
              )
            ),

            # Basic Shiny Date and File Inputs
            div(
              class = "mb-5",
              h5("Date & File Inputs", class = "text-primary mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Functions: "),
                tags$code("dateRangeInput(), fileInput()"),
                class = "small text-muted mb-3"
              ),
              dateRangeInput(
                "date_range",
                "Analysis Period (Date Range):",
                start = Sys.Date() - 30,
                end = Sys.Date()
              ),
              fileInput(
                "upload_data",
                "Upload Custom Data (File Input)",
                accept = c(".csv", ".xlsx")
              )
            )
          )
        ),

        # shinyWidgets Tab
        tabPanel(
          "shinyWidgets",
          div(
            class = "overflow-auto p-3",

            # shinyWidgets Pretty Checkboxes
            div(
              class = "mb-5",
              h5("Enhanced Checkboxes", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("prettyCheckboxGroup()"),
                class = "small text-muted mb-3"
              ),
              # CLAUDE: Updated to use ACS poverty categories
              prettyCheckboxGroup(
                "poverty_category_pretty",
                "Poverty Levels (Pretty Checkboxes):",
                choices = c("Very Low (<10%)", "Low (10-15%)", "Moderate (15-20%)",
                            "High (20-30%)", "Very High (30%+)"),
                selected = c("Very Low (<10%)", "Low (10-15%)", "Moderate (15-20%)",
                             "High (20-30%)", "Very High (30%+)"),
                inline = TRUE,
                status = "primary",
                shape = "curve"
              )
            ),

            # shinyWidgets Pretty Radio Buttons
            div(
              class = "mb-5",
              h5("Enhanced Radio Buttons", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("prettyRadioButtons()"),
                class = "small text-muted mb-3"
              ),
              prettyRadioButtons(
                "color_scheme",
                "Color Scheme (Pretty Radio):",
                choices = list(
                  "CPAL Primary" = "primary",
                  "CPAL Secondary" = "secondary",
                  "Viridis" = "viridis"
                ),
                selected = "primary",
                inline = TRUE,
                status = "info",
                fill = TRUE
              )
            ),

            # shinyWidgets Picker Input
            div(
              class = "mb-5",
              h5("Picker Input", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("pickerInput()"),
                class = "small text-muted mb-3"
              ),
              # CLAUDE: Updated to use ACS income categories
              pickerInput(
                "income_picker",
                "Income Categories (Picker with Actions):",
                choices = c("High Income ($75k+)", "Middle Income ($50-75k)",
                            "Lower Middle ($35-50k)", "Low Income (<$35k)"),
                selected = c("High Income ($75k+)", "Middle Income ($50-75k)",
                             "Lower Middle ($35-50k)", "Low Income (<$35k)"),
                multiple = TRUE,
                options = list(`actions-box` = TRUE)
              )
            ),

            # shinyWidgets Color Input
            div(
              class = "mb-5",
              h5("Color Picker", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("colorPickr()"),
                class = "small text-muted mb-3"
              ),
              colorPickr(
                "custom_color",
                "Custom Color (Color Picker):",
                selected = "#1f77b4"
              )
            ),

            # shinyWidgets Advanced Inputs
            div(
              class = "mb-5",
              h5("Advanced Widget Inputs", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Functions: "),
                tags$code("materialSwitch(), searchInput(), airDatepickerInput()"),
                class = "small text-muted mb-3"
              ),
              materialSwitch(
                "show_labels",
                "Show Labels (Material Switch)",
                value = TRUE,
                status = "primary"
              ),
              searchInput(
                "search_cars",
                "Search Cars (Search Input)",
                placeholder = "Enter car name...",
                btnSearch = icon("magnifying-glass"),
                btnReset = icon("xmark"),
              ),
              airDatepickerInput(
                "air_date",
                "Select Date (Air Date Picker)",
                value = Sys.Date(),
                dateFormat = "mm/dd/yyyy"
              )
            ),

            # shinyWidgets Numeric Range
            div(
              class = "mb-5",
              h5("Numeric Range Input", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("numericRangeInput()"),
                class = "small text-muted mb-3"
              ),
              numericRangeInput("weight_range", "Weight Range:", value = c(2, 4))
            ),

            # Progress Bars (shinyWidgets)
            div(
              class = "mb-5",
              h5("Progress Indicators", class = "mb-3"),
              p(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("progressBar()"),
                class = "small text-muted mb-3"
              ),
              progressBar(
                "demo_progress1",
                value = 65,
                status = "info",
                display_pct = TRUE,
                striped = TRUE,
                title = "Demo Progress 1"
              ),
              br(),
              progressBar(
                "demo_progress2",
                value = 85,
                status = "success",
                display_pct = TRUE,
                title = "Demo Progress 2"
              )
            )
          )
        ),

        # Action Buttons Tab
        tabPanel(
          "Action Buttons",
          div(
            class = "overflow-auto p-3",

            # Standard Action Buttons
            div(
              class = "mb-5",
              h5("Standard Shiny Buttons", class = "mb-3"),
              p(
                tags$strong("Package: "),
                tags$code("shiny"),
                " | ",
                tags$strong("Functions: "),
                tags$code("actionButton(), downloadButton()"),
                class = "small text-muted mb-3"
              ),
              div(
                class = "d-flex flex-column align-items-start",
                tags$strong("Primary"),
                # CLAUDE: Changed ID to avoid duplicate (was "refresh_data")
                actionButton("btn_primary_demo", "Refresh Analysis", class = "btn-primary m-2")
              ),
              div(
                class = "d-flex flex-column align-items-start",
                tags$strong("Outline Primary"),
                # CLAUDE: Changed ID to avoid duplicate (was "refresh_data")
                actionButton("btn_outline_demo", "Refresh Analysis", class = "btn-outline-primary me-2 mb-2")
              ),
              div(
                class = "d-flex flex-column align-items-start",
                tags$strong("Download"),
                downloadButton("download_report", "Download Report", class = "btn-primary me-2 mb-2")
              ),
              div(
                class = "d-flex flex-column align-items-start",
                tags$strong("Secondary"),
                actionButton("update_progress", "Update Progress Bars", class = "btn-secondary me-2 mb-2")
              ),
              div(
                class = "d-flex flex-column",
                tags$strong("Link button"),
                # CLAUDE: Changed ID to avoid duplicate (was "show_static_charts")
                actionLink(
                  "link_demo",
                  class = "sidebar-link",
                  label = tagList(icon("line-chart", class = "sidebar-icon"), "Static Charts")
                ),
              ),
              div(
                class = "d-flex flex-column",
                tags$strong("Circle button"),
                circleButton(
                  "circle1",
                  icon = icon("check"),
                  status = "primary",
                  size = "sm"
                )
              )
            ),


            # Dropdown Button
            div(
              class = "mb-5",
              h5("Dropdown Button", class = "mb-3"),
              div(
                tags$strong("Package: "),
                tags$code("shinyWidgets"),
                " | ",
                tags$strong("Function: "),
                tags$code("dropdown()"),
                class = "small text-muted mb-3"
              ),
              dropdown(
                h5("Additional Options"),
                br(),
                checkboxInput("dropdown_opt1", "Option 1", TRUE),
                checkboxInput("dropdown_opt2", "Option 2", FALSE),
                sliderInput("dropdown_slider", "Value", 1, 10, 5),
                style = "simple",
                status = "primary",
                icon = icon("gear"),
                width = "300px"
              )
            ),

            # Dropdown Button
            div(
              class = "mb-3 p-3 bg-primary-subtle rounded",
              h5("Primary Section", class = "text-primary mb-3"),
              p(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
              )
            ),
            div(
              class = "mb-3 p-3 bg-success-subtle rounded",
              h5("Success Section", class = "text-success mb-3"),
              p(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
              )
            ),
            div(
              class = "mb-3 p-3 bg-info-subtle rounded",
              h5("Information Section", class = "text-info mb-3"),
              p(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
              )
            ),
            div(
              class = "mb-3 p-3 bg-warning-subtle rounded",
              h5("Warning Section", class = "text-warning mb-3"),
              p(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
              )
            ),
            div(
              class = "mb-3 p-3 bg-danger-subtle rounded",
              h5("Danger Section", class = "text-danger mb-3"),
              p(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
              )
            )
          )
        )
      )
    ),

    # Main Visualization Area
    card(
      card_header("Dynamic Visualization"),
      plotOutput("main_plot", height = "500px"),
      br(),

      # Value boxes - CLAUDE: Updated for ACS child poverty data
      layout_columns(
        col_widths = c(3, 3, 3, 3),
        value_box(
          title = "Avg Child Poverty Rate",
          value = textOutput("avg_poverty_rate"),
          showcase = icon("child"),
          theme = value_box_theme(bg = cpal_get_color("deep_teal"))
        ),
        value_box(
          title = "Counties Selected",
          value = textOutput("total_counties"),
          showcase = icon("map-marker-alt"),
          theme = value_box_theme(bg = cpal_get_color("teal"))
        ),
        value_box(
          title = "Children in Poverty",
          value = textOutput("total_children_poverty"),
          showcase = icon("users"),
          theme = value_box_theme(bg = cpal_get_color("coral"))
        ),
        value_box(
          title = "Median Income",
          value = textOutput("avg_median_income"),
          showcase = icon("dollar-sign"),
          theme = value_box_theme(bg = cpal_get_color("sage"))
        )
      )
    )
  )
)
