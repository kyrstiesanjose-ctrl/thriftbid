# queries.py

# =============
# OVERVIEW TAB
# =============

TOTAL_REVENUE = """
SELECT
    COALESCE(SUM(amount_paid),0) AS total_revenue
FROM PAYMENTS
WHERE payment_status='Completed';
"""

LISTINGS_SOLD = """
SELECT COUNT(*) AS listings_sold
FROM ORDERS;
"""

TOTAL_ORDERS = """
SELECT COUNT(*) AS total_orders
FROM ORDERS;
"""

AVERAGE_RATING = """
SELECT ROUND(AVG(rating),2) AS average_rating
FROM REVIEWS;
"""

PENALTY_COUNT = """
SELECT COUNT(*) AS penalty_count
FROM PENALTIES
WHERE status='Active';
"""

MONTHLY_REVENUE = """
SELECT
    YEAR(payment_date) AS yr,
    MONTH(payment_date) AS mon,
    DATE_FORMAT(payment_date, '%b %Y') AS month,
    SUM(amount_paid) AS revenue
FROM PAYMENTS
WHERE payment_status = 'Completed'
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date),
    DATE_FORMAT(payment_date, '%b %Y')
ORDER BY
    yr,
    mon;
"""

REVENUE_BY_CATEGORY = """
SELECT
    c.name AS category,
    SUM(p.amount_paid) AS revenue
FROM PAYMENTS p
JOIN ORDERS o
    ON p.order_id = o.order_id
JOIN LISTINGS l
    ON o.listing_id = l.listing_id
JOIN CATEGORIES c
    ON l.category_id = c.category_id
WHERE p.payment_status = 'Completed'
GROUP BY
    c.category_id,
    c.name
ORDER BY
    revenue DESC
LIMIT 10;
"""

RECENT_PENALTIES = """
SELECT
DATE_FORMAT(issued_at,'%b %d, %Y') AS Date,
reason,
penalty_type AS Penalty,
status
FROM PENALTIES
ORDER BY issued_at DESC
LIMIT 10;
"""

RECENT_AWARDS = """
SELECT
DATE_FORMAT(issued_at,'%b %d, %Y') AS Date,
award_type AS Award,
reason AS Description
FROM SELLER_AWARDS
ORDER BY issued_at DESC
LIMIT 10;
"""



# ================
# PERFORMANCE TAB
# ================

PERFORMANCE_TOTAL_REVENUE = """
SELECT
COALESCE(SUM(p.amount_paid),0)
FROM PAYMENTS p
JOIN ORDERS o
ON p.order_id = o.order_id
WHERE p.payment_status='Completed';
"""


PERFORMANCE_LISTINGS_SOLD = """
SELECT
COUNT(order_id)
FROM ORDERS
WHERE status='Delivered';
"""


PERFORMANCE_SELLER_RATING = """
SELECT
ROUND(AVG(rating),2)
FROM REVIEWS;
"""


PERFORMANCE_PENALTY_COUNT = """
SELECT
COUNT(*)
FROM PENALTIES
WHERE status='Active';
"""

SELLER_PERFORMANCE = """
SELECT
    COALESCE(SUM(p.amount_paid),0) AS revenue,
    COUNT(DISTINCT o.order_id) AS listings_sold,
    ROUND(COALESCE(AVG(r.rating),0),2) AS seller_rating,
    (
        SELECT COUNT(*)
        FROM PENALTIES
        WHERE status='Active'
    ) AS penalty_count
FROM ORDERS o
LEFT JOIN PAYMENTS p
    ON o.order_id = p.order_id
LEFT JOIN REVIEWS r
    ON o.order_id = r.order_id
WHERE p.payment_status='Completed';
"""

# =========================================================
# PRODUCT AUTHENTICATION STATISTICS
# =========================================================

AUTH_VERIFIED = """
SELECT COUNT(*)
FROM AUTHENTICATION
WHERE authentication_status='Verified';
"""

AUTH_PENDING = """
SELECT COUNT(*)
FROM AUTHENTICATION
WHERE authentication_status='Pending';
"""

AUTH_REJECTED = """
SELECT COUNT(*)
FROM AUTHENTICATION
WHERE authentication_status='Rejected';
"""

AUTH_TOTAL = """
SELECT COUNT(*)
FROM AUTHENTICATION;
"""

# =========================================================
# PRODUCT AUTHENTICATION DETAILS
# =========================================================

