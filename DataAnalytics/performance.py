from queries import (
    PERFORMANCE_TOTAL_REVENUE,
    PERFORMANCE_LISTINGS_SOLD,
    PERFORMANCE_SELLER_RATING,
    PERFORMANCE_PENALTY_COUNT,
    SELLER_PERFORMANCE,
    AUTH_VERIFIED,
    AUTH_PENDING,
    AUTH_REJECTED,
    AUTH_TOTAL,
    PRODUCT_AUTH_DETAILS
)

from formatter import print_table
from charts import (
    seller_performance_chart,
    authentication_statistics_chart
)


def execute(cursor, query):
    cursor.execute(query)
    result = cursor.fetchone()[0]
    return result if result is not None else 0

def run_performance(cursor):

    print("=" * 70)
    print("PERFORMANCE DASHBOARD")
    print("=" * 70)

    revenue = execute(cursor, PERFORMANCE_TOTAL_REVENUE)
    sold = execute(cursor, PERFORMANCE_LISTINGS_SOLD)
    rating = execute(cursor, PERFORMANCE_SELLER_RATING)
    penalty = execute(cursor, PERFORMANCE_PENALTY_COUNT)

    data = [
        ["Total Revenue", f"₱{revenue:,.2f}"],
        ["Listings Sold", sold],
        ["Seller Rating", rating],
        ["Penalty Count", penalty]
    ]

    print_table(
        "PERFORMANCE KPI",
        ["Metric", "Value"],
        data
    )

    # ==========================================
    # Seller Performance Chart
    # ==========================================

    cursor.execute(SELLER_PERFORMANCE)

    row = cursor.fetchone()

    labels = [
        "Revenue",
        "Listings Sold",
        "Seller Rating",
        "Penalty Count"
    ]

    values = [
        float(row[0]),
        int(row[1]),
        float(row[2]),
        int(row[3])
    ]

    seller_performance_chart(labels, values)

    # ==========================================
    # Product Authentication Statistics
    # ==========================================

    verified = execute(cursor, AUTH_VERIFIED)
    pending = execute(cursor, AUTH_PENDING)
    rejected = execute(cursor, AUTH_REJECTED)
    total = execute(cursor, AUTH_TOTAL)

    if total > 0:

        verified_pct = verified / total * 100
        pending_pct = pending / total * 100
        rejected_pct = rejected / total * 100

    else:

        verified_pct = 0
        pending_pct = 0
        rejected_pct = 0

    stats = [

        ["Verified", verified, f"{verified_pct:.1f}%"],
        ["Pending", pending, f"{pending_pct:.1f}%"],
        ["Rejected", rejected, f"{rejected_pct:.1f}%"]

    ]

    authentication_statistics_chart(
        verified,
        pending,
        rejected,
        verified_pct,
        pending_pct,
        rejected_pct
    )

    
    # ==========================================
    # Product Authentication Details
    # ==========================================

    cursor.execute(PRODUCT_AUTH_DETAILS)

    rows = cursor.fetchall()

    formatted_rows = []

    for index, row in enumerate(rows, start=1):

        manufacture_year = row[3] if row[3] else "-"
        verified_by = row[5] if row[5] != "-" else "-"

        if row[6]:
            date_verified = row[6][:10]
        else:
            date_verified = "-"

        formatted_rows.append([

            index,               # Replaces Authentication ID
            row[1],              # Brand
            row[2],              # Item
            manufacture_year,
            row[4],              # Status
            verified_by,
            date_verified

        ])

    print_table(

        "PRODUCT AUTHENTICATION DETAILS",

        [
            "#",
            "Brand",
            "Item",
            "Year Manufactured",
            "Status",
            "Verified By",
            "Date Verified"
        ],

        formatted_rows
    )

    
        
