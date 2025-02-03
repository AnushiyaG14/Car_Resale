 select p.order_id,p.sub_category,sum(o.sales_price),rank() over(order by sum(o.sales_price) desc) as rank from 
 order_ret1 as p join order_ret2 as o on p.order_id=o.id group by p.order_id;

 Select extract(Year from c.order_date) as Year, extract(Month from c.order_date) as Month, SUM(p.sales_price) AS total_sales FROM 
 order_ret1 as c join order_ret2  as p on c.order_id=p.id group by
 extract(Year from c.order_date),extract(Month from c.order_date) order by Year, Month ;

 select extract(Month from c.order_date) as Month, sum((p.sales_price)*p.quantity) as TotalRevenue from 
 order_ret2 as p, order_ret1 as c group by  extract(Month from c.order_date) order by Month;

 SELECT c.order_id, SUM(p.sales_price) AS total_revenue, SUM(profit) AS total_profit,
 CASE WHEN SUM(p.profit)/NULLIF(SUM(p.sales_price), 0) > 0.2 THEN 'High Margin' ELSE 'Low Margin' END 
 AS profit_category, ROW_NUMBER() OVER(ORDER BY SUM(p.sales_price) DESC) AS rank FROM order_ret1 as c join order_ret2 as p 
 on c.order_id=p.id GROUP BY c.order_id HAVING SUM(p.sales_price) > 0 ORDER BY total_revenue DESC limit 10;

 SELECT c.region, SUM(p.sales_price) AS total_sales FROM order_ret1 as c join order_ret2 as p on c.order_id=p.id
 GROUP BY c.region ORDER BY total_sales DESC;


 select c.sub_category as product from order_ret1 as c join
 order_ret2 as p on c.order_id=p.id group by c.sub_category order by avg(p.discount_percent)>20 desc limit 10;
 
 