from queries import (
    TOTAL_LISTINGS_ANALYZED,
    AVERAGE_COMPLETENESS_SCORE,
    AVERAGE_VIEW_TO_BID,
    LISTINGS_NEEDING_IMPROVEMENT,
    LISTING_COMPLETENESS,
    TOP_LISTING_ISSUES,
    LISTING_OPTIMIZATION_RECOMMENDATIONS
)

from formatter import print_table

from charts import (
    listing_completeness_chart,
    listing_optimization_recommendations
)

def execute(cursor, query):

    cursor.execute(query)

    result = cursor.fetchone()[0]

    return result if result is not None else 0

def run_optimization(cursor):

    print("=" * 70)
    print("OPTIMIZATION DASHBOARD")
    print("=" * 70)

    listings = execute(cursor, TOTAL_LISTINGS_ANALYZED)
    completeness = execute(cursor, AVERAGE_COMPLETENESS_SCORE)
    conversion = execute(cursor, AVERAGE_VIEW_TO_BID)
    improvement = execute(cursor, LISTINGS_NEEDING_IMPROVEMENT)

    data = [

        ["Total Listings Analyzed", listings],
        ["Average Completeness Score", f"{completeness:.1f}/100"],
        ["Average View-to-Bid Conversion", f"{conversion:.2f}%"],
        ["Listings Needing Improvement", improvement]

    ]

    print_table(

        "OPTIMIZATION KPI",
        ["Metric","Value"],
        data

    )


    # ==========================================
    # Listing Completeness Score
    # ==========================================

    cursor.execute(LISTING_COMPLETENESS)

    row = cursor.fetchone()

    overall = float(row[0])
    photo = float(row[1])
    details = float(row[2])
    condition = float(row[3])
    shipping = float(row[4])
    pricing = float(row[5])

    listing_completeness_chart(

        overall,
        photo,
        details,
        condition,
        shipping,
        pricing

    )


# ==========================================
# Top Listing Issues
# ==========================================

    cursor.execute(TOP_LISTING_ISSUES)

    row = cursor.fetchone()

    photos = int(row[0])
    details = int(row[1])
    conditions = int(row[2])
    shipping = int(row[3])
    pricing = int(row[4])

    print("\n")
    print("=" * 60)
    print("TOP LISTING ISSUES")
    print("=" * 60)

    issues = [
        ("Missing or Low-quality Photos", photos),
        ("Missing Product Details", details),
        ("Incomplete Item Condition", conditions),
        ("No Shipping Information", shipping),
        ("Pricing Not Competitive", pricing),
    ]

    for issue, count in issues:
        print(f"{issue:<35} [{count:>3}]   View Listings")

    print("\nFixing these issues can significantly improve listing performance.")

    
# ==========================================
# Listing Optimization Recommendations
# ==========================================

    cursor.execute(LISTING_OPTIMIZATION_RECOMMENDATIONS)

    row = cursor.fetchone()

    photo = float(row[0])
    details = float(row[1])
    condition = float(row[2])
    shipping = float(row[3])
    pricing = float(row[4])

    listing_optimization_recommendations(

        photo,
        details,
        condition,
        shipping,
        pricing

    )