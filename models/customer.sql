{{
    config(
        materialized='table'
    )
}}

with customers as (
	SELECT
		id as customer_id,
		first_name,
		last_name
	FROM `dbt-tutorial.data_prep.jaffle_shop_customers`
),

orders as (
	SELECT
		id as order_id,
		user_id as customer_id,
		order_date,
		status
	FROM `dbt-tutorial.data_prep.jaffle_shop_orders`
),

customer_orders as (
	SELECT
		customer_id,
		min(order_date) as first_order_date,
		max(order_date) as most_recent_order_date,
		count(order_id) as number_of_orders
	FROM orders
	GROUP BY 1
),

final as (
	SELECT
		customers.customer_id,
		customers.first_name,
		customers.last_name,
		customer_orders.first_order_date,
		customer_orders.most_recent_order_date,
		COALESCE(customer_orders.number_of_orders, 0) as number_of_orders
	FROM customers
	
	left join customer_orders using (customer_id)
)

SELECT * FROM final