PRODUCT_AUTH_DETAILS = """
SELECT

    a.authentication_id,
    b.brand_name,
    l.title,
    COALESCE(a.manufacture_year,'-') AS manufacture_year,
    a.authentication_status,
    COALESCE(a.verified_by_admin_id,'-') AS verified_by,
    COALESCE(a.date_verified,'-') AS date_verified

FROM AUTHENTICATION a

JOIN LISTINGS l
ON a.listing_id = l.listing_id

JOIN PRODUCT_LINES pl
ON l.product_line_id = pl.product_line_id

JOIN BRANDS b
ON pl.brand_id = b.brand_id

ORDER BY
a.authentication_id ASC;
"""

# =================
# SALES DRIVERS TAB
# =================

# =========================================================
# SALES DRIVERS KPI
# =========================================================

TOTAL_CUSTOMERS = """
SELECT
COUNT(DISTINCT buyer_id)
FROM ORDERS;
"""


TOTAL_ORDERS_SD = """
SELECT
COUNT(order_id)
FROM ORDERS;
"""


REPEAT_CUSTOMERS = """
SELECT
COUNT(*)
FROM
(
    SELECT buyer_id
    FROM ORDERS
    GROUP BY buyer_id
    HAVING COUNT(order_id) > 1

) t;
"""


AVERAGE_SPENDING = """
SELECT
COALESCE(
SUM(amount_paid) /
COUNT(DISTINCT o.buyer_id),
0
)
FROM PAYMENTS p

JOIN ORDERS o
ON p.order_id = o.order_id

WHERE p.payment_status='Completed';
"""


# =========================================================
# CUSTOMER SALES DRIVERS
# =========================================================

CUSTOMER_SALES_DRIVERS = """
SELECT

CONCAT(b.first_name,' ',b.last_name) AS customer,
SUM(p.amount_paid) AS total_spent
FROM PAYMENTS p
JOIN ORDERS o
ON p.order_id = o.order_id
JOIN BUYER b
ON o.buyer_id = b.buyer_id
WHERE p.payment_status='Completed'

GROUP BY
b.buyer_id,
b.first_name,
b.last_name
ORDER BY total_spent DESC

LIMIT 5;
"""


# =========================================================
# SALES BIAS ANALYSIS
# =========================================================

SALES_BIAS = """
SELECT

    YEAR(order_date) AS year_num,
    MONTH(order_date) AS month_num,
    DATE_FORMAT(MIN(order_date), '%b %Y') AS month,
    COUNT(order_id) AS orders,
    COUNT(DISTINCT buyer_id) AS customers,

    ROUND(
        COUNT(order_id) /
        NULLIF(COUNT(DISTINCT buyer_id), 0),
        2
    ) AS conversion_rate

FROM ORDERS
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    YEAR(order_date),
    MONTH(order_date);
"""


# =========================================================
# CURRENCY RATES
# =========================================================

CURRENCY_RATES_QUERY = """
SELECT
    recorded_date,
    target_currency,
    exchange_rate
FROM CURRENCY_RATES
WHERE base_currency = 'PHP'
ORDER BY recorded_date;
"""


# ===============
# FORECAST TAB
# ===============
# KPI 1
PROJECTED_REVENUE = """
SELECT
ROUND(AVG(monthly_revenue),2)
FROM (

    SELECT
        SUM(amount_paid) AS monthly_revenue

    FROM PAYMENTS p
    JOIN ORDERS o
        ON p.order_id = o.order_id
    WHERE payment_status = 'Completed'
    GROUP BY
        DATE_FORMAT(payment_date,'%Y-%m')
    ORDER BY
        DATE_FORMAT(payment_date,'%Y-%m') DESC
    LIMIT 3

) t;
"""

#KPI 2
PROJECTED_ORDERS = """
SELECT
ROUND(AVG(monthly_orders),0)

FROM (

    SELECT
        COUNT(order_id) AS monthly_orders

    FROM ORDERS
    GROUP BY
        DATE_FORMAT(order_date,'%Y-%m')
    ORDER BY
        DATE_FORMAT(order_date,'%Y-%m') DESC
    LIMIT 3

)t;
"""

# KPI 3
AVERAGE_PREDICTED_PRICE = """
SELECT

ROUND(
AVG(
(estimated_price_min+estimated_price_max)/2
),2)

FROM PRODUCT_LINES

WHERE
estimated_price_min IS NOT NULL
AND estimated_price_max IS NOT NULL;
"""

