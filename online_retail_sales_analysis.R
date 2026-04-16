# Load libraries 
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)

# Import the CSV file into R. Call it: online_retail_data. 
online_retail_data <- read_csv("online_retail.csv", show_col_types = FALSE)
online_retail_data

# Then inspect it with: str(), summary(), glimpse(), and head()
str(online_retail_data)
summary(online_retail_data)
glimpse(online_retail_data)
head(online_retail_data)

# Create a clean dataset called: online_retail_data_clean. Clean the data by: Removing rows with missing CustomerID and Description.
online_retail_data_clean <- online_retail_data %>%
  filter(!is.na(CustomerID), !is.na(Description))
online_retail_data_clean

# Clean the data by Removing rows where Quantity ≤ 0, Removing rows where UnitPrice ≤ 0. These rows represent returns or errors.
online_retail_data_clean <- online_retail_data_clean %>%
  filter(Quantity > 0, UnitPrice > 0)
online_retail_data_clean

# Create Revenue Column. Create a new column: purchase_amount = Quantity * UnitPrice. This represents revenue per transaction.
online_retail_data_clean <- online_retail_data_clean %>%
  mutate(
    purchase_amount = Quantity * UnitPrice
  )
online_retail_data_clean

# Convert: InvoiceDate to Date format. 
online_retail_data_clean <- online_retail_data_clean %>%
  mutate(InvoiceDate = as.POSIXct(InvoiceDate))
online_retail_data_clean

# Then create: year	purchase year, month	purchase month, year_month	monthly period
online_retail_data_clean <- online_retail_data_clean %>%
  mutate(
    purchase_year = year(InvoiceDate),
    month_purchase = month(InvoiceDate),
    year_month = floor_date(InvoiceDate, "month")
  )
online_retail_data_clean

# Monthly Revenue Trend. Create a dataset showing: year_month vs total_revenue.
monthly_revenue_trend <- online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  arrange(desc(total_revenue))
monthly_revenue_trend

# Monthly Orders. Calculate: year_month vs total_orders
monthly_orders <- online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(total_orders = n()) %>%
  arrange(desc(total_orders))
monthly_orders

# Monthly Unique Customers. Calculate: year_month vs unique_customers
monthly_unique_customers <- online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(unique_customers = n_distinct(CustomerID)) %>%
  arrange(desc(unique_customers))
monthly_unique_customers

# Visualization 1 — Revenue Trend. Create a line chart: year_month vs total_revenue. Use: geom_line() and geom_point(). Title example: Monthly Revenue Trend
online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(total_revenue = sum(purchase_amount), .groups = "drop") %>%
  arrange(year_month) %>%
  ggplot(aes(x = year_month, y = total_revenue)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Monthly Revenue Trend",
    x = "Year-Month",
    y = "Total Revenue"
  )

# Visualization 2 — Customer Growth. Create another line chart: year_month vs unique_customers. Title: Monthly Active Customers
online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(unique_customers = n_distinct(CustomerID), .groups = "drop") %>%
  arrange(year_month) %>%
  ggplot(aes(x = year_month, y = unique_customers)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Monthly Active Customers",
    x = "Year-Month",
    y = "Unique Customers"
  )

# Total Revenue by Month Chart
online_retail_data_clean %>%
  group_by(month_purchase) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  arrange(month_purchase) %>%
  ggplot(aes(x = month_purchase, y = total_revenue, fill = month_purchase)) +
  geom_col() +
  labs(
    title = "Total Revenue by Month",
    x = "Month Purchase",
    y = "Total Revenue"
  ) +
  coord_flip()

# Top 10 Products by Revenue. Find the top 10 product descriptions by revenue. Then create a bar chart. Plot: Description vs total_revenue. Use: coord_flip()
top_10_products <- online_retail_data_clean %>%
  group_by(Description) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  slice_max(total_revenue, n = 10) %>%
  ggplot(aes(x = reorder(Description, total_revenue), 
             y = total_revenue, fill = Description)) +
  geom_col() +
  labs(
    title = "Top 10 Products by Revenue",
    x = "Product",
    y = "Total_Revenue"
  ) +
  coord_flip()
top_10_products

# Top Countries by Revenue. Find: Top 10 countries by total revenue. Create a bar chart.
top_10_countries <- online_retail_data_clean %>%
  group_by(Country) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  slice_max(total_revenue, n = 10) %>%
  ggplot(aes(x = reorder(Country, total_revenue),
             y = total_revenue, fill = Country)) +
  geom_col() +
  labs(
    title = "Top 10 Countries by Total Revenue",
    x = "Country",
    y = "Total Revenue"
  ) +
  coord_flip()
top_10_countries

# Top Customers. Find: Top 10 customers by revenue
top_10_customers <- online_retail_data_clean %>%
  group_by(CustomerID) %>%
  summarise(total_revenue = sum(purchase_amount)) %>%
  slice_max(total_revenue, n = 10) %>%
  ggplot(aes(x = reorder(CustomerID, total_revenue),
             y = total_revenue, fill = CustomerID)) +
  geom_col() +
  labs(
    title = "Top 10 Customers by Revenue",
    x = "Customers",
    y = "Total Revenue"
  ) +
  coord_flip()
top_10_customers

# Average Order Value. Create: average_order_value = total_revenue / total_orders. Plot trend over time.
aov_trend <- online_retail_data_clean %>%
  group_by(year_month) %>%
  summarise(
    total_revenue = sum(purchase_amount),
    total_orders = n()
  ) %>%
  mutate(average_order_value = total_revenue / total_orders)
aov_trend

# Plot trend
ggplot(aov_trend, aes(x = year_month, y = average_order_value)) +
  geom_line() +
  geom_point() +
labs(
  title = "Average Order Value Over Time",
  x = "Year-Month",
  y = "Average Order Value"
)