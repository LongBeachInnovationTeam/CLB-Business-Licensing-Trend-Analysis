
#' Merge history and forecast for plotting.
#'
#' @param m Prophet object.
#' @param fcst Data frame returned by prophet predict.
#'
#' @importFrom dplyr "%>%"
df_for_plotting <- function(m, fcst) {
  # Make sure there is no y in fcst
  fcst$y <- NULL
  df <- m$history %>%
    dplyr::select(ds, y) %>%
    dplyr::full_join(fcst, by = "ds") %>%
    dplyr::arrange(ds)
  return(df)
}

#' Plot the prophet forecast.
#'
#' @param x Prophet object.
#' @param fcst Data frame returned by predict(m, df).
#' @param uncertainty Boolean indicating if the uncertainty interval for yhat
#'  should be plotted. Must be present in fcst as yhat_lower and yhat_upper.
#' @param xlabel Optional label for x-axis
#' @param ylabel Optional label for y-axis
#' @param ... additional arguments
#'
#' @return A ggplot2 plot.
#'
#' @examples
#' \dontrun{
#' history <- data.frame(ds = seq(as.Date('2015-01-01'), as.Date('2016-01-01'), by = 'd'),
#'                       y = sin(1:366/200) + rnorm(366)/10)
#' m <- prophet(history)
#' future <- make_future_dataframe(m, periods = 365)
#' forecast <- predict(m, future)
#' plot(m, forecast)
#' }
#'
#' @export
plot_forecast <- function(x, fcst, uncertainty = TRUE, xlabel = 'ds',
                         ylabel = 'y', ...) {
  df <- df_for_plotting(x, fcst)
  forecast.color <- "#0072B2"
  gg <- ggplot2::ggplot(df, ggplot2::aes(x = ds, y = y)) +
    ggplot2::labs(x = xlabel, y = ylabel)
  if (exists('cap', where = df)) {
    gg <- gg + ggplot2::geom_line(
      ggplot2::aes(y = cap), linetype = 'dashed', na.rm = TRUE)
  }
  if (uncertainty && exists('yhat_lower', where = df)) {
    gg <- gg +
      ggplot2::geom_ribbon(ggplot2::aes(ymin = yhat_lower, ymax = yhat_upper),
                           alpha = 0.2,
                           fill = forecast.color,
                           na.rm = TRUE)
  }
  gg <- gg +
    ggplot2::geom_point(na.rm=TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = yhat), color = forecast.color,
                       na.rm = TRUE) +
    ggplot2::theme(aspect.ratio = 3 / 5)
  return(gg)
}

#' Plot the trend component of a prophet forecast.
#' Prints a ggplot2 with panels for trend, weekly and yearly seasonalities if
#' present, and holidays if present.
#'
#' @param m Prophet object.
#' @param fcst Data frame returned by predict(m, df).
#' @param uncertainty Boolean indicating if the uncertainty interval should be
#'  plotted for the trend, from fcst columns trend_lower and trend_upper.
#' @param xlabel Optional label for x-axis
#' @param ylabel Optional label for y-axis
#'
#' @return A ggplot2 plot.
#'
#' @export
#' @importFrom dplyr "%>%"
prophet_plot_trend_component <- function(m, fcst, uncertainty = TRUE, xlabel = 'Day of year', ylabel = '') {
  df <- df_for_plotting(m, fcst)
  forecast.color <- "#0072B2"
  # Plot the trend
  gg.trend <- ggplot2::ggplot(df, ggplot2::aes(x = ds, y = trend)) +
    ggplot2::geom_line(color = forecast.color, na.rm = TRUE)
  if (exists('cap', where = df)) {
    gg.trend <- gg.trend + ggplot2::geom_line(ggplot2::aes(y = cap),
                                              linetype = 'dashed',
                                              na.rm = TRUE)
  }
  if (uncertainty) {
    gg.trend <- gg.trend +
      ggplot2::geom_ribbon(ggplot2::aes(ymin = trend_lower,
                                        ymax = trend_upper),
                           alpha = 0.2,
                           fill = forecast.color,
                           na.rm = TRUE)
  }
  gg.trend <- gg.trend +
    ggplot2::labs(x = xlabel, y = ylabel)
  return (gg.trend)
}

#' Plot the yearly component of a prophet forecast.
#' Prints a ggplot2 with panels for trend, weekly and yearly seasonalities if
#' present, and holidays if present.
#'
#' @param m Prophet object.
#' @param fcst Data frame returned by predict(m, df).
#' @param uncertainty Boolean indicating if the uncertainty interval should be
#'  plotted for the trend, from fcst columns trend_lower and trend_upper.
#' @param xlabel Optional label for x-axis
#' @param ylabel Optional label for y-axis
#'
#' @return A ggplot2 plot.
#'
#' @export
#' @importFrom dplyr "%>%"
prophet_plot_yearly_component <- function(m, fcst, uncertainty = TRUE, xlabel = 'Day of year', ylabel = '') {
  df <- df_for_plotting(m, fcst)
  forecast.color <- "#0072B2"
  # Plot yearly seasonality, if present
  if ("yearly" %in% colnames(df)) {
    # Drop year from the dates
    df.s <- df %>%
      dplyr::mutate(doy = strftime(ds, format = "2000-%m-%d")) %>%
      dplyr::group_by(doy) %>%
      dplyr::slice(1) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(doy = zoo::as.Date(doy)) %>%
      dplyr::arrange(doy)
    gg.yearly <- ggplot2::ggplot(df.s, ggplot2::aes(x = doy, y = yearly,
                                                    group = 1)) +
      ggplot2::geom_line(color = forecast.color, na.rm = TRUE) +
      ggplot2::scale_x_date(labels = scales::date_format('%B %d')) +
      ggplot2::labs(x = xlabel, y = ylabel)
    if (uncertainty) {
      gg.yearly <- gg.yearly +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = yearly_lower,
                                          ymax = yearly_upper),
                             alpha = 0.2,
                             fill = forecast.color,
                             na.rm = TRUE)
    }
    return (gg.yearly)
  }
}

df_daily_count <- function(df, start_date, end_date, target_date) {
  return (
    df %>%
      mutate(ds = as_date(target_date)) %>%
      filter(ds >= start_date & ds <= end_date) %>%
      group_by(ds) %>% 
      summarise(
        y = log(n())
      ) %>% 
      select(ds, y)
  )
}