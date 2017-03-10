active_licstatus = c('Active', 'CollcInBus', 'Expired', 'Pending', 'Reactivate', 'Conditionl')
active_milestones = c('Issued', 'Renewed', 'Collections', 'Pre-Collections', 'Pre-Renew', 'Renewed')

business_licenses <- read_csv("../data/raw/business_licenses.csv",
                              col_types = cols(
                                servicedate = col_date("%Y-%m-%d %H:%M:%S"),
                                startdate = col_date("%Y-%m-%d %H:%M:%S"),
                                milestonedate = col_date("%Y-%m-%d %H:%M:%S"),
                                load_date = col_datetime(),
                                bid_code = col_character(),
                                licensecat = col_character(),
                                zip = col_character()
                              )) %>%
  # Filter for observation date
  filter(milestonedate >= analysis_date_start & milestonedate <= analysis_date_end) %>% 
  # Filter for active licenses
  filter(licstatus %in% active_licstatus & milestone %in% active_milestones)

milestones <- read_csv("../data/raw/milestones.csv",
                       col_types = cols(
                         licenseno = col_character(),
                         addby = col_character(),
                         aplickey = col_character(),
                         statusdttm = col_datetime("%Y-%m-%d %H:%M:%S"),
                         code = col_character(),
                         load_date = col_datetime("%Y-%m-%d %H:%M:%S")
                       ))

# Join master license record with milestones
active_license_milestones <- business_licenses %>%
  left_join(milestones, by = c("licenseno"))

# Get a dataframe of license-milestones only only have an "Intake" milestone
active_license_milestones_intake <- active_license_milestones %>% 
  filter(code == "Intake")

# Get a dataframe of license-milestones which only have an "Issued" milestone
active_license_milestones_issued <- active_license_milestones %>% 
  filter(code == "Issued")

# Get a dataframe of license-milestones which only have an "Renewed" milestone
active_license_milestones_renewed <- active_license_milestones %>% 
  filter(code == "Renewed")

# Get the earliest intake statusdttm (process date) for each license
statusdttm_intake <- aggregate(
  active_license_milestones_intake$"statusdttm",
  by = list(active_license_milestones_intake$"licenseno"),
  min
)

# Get the earliest issued statusdttm (process date) for each license
statusdttm_issued <- aggregate(
  active_license_milestones_issued$"statusdttm",
  by = list(active_license_milestones_issued$"licenseno"),
  min
)

# Get the earliest renewed statusdttm (process date) for each license
statusdttm_renewed <- aggregate(
  active_license_milestones_renewed$"statusdttm",
  by = list(active_license_milestones_renewed$"licenseno"),
  min
)

active_license_milestone_summary <- business_licenses %>% 
  merge(statusdttm_intake, by.x = 1, by.y = 1, all.x = TRUE) %>%
  merge(statusdttm_issued, by.x = 1, by.y = 1, all.x = TRUE) %>%
  merge(statusdttm_renewed, by.x = 1, by.y = 1, all.x = TRUE) %>%
  mutate(days_to_issue = as.integer(round(difftime(x.y, x.x, units = "days")))) %>% 
  rename(date_intake = x.x, date_issued = x.y, date_renewed = x)
