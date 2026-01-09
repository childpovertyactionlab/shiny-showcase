# CPAL Shiny Header Template
# Copy this file to your project's views/ folder and modify as needed
#
# Usage in app.R:
#   ui <- page_sidebar(
#     title = source("views/header-ui.R")$value,
#     ...
#   )

header_ui <- div(
  class = "d-flex align-items-center justify-content-between w-100",


  # Left side: logo + title
  # Modify the title text and logo path for your project
  div(
    class = "d-flex align-items-center",
    tags$img(
      src = "images/CPAL_Logo_OneColor.png",  # Place logo in www/images/
      height = "30",
      class = "me-2"
    ),
    tags$div("Your Dashboard Title", class = "header-title")  # <- MODIFY THIS
  ),

  # Right side: dark mode toggle

# Options for mode: "light" (default light), "dark" (default dark), NULL (system preference)
  input_dark_mode(id = "dark_mode_toggle", mode = "light")
)
