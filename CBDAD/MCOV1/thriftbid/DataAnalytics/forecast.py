from queries import (
    PROJECTED_REVENUE,
    PROJECTED_ORDERS,
    AVERAGE_PREDICTED_PRICE,
    BEST_PERFORMING_MONTH,
    SEASONALITY_FORECAST,
    BRAND_PRICING_PREDICTOR,
    TOP_BRAND_PREDICTIONS
)

from formatter import print_table

from charts import (
    seasonality_forecast_chart, 
    brand_pricing_scatter
)


def execute(cursor, query):

    cursor.execute(query)

    result = cursor.fetchone()[0]

    return result if result is not None else 0


def run_forecast(cursor):

    print("="*70)
    print("FORECAST DASHBOARD")
    print("="*70)

    projected_revenue = execute(cursor, PROJECTED_REVENUE)
    projected_orders = execute(cursor, PROJECTED_ORDERS)
    avg_price = execute(cursor, AVERAGE_PREDICTED_PRICE)
    best_month = execute(cursor, BEST_PERFORMING_MONTH)

    data=[

        ["Projected Revenue",f"₱{projected_revenue:,.2f}"],
        ["Projected Orders",projected_orders],
        ["Average Predicted Price",f"₱{avg_price:,.2f}"],
        ["Best Performing Month",best_month]

    ]

    print_table(

        "FORECAST KPI",
        ["Metric","Value"],
        data

    )


# ==========================================
# Seasonality Forecast
# ==========================================

    cursor.execute(SEASONALITY_FORECAST)

    rows = cursor.fetchall()

    months = []
    revenues = []

    for row in rows:

        months.append(row[2])
        revenues.append(float(row[3]))

    seasonality_forecast_chart(
        months,
        revenues
    )


# ==========================================
# Forecast Summary Panel
# ==========================================

    peak_index = revenues.index(max(revenues))
    lowest_index = revenues.index(min(revenues))

    peak_month = months[peak_index]
    lowest_month = months[lowest_index]

    average_revenue = sum(revenues) / len(revenues)

    # Growth Trend (%)
    if len(revenues) >= 2:

        growth = (
            (revenues[-1] - revenues[-2])
            / revenues[-2]
        ) * 100

    else:

        growth = 0

    summary = [

        ["Peak Month", peak_month],
        ["Lowest Month", lowest_month],
        ["Average Monthly Revenue", f"₱{average_revenue:,.2f}"],
        ["Growth Trend", f"{growth:.2f}%"]

    ] 

    print_table(

        "FORECAST SUMMARY",
        ["Metric","Value"],
        summary

    )



# ==========================================
# Brand Pricing Predictor
# ==========================================

    cursor.execute(BRAND_PRICING_PREDICTOR)

    rows = cursor.fetchall()

    high_x = []
    high_y = []

    mid_x = []
    mid_y = []

    low_x = []
    low_y = []

    for row in rows:

        tier = row[0]

        predicted = float(row[2])
        current = float(row[3])

        if tier == "High":

            high_x.append(current)
            high_y.append(predicted)

        elif tier == "Mid":

            mid_x.append(current)
            mid_y.append(predicted)

        elif tier == "Low":

            low_x.append(current)
            low_y.append(predicted)

    brand_pricing_scatter(
        high_x,
        high_y,
        mid_x,
        mid_y,
        low_x,
        low_y
    )


# ==========================================
# Top Brand Predictions
# ==========================================

    cursor.execute(TOP_BRAND_PREDICTIONS)

    rows = cursor.fetchall()

    prediction_table = []

    for row in rows:

        brand = row[0]
        tier = row[1]
        current = float(row[2])
        predicted = float(row[3])

        if current == 0:

            difference = 0

        else:

            difference = ((predicted - current)/ current) * 100

        prediction_table.append([
            brand,
            tier,

            f"₱{current:,.2f}",
            f"₱{predicted:,.2f}",
            f"{difference:+.2f}%"
        ])

    print_table(

        "TOP BRAND PREDICTIONS",

        [
            "Brand",
            "Brand Tier",
            "Price",
            "Predicted Price",
            "Difference"
        ],

        prediction_table

    )