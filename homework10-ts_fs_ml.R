#---------------------------------
#Script Name
#Purpose:homework10
#Author:  botaoyuan
#Email:  botaoyuan@foxmail.com
#Date:  2024/05/17  edit
#
#-------------------------------
# Clear console and remove all variables
cat("\014")
rm(list = ls())

# 安装并加载必要的库
library(tidyverse)
library(lubridate)
library(timetk)
library(tsibble)
library(tidymodels)
library(imputeTS)

# 加载数据
data <- read.table('/home/botaoyuan/Prunier et al._RawBiomassData.txt', header = TRUE)

# 过滤出VERCah站点的VAI物种的数据
fish_data <- data %>%
  filter(STATION == "VERCah", SP == "VAI")

# 创建时间序列对象
# 检查是否有重复的日期
duplicate_dates <- fish_data %>%
  group_by(DATE) %>%
  filter(n() > 1) %>%
  arrange(DATE)

if(nrow(duplicate_dates) > 0) {
  cat("存在重复的日期:\n")
  print(duplicate_dates)
}

# 为处理重复日期，进行聚合
fish_data <- fish_data %>%
  group_by(DATE) %>%
  summarize(DENSITY = mean(DENSITY, na.rm = TRUE))

# 创建时间序列对象
ts_data <- fish_data %>%
  mutate(DATE = ymd(DATE)) %>%
  as_tsibble(index = DATE)

# 检查并替换缺失值
ts_data <- ts_data %>%
  fill_gaps()

# 使用线性插值来填充连续缺失值
ts_data <- ts_data %>%
  mutate(DENSITY = na_interpolation(DENSITY, option = "linear"))

# 再次检查是否有缺失值
if(any(is.na(ts_data$DENSITY))) {
  cat("警告: 数据中仍存在缺失值\n")
}

# 确保 DENSITY 列为数值型
ts_data <- ts_data %>%
  mutate(DENSITY = as.numeric(DENSITY))

# 可视化时间序列
ggplot(ts_data, aes(x = DATE, y = DENSITY)) +
  geom_line() +
  labs(title = "Fish Density Time Series", x = "Date", y = "Density")

# 特征提取：添加滞后值作为特征
lagged_data <- ts_data %>%
  tk_augment_lags(DENSITY, .lags = 1:3)

# 检查滞后特征中的缺失值并处理
lagged_data <- lagged_data %>%
  filter(!is.na(DENSITY_lag1) & !is.na(DENSITY_lag2) & !is.na(DENSITY_lag3))

# 确保 lagged_data 是一个标准的 tibble
lagged_data <- as_tibble(lagged_data)

# 确认 lagged_data 中没有日期重复
lagged_data <- lagged_data %>%
  distinct(DATE, .keep_all = TRUE)

# 将数据拆分为训练集和测试集
train_size <- floor(0.8 * nrow(lagged_data))
train_data <- lagged_data[1:train_size, ]
test_data <- lagged_data[(train_size + 1):nrow(lagged_data), ]

# 确认训练数据和测试数据中没有缺失值
if(any(is.na(train_data$DENSITY)) || any(is.na(test_data$DENSITY))) {
  cat("警告: 训练集或测试集中存在缺失值\n")
} else {
  cat("训练集和测试集中无缺失值\n")
}

# 确保 DENSITY 列为数值型
train_data <- train_data %>%
  mutate(DENSITY = as.numeric(DENSITY))
test_data <- test_data %>%
  mutate(DENSITY = as.numeric(DENSITY))

# 构建机器学习预测模型
model <- linear_reg() %>%
  set_engine("lm")

# 训练模型
fit <- model %>%
  fit(DENSITY ~ ., data = train_data)

# 进行预测
predictions <- predict(fit, new_data = test_data)

# 将预测结果合并到测试数据中
test_data <- test_data %>%
  mutate(predicted_DENSITY = predictions$.pred)

# 评估模型
rmse_val <- rmse(test_data, truth = DENSITY, estimate = predicted_DENSITY)
mae_val <- mae(test_data, truth = DENSITY, estimate = predicted_DENSITY)

cat("RMSE:", rmse_val$.estimate, "\n")
cat("MAE:", mae_val$.estimate, "\n")

# 可视化实际值和预测值
ggplot() +
  geom_line(data = ts_data, aes(x = DATE, y = DENSITY), color = "black", linewidth = 1) +
  geom_line(data = test_data, aes(x = DATE, y = predicted_DENSITY), color = "red", linewidth = 1) +
  labs(title = "Actual vs Predicted Fish Density", x = "Date", y = "Density") +
  theme_minimal()

