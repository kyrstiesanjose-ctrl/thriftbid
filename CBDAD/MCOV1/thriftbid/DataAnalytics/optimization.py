from queries import (
    TOTAL_LISTINGS_ANALYZED,
    AVERAGE_COMPLETENESS_SCORE,
    AVERAGE_VIEW_TO_BID,
    LISTINGS_NEEDING_IMPROVEMENT,
    LISTING_COMPLETENESS,
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
    # Now shows only 3 sub-scores: Photos, Item Details, Pricing Info
    # ==========================================

    cursor.execute(LISTING_COMPLETENESS)

    row = cursor.fetchone()

    overall = float(row[0])
    photo = float(row[1])
    details = float(row[2])
    pricing = float(row[3])

    listing_completeness_chart(
        overall,
        photo,
        details,
        pricing
    )

    
    # ==========================================
    # Listing Optimization Recommendations
    # Now shows only 3 recommendations
    # ==========================================

    cursor.execute(LISTING_OPTIMIZATION_RECOMMENDATIONS)

    row = cursor.fetchone()

    photo = float(row[0])
    details = float(row[1])
    pricing = float(row[2])

    listing_optimization_recommendations(
        photo,
        details,
        pricing
    )