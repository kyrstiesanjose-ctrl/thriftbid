import matplotlib.pyplot as plt


def monthly_revenue_chart(months, revenues):

    plt.figure(figsize=(14,6))
    plt.xticks(rotation=45)
    plt.grid(alpha=0.3)
    plt.tight_layout()

    plt.plot(
        months,
        revenues,
        marker='o',
        linewidth=3
    )

    plt.title("Monthly Revenue")
    plt.xlabel("Month")
    plt.ylabel("Revenue (PHP)")
    plt.grid(True)
    plt.tight_layout()
    plt.show()


def revenue_category_chart(categories, revenues):

    plt.figure(figsize=(10,10))

    plt.pie(
        revenues,
        labels=categories,
        autopct="%1.1f%%",
        startangle=90,
        pctdistance=0.78,
        labeldistance=1.08,
        wedgeprops=dict(width=0.45)
   )

    plt.title("Revenue by Category")

    plt.tight_layout()

    plt.show()


import matplotlib.pyplot as plt


def seller_performance_chart(labels, values):

    # Normalize all values to 0-100
    max_value = max(values)

    normalized = [
        (v / max_value) * 100
        for v in values
    ]

    plt.figure(figsize=(10,5))

    bars = plt.barh(
        labels,
        normalized
    )

    plt.xlim(0, 100)

    plt.xlabel("Performance Scale (Higher is Better)")
    plt.title("Seller Performance Comparison")

    # Display original values beside bars
    for i, bar in enumerate(bars):

        plt.text(
            bar.get_width() + 1,
            bar.get_y() + bar.get_height()/2,
            str(values[i]),
            va="center",
            fontsize=10
        )

    plt.tight_layout()
    plt.show()


import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


def authentication_statistics_chart(
    verified,
    pending,
    rejected,
    verified_pct,
    pending_pct,
    rejected_pct
):

    fig, ax = plt.subplots(figsize=(10,4))

    ax.set_xlim(0, 3)
    ax.set_ylim(0, 1)

    ax.axis("off")

    cards = [

        {
            "x":0.1,
            "color":"#A8E6A3",
            "count":verified,
            "title":"Verified",
            "percent":verified_pct,
            "icon":"✓"
        },

        {
            "x":1.05,
            "color":"#FFE89A",
            "count":pending,
            "title":"Pending",
            "percent":pending_pct,
            "icon":"⌛"
        },

        {
            "x":2.0,
            "color":"#FF9999",
            "count":rejected,
            "title":"Rejected",
            "percent":rejected_pct,
            "icon":"✕"
        }

    ]

    for card in cards:

        ax.add_patch(

            Rectangle(

                (card["x"],0.1),
                0.75,
                0.8,
                facecolor=card["color"],
                edgecolor="none"

            )

        )

        ax.text(
            card["x"]+0.375,
            0.72,
            str(card["count"]),
            ha="center",
            fontsize=20,
            fontweight="bold"
        )

        ax.text(
            card["x"]+0.375,
            0.60,
            card["title"],
            ha="center",
            fontsize=12
        )

        ax.text(
            card["x"]+0.375,
            0.42,
            card["icon"],
            ha="center",
            fontsize=36
        )

        ax.text(
            card["x"]+0.375,
            0.18,
            f"{card['percent']:.1f}% of Total",
            ha="center",
            fontsize=10
        )

    plt.title("Product Authentication Statistics", fontsize=14, weight="bold")
    plt.tight_layout()
    plt.show()


def customer_sales_driver_chart(customers, spending):

    import matplotlib.pyplot as plt

    plt.figure(figsize=(9,5))
    plt.barh(customers, spending)
    plt.title("Customer Sales Drivers")
    plt.xlabel("Total Spending (PHP)")
    plt.tight_layout()
    plt.show()


def sales_bias_chart(dates, orders, buyers, conversion):

    import matplotlib.pyplot as plt

    plt.figure(figsize=(10,5))
    plt.plot(dates, orders, marker="o", label="Orders")
    plt.plot(dates, buyers, marker="s", label="Customers")
    plt.plot(dates, conversion, marker="^", label="Conversion Rate")
    plt.title("Sales Bias Analysis")
    plt.xlabel("Order Date")
    plt.ylabel("Value")
    plt.xticks(rotation=45)
    plt.legend()
    plt.tight_layout()
    plt.show()


def currency_rate_chart(dates, php, usd, krw):

    import matplotlib.pyplot as plt
    plt.figure(figsize=(10,5))
    plt.plot(dates, php, marker="o", label="PHP")
    plt.plot(dates, usd, marker="s", label="USD")
    plt.plot(dates, krw, marker="^", label="KRW")
    plt.title("Currency Exchange Rates")
    plt.xlabel("Recorded Date")
    plt.ylabel("Exchange Rate")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()


