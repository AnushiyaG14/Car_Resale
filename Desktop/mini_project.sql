create table order_ret("order_id" SERIAL PRIMARY KEY, "order_date" date,"ship_mode" varchar(50),"segment" varchar(50),"country" varchar(50), "city" varchar(50),
       "state" varchar(50),"postal_code"varchar(50),"region"varchar(50),"category"varchar(50),"sub_category"varchar(50),
       "product_id"varchar(50),"cost_price"numeric,"list_price"numeric,"quantity" integer,
       "discount_percent" numeric,"discount" numeric,"sales_price" numeric,"profit" numeric);

select * from order_ret;

create table order_ret1("order_id" SERIAL PRIMARY KEY, "order_date" date,"ship_mode" varchar(50),"segment" varchar(50),"country" varchar(50), "city" varchar(50),
       "state" varchar(50),"postal_code"varchar(50),"region"varchar(50),"category"varchar(50),"sub_category"varchar(50));

insert into order_ret1 (order_id, order_date, 
ship_mode,segment,country,city,state,postal_code,region,category,sub_category)
select order_id, order_date,ship_mode,segment,country,city,state,postal_code,
region,category,sub_category order_ret from order_ret ;

create table order_ret2 ("id" SERIAL PRIMARY KEY,"product_id"varchar(50),"cost_price"numeric,"list_price"numeric,"quantity" integer,
       "discount_percent" numeric,"discount" numeric,"sales_price" numeric,"profit" numeric);

alter table order_ret2 add constraint fk_order_ret2 foreign key (id) references order_ret1(order_id);
select * from information_schema.table_constraints where table_name = 'order_ret2';

insert into order_ret2(id,product_id,cost_price,list_price,quantity,discount_percent,discount,sales_price,
profit) select order_id,product_id,cost_price,list_price,quantity,discount_percent,discount,sales_price,
profit from order_ret;
	 /* Query1 */
 /**************************/
select c.category as product,sum(p.sales_price * p.quantity) as Top_10_Revenue from order_ret1 as c, order_ret2 as p group by c.category order by Top_10_Revenue DESC limit 10;
select c.sub_category as product,sum(p.sales_price * p.quantity) as Top_10_Revenue from order_ret1 as c, order_ret2 as p group by c.sub_category order by Top_10_Revenue DESC limit 10;


		 /* Query2 */
 /**************************/
select c.city,
case
when sum(p.sales_price - p.cost_price) = 0 then 0
else (sum((p.sales_price - p.cost_price)* p.quantity)/ sum(p.sales_price*p.quantity)) * 100
end as profit_margin
from order_ret1 as c, order_ret2 as p group by c.city order by profit_margin desc limit 5;

	 /* Query3 */
 /**************************/
select c.category, sum(p.discount) as total_discount from order_ret1 as c, order_ret2 as p group by c.category;

	 /* Query4 */
 /**************************/
select c.category,(sum(p.sales_price * p.quantity)/sum(p.quantity))as Average_salesprice from order_ret2 as p, order_ret1 as c group by c.category;

 /* Query5 */
 /**************************/
select c.region,(sum(p.sales_price * p.quantity)/sum(p.quantity))as highest_average_salesprice from order_ret2 as p, order_ret1 as c group by c.region order by highest_average_Salesprice desc limit 1;

/* Query 6 */
 /**************************/
select c.category, sum((p.sales_price-p.cost_price)*p.quantity) as total_profit from order_ret2 as p, order_ret1 as c group by c.category;

/* Query 7 */
 /**************************/
select c.segment, sum(p.quantity) as highest_quantity from order_ret2 as p, order_ret1 as c group by c.segment order by highest_quantity desc limit 3;
/* Query 8 */
 /**************************/
select c.region,avg(p.discount_percent) as discount_percentage from order_ret2 as p, order_ret1 as c group by c.region;
/* Query 9 */
 /**************************/
 select c.category,sum((p.sales_price - p.cost_price)*p.quantity) as total_profit from order_ret2 as p, order_ret1 as c group by c.category order by total_profit desc;
/* Query10 */
 /**********************/
 select extract(Year from c.order_date) as Year, sum((p.sales_price)*p.quantity) as TotalRevenue from order_ret2 as p, order_ret1 as c group by  extract(Year from c.order_date) order by Year;
/* Query11 */
 /****Join to Fetch Complete Order Details*******/
 SELECT c.order_id, c.order_date, c.Region,p.cost_price,p.sales_price, p.quantity, p.discount_percent
FROM order_ret1 as c
JOIN order_ret2 as p ON c.order_id = p.id;
/* Query12 */
 /****Calculate Total Revenue per Order*******/ 
 select c.order_id, sum(p.sales_price *p.quantity)as total_revenue from order_ret1 as c join order_ret2 as p on c.order_id=p.id group by c.order_id;
 /* Query13 */
 /****Calculate Total profit per Order*******/
  select c.order_id, sum((p.sales_price - p.cost_price)*p.quantity)as total_profit from order_ret1 as c join order_ret2 as p on c.order_id=p.id group by c.order_id;
 /* Query14 */
 /****Least Revenue generating products*******/
 select c.sub_category as product,sum(p.sales_price * p.quantity) as least_Revenue from order_ret1 as c, order_ret2 as p group by c.sub_category order by least_Revenue asc limit 10;
/*Query 15 */
 /*******Count Orders by Region*************/
 select region, sum(order_id) as count_orders from order_ret1 group by region;
  /* Query16 */
 /*******Calculate Average Discount by state *************/
  select c.state, avg(p.discount_percent) as avg_discount from order_ret1 as c, order_ret2 as p group by c.state;
  /* Query17 */
 /*******Calculate the total revenue generated on December month *************/
  select extract(Month from c.order_date) as Month, sum((p.sales_price)*p.quantity) as TotalRevenue from order_ret2 as p, order_ret1 as c group by  extract(Month from c.order_date) order by Month;
select extract(Month from c.order_date) as Month, sum((p.sales_price)*p.quantity) as TotalRevenue from order_ret2 as p, order_ret1 as c group by  extract(Month from c.order_date) order by Month;
  /* Query18 */
 /*******Region with the Highest Profit*************/													
 select c.region,sum((p.sales_price-p.cost_price)*p.quantity) as highest_profit from order_ret2 as p, order_ret1 as c group by c.region order by highest_profit desc limit 1;
   /* Query19 */
 /********Identify Orders with No Profit (Profit = 0)********/
 select c.order_id,(p.sales_price - p.cost_price)*quantity as profit from order_ret2 as p join order_ret1 as c on c.order_id=p.id where  (p.sales_price - p.cost_price)*quantity=0;
    /* Query20 */
 /********Most Frequently Ordered Product Category********/
SELECT c.category, count(p.id) AS OrderCount FROM order_ret1 as c JOIN order_ret2 as p ON c.order_id = p.id
GROUP BY c.category ORDER BY OrderCount DESC LIMIT 1;