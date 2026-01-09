# CPAL Shiny Showcase

A comprehensive reference application demonstrating Shiny UI components styled with the [`cpaltemplates`](https://github.com/childpovertyactionlab/cpaltemplates) package for the Child Poverty Action Lab Data Science team.

[![cpaltemplates](https://img.shields.io/badge/styled%20with-cpaltemplates-007A8C)](https://github.com/childpovertyactionlab/cpaltemplates)
[![Shiny](https://img.shields.io/badge/Shiny-App-blue)](https://shiny.posit.co/)

**Live Demo:** [cpal.shinyapps.io/shiny-showcase](https://cpal.shinyapps.io/shiny-showcase)

## Purpose

This application serves as a **living style guide** and **code reference** for building Shiny applications at CPAL. It demonstrates:

- All standard Shiny inputs with CPAL theming
- Interactive and static data visualizations
- Multiple table formats (GT, Reactable, DT)
- Maps with Mapbox GL
- Layout patterns and UI components
- Real American Community Survey data (Texas county child poverty)

## Quick Start

### Prerequisites

```r
# Install cpaltemplates from GitHub
remotes::install_github("childpovertyactionlab/cpaltemplates")

# Install other required packages
install.packages(c(
  "shiny", "bslib", "shinyjs", "shinyWidgets",
  "ggplot2", "highcharter", "dplyr", "tidyr", "scales",
  "DT", "reactable", "gt", "mapgl", "sf", "thematic"
))
```

### Run the App

```r
# Clone the repository
git clone https://github.com/childpovertyactionlab/shiny-showcase.git

# Open the project in RStudio/Positron and run:
shiny::runApp()
```

## Project Structure

```
shiny-showcase/
├── app.R                    # Main application entry point
├── _brand.yml               # CPAL brand configuration (colors, fonts)
├── views/                   # UI components by section
│   ├── header-ui.R          # Header with dark mode toggle
│   ├── sidebar-ui.R         # Navigation sidebar
│   ├── input-components-ui.R    # Input showcase
│   ├── interactive-charts-ui.R  # Highcharter charts
│   ├── static-charts-ui.R       # ggplot2 charts
│   ├── data-tables-ui.R         # GT, Reactable, DT tables
│   ├── maps-ui.R                # Mapbox GL maps
│   ├── typography-ui.R          # Typography examples
│   └── advanced-features-ui.R   # Modals, notifications, etc.
├── templates/               # Copy-paste starter templates
│   ├── app-template.R       # Basic app structure
│   ├── header-template.R    # Header component
│   └── loading-spinner-template.R
├── data/                    # Cached ACS data
│   ├── tx_counties_poverty.rds      # Spatial data (sf)
│   └── tx_counties_poverty_df.rds   # Non-spatial data frame
├── data-raw/                # Data fetching scripts
│   └── fetch_acs_data.R
├── www/                     # Static assets
│   ├── images/              # CPAL logos and assets
│   ├── styles.css           # Custom CSS
│   └── *.scss               # SCSS theme files
├── docs/                    # Quarto documentation site
├── R/                       # Helper functions
│   └── notify.R             # Notification helpers
└── logs/                    # Development logs
```

## Components Showcased

### Input Components
- Text inputs (text, textarea, password)
- Numeric inputs (slider, numeric)
- Selection inputs (dropdown, radio, checkbox, picker)
- Date inputs (single, range)
- Action elements (buttons, links)
- File upload

### Visualizations
- **Interactive Charts** (Highcharter): scatter, line, bar, heatmap
- **Static Charts** (ggplot2): scatter, line, bar, correlation matrix
- **Maps** (Mapbox GL): choropleth maps with hover interactions

### Tables
- **GT**: Static and interactive tables with CPAL styling
- **Reactable**: Sortable, filterable React tables
- **DT**: DataTables with search and pagination

### UI Components
- Value boxes with icons
- Cards and layouts
- Modal dialogs
- Notifications (standard and SweetAlert)
- Progress bars
- Loading states
- Dark mode support

## Data

The app uses real American Community Survey (ACS) data for Texas counties, including:
- Child poverty rates
- Median household income
- Population demographics
- County classifications

To refresh the data:
```r
source("data-raw/fetch_acs_data.R")
```

## Theming

The app uses `cpaltemplates` for consistent CPAL branding:

```r
# Apply CPAL dashboard theme
ui <- page_sidebar(

  theme = cpal_dashboard_theme(),
  ...
)

# Use CPAL ggplot2 theme
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_cpal_auto()  # Supports dark mode

# CPAL color scales
scale_color_cpal_d()
scale_fill_cpal_d()
```

## Deployment

The app is deployed to shinyapps.io. To deploy updates:

```r
rsconnect::deployApp(appName = "shiny-showcase")
```

## Development

### For CPAL Team Members

1. Create a branch for your changes
2. Add or modify components as needed
3. Test with `shiny::runApp()`
4. Submit a pull request

### Adding New Components

1. Add UI code to the appropriate `views/` file
2. Add server logic to `app.R`
3. Consider adding a template to `templates/` for reusability

### Logging (Claude Code Sessions)

Development sessions use structured logging in the `logs/` folder:
- `session-log.md` - All actions taken
- `changelog.md` - File modifications
- `decisions.md` - Design decisions
- `issues.md` - Bugs and todos

## Related Resources

- [cpaltemplates Package](https://github.com/childpovertyactionlab/cpaltemplates)
- [CPAL Website](https://childpovertyactionlab.org)
- [Shiny Documentation](https://shiny.posit.co/)
- [bslib Package](https://rstudio.github.io/bslib/)

## License

GPL-3 License - See LICENSE file for details.

---

*Maintained by the CPAL Data Science Team*