def seasonality_forecast_chart(months, revenue):

    import matplotlib.pyplot as plt

    plt.figure(figsize=(11,5))
    plt.plot(
        months,
        revenue,
        marker="o",
        linewidth=3
    )

    plt.fill_between(
        months,
        revenue,
        alpha=0.20
    )

    plt.title("Seasonality Forecast")
    plt.xlabel("Month")
    plt.ylabel("Revenue (PHP)")
    plt.xticks(rotation=45)
    plt.grid(True)
    plt.tight_layout()
    plt.show()


def brand_pricing_scatter(
    high_x,
    high_y,
    mid_x,
    mid_y,
    low_x,
    low_y
):

    import matplotlib.pyplot as plt

    plt.figure(figsize=(8,6))
    plt.scatter(
        high_x,
        high_y,
        color="red",
        s=70,
        label="High Tier Brands"
    )

    plt.scatter(
        mid_x,
        mid_y,
        color="blue",
        s=70,
        label="Mid Tier Brands"
    )

    plt.scatter(
        low_x,
        low_y,
        color="green",
        s=70,
        label="Low Tier Brands"
    )

    plt.title("Brand Pricing Predictor")
    plt.xlabel("Actual Price (PHP)")
    plt.ylabel("Predicted Price (PHP)")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()


import matplotlib.pyplot as plt


def listing_completeness_chart(
    overall,
    photo,
    details,
    pricing
):

    categories = [
        "Photos",
        "Item Details",
        "Pricing Info"
    ]

    scores = [
        photo,
        details,
        pricing
    ]

    colors = []

    for score in scores:

        if score >= 75:
            colors.append("#2ecc71")      # Green
        elif score >= 60:
            colors.append("#f39c12")      # Orange
        else:
            colors.append("#e74c3c")      # Red

    fig = plt.figure(figsize=(12,5))

    # ===================================================
    # LEFT SIDE - Gauge
    # ===================================================

    ax1 = plt.subplot(1,2,1)

    ax1.pie(
        [overall,100-overall],
        startangle=90,
        counterclock=False,
        wedgeprops=dict(width=0.28),
    )

    ax1.text(
        0,
        0.12,
        f"{overall:.0f}",
        ha="center",
        fontsize=34,
        fontweight="bold"
    )

    ax1.text(
        0,
        -0.12,
        "/100",
        ha="center",
        fontsize=14
    )

    if overall >= 80:
        label = "Excellent"
    elif overall >= 70:
        label = "Good"
    elif overall >= 60:
        label = "Average"
    else:
        label = "Needs Improvement"

    ax1.text(
        0,
        -0.42,
        label,
        ha="center",
        fontsize=12
    )

    ax1.set_title(
        "Listing Completeness Score",
        fontsize=14,
        fontweight="bold"
    )

    # ===================================================
    # RIGHT SIDE - Progress Bars
    # ===================================================

    ax2 = plt.subplot(1,2,2)
    y = range(len(categories))

    ax2.barh(
        y,
        [100]*len(categories),
        color="#eeeeee",
        height=0.35
    )

    ax2.barh(
        y,
        scores,
        color=colors,
        height=0.35
    )

    ax2.set_yticks(y)
    ax2.set_yticklabels(categories)
    ax2.invert_yaxis()
    ax2.set_xlim(0,100)
    ax2.set_xticks([])
    ax2.set_title(
        "Category Scores",
        fontsize=14,
        fontweight="bold"
    )

    for i, score in enumerate(scores):
        ax2.text(
            102,
            i,
            f"{score:.0f}/100",
            va="center",
            fontsize=10
        )

    # Remove borders
    ax2.spines["top"].set_visible(False)
    ax2.spines["right"].set_visible(False)
    ax2.spines["bottom"].set_visible(False)
    ax2.spines["left"].set_visible(False)

    plt.tight_layout()
    plt.show()


def listing_optimization_recommendations(
    photo,
    details,
    pricing
):

    print("\n")
    print("=" * 70)
    print("LISTING OPTIMIZATION RECOMMENDATIONS")
    print("=" * 70)

    recommendations = [
        (
            "Add More Photos",
            photo,
            "Listings with 3+ high quality photos get more views and higher bids."
        ),
        (
            "Complete Item Details",
            details,
            "Add color, gender, material, and made-in fields to build buyer trust."
        ),
        (
            "Pricing Info",
            pricing,
            "Review items with inconsistent pricing across the same product line."
        )
    ]

    for title, score, description in recommendations:

        if score >= 80:
            status = "Excellent"
        elif score >= 70:
            status = "Good"
        elif score >= 60:
            status = "Needs Attention"
        else:
            status = "High Priority"

        print(f"\n{title}")
        print("-" * len(title))
        print(description)
        print(f"Current Score : {score:.1f}/100")
        print(f"Priority      : {status}")

    print("\nSmall improvements can lead to big results. Follow these recommendations and watch your sales grow.")