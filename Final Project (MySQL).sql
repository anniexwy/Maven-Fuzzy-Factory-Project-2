USE mavenfuzzyfactory

/*Overall Session & Order Volume (Quarterly)*/
SELECT YEAR(ws.created_at) yr,
       QUARTER(ws.created_at) qt,
	   COUNT(ws.website_session_id) sessions,
	   COUNT(o.order_id) orders
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
--The number of orders has increased dramatically in this three year period, from 60 orders at the beginning to nearly 100 times of that many at present
--The number of sessions also follows similar pattern


/*Efficiency Improvements (Quarterly)*/
SELECT YEAR(ws.created_at) yr,
       QUARTER(ws.created_at) qt,
	   ROUND(COUNT(o.order_id)/COUNT(ws.website_session_id),4) session_to_order_cvr,
	   ROUND(SUM(o.price_usd)/COUNT(o.order_id),4) revenue_per_order,
	   ROUND(SUM(o.price_usd)/COUNT(ws.website_session_id),4) revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
--Session to order conversion rate also follows an increasing trend: from 3.19% at the beginning to 8.44% in the most recent quarter
--After we introduced more products from the beginning of 2013, customers tend to purchase more than one product for each order, which lead to rises in revenue per order from $49.99 to $62.80 in the most recent quarter
--Upward trends can also be spotted for revenue per session, which increased from $1.59 per session to $5.30 per session


/*Quarterly Orders Review Among Different Channels*/
---What Sessions Are There Until 19 March 2015?
SELECT DISTINCT utm_source,utm_campaign,http_referer
FROM website_sessions;
--There are 9 channels in total: bsearch brand, bsearch nonbrand, gsearch brand, gsearch nonbrand, socialbook desktop targeted, socialbook pilot, bsearch organic, gsearch organic & direct

---Calculate Orders		
SELECT YEAR(ws.created_at) yr,
       QUARTER(ws.created_at) qt,
	   COUNT(CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) gsearch_nonbrand,
	   COUNT(CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) bsearch_nonbrand,
	   COUNT(CASE WHEN ws.utm_campaign='brand' THEN o.order_id ELSE NULL END) brand_search_overall,
	   COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL 
			 AND ws.http_referer IS NOT NULL THEN o.order_id ELSE NULL END) organic_search,
	   COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL 
			 AND ws.http_referer IS NULL THEN o.order_id ELSE NULL END) direct_type_in
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
--All the channels have upward trends in this three-year time
--It is good to see those unpaid channels (i.e. orgainic & direct) are gaining more porpotion in the number of sessions as time went on (from 10.53% to 21.99%). This indicates that we are less dependent on paid channels and starting to bulid our own brand


/*Overall Session-to-Order CVR by Channel (Quarterly)*/
SELECT YEAR(ws.created_at) yr,
       QUARTER(ws.created_at) qt,
       COUNT(CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) gs_orders,
       COUNT(CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign='nonbrand' THEN ws.website_session_id 
	     ELSE NULL END) gs_sessions,
       COUNT(CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) bs_orders,
       COUNT(CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign='nonbrand' 
             THEN ws.website_session_id ELSE NULL END) bs_sessions,
       COUNT(CASE WHEN ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) bo_orders,
       COUNT(CASE WHEN ws.utm_campaign='nonbrand' THEN ws.website_session_id ELSE NULL END) bo_sessions,
       COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL AND ws.http_referer IS NOT NULL
             THEN o.order_id ELSE NULL END) os_orders,
       COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL AND ws.http_referer IS NOT NULL
             THEN ws.website_session_id ELSE NULL END) os_sessions,		   
       COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL AND ws.http_referer IS NULL
	     THEN o.order_id ELSE NULL END) dti_orders,
       COUNT(CASE WHEN ws.utm_source IS NULL AND ws.utm_campaign IS NULL AND ws.http_referer IS NULL
	     THEN ws.website_session_id ELSE NULL END) dti_sessions
      FROM website_sessions ws
      LEFT JOIN orders o
      ON ws.website_session_id=o.website_session_id
      GROUP BY 1,2
      ORDER BY 1,2;
--In general, all channels have upward trends in session to order conversion rates
--Significant improvements in cvr can be seen at the first quarter in 2013. 
--In the recent quarter, brand search, organic search and direct search share the similar conversion rates with paid channels (around 8%)


