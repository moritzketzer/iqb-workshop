source(file.path(dirname(sys.frame(1)$ofile), "plot-theme.R"))

set.seed(42)

n_per_group <- 300

# Fork DGP: Z -> X, Z -> Y
# 3 overlapping groups — cloud looks homogeneous, reversal hidden
# Within each group: positive slope
# Aggregate: negative slope from intercept shifts

intercepts <- c(22, 14, 6)
x_means <- c(6, 14, 22)
x_sd <- 5
slope <- 0.5
y_noise_sd <- 3
labels <- c("Group 1", "Group 2", "Group 3")

data <- do.call(rbind, lapply(seq_along(labels), function(i) {
  x <- rnorm(n_per_group, mean = x_means[i], sd = x_sd)
  y <- slope * x + intercepts[i] + rnorm(n_per_group, sd = y_noise_sd)
  data.frame(x = x, y = y, group = labels[i])
}))
data$group <- factor(data$group)

shared_theme <- theme(
  axis.title = element_text(size = 22),
  axis.text = element_text(size = 18),
  legend.text = element_text(size = 20),
  legend.key.size = unit(1.5, "lines"),
  legend.position = "top"
)

# Plot 1: innocent-looking cloud with aggregate line only
p_aggregate <- ggplot(data, aes(x = x, y = y)) +
  geom_point(alpha = 0.3, color = STYLE_MUTED, size = 2) +
  geom_smooth(
    method = "lm", se = TRUE, color = STYLE_INK,
    linewidth = 1.8, fill = STYLE_AXIS, alpha = 0.25
  ) +
  labs(x = "X", y = "Y") +
  shared_theme

# Plot 2: same data, colored by group, group lines + aggregate
p_stratified <- ggplot(data, aes(x = x, y = y)) +
  geom_point(aes(color = group), alpha = 0.4, size = 2) +
  geom_smooth(
    method = "lm", se = TRUE, color = STYLE_INK,
    linewidth = 1.8, fill = STYLE_AXIS, alpha = 0.25
  ) +
  geom_smooth(
    aes(color = group), method = "lm", se = FALSE, linewidth = 1.4
  ) +
  scale_color_qual(n = 3) +
  labs(x = "X", y = "Y") +
  shared_theme +
  guides(color = "none")

ggsave(
  "images/plots/fork-simpsons-aggregate.png",
  plot = p_aggregate,
  width = 16, height = 9, units = "in",
  dpi = 300, device = ragg::agg_png
)

ggsave(
  "images/plots/fork-simpsons-stratified.png",
  plot = p_stratified,
  width = 16, height = 9, units = "in",
  dpi = 300, device = ragg::agg_png
)