# KPI 4
BEST_PERFORMING_MONTH = """
SELECT
DATE_FORMAT(MAX(payment_date), '%M')

FROM PAYMENTS
WHERE payment_status='Completed'
GROUP BY
DATE_FORMAT(payment_date,'%Y-%m')
ORDER BY
SUM(amount_paid) DESC
LIMIT 1;
"""

# =========================================================
# SEASONALITY_FORECAST
# =========================================================
SEASONALITY_FORECAST = """
SELECT
    YEAR(p.payment_date) AS year,
    MONTH(p.payment_date) AS month_number,
    DATE_FORMAT(p.payment_date,'%b %Y') AS month,
    SUM(p.amount_paid) AS revenue
FROM PAYMENTS p
JOIN ORDERS o
    ON p.order_id = o.order_id
WHERE p.payment_status='Completed'
GROUP BY
    YEAR(p.payment_date),
    MONTH(p.payment_date),
    DATE_FORMAT(p.payment_date,'%b %Y')
ORDER BY
    YEAR(p.payment_date),
    MONTH(p.payment_date);
"""


# =========================================================
# BRAND PRICING PREDICTOR
# =========================================================
BRAND_PRICING_PREDICTOR = """
SELECT

    pl.tier,
    b.brand_name,
    ROUND(
        AVG(
            (pl.estimated_price_min + pl.estimated_price_max) / 2
        ),
        2
    ) AS predicted_price,
    ROUND(
        AVG(l.price),
        2
    ) AS current_market_price
FROM PRODUCT_LINES pl
JOIN BRANDS b
    ON pl.brand_id = b.brand_id
JOIN LISTINGS l
    ON pl.product_line_id = l.product_line_id
WHERE pl.tier <> 'Unbranded'
GROUP BY

    pl.tier,
    b.brand_name

ORDER BY

    FIELD(pl.tier,'High','Mid','Low'),
    predicted_price DESC;
"""


# =========================================================
# TOP BRAND PREDICTIONS 
# =========================================================
TOP_BRAND_PREDICTIONS = """
SELECT

    b.brand_name,
    pl.tier,
    ROUND(
        AVG(l.price),
        2
    ) AS current_price,
    ROUND(
        AVG(
            (pl.estimated_price_min + pl.estimated_price_max)/2
        ),
        2
    ) AS predicted_price

FROM PRODUCT_LINES pl
JOIN BRANDS b
    ON pl.brand_id = b.brand_id
JOIN LISTINGS l
    ON pl.product_line_id = l.product_line_id
WHERE
    pl.tier <> 'Unbranded'

GROUP BY

    b.brand_name,
    pl.tier

ORDER BY
ABS(
    (
        AVG((pl.estimated_price_min + pl.estimated_price_max)/2)
        - AVG(l.price)
    ) / AVG(l.price)
) DESC
LIMIT 5;
"""



# ===============
# OPTIMIZATION TAB
# ===============

# =========================================================
# OPTIMIZATION TAB KPI
# =========================================================

TOTAL_LISTINGS_ANALYZED = """
SELECT COUNT(*)
FROM LISTINGS
WHERE deleted_at IS NULL;
"""


AVERAGE_COMPLETENESS_SCORE = """
SELECT
ROUND(AVG(completeness_score),1)
FROM LISTING_ANALYTICS;
"""


AVERAGE_VIEW_TO_BID = """
SELECT
ROUND(AVG(view_to_bid_score),2)
FROM LISTING_ANALYTICS;
"""


LISTINGS_NEEDING_IMPROVEMENT = """
SELECT COUNT(*)
FROM LISTING_ANALYTICS
WHERE completeness_score < 70;
"""


# ==========================================================
# LISTING COMPLETENESS SCORE
# Now returns only 3 sub-scores: Photos, Item Details, Pricing Info
# ==========================================================

LISTING_COMPLETENESS = """
SELECT
ROUND(AVG(completeness_score),1),
ROUND(AVG(photo_score),1),
ROUND(AVG(details_score),1),
ROUND(AVG(pricing_score),1)
FROM LISTING_ANALYTICS;
"""


# ==========================================================
# LISTING OPTIMIZATION RECOMMENDATIONS
# Now returns only 3 scores: Photos, Item Details, Pricing Info
# ==========================================================

LISTING_OPTIMIZATION_RECOMMENDATIONS = """
SELECT

ROUND(AVG(photo_score),1),
ROUND(AVG(details_score),1),
ROUND(AVG(pricing_score),1)

FROM LISTING_ANALYTICS;
"""