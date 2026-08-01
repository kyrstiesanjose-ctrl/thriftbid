"""
Shared logic for turning a LISTINGS row into a Chroma document +
metadata. Used by both build_index.py (full rebuild) and app.py's
/api/reindex-listing endpoint (instant single-listing update), so the
two never drift out of sync with each other.
"""

# Used for the full rebuild (build_index.py) - only currently-visible listings.
BULK_LISTING_QUERY = """
    SELECT
        l.listing_id, l.title, l.description, l.price,
        l.color, l.material, l.made_in,
        c.name AS category_name,
        b.brand_name
    FROM LISTINGS l
    JOIN CATEGORIES c ON l.category_id = c.category_id
    JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
    JOIN BRANDS b ON pl.brand_id = b.brand_id
    WHERE l.deleted_at IS NULL AND l.is_active = 1
"""

# Used for a single-listing lookup (app.py's /api/reindex-listing) - includes
# is_active/deleted_at so the endpoint can decide to index vs. remove.
SINGLE_LISTING_QUERY = """
    SELECT
        l.listing_id, l.title, l.description, l.price,
        l.color, l.material, l.made_in, l.is_active, l.deleted_at,
        c.name AS category_name,
        b.brand_name
    FROM LISTINGS l
    JOIN CATEGORIES c ON l.category_id = c.category_id
    JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
    JOIN BRANDS b ON pl.brand_id = b.brand_id
    WHERE l.listing_id = %s
"""


def listing_to_document(r) -> str:
    parts = [
        f"[ID: {r['listing_id']}] {r['title']} ({r['category_name']}, {r['brand_name']}): "
        f"{r['description'] or ''} Price: PHP {r['price']}"
    ]
    if r["color"]:
        parts.append(f"Color: {r['color']}.")
    if r["material"]:
        parts.append(f"Material: {r['material']}.")
    if r["made_in"]:
        parts.append(f"Made in {r['made_in']}.")
    return " ".join(parts)


def listing_to_metadata(r) -> dict:
    return {
        "title": r["title"],
        "category": r["category_name"],
        "brand": r["brand_name"],
        "color": r["color"] or "",
        "made_in": r["made_in"] or "",
        "price": float(r["price"]),
    }