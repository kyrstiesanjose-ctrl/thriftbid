"""
Shared logic for turning a LISTINGS row into a Chroma document +
metadata. Used by both build_index.py (full rebuild) and app.py's
/api/reindex-listing endpoint (instant single-listing update), so the
two never drift out of sync with each other.
"""

# Updated to use LEFT JOIN and GROUP_CONCAT for the new normalized Color and Material tables
BULK_LISTING_QUERY = """
    SELECT
        l.listing_id, l.title, l.description, l.price,
        l.made_in,
        c.name AS category_name,
        b.brand_name,
        GROUP_CONCAT(DISTINCT co.color_name SEPARATOR ', ') AS color,
        GROUP_CONCAT(DISTINCT m.material_name SEPARATOR ', ') AS material
    FROM LISTINGS l
    JOIN CATEGORIES c ON l.category_id = c.category_id
    JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
    JOIN BRANDS b ON pl.brand_id = b.brand_id
    LEFT JOIN LISTING_COLORS lc ON l.listing_id = lc.listing_id
    LEFT JOIN COLORS co ON lc.color_id = co.color_id
    LEFT JOIN LISTING_MATERIALS lm ON l.listing_id = lm.listing_id
    LEFT JOIN MATERIALS m ON lm.material_id = m.material_id
    WHERE l.deleted_at IS NULL AND l.is_active = 1
    GROUP BY l.listing_id
"""

# Same logic, but filtered for a single listing_id
SINGLE_LISTING_QUERY = """
    SELECT
        l.listing_id, l.title, l.description, l.price,
        l.made_in, l.is_active, l.deleted_at,
        c.name AS category_name,
        b.brand_name,
        GROUP_CONCAT(DISTINCT co.color_name SEPARATOR ', ') AS color,
        GROUP_CONCAT(DISTINCT m.material_name SEPARATOR ', ') AS material
    FROM LISTINGS l
    JOIN CATEGORIES c ON l.category_id = c.category_id
    JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
    JOIN BRANDS b ON pl.brand_id = b.brand_id
    LEFT JOIN COLORS lc ON l.listing_id = lc.listing_id
    LEFT JOIN COLORS co ON lc.color_id = co.color_id
    LEFT JOIN LISTING_MATERIALS lm ON l.listing_id = lm.listing_id
    LEFT JOIN MATERIALS m ON lm.material_id = m.material_id
    WHERE l.listing_id = %s
    GROUP BY l.listing_id
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