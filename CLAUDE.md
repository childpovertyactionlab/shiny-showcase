# CLAUDE.md - CPAL Shiny Theme Reference App Project Plan

## Project Overview

This project is a **reference Shiny application** for the Child Poverty Action Lab (CPAL) Data Science and Data Operations team. It serves as a living showcase of all available Shiny inputs, outputs, and UI components that work with the `cpaltemplates` package theming system.

**Repository:** https://github.com/childpovertyactionlab/cpaltemplates
**Purpose:** Provide team members with a visual reference and code examples for building consistent, branded Shiny applications

---

## ⚠️ CRITICAL: Logging & Best Practices

### Mandatory Logging

**Claude Code MUST maintain logs throughout this project.** Before making ANY changes:

1. **Log every action** in `logs/session-log.md`
2. **Document decisions** in `logs/decisions.md`
3. **Track all file changes** in `logs/changelog.md`

### Log Entry Format

Every significant action should be logged with:
```markdown
### [TIMESTAMP] - [ACTION TYPE]
**What:** Brief description of action
**Why:** Reasoning behind the action
**Files affected:** List of files
**Result:** Outcome (success/failure/partial)
**Next steps:** What follows from this
```

### Action Types to Log
- `DISCOVERY` - Reading/analyzing files
- `DIAGNOSIS` - Identifying issues
- `CHANGE` - Modifying code
- `CREATE` - Creating new files
- `DELETE` - Removing files
- `TEST` - Running/testing code
- `DECISION` - Making a choice between options
- `QUESTION` - Flagging something for human review
- `ROLLBACK` - Undoing a change

### Before ANY Code Change

1. ✅ Log what you're about to do
2. ✅ Explain WHY you're doing it
3. ✅ Create backup if modifying existing file (copy to `backups/`)
4. ✅ Make the change
5. ✅ Test if possible
6. ✅ Log the result

### Git Commit Conventions

When suggesting or making commits, use conventional commits:
```
feat: add new component showcase for datatables
fix: resolve _brand.yml loading error
refactor: migrate color functions to cpaltemplates
docs: update README with usage examples
chore: remove deprecated template-sources files
style: apply consistent formatting to views
test: add component rendering tests
```

### File Modification Rules

1. **Never overwrite without backup** - Copy original to `backups/[filename].[timestamp].bak`
2. **Small, incremental changes** - Don't refactor everything at once
3. **Test after each change** - Run `shiny::runApp()` to verify
4. **Comment your changes** - Add `# CLAUDE: [reason]` comments for non-obvious changes

### Communication Patterns

**🔔 NOTIFICATIONS: When you need human input, ALWAYS trigger a notification:**

```r
# Source the notification helper (do this once per session)
source("R/notify.R")

# Then call when needed:
notify_decision_needed("Which option for component layout?")
notify_error("App failed to start - see error below")
notify_blocked("Need API key to continue")
notify_complete("Phase 1 review finished")
notify_ready_for_review("Phase 1 Discovery")
```

Or via PowerShell (Windows):
```powershell
.\notify.ps1 "Decision needed: component layout options"
.\notify.ps1 -Message "Your message" -Title "Custom Title"
```

**When you need human input, clearly state:**
```
🔴 DECISION NEEDED:
[Clear description of the choice]

Option A: [description]
- Pros: ...
- Cons: ...

Option B: [description]
- Pros: ...
- Cons: ...

My recommendation: [X] because [reason]

Please confirm or choose differently.
```

**When reporting progress:**
```
✅ COMPLETED: [task]
📋 SUMMARY: [what was done]
📁 FILES CHANGED: [list]
⏭️ NEXT: [what's coming]
```

**When encountering errors:**
```
🔴 ERROR ENCOUNTERED:
[Error message]

📍 Location: [file:line or context]
🔍 Likely cause: [analysis]
💡 Proposed fix: [solution]
⚠️ Risk level: [low/medium/high]
```

---

## Phase 1: Discovery & Understanding

### 1.1 Review Project Structure

**First, explore the full project directory structure:**
```r
# List all files in the project
fs::dir_tree(".", recurse = TRUE)
```

**Key files and folders to examine:**
- [ ] `app.R` - Main application entry point
- [ ] `_brand.yml` - Brand configuration (sourced from cpaltemplates)
- [ ] `views/` folder - Individual view modules for the Shiny app
- [ ] `template-sources/` folder - Legacy function scripts (to be deprecated)
- [ ] Any `R/` folder for helper functions
- [ ] `www/` folder for static assets (CSS, images, JS)
- [ ] `.Rprofile` or `renv.lock` for dependencies

### 1.2 Understand the cpaltemplates Package

**Review the package documentation:**
```r
# Check if cpaltemplates is installed
packageVersion("cpaltemplates")

# List all exported functions
ls("package:cpaltemplates")

# Review key functions
?cpaltemplates::cpal_theme
# Or explore the GitHub repo structure
```

