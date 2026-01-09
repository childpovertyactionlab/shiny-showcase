# CPAL Shiny Loading Spinner Template
# Copy this file to your project's R/ folder and source it in your app
#
# Usage in app.R UI section:
#   source("R/loading-spinner.R")
#   ui <- page_sidebar(
#     ...
#     useShinyjs(),
#     loading_overlay_ui(),  # Add this after useShinyjs()
#     ...
#   )
#
# Usage in app.R server section:
#   server <- function(input, output, session) {
#     # Call this at the start of your server function
#     setup_loading_overlay(session)
#     ...
#   }

# UI Component: Loading overlay with spinner
# Customize the message and styling as needed
loading_overlay_ui <- function(
    message = "Loading application...",
    spinner_color = "text-primary",
    background = "rgba(255,255,255,0.9)"
) {
  div(
    id = "loading_overlay",
    class = "loading-overlay",
    style = paste0(
      "position: fixed; top: 0; left: 0; width: 100%; height: 100%;
       background: ", background, "; z-index: 9999;
       display: flex; justify-content: center; align-items: center;
       flex-direction: column;"
    ),
    div(
      class = paste("spinner-border", spinner_color),
      role = "status",
      style = "width: 3rem; height: 3rem;"
    ),
    p(message, class = "mt-3 text-muted", style = "font-size: 1.1rem;")
  )
}

# Server Component: Hide loading overlay after initialization
# Optionally setup CPAL Google Fonts (set setup_fonts = FALSE to skip)
setup_loading_overlay <- function(session, setup_fonts = TRUE) {
  session$onFlushed(function() {
    # Optional: Setup CPAL Google Fonts (can be slow on first load)
    if (setup_fonts && exists("setup_cpal_google_fonts")) {
      setup_cpal_google_fonts()
    }

    # Hide the loading overlay with fade animation
    shinyjs::hide("loading_overlay", anim = TRUE, animType = "fade")
  }, once = TRUE)
}
