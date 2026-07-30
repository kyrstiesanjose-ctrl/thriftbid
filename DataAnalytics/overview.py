from queries import *
from formatter import print_table
from charts import *

def run_overview(cursor):

    print("=" * 70)
    print("OVERVIEW DASHBOARD")
    print("=" * 70)

    from queries import (
    TOTAL_REVENUE,
    LISTINGS_SOLD,
    TOTAL_ORDERS,
    AVERAGE_RATING,
    PENALTY_COUNT,
    MONTHLY_REVENUE,
    REVENUE_BY_CATEGORY,
    RECENT_PENALTIES,
    RECENT_AWARDS
)

from formatter import print_table

from charts import (
    monthly_revenue_chart,
    revenue_category_chart
)


def run_overview(cursor):

    # ==========================================
    # Helper Function
    # ==========================================

    def execute(query):
        cursor.execute(query)
        return cursor.fetchone()[0]


    # ==========================================
    # KPI Queries
    # ==========================================

    revenue = execute(TOTAL_REVENUE)
    sold = execute(LISTINGS_SOLD)
    orders = execute(TOTAL_ORDERS)
    rating = execute(AVERAGE_RATING)
    penalty = execute(PENALTY_COUNT)


    # ==========================================
    # KPI CARDS
    # ==========================================

    data = [
        ["Total Revenue", f"₱{revenue:,.2f}"],
        ["Listings Sold", sold],
        ["Total Orders", orders],
        ["Average Rating", rating],
        ["Penalty Count", penalty]
    ]

    print_table(
        "OVERVIEW KPI",
        ["Metric", "Value"],
        data
    )


    # ==========================================
    # Monthly Revenue
    # ==========================================

    cursor.execute(MONTHLY_REVENUE)

    rows = cursor.fetchall()

    months = [row[2] for row in rows]
    revenues = [float(row[3]) for row in rows]

    print("\nMonthly Revenue Data")
    print("-----------------------------")

    for month, revenue in zip(months, revenues):
        print(f"{month}: ₱{revenue:,.2f}")

    monthly_revenue_chart(months, revenues)


    # ==========================================
    # Revenue by Category
    # ==========================================

    cursor.execute(REVENUE_BY_CATEGORY)

    rows = cursor.fetchall()

    categories = []
    revenues = []

    for row in rows:
        categories.append(row[0])
        revenues.append(float(row[1]))

    print("\nRevenue by Category")
    print("-----------------------------")

    for c, r in zip(categories, revenues):
        print(f"{c:<20} ₱{r:,.2f}")

    if len(categories) > 0:
        revenue_category_chart(categories, revenues)
    else:
        print("No revenue data available.")


# ==========================================
# RECENT PENALTIES
# ==========================================

    cursor.execute(RECENT_PENALTIES)

    penalties = cursor.fetchall()

    if penalties:

            print_table(
            "RECENT PENALTIES",
            [
                "Date",
                "Reason",
                "Penalty",
                "Status"
            ],
            penalties
        )

    else:

        print("\nRECENT PENALTIES")
        print("---------------------------")
        print("No penalties found.")


# ==========================================
# RECENT AWARDS
# ==========================================

    cursor.execute(RECENT_AWARDS)

    awards = cursor.fetchall()

    if awards:

            print_table(
            "RECENT AWARDS",
            [
                "Date",
                "Award",
                "Description"
            ],
            awards
     )

    else:

        print("\nRECENT AWARDS")
        print("--------------------------")
        print("No awards found.")

   