**Key questions to answer:**
- What UI components does cpaltemplates provide?
- What themes/color palettes are available?
- What Shiny-specific functions exist (inputs, outputs, wrappers)?
- How does `_brand.yml` integrate with the package?

### 1.3 Analyze Current app.R

**Read and understand the main application file:**
- How is the UI structured?
- What server logic exists?
- Which scripts from `template-sources/` are being sourced?
- Are there any hardcoded styles that should be in cpaltemplates?

### 1.4 Review Views Folder

**For each file in `views/`:**
- Document what UI components are demonstrated
- Note any custom styling or workarounds
- Identify reusable patterns vs. one-off implementations

### 1.5 Audit template-sources Folder

**For each script in `template-sources/`:**
- [ ] Check if function already exists in cpaltemplates
- [ ] If not in package, determine if it SHOULD be added
- [ ] Document any functions that should remain as reference-only examples

---

## Phase 2: Error Checking & Validation

### 2.1 Run the Application

```r
# Attempt to run the app and capture any warnings/errors
shiny::runApp()
```

**Document:**
- [ ] Any startup errors
- [ ] Console warnings during load
- [ ] Missing dependencies
- [ ] Deprecated function warnings
- [ ] UI rendering issues

### 2.2 Package Dependency Check

```r
# Check all dependencies are available
renv::status()  # if using renv
# OR
devtools::check()  # for general dependency issues
```

### 2.3 Code Quality Review

- [ ] Check for `source()` calls that should be replaced with package imports
- [ ] Identify any `library()` calls for packages not in DESCRIPTION/renv
- [ ] Look for hardcoded paths that may break on other machines
- [ ] Find any deprecated Shiny syntax

---

## Phase 3: Gap Analysis & Documentation

### 3.1 Create Component Inventory

Build a comprehensive list of all Shiny components that SHOULD be demonstrated:

**Standard Shiny Inputs:**
- [ ] textInput / textAreaInput
- [ ] numericInput
- [ ] selectInput / selectizeInput
- [ ] checkboxInput / checkboxGroupInput
- [ ] radioButtons
- [ ] sliderInput
- [ ] dateInput / dateRangeInput
- [ ] fileInput
- [ ] actionButton / actionLink
- [ ] downloadButton

**Standard Shiny Outputs:**
- [ ] textOutput / verbatimTextOutput
- [ ] tableOutput / dataTableOutput
- [ ] plotOutput
- [ ] imageOutput
- [ ] uiOutput / htmlOutput

**Layout Components:**
- [ ] fluidPage / fixedPage
- [ ] sidebarLayout
- [ ] navbarPage / tabsetPanel
- [ ] fluidRow / column
- [ ] wellPanel / conditionalPanel
- [ ] bslib cards and components

**cpaltemplates-specific Components:**
- [ ] (List after reviewing package)

### 3.2 Determine What Goes Where

Create decision matrix:

| Component/Function | In cpaltemplates? | Should be in package? | Reference doc only? | Notes |
|-------------------|-------------------|----------------------|---------------------|-------|
| (Fill after review) | | | | |

### 3.3 Document Gaps

**Functions needed in cpaltemplates:**
- (List after analysis)

**Reference documentation needed:**
- (List after analysis)

---

## Phase 4: Refactoring & Cleanup

### 4.1 Remove template-sources Dependencies

**For each sourced script:**
1. Identify the equivalent cpaltemplates function
2. Replace `source("template-sources/xyz.R")` with package import
3. Test that functionality is preserved
4. Remove the source file OR move to an `examples/` folder

### 4.2 Restructure Views

Consider organizing views by category:
```
views/
├── 01_inputs/
│   ├── text_inputs.R
│   ├── selection_inputs.R
│   └── action_inputs.R
├── 02_outputs/
│   ├── text_outputs.R
│   ├── table_outputs.R
│   └── plot_outputs.R
├── 03_layouts/
│   └── layout_examples.R
└── 04_advanced/
    └── custom_components.R
```

### 4.3 Improve Code Organization

- [ ] Use Shiny modules where appropriate
- [ ] Add roxygen-style comments to complex functions
- [ ] Ensure consistent code style (consider styler package)
- [ ] Add meaningful comments for team reference

---

## Phase 5: Enhancement Planning

### 5.1 Potential New Features

**Interactive Documentation:**
- [ ] Code preview alongside rendered components
- [ ] Copy-to-clipboard functionality for code snippets
- [ ] Toggle between "preview" and "code" views

**Component Showcase Improvements:**
- [ ] Live customization options (change colors, sizes)
- [ ] Responsive design testing view
- [ ] Dark mode preview (if supported)
- [ ] Accessibility information

**Developer Experience:**
- [ ] Quick-start templates for common app patterns
- [ ] Component search/filter functionality
- [ ] Integration with pkgdown documentation

### 5.2 Priority Matrix

| Feature | Impact | Effort | Priority |
|---------|--------|--------|----------|
| (Fill after discussion) | | | |

---

## Phase 6: Repository Setup

### 6.1 Suggested Repository Names

**Primary Recommendations:**
1. `shiny-showcase` - Clear, descriptive
2. `cpal-shiny-reference` - Emphasizes reference nature
3. `cpal-ui-gallery` - Broader scope implication
4. `shinycpal` - Short, memorable (like shinydashboard)
5. `cpal-component-library` - Technical, comprehensive

**App Name Options (replacing "theme-base"):**
1. `CPAL Shiny Gallery`
2. `CPAL Component Showcase`
3. `CPAL UI Reference`
4. `CPAL Design System`
5. `cpaltemplates Explorer`

### 6.2 Repository Structure

```
shiny-showcase/
├── app.R
├── _brand.yml
├── CLAUDE.md
├── README.md
├── NEWS.md
├── .gitignore
├── renv.lock
├── R/
│   └── helpers.R
├── views/
│   ├── inputs.R
│   ├── outputs.R
│   └── layouts.R
├── www/
│   ├── custom.css
│   └── images/
└── examples/
    └── starter_templates/
```

---

## Working Notes

### Questions for Team Discussion
1. Should this app be deployed to shinyapps.io or internal server?
2. What's the current deployment workflow for CPAL Shiny apps?
3. Are there any compliance/accessibility requirements?
4. Which team members will be primary maintainers?

### Technical Decisions Needed
1. Use `bslib` vs. traditional Bootstrap?
2. Module architecture vs. flat structure?
3. Renv vs. no dependency management?
4. GitHub Actions for CI/CD?

### Current Session Progress
- [ ] Phase 1 complete
- [ ] Phase 2 complete
- [ ] Phase 3 complete
- [ ] Phase 4 complete
- [ ] Phase 5 complete
- [ ] Phase 6 complete

---

## Commands Reference

```r
# Run the app
shiny::runApp()

# Install cpaltemplates from GitHub
remotes::install_github("childpovertyactionlab/cpaltemplates")

# Check package functions
ls("package:cpaltemplates")

# Style code
styler::style_dir(".")

# Check for issues
lintr::lint_dir(".")
```

---

## Safety & Recovery Practices

### Backup Strategy

Before modifying any file:
```r
# Create timestamped backup
file.copy("app.R", paste0("backups/app.R.", format(Sys.time(), "%Y%m%d_%H%M%S"), ".bak"))
```

### Recovery Commands

If something breaks:
```r
# Restore from backup
file.copy("backups/app.R.[timestamp].bak", "app.R", overwrite = TRUE)

# Or use git
# git checkout -- app.R
# git stash
```

### Testing After Changes

Always run these checks after modifications:
```r
# 1. Syntax check
source("app.R")  # Should not error

# 2. Run app
shiny::runApp()  # Should launch without errors

# 3. Check for warnings
options(warn = 2)  # Treat warnings as errors temporarily
shiny::runApp()
options(warn = 0)  # Reset
```

---

## Session Management

### Starting a New Session

1. Read this entire CLAUDE.md file
2. Check `logs/session-log.md` for previous session context
3. Review any open items in `logs/decisions.md`
4. Announce session start in log

### Ending a Session

1. Summarize all changes made in `logs/session-log.md`
2. List any incomplete tasks
3. Note any blockers or questions for human
4. Update "Current Session Progress" checklist
5. Create session summary entry

### Handing Off to Human

When ending a session or needing human review:
```markdown
## Session Summary - [DATE]

### Completed This Session
- [ ] Task 1
- [ ] Task 2

### In Progress
- [ ] Task 3 (blocked by X)

### Needs Human Decision
- [ ] Decision about Y (see logs/decisions.md)

### Recommended Next Steps
1. Step 1
2. Step 2

### Files Modified
- `file1.R` - [brief description]
- `file2.R` - [brief description]

### Known Issues
- Issue 1
- Issue 2
```

---

## Quality Standards

### Code Style

- Use tidyverse style guide
- 2-space indentation
- Maximum line length: 80 characters
- Meaningful variable names
- Comment complex logic

### Documentation Standards

Every function should have:
```r
#' Brief description
#'
#' Longer description if needed
#'
#' @param x Description of x
#' @return Description of return value
#' @examples
#' example_usage()
function_name <- function(x) {
  # Implementation
}
```

### Shiny-Specific Standards

- Use modules for reusable components
- Namespace all IDs properly
- Avoid global variables
- Use reactive values appropriately
- Include loading states for async operations

---

*Last Updated: [Date]*
*Claude Code Session: [Session ID]*
