from queries import (
    TOTAL_CUSTOMERS,
    TOTAL_ORDERS_SD,
    REPEAT_CUSTOMERS,
    AVERAGE_SPENDING,
    CUSTOMER_SALES_DRIVERS,
    SALES_BIAS,
    CURRENCY_RATES_QUERY
)

from formatter import print_table
from charts import (
    customer_sales_driver_chart,
    sales_bias_chart,
    currency_rate_chart
)


def execute(cursor, query):

    cursor.execute(query)

    result = cursor.fetchone()[0]

    return result if result is not None else 0


# ==========================================
# Generate Insights
# ==========================================

def generate_sales_insights(
    total_customers,
    repeat_customers,
    average_spending
):

    insights = []

    repeat_rate = 0

    if total_customers > 0:
        repeat_rate = (repeat_customers / total_customers) * 100

    if repeat_rate >= 40:

        insights.append(
            "Excellent customer retention. Many customers return for additional purchases."
        )

    elif repeat_rate >= 20:

        insights.append(
            "Customer retention is moderate. Loyalty rewards may increase repeat purchases."
        )

    else:

        insights.append(
            "Repeat customer rate is low. Promotions may encourage customers to return."
        )

    if average_spending >= 1500:

        insights.append(
            "Customers have a high average spending value."
        )

    elif average_spending >= 800:

        insights.append(
            "Average spending is healthy and consistent."
        )

    else:

        insights.append(
            "Average spending is relatively low."
        )

    return insights



def run_sales_drivers(cursor):

    print("=" * 70)
    print("SALES DRIVERS DASHBOARD")
    print("=" * 70)

    customers = execute(cursor, TOTAL_CUSTOMERS)
    orders = execute(cursor, TOTAL_ORDERS_SD)
    repeat = execute(cursor, REPEAT_CUSTOMERS)
    spending = execute(cursor, AVERAGE_SPENDING)

    data = [

        ["Total Customers", customers],
        ["Total Orders", orders],
        ["Repeat Customers", repeat],
        ["Average Spending", f"₱{spending:,.2f}"]

    ]

    print_table(

        "SALES DRIVER KPI",
        ["Metric", "Value"],
        data

    )


    # ==========================================
    # Customer Sales Drivers
    # ==========================================

    cursor.execute(CUSTOMER_SALES_DRIVERS)

    rows = cursor.fetchall()

    customer_names = []
    customer_spending = []

    for row in rows:

        customer_names.append(row[0])
        customer_spending.append(float(row[1]))

    customer_sales_driver_chart(
        customer_names,
        customer_spending
)


    # ==========================================
    # Sales Bias Analysis
    # ==========================================

    cursor.execute(SALES_BIAS)

    rows = cursor.fetchall()

    months=[]
    orders=[]
    buyers=[]
    conversion=[]

    for row in rows:

        months.append(str(row[2]))    # "Jan 2026"
        orders.append(int(row[3]))
        buyers.append(int(row[4]))
        conversion.append(float(row[5]))

    sales_bias_chart(
        months,
        orders,
        buyers,
        conversion
    )


    # ==========================================
    # Currency Rates
    # ==========================================

    cursor.execute(CURRENCY_RATES_QUERY)

    rows = cursor.fetchall()

    dates = []
    usd = []
    krw = []

    for row in rows:

        date = str(row[0])

        if date not in dates:
            dates.append(date)

        if row[1] == "USD":
            usd.append(float(row[2]))

        elif row[1] == "KRW":
            krw.append(float(row[2]))

    php = [1.0] * len(dates)

    currency_rate_chart(
        dates,
        php,
        usd,
        krw
    )


    # ==========================================
    # Insights Panel
    # ==========================================

    insights = generate_sales_insights(
        customers,
        repeat,
        spending
    )

    print("\n")
    print("=" * 70)
    print("SALES INSIGHTS")
    print("=" * 70)

    for insight in insights:
        print(f"• {insight}")
