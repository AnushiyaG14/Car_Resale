import streamlit as st
import psycopg2
import pandas as pd


# Define a function to connect to the PostgreSQL database
def connect_to_db():
    try:
        # Establish a connection to the PostgreSQL server
        _conn = psycopg2.connect(
            dbname="project",
            user="postgres",
            password="root",
            host="localhost",
            port="5433"
        )
        return _conn
    except Exception as e:
        st.error(f"Error: {e}")
        return None

# Fetch top-selling products
@st.cache_data
def fetch_top_selling_products(_conn, limit=10):
    query = """
    SELECT category,sub_category,product_id,round(cast(sum(total_sales) as numeric),2) as total_sales_value
    FROM retail_sales
    GROUP BY category,sub_category,product_id
    ORDER BY total_sales_value DESC
    LIMIT %s;
    """
    try:
        return pd.read_sql_query(query, _conn, params=(limit,))
    except Exception as e:
        st.error(f"Error fetching data: {e}")
        return pd.DataFrame()
# Fetch product sales by category data
@st.cache_data
def fetch_product_sales_data(_conn, category, limit, sales_type):
    query = """
    WITH product_summary AS (
    SELECT product_id, category, 
           ROUND(CAST(SUM(total_sales) AS NUMERIC), 2) AS tot_rev,
           SUM(t_profit) AS total_margin
    FROM retail_sales
    GROUP BY product_id, category
),
rank_prod AS (
    SELECT product_id, category, tot_rev, total_margin,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY tot_rev DESC) AS r_rank
    FROM product_summary
)
SELECT product_id, category, tot_rev, total_margin, r_rank,
       CASE
           WHEN tot_rev > 10000 THEN 'Most Selling'
           ELSE 'Least Selling'
       END AS rev_cat
FROM rank_prod
WHERE tot_rev > 0
  AND LOWER(category) = LOWER(%s)
  AND LOWER(
      CASE
          WHEN tot_rev > 10000 THEN 'Most Selling'
          ELSE 'Least Selling'
      END
  ) = LOWER(%s)
ORDER BY r_rank
LIMIT %s;  
    """
    try:
        return pd.read_sql_query(query, _conn, params=(category, sales_type, limit))
    except Exception as e:
        st.error(f"Error fetching data: {e}")
        return pd.DataFrame()

# Dashboard: Top-Selling Products
def top_selling_dashboard(conn):
    st.title("Top-Selling Products Dashboard")
    limit = st.slider("Number of Top Products to Display", min_value=5, max_value=50, value=10)

    if st.button("Run Query"):
        top_products = fetch_top_selling_products(conn, limit)
        if not top_products.empty:
            st.dataframe(top_products)
            st.bar_chart(data=top_products.set_index("product_id"), y="total_sales_value")
        else:
            st.warning("No data available.")

# Dashboard: Product Sales by Category
def product_sales_dashboard(conn):
    st.title("Product Sales by Category")
    st.sidebar.header("Filters")
    category = st.sidebar.text_input("Enter Category")
    sales_type = st.sidebar.radio(
        "Select Sales Type",
        options=["Most Selling", "Least Selling"],
        index=0
    )
    limit = st.sidebar.slider("Number of Products to Display", 1, 20, 10)

    if st.sidebar.button("Run Query"):
        data = fetch_product_sales_data(conn, category, limit, sales_type)
        if not data.empty:
            st.dataframe(data)
            st.bar_chart(data.set_index("product_id")["tot_rev"])
        else:
            st.warning("No data found for the selected filters.")

# Main function
def main():
    st.sidebar.title("Dashboard Selection")
    dashboard = st.sidebar.radio(
        "Choose a Dashboard",
        options=["Top-Selling Products", "Product Sales by Category"]
    )

    # Connect to the database
    conn = connect_to_db()
    if conn is None:
        return

    # Display selected dashboard
    if dashboard == "Top-Selling Products":
        top_selling_dashboard(conn)
    elif dashboard == "Product Sales by Category":
        product_sales_dashboard(conn)

    # Close the connection
    conn.close()

if __name__ == "__main__":
    main()






