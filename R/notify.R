# notify.R - Desktop notification helper for Claude Code sessions
# Source this file to enable notifications: source("R/notify.R")

notify_user <- function(message = "Claude Code needs your input", 
                        title = "Claude Code") {
  
  # Detect OS
  sys_info <- Sys.info()["sysname"]
  
  if (sys_info == "Windows") {
    # Windows 10/11 Toast Notification via PowerShell
    
    # Escape quotes in message
    safe_message <- gsub('"', '`"', message)
    safe_title <- gsub('"', '`"', title)
    
    ps_script <- sprintf('
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
$template = @"
<toast>
  <visual>
    <binding template="ToastText02">
      <text id="1">%s</text>
      <text id="2">%s</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.Default"/>
</toast>
"@
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code")
$notifier.Show($toast)
', safe_title, safe_message)
    
    # Write to temp file and execute
    temp_ps <- tempfile(fileext = ".ps1")
    writeLines(ps_script, temp_ps)
    system2("powershell", 
            args = c("-ExecutionPolicy", "Bypass", "-File", temp_ps), 
            wait = FALSE, 
            invisible = TRUE)
    Sys.sleep(0.5)  # Brief pause to let notification fire
    unlink(temp_ps, force = TRUE)
    
    message(paste0("\u2713 Notification sent: ", message))
    
  } else if (sys_info == "Darwin") {
    # macOS
    system(sprintf(
      "osascript -e 'display notification \"%s\" with title \"%s\" sound name \"Ping\"'",
      message, title
    ))
    
  } else if (sys_info == "Linux") {
    # Linux
    result <- system("which notify-send", ignore.stdout = TRUE, ignore.stderr = TRUE)
    if (result == 0) {
      system(sprintf('notify-send "%s" "%s"', title, message))
    } else {
      cat("\a")
      message(paste0("\n!! ATTENTION: ", message, "\n"))
    }
    
  } else {
    # Fallback - terminal bell and message
    cat("\a")
    message(paste0("\n!! ATTENTION: ", message, "\n"))
  }
  
  invisible(TRUE)
}

# ============================================================================
# Convenience wrappers - Claude Code should use these
# ============================================================================

#' Notify when a decision is needed
notify_decision_needed <- function(topic) {
  notify_user(
    message = paste("Decision needed:", topic), 
    title = "Input Required"
  )
}

#' Notify when an error occurs
notify_error <- function(error_msg) {
  notify_user(
    message = paste("Error:", error_msg), 
    title = "Error Encountered"
  )
}

#' Notify when a task is complete
notify_complete <- function(task) {
  notify_user(
    message = paste("Completed:", task), 
    title = "Task Done"
  )
}

#' Notify when blocked on something
notify_blocked <- function(reason) {
  notify_user(
    message = paste("Blocked:", reason), 
    title = "Needs Attention"
  )
}

#' Notify when a phase is complete and ready for review
notify_ready_for_review <- function(phase) {
  notify_user(
    message = paste(phase, "- Ready for your review"), 
    title = "Review Needed"
  )
}

# ============================================================================
# Test function
# ============================================================================

#' Test that notifications are working
test_notification <- function() {
  notify_user("Test notification - if you see this, it's working!", "Test")
}

# Uncomment to test when sourcing:
# test_notification()

message("Notification system loaded. Use notify_user(), notify_decision_needed(), etc.")