/*Monthly Trending For Product Sales*/
SELECT YEAR(created_at) yr,
       MONTH(created_at) mo,
	   SUM(CASE WHEN product_id=1 THEN price_usd ELSE NULL END) rev_mr_fuzzy,
	   SUM(CASE WHEN product_id=1 THEN price_usd-cogs_usd ELSE NULL END) margin_mr_fuzzy,
	   SUM(CASE WHEN product_id=2 THEN price_usd ELSE NULL END) rev_love_bear,
	   SUM(CASE WHEN product_id=2 THEN price_usd-cogs_usd ELSE NULL END) margin_love_bear,
	   SUM(CASE WHEN product_id=3 THEN price_usd ELSE NULL END) rev_sugar_panda,
	   SUM(CASE WHEN product_id=3 THEN price_usd-cogs_usd ELSE NULL END) margin_sugar_panda,
	   SUM(CASE WHEN product_id=4 THEN price_usd ELSE NULL END) rev_mini_bear,
       SUM(CASE WHEN product_id=4 THEN price_usd-cogs_usd ELSE NULL END) margin_mini_bear,	   
       SUM(price_usd) rev_total,
	   COUNT(price_usd-cogs_usd) margin_total
FROM order_items
GROUP BY 1,2
ORDER BY 1,2;
--For Original Mr.Fuzzy, there are rises in revenue in every November and December. This is quite understandable, since there are Thanksgiving in November (as well as Black Friday) and Christmas in December.
--For Love Bear, there are rises in every February. This is quite understandable too--Valentine's Day is in February
--It is hard to tell whether there are seasonality trends for Sugar Panda and Mini Bear since we don't have enough data


/*Impact Of Introducing New Products*/
---Indentify all the views on /products page
CREATE TEMPORARY TABLE product_pageview 
	 SELECT website_session_id,
            website_pageview_id,
	        created_at
     FROM website_pageviews
     WHERE pageview_url='/products';

---Calculate product sessions, product clickthrough rate & product to order cvr	 
SELECT YEAR(pp.created_at) yr,
       MONTH(pp.created_at) mo,
	   COUNT(DISTINCT pp.website_session_id) product_sessions,
	   ROUND(COUNT(DISTINCT wp.website_session_id)/COUNT(DISTINCT pp.website_session_id),4) product_clickthrough,
	   ROUND(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT pp.website_session_id),4) products_to_order_cvr
FROM product_pageview pp
LEFT JOIN website_pageviews wp
ON pp.website_session_id=wp.website_session_id
   AND wp.website_pageview_id>pp.website_pageview_id
LEFT JOIN orders o
ON o.website_session_id=pp.website_session_id
GROUP BY 1,2;
--The product clickthrough rate has rised from 71.33% at the beginning to 85.60% rencently
--Product to order conversion rate is rising as well (from 8.08% to around 14%)
--All these indicate that the our products are becoming more attractive to our customers, and improve the healthiness of our business as well 
	 	 

/*Cross-Sell Analysis*/
CREATE TEMPORARY TABLE primary_products
	 SELECT order_id,
            primary_product_id,
	        created_at ordered_at
     FROM orders
     WHERE created_at>'2014-12-05';
	 
CREATE TEMPORARY TABLE primary_w_cross_sell 
	 SELECT pp.*,
	        oi.product_id cross_sell_product_id
	 FROM primary_products pp
	 LEFT JOIN order_items oi
	 ON oi.order_id=pp.order_id
	    AND oi.is_primary_item=0;

SELECT primary_product_id,
       COUNT(order_id) total_sales,
       COUNT(CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END) mr_fuzzy_sales,
	   COUNT(CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END) love_bear_sales,
	   COUNT(CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END) sugar_panda_sales,
	   COUNT(CASE WHEN cross_sell_product_id=4 THEN order_id ELSE NULL END) mini_bear_sales,
	   ROUND(COUNT(CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END)/
			 COUNT(order_id),4) mr_fuzzy_sales_rt,
	   ROUND(COUNT(CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END)/
			 COUNT(order_id),4) love_bear_sales_rt,
	   ROUND(COUNT(CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END)/
			 COUNT(order_id),4) sugar_panda_sales_rt,	 
	   ROUND(COUNT(CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END)/
			 COUNT(order_id),4) mini_bear_sales_rt
FROM primary_w_cross_sell
GROUP BY 1
ORDER BY 1;
--Original Mr.Fuzzy is still our selling champion, with a total of 4467 items being sold
--Our customers are less likely to purchase Mini Bear as their primary product. However, it is cross-sold pretty well with the other three products: around 21% customers who had the other three products as primary products also chose Mini Bear
--Another popular cross-sale package for our customers is choosing Mr.Fuzzy as primary products and Sugar Panda as cross-sale products