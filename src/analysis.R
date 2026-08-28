# analysis.R -- Video view analysis (week 2 practice)
# Run from the repo root:
#   Rscript src/analysis.R
# Outputs are written to tmp/.

library(tidyverse)

# --- Load the data -------------------------------------------------------
# Same loading pattern as the tutorial: use the local file if it exists,
# otherwise download it once.
data_path <- "data/video_view.csv"

if (!file.exists(data_path)) {
  dir.create("data", showWarnings = FALSE)
  data_url <- paste0(
    "https://raw.githubusercontent.com/hannesdatta/",
    "course-dprep/refs/heads/main/material/tutorials/r-bootcamp-rev/",
    "video_view.csv"
  )
  download.file(data_url, data_path)
}

videos <- read_csv(data_path)

# --- Inspect -------------------------------------------------------------
glimpse(videos)

# Make sure the output folder exists.
dir.create("tmp", showWarnings = FALSE)

# --- 1. Creator summary (group_by + summarise) ---------------------------
creator_summary <- videos %>%
  group_by(creator_id) %>%
  summarise(
    videos_n          = n(),
    impressions_total = sum(impressions_n, na.rm = TRUE),
    watch_rate_avg    = mean(watch_rate, na.rm = TRUE)
  ) %>%
  arrange(desc(impressions_total))

write_csv(creator_summary, "tmp/creator_summary.csv")

# --- 2. Top-watched, reasonably-visible videos (select + filter) ---------
top_watch <- videos %>%
  select(video_id, creator_id, impressions_n, watch_rate) %>%
  filter(impressions_n >= 50) %>%
  arrange(desc(watch_rate))

write_csv(top_watch, "tmp/top_watch.csv")

# --- 3. Creator engagement (mutate + group_by + summarise) ---------------
creator_engagement <- videos %>%
  mutate(engagement = watched_n / impressions_n) %>%
  group_by(creator_id) %>%
  summarise(mean_engagement = mean(engagement, na.rm = TRUE)) %>%
  arrange(desc(mean_engagement))

write_csv(creator_engagement, "tmp/creator_engagement.csv")

message("Done. Results written to tmp/.")
