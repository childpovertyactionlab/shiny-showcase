# Data Preparation Script: Fetch ACS Child Poverty Data for Texas Counties
# Run this script once to generate cached data files for the Shiny app
# This avoids live API queries when deployed to shinyapps.io

library(tidycensus)
library(tidyverse)
library(sf)

# Set options for tidycensus
options(tigris_use_cache = TRUE)

cat("Fetching ACS data for Texas counties...\n")

# Define ACS variables for child poverty focus
acs_vars <- c(
  total_pop = "B17001_001",           # Total population (poverty universe)
  pop_below_poverty = "B17001_002",   # Population below poverty level
  children_total = "B17020_001",      # Children under 18 (poverty universe)
  children_poverty = "B17020_002",    # Children under 18 below poverty
  median_income = "B19013_001"        # Median household income
)

# Fetch ACS 5-year estimates for Texas counties with geometry
tx_counties_acs <- get_acs(

geography = "county",
  variables = acs_vars,
  state = "TX",
  year = 2022,  # Most recent 5-year ACS
  geometry = TRUE,
  output = "wide"
)

cat("Processing data...\n")

# Clean and calculate derived metrics
tx_poverty_data <- tx_counties_acs %>%
  # Clean county names (remove ", Texas")
  mutate(
    county_name = str_remove(NAME, ", Texas"),
    # Calculate rates
    poverty_rate = (pop_below_povertyE / total_popE) * 100,
    child_poverty_rate = (children_povertyE / children_totalE) * 100,
    # Categorize child poverty levels
    poverty_category = case_when(
      child_poverty_rate >= 30 ~ "Very High (30%+)",
      child_poverty_rate >= 20 ~ "High (20-30%)",
      child_poverty_rate >= 15 ~ "Moderate (15-20%)",
      child_poverty_rate >= 10 ~ "Low (10-15%)",
      TRUE ~ "Very Low (<10%)"
    ),
    # Categorize by median income
    income_category = case_when(
      median_incomeE >= 75000 ~ "High Income ($75k+)",
      median_incomeE >= 50000 ~ "Middle Income ($50-75k)",
      median_incomeE >= 35000 ~ "Lower Middle ($35-50k)",
      TRUE ~ "Low Income (<$35k)"
    ),
    # Population size category
    pop_category = case_when(
      total_popE >= 500000 ~ "Large (500k+)",
      total_popE >= 100000 ~ "Medium (100-500k)",
      total_popE >= 25000 ~ "Small (25-100k)",
      TRUE ~ "Rural (<25k)"
    )
  ) %>%
  # Rename estimate columns for clarity
  rename(
    total_population = total_popE,
    population_in_poverty = pop_below_povertyE,
    total_children = children_totalE,
    children_in_poverty = children_povertyE,
    median_household_income = median_incomeE
  ) %>%
  # Select and order columns
  select(
    GEOID, county_name,
    total_population, population_in_poverty, poverty_rate,
    total_children, children_in_poverty, child_poverty_rate,
    median_household_income,
    poverty_category, income_category, pop_category,
    geometry
  ) %>%
  # Remove any counties with missing data
 filter(!is.na(child_poverty_rate) & !is.na(median_household_income))

cat(paste("Processed", nrow(tx_poverty_data), "Texas counties\n"))

# Summary statistics
cat("\nData Summary:\n")
cat(paste("- Total children in Texas:", scales::comma(sum(tx_poverty_data$total_children)), "\n"))
cat(paste("- Children in poverty:", scales::comma(sum(tx_poverty_data$children_in_poverty)), "\n"))
cat(paste("- Average child poverty rate:", round(mean(tx_poverty_data$child_poverty_rate), 1), "%\n"))
cat(paste("- Median household income range: $",
          scales::comma(min(tx_poverty_data$median_household_income)), " - $",
          scales::comma(max(tx_poverty_data$median_household_income)), "\n"))

# Save as RDS (preserves sf geometry and R data types)
cat("\nSaving data files...\n")

# Full dataset with geometry (for maps)
saveRDS(tx_poverty_data, "data/tx_counties_poverty.rds")
cat("- Saved: data/tx_counties_poverty.rds\n")

# Non-spatial version for faster loading in tables/charts
tx_poverty_df <- tx_poverty_data %>%
  st_drop_geometry() %>%
  as_tibble()
saveRDS(tx_poverty_df, "data/tx_counties_poverty_df.rds")
cat("- Saved: data/tx_counties_poverty_df.rds\n")

cat("\nData preparation complete!\n")
cat("These files will be used by the Shiny app instead of live API queries.\n")
