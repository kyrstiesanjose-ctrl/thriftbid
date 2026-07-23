CREATE DATABASE IF NOT EXISTS thriftbid_db2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE thriftbid_db2;

SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================================
-- 1. SELLER TABLE
-- =========================================================================
CREATE TABLE SELLER (
    seller_id INT(12) NOT NULL AUTO_INCREMENT,
    username VARCHAR(48) NOT NULL UNIQUE,
    shop_name VARCHAR(100) DEFAULT NULL, -- storefront/display name shown to buyers; falls back to username if not set
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cellphone_number VARCHAR(15) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    ig_follower_count INT DEFAULT 0, -- For Sales Bias Dashboard  
    seller_status ENUM('Active', 'Suspended', 'Banned') DEFAULT 'Active',
    offense_count INT DEFAULT 0,                 -- Tracks seller rules violations[cite: 1]
    wallet_frozen_until DATETIME DEFAULT NULL,   -- Temporary payout freezes[cite: 1]
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- ARCHIVING LOGIC: If a seller deactivates their account, set this to CURRENT_TIMESTAMP.
    -- DO NOT DELETE the row, otherwise past ORDERS and PAYMENTS will break.
    deactivated_at DATETIME DEFAULT NULL,        
    
    CONSTRAINT PK_SELLER PRIMARY KEY (seller_id)
);

-- =========================================================================
-- 2. BUYER TABLE
-- =========================================================================
CREATE TABLE BUYER (
    buyer_id INT(12) NOT NULL AUTO_INCREMENT,
    username VARCHAR(40) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cellphone_number VARCHAR(15) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    buyer_status ENUM('Active', 'Suspended', 'Banned') DEFAULT 'Active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- ARCHIVING LOGIC: If a buyer deactivates their account, set this to CURRENT_TIMESTAMP.
    -- This preserves their past purchase history and transaction logs.
    deactivated_at DATETIME DEFAULT NULL,        
    
    CONSTRAINT PK_BUYER PRIMARY KEY (buyer_id)
);

-- =====
-- ADMIN TABLE
-- =====
CREATE TABLE ADMIN (
    admin_id INT(12) NOT NULL AUTO_INCREMENT,
    username VARCHAR(40) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_ADMIN PRIMARY KEY (admin_id)
);

-- ==
-- ADDRESS
-- ==
CREATE TABLE ADDRESSES (
    address_id INT(12) NOT NULL AUTO_INCREMENT,
    user_id INT(12) NOT NULL, 
    user_type ENUM('Buyer', 'Seller') NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    is_default BOOLEAN DEFAULT TRUE,
    CONSTRAINT PK_ADDRESSES PRIMARY KEY (address_id)
);

-- ======
-- PARENT_CATEGORIES
-- ======
-- A real lookup table now — one row per parent group (7 rows total),
-- not one row per subcategory. CATEGORIES.parent_category_id below is
-- an actual foreign key into this table, so browsing by parent group
-- is a normal JOIN/WHERE instead of relying on two separately
-- auto-incrementing tables happening to be seeded in the same order.
CREATE TABLE PARENT_CATEGORIES (
    parent_category_id INT(5) NOT NULL AUTO_INCREMENT,
    parent_category ENUM('Tops', 'Bottoms', 'Dresses & Co_ords', 'Footwear', 'Bags & Purses', 'Accessories', 'Others') NOT NULL UNIQUE,
    CONSTRAINT PK_PARENT_CATEGORIES PRIMARY KEY (parent_category_id)
);


-- =========================================================================
-- 3. CATEGORIES TABLE
-- =========================================================================
CREATE TABLE CATEGORIES (
    category_id INT(5) NOT NULL AUTO_INCREMENT,
    name ENUM(
        'Blouse', 'Sleeveless', 'Long sleeve', 'Shirt',
        'Shorts', 'Skirts', 'Pants', 
        'Dress', 'Co-ords', 'Athleisure', 
        'Heels', 'Sneakers', 'Running shoes', 'Boots', 'Flats', 'Sandals',
        'Bags & Purses',
        'Accessories', 'Earrings', 'Rings', 'Necklace', 'Bracelet', 
        'Aesthetic Bundles'
    ) NOT NULL,
    parent_category_id INT(5) NOT NULL,
    CONSTRAINT PK_CATEGORIES PRIMARY KEY (category_id),
    CONSTRAINT FK_CATEGORIES_PARENT FOREIGN KEY (parent_category_id) REFERENCES PARENT_CATEGORIES(parent_category_id)
);


-- =========================================================================
-- 4. CATEGORY_SIZES TABLE (Feeds dynamic dropdown options by Category)
-- =========================================================================
CREATE TABLE CATEGORY_SIZES (
    size_id INT(12) NOT NULL AUTO_INCREMENT,
    category_id INT(5) NOT NULL,
    -- NOTE: the source spec had this as an empty ENUM() — MySQL rejects an
    -- ENUM with zero values, so this is filled in with every size token used
    -- across all categories (clothing letters, numeric shoe/pants sizes,
    -- bag/accessory sizing, and jewelry). Which values are *offered* for a
    -- given listing is still controlled by category_id, not by this list.
    size_value ENUM(
        'XXS','XS','S','M','L','XL','XXL','XXXL',
        '24','25','26','27','28','29','30','31','32','33','34','35','36','38','40','42',
        '35.5','36.5','37','37.5','38.5','39','39.5','40.5','41','41.5','42.5','43','43.5','44','45',
        'Mini','Small','Medium','Large','One Size',
        '5','6','7','8','9','10','11','12'
    ) NOT NULL,
    CONSTRAINT PK_CATEGORY_SIZES PRIMARY KEY (size_id),
    CONSTRAINT FK_SIZE_CATEGORY FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id) ON DELETE CASCADE
);

-- =========================================================================
-- 5. BRANDS TABLE
-- =========================================================================
CREATE TABLE BRANDS (
    brand_id INT(12) NOT NULL AUTO_INCREMENT,
    brand_name VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT PK_BRANDS PRIMARY KEY (brand_id)
);

-- =========================================================================
-- 6. PRODUCT_LINES TABLE (Binds Brands to specific Tiers & price models)
-- =========================================================================
CREATE TABLE PRODUCT_LINES (
    product_line_id INT(12) NOT NULL AUTO_INCREMENT,
    brand_id INT(12) NOT NULL,
    line_name VARCHAR(100) NOT NULL,
    tier ENUM('High', 'Mid', 'Low', 'Unbranded') NOT NULL DEFAULT 'Low',
    estimated_price_min DECIMAL(10,2) DEFAULT NULL, -- Used for price prediction algorithm[cite: 1]
    estimated_price_max DECIMAL(10,2) DEFAULT NULL, -- Used for price prediction algorithm[cite: 1]
    CONSTRAINT PK_PRODUCT_LINES PRIMARY KEY (product_line_id),
    CONSTRAINT FK_PL_BRAND FOREIGN KEY (brand_id) REFERENCES BRANDS(brand_id) ON DELETE CASCADE
);

-- =========================================================================
-- 7. LISTINGS TABLE
-- =========================================================================
CREATE TABLE LISTINGS (
    listing_id INT(12) NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2) DEFAULT NULL,   -- Optional: what the item retailed for new, shown alongside the selling price
    condition_grade ENUM('Brand New', 'Like New', 'Lightly Used', 'Well Used', 'Heavily Used') NOT NULL,
    color VARCHAR(50) DEFAULT NULL,               -- Optional descriptive attribute, e.g. 'Black', 'Multicolor'
    material VARCHAR(50) DEFAULT NULL,            -- Optional descriptive attribute, e.g. 'Leather', 'Cotton'
    target_gender ENUM('Men', 'Women', 'Unisex', 'Kids') DEFAULT NULL,  -- Optional, filterable
    made_in VARCHAR(100) DEFAULT NULL,            -- Optional country of manufacture
    is_active BOOLEAN DEFAULT TRUE,              -- Toggle for drafts or temporarily pausing the listing
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    category_id INT(5) NOT NULL,
    seller_id INT(12) NOT NULL,
    product_line_id INT(12) NOT NULL,             -- Automatically determines tier level via join
    size_id INT(12) NOT NULL,                    -- Pulls specific sizes dynamically matched to category
    
    -- ARCHIVING LOGIC: When a seller "deletes" an item, we fill this with CURRENT_TIMESTAMP.
    -- The frontend should filter search results with `WHERE deleted_at IS NULL`.
    -- This ensures old orders pointing to this listing_id don't break.
    deleted_at DATETIME DEFAULT NULL,            
    
    CONSTRAINT PK_LISTINGS PRIMARY KEY (listing_id),
    CONSTRAINT FK_LISTINGS_CATEGORY FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id),
    CONSTRAINT FK_LISTINGS_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id),
    CONSTRAINT FK_LISTINGS_PROD_LINE FOREIGN KEY (product_line_id) REFERENCES PRODUCT_LINES(product_line_id),
    CONSTRAINT FK_LISTINGS_SIZE FOREIGN KEY (size_id) REFERENCES CATEGORY_SIZES(size_id)
);


-- == 
-- LISTING_IMAGES
-- ==
CREATE TABLE LISTING_IMAGES (
    image_id INT(12) NOT NULL AUTO_INCREMENT,
    listing_id INT(12) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_LISTING_IMAGES PRIMARY KEY (image_id),
    CONSTRAINT FK_IMAGES_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);

-- =========================================================================
-- 8. AUCTIONS TABLE
-- =========================================================================
CREATE TABLE AUCTIONS (
    auction_id INT(12) NOT NULL AUTO_INCREMENT,
    start_bid DECIMAL(10,2) NOT NULL,
    min_increment DECIMAL(10,2) NOT NULL,
    current_highest_bid DECIMAL(10,2) DEFAULT 0.00,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('Active', 'Closed') DEFAULT 'Active',
    listing_type ENUM('Auction') DEFAULT 'Auction', -- Adjusted to fit non-live bidding rules
    extension_count INT DEFAULT 0,
    listing_id INT(12) NOT NULL,
    
    -- ARCHIVING LOGIC: If a seller cancels or deletes an active auction setup.
    deleted_at DATETIME DEFAULT NULL,            
    
    CONSTRAINT PK_AUCTIONS PRIMARY KEY (auction_id),
    CONSTRAINT FK_AUCTIONS_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);

-- =========================================================================
-- 9. BIDDINGS TABLE
-- =========================================================================
CREATE TABLE BIDDINGS (
    bidding_id INT(12) NOT NULL AUTO_INCREMENT,
    bid_amount DECIMAL(10,2) NOT NULL,
    bid_time DATETIME NOT NULL,
    auction_id INT(12) NOT NULL,
    buyer_id INT(12) NOT NULL,
    
    -- ARCHIVING LOGIC: If an admin removes a fraudulent bid, we soft-delete it.
    -- Deleted bids will not be calculated by the trigger updating the highest bid.
    is_deleted BOOLEAN DEFAULT FALSE,            
    
    CONSTRAINT PK_BIDDINGS PRIMARY KEY (bidding_id),
    CONSTRAINT FK_BIDDINGS_AUCTION FOREIGN KEY (auction_id) REFERENCES AUCTIONS(auction_id) ON DELETE CASCADE,
    CONSTRAINT FK_BIDDINGS_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id)
);


-- =========================================================================
-- 11. ORDERS TABLE
-- =========================================================================
CREATE TABLE ORDERS (
    order_id INT(12) NOT NULL AUTO_INCREMENT,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Preparing', 'Shipped', 'Out for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Preparing',
    listing_id INT(12) NOT NULL,
    buyer_id INT(12) NOT NULL,
    seller_id INT(12) NOT NULL,
    
    -- ARCHIVING LOGIC: Orders are legal/financial history and should NEVER be hard deleted.
    -- If an order is canceled, its status changes to 'Cancelled', we don't delete the row.
    
    CONSTRAINT PK_ORDERS PRIMARY KEY (order_id),
    CONSTRAINT FK_ORDERS_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id),
    CONSTRAINT FK_ORDERS_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_ORDERS_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);


-- == 
-- CURRENCY RATES
-- ==
CREATE TABLE CURRENCY_RATES (
    rate_id INT(12) NOT NULL AUTO_INCREMENT,
    base_currency ENUM('PHP', 'USD', 'KRW') NOT NULL,
    target_currency ENUM('PHP', 'USD', 'KRW') NOT NULL,
    exchange_rate DECIMAL(10,4) NOT NULL,
    recorded_date DATE NOT NULL,
    CONSTRAINT PK_CURRENCY_RATES PRIMARY KEY (rate_id),
    -- Needed so currency.php's "INSERT ... ON DUPLICATE KEY UPDATE"
    -- (persistRates()) actually updates today's row in place instead of
    -- silently inserting a fresh duplicate row every single day forever.
    CONSTRAINT UQ_CURRENCY_RATES UNIQUE (base_currency, target_currency, recorded_date)
);

-- =========================================================================
-- 12. PAYMENTS TABLE (Funnels External API Data directly inside)
-- =========================================================================
CREATE TABLE PAYMENTS (
    payment_id INT(12) NOT NULL AUTO_INCREMENT,
    payment_method ENUM('GCash', 'Bank') NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    currency ENUM('PHP', 'USD', 'KRW') DEFAULT 'PHP',
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    gateway_reference_token VARCHAR(255) NULL,   -- Captures external unique charge transaction key[cite: 1]
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_id INT(12) NOT NULL,
    
    -- ARCHIVING LOGIC: Payments must NEVER be deleted for financial audit reasons.
    
    CONSTRAINT PK_PAYMENTS PRIMARY KEY (payment_id),
    CONSTRAINT FK_PAYMENTS_ORDER FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE
);

-- =========================================================================
-- 13. TRANSACTIONS TABLE
-- =========================================================================
CREATE TABLE TRANSACTIONS (
    transaction_id INT(12) NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_id INT(12) NOT NULL,
    payment_id INT(12) NOT NULL,
    CONSTRAINT PK_TRANSACTIONS PRIMARY KEY (transaction_id),
    CONSTRAINT FK_TRANSACTIONS_ORDER FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    CONSTRAINT FK_TRANSACTIONS_PAYMENT FOREIGN KEY (payment_id) REFERENCES PAYMENTS(payment_id)
);


-- =========================================================================
-- 15. REVIEWS TABLE
-- =========================================================================
CREATE TABLE REVIEWS (
    review_id INT(12) NOT NULL AUTO_INCREMENT,
    buyer_id INT(12) NOT NULL,
    seller_id INT(12) NOT NULL,
    order_id INT(12) NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- ARCHIVING LOGIC: If a user deletes their review, we soft-delete it.
    -- Soft-deleted reviews won't show on the seller's profile or affect average ratings.
    deleted_at DATETIME DEFAULT NULL,            
    
    CONSTRAINT PK_REVIEWS PRIMARY KEY (review_id),
    CONSTRAINT FK_REVIEWS_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_REVIEWS_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id),
    CONSTRAINT FK_REVIEWS_ORDER FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
);

-- =========================================================================
-- 16. DISPUTES TABLE
-- =========================================================================
CREATE TABLE DISPUTES (
    dispute_id INT(12) NOT NULL AUTO_INCREMENT,
    order_id INT(12) NOT NULL,
    buyer_id INT(12) NOT NULL,
    seller_id INT(12) NOT NULL,
    assigned_admin_id INT(12) NULL,             -- System admin reviewing the case[cite: 1]
    reason VARCHAR(255) NOT NULL,
    status ENUM('Open', 'Under Review', 'Resolved', 'Rejected') DEFAULT 'Open',
    resolution_type ENUM('Full Refund', 'Partial Refund') DEFAULT NULL,
    opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME DEFAULT NULL,
    CONSTRAINT PK_DISPUTES PRIMARY KEY (dispute_id),
    CONSTRAINT FK_DISPUTES_ORDER FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    CONSTRAINT FK_DISPUTES_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_DISPUTES_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- =========================================================================
-- 17. NOTIFICATIONS TABLE
-- =========================================================================
CREATE TABLE NOTIFICATIONS (
    notification_id INT(12) NOT NULL AUTO_INCREMENT,
    buyer_id INT(12) NULL,
    seller_id INT(12) NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
                
    
    CONSTRAINT PK_NOTIFICATIONS PRIMARY KEY (notification_id),
    CONSTRAINT FK_NOTIFICATIONS_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_NOTIFICATIONS_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- =========================================================================
-- 18. COURIERS TABLE
-- =========================================================================
CREATE TABLE COURIERS (
    courier_id INT(12) NOT NULL AUTO_INCREMENT,
    courier_name VARCHAR(50) NOT NULL,
    contact_no VARCHAR(20),
    CONSTRAINT PK_COURIERS PRIMARY KEY (courier_id)
);

-- =========================================================================
-- 19. SHIPMENTS TABLE (Physical shipment tracking metadata)
-- =========================================================================
CREATE TABLE SHIPMENTS (
    shipment_id INT(12) NOT NULL AUTO_INCREMENT,
    order_id INT(12) NOT NULL,
    courier_id INT(12) NOT NULL,
    tracking_number VARCHAR(50) NOT NULL UNIQUE,
    shipping_fee DECIMAL(10,2) DEFAULT 0.00,
    estimated_delivery DATE,
    shipped_date DATETIME,
    delivered_date DATETIME,
    status ENUM('Preparing', 'Shipped', 'Out for Delivery', 'Delivered', 'Returned') DEFAULT 'Preparing',
    CONSTRAINT PK_SHIPMENTS PRIMARY KEY (shipment_id),
    CONSTRAINT FK_SHIPMENTS_ORDER FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_SHIPMENTS_COURIER FOREIGN KEY (courier_id) REFERENCES COURIERS(courier_id)
);

-- =========================================================================
-- 20. TRACKING_LOGS TABLE (Detailed progress stops timeline for transit)
-- =========================================================================
CREATE TABLE TRACKING_LOGS (
    tracking_id INT(12) NOT NULL AUTO_INCREMENT,
    shipment_id INT(12) NOT NULL,
    location VARCHAR(100) NOT NULL,
    status ENUM('Preparing', 'Shipped', 'Out for Delivery', 'Delivered', 'Returned') NOT NULL,
    remarks VARCHAR(255),
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_TRACKING_LOGS PRIMARY KEY (tracking_id),
    CONSTRAINT FK_TRACKING_LOGS_SHIPMENT FOREIGN KEY (shipment_id) REFERENCES SHIPMENTS(shipment_id) ON DELETE CASCADE
);

-- =========================================================================
-- 21. PENALTIES TABLE
-- =========================================================================
CREATE TABLE PENALTIES (
    penalty_id INT(12) NOT NULL AUTO_INCREMENT,
    buyer_id INT(12) NULL,
    seller_id INT(12) NULL,
    reason VARCHAR(255) NOT NULL,
    penalty_type ENUM('Bidding Suspension', 'Selling Suspension', 'Wallet Freeze', 'Account Ban') NOT NULL,
    status ENUM('Active', 'Served', 'Expired') DEFAULT 'Active',
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    period_end DATETIME DEFAULT NULL,
    CONSTRAINT PK_PENALTIES PRIMARY KEY (penalty_id),
    CONSTRAINT FK_PENALTIES_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_PENALTIES_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- =========================================================================
-- 22. SELLER_AWARDS TABLE
-- =========================================================================
CREATE TABLE SELLER_AWARDS (
    award_id INT(12) NOT NULL AUTO_INCREMENT,
    seller_id INT(12) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    award_type ENUM('Top Seller Badge', 'Fee Discount') NOT NULL,
    status ENUM('Active', 'Expired') DEFAULT 'Active',
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    period_end DATETIME DEFAULT NULL,
    CONSTRAINT PK_SELLER_AWARDS PRIMARY KEY (award_id),
    CONSTRAINT FK_AWARDS_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id) ON DELETE CASCADE
);

-- =========================================================================
-- 23. FRAUD_FLAGS TABLE
-- =========================================================================
CREATE TABLE FRAUD_FLAGS (
    fraud_flag_id INT(12) NOT NULL AUTO_INCREMENT,
    auction_id INT(12) NULL,
    listing_id INT(12) NULL,
    buyer_id INT(12) NULL,
    seller_id INT(12) NULL,
    signals_detected VARCHAR(255) NOT NULL,
    status ENUM('Pending', 'Reviewed', 'Resolved') DEFAULT 'Pending',
    reviewed_by_admin_id INT(12) NULL,          -- Admin who checked the warning flag[cite: 1]
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_FRAUD_FLAGS PRIMARY KEY (fraud_flag_id),
    CONSTRAINT FK_FRAUD_AUCTION FOREIGN KEY (auction_id) REFERENCES AUCTIONS(auction_id),
    CONSTRAINT FK_FRAUD_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id),
    CONSTRAINT FK_FRAUD_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id),
    CONSTRAINT FK_FRAUD_SELLER FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);


-- =========================================================================
-- 25. BROWSING_HISTORY TABLE
-- =========================================================================
CREATE TABLE BROWSING_HISTORY (
    history_id INT(12) NOT NULL AUTO_INCREMENT,
    buyer_id INT(12) NOT NULL,
    listing_id INT(12) NOT NULL,
    interaction_type ENUM('Viewed', 'Added_To_Cart', 'Bid', 'Outbid', 'Won', 'Lost') NOT NULL,
    viewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_BROWSING_HISTORY PRIMARY KEY (history_id),
    CONSTRAINT FK_HISTORY_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id) ON DELETE CASCADE,
    CONSTRAINT FK_HISTORY_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);

-- =========================================================================
-- 28. CART_ITEMS TABLE
-- =========================================================================
CREATE TABLE CART_ITEMS (
    cart_item_id INT(12) NOT NULL AUTO_INCREMENT,
    buyer_id INT(12) NOT NULL,
    listing_id INT(12) NOT NULL,
    quantity INT DEFAULT 1,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- ARCHIVING LOGIC: Shopping carts are completely temporary. When a user checks out 
    -- or removes an item, we can run a hard DELETE on the row here.
    
    CONSTRAINT PK_CART_ITEMS PRIMARY KEY (cart_item_id),
    CONSTRAINT FK_CART_BUYER FOREIGN KEY (buyer_id) REFERENCES BUYER(buyer_id) ON DELETE CASCADE,
    CONSTRAINT FK_CART_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE,
    CONSTRAINT UQ_CART_ITEM UNIQUE (buyer_id, listing_id)
);

-- =========================================================================
-- 29. AUTHENTICATION TABLE (Handles High-Tier Admin Authentications)
-- =========================================================================
CREATE TABLE AUTHENTICATION (
    authentication_id INT(12) NOT NULL AUTO_INCREMENT,
    listing_id INT(12) NOT NULL,
    authentication_status ENUM('Verified', 'Pending', 'Rejected') DEFAULT 'Pending',
    verified_by_admin_id INT(12) NULL,          -- Admin key verifying product authenticity[cite: 1]
    date_verified DATETIME DEFAULT NULL,
    manufacture_year YEAR DEFAULT NULL,
    remarks VARCHAR(255) DEFAULT NULL,
    CONSTRAINT PK_AUTHENTICATION PRIMARY KEY (authentication_id),
    CONSTRAINT FK_AUTH_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);

-- =========================================================================
-- 30. LISTING_ANALYTICS TABLE
-- =========================================================================
CREATE TABLE LISTING_ANALYTICS (
    analytics_id INT(12) NOT NULL AUTO_INCREMENT,
    listing_id INT(12) NOT NULL,
    view_count INT DEFAULT 0,
    follower_count INT DEFAULT 0,
    completeness_score DECIMAL(5,2) DEFAULT NULL,
    photo_score DECIMAL(5,2) DEFAULT NULL,
    details_score DECIMAL(5,2) DEFAULT NULL,
    condition_score DECIMAL(5,2) DEFAULT NULL,
    shipping_score DECIMAL(5,2) DEFAULT NULL,
    pricing_score DECIMAL(5,2) DEFAULT NULL,
    view_to_bid_score DECIMAL(5,2) DEFAULT NULL,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT PK_LISTING_ANALYTICS PRIMARY KEY (analytics_id),
    CONSTRAINT FK_ANALYTICS_LISTING FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);


-- == 
-- AUDIT LOGS
-- ===
CREATE TABLE AUDIT_LOGS (
    log_id INT(12) NOT NULL AUTO_INCREMENT,
    admin_id INT(12) NOT NULL,
    action_taken VARCHAR(255) NOT NULL,
    table_affected VARCHAR(50) NOT NULL,
    record_id INT(12) NOT NULL, 
    old_value TEXT NULL,
    new_value TEXT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_AUDIT_LOGS PRIMARY KEY (log_id),
    CONSTRAINT FK_AUDIT_ADMIN FOREIGN KEY (admin_id) REFERENCES ADMIN(admin_id)
);

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- TRIGGERS (merged into schema so no separate file/manual step is needed)
-- ============================================================

-- ============================================================
-- ThriftBid — Core Trigger Set (updated schema: thriftbid_db2)
-- ------------------------------------------------------------
-- 16 triggers covering the auction/bidding engine, order/payment
-- automation, seller shipping-obligation penalties, the luxury
-- authentication workflow, and listing analytics upkeep.
-- Run this AFTER schema.sql (all referenced tables must exist).
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- 1. BEFORE INSERT ON BIDDINGS — validate the bid before it lands
--    (auction must be Active and not past end_time; amount must
--    clear current_highest_bid + min_increment)
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS before_bid_validate_amount$$
CREATE TRIGGER before_bid_validate_amount
BEFORE INSERT ON BIDDINGS
FOR EACH ROW
BEGIN
    DECLARE v_highest DECIMAL(10,2);
    DECLARE v_incr    DECIMAL(10,2);
    DECLARE v_status  VARCHAR(20);
    DECLARE v_end     DATETIME;

    SELECT current_highest_bid, min_increment, status, end_time
      INTO v_highest, v_incr, v_status, v_end
      FROM AUCTIONS WHERE auction_id = NEW.auction_id;

    IF v_status <> 'Active' OR NOW() >= v_end THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This auction has already closed.';
    END IF;

    IF NEW.bid_amount < (v_highest + v_incr) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bid does not meet the minimum increment requirement.';
    END IF;
END$$

-- ------------------------------------------------------------
-- 2. AFTER INSERT ON BIDDINGS — bump the auction's highest bid AND
--    apply the anti-snipe rule (extend by 2 min if bid lands inside
--    the last 2 minutes, capped at 10 extensions / +20 min total)
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_bid_update_auction$$
CREATE TRIGGER after_bid_update_auction
AFTER INSERT ON BIDDINGS
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = FALSE THEN
        UPDATE AUCTIONS
           SET current_highest_bid = NEW.bid_amount
         WHERE auction_id = NEW.auction_id
           AND NEW.bid_amount > current_highest_bid;

        UPDATE AUCTIONS
           SET end_time = DATE_ADD(end_time, INTERVAL 2 MINUTE),
               extension_count = extension_count + 1
         WHERE auction_id = NEW.auction_id
           AND status = 'Active'
           AND extension_count < 10
           AND TIMESTAMPDIFF(SECOND, NEW.bid_time, end_time) <= 120;
    END IF;

    -- Log the interaction for the diagnostic/behavior reports
    INSERT INTO BROWSING_HISTORY (buyer_id, listing_id, interaction_type)
    SELECT NEW.buyer_id, a.listing_id, 'Bid'
      FROM AUCTIONS a WHERE a.auction_id = NEW.auction_id;
END$$

-- ------------------------------------------------------------
-- 3. AFTER INSERT ON ORDERS — deactivate the sold listing and
--    notify the seller
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_order_insert_deactivate_listing$$
CREATE TRIGGER after_order_insert_deactivate_listing
AFTER INSERT ON ORDERS
FOR EACH ROW
BEGIN
    UPDATE LISTINGS SET is_active = FALSE WHERE listing_id = NEW.listing_id;

    INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
    VALUES (
        NEW.seller_id,
        'New Order Received!',
        CONCAT('Order #', NEW.order_id, ' has been placed. Ship within 48 hours.'),
        'ORDER'
    );
END$$

-- ------------------------------------------------------------
-- 4. AFTER INSERT ON PAYMENTS — per the buyer flow rule, a payment
--    is treated as confirmed/completed as soon as it's recorded, so
--    auto-create the TRANSACTIONS ledger row and notify the buyer.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_payment_insert_create_transaction$$
CREATE TRIGGER after_payment_insert_create_transaction
AFTER INSERT ON PAYMENTS
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'Completed' THEN
        INSERT INTO TRANSACTIONS (amount, order_id, payment_id)
        VALUES (NEW.amount_paid, NEW.order_id, NEW.payment_id);

        INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
        SELECT o.buyer_id, 'Payment Confirmed', CONCAT('Your payment for Order #', o.order_id, ' was received.'), 'PAYMENT'
          FROM ORDERS o WHERE o.order_id = NEW.order_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- 5. AFTER UPDATE ON PAYMENTS — if a payment flips to Completed
--    later (edge case), still backfill the transaction ledger.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_payment_update_create_transaction$$
CREATE TRIGGER after_payment_update_create_transaction
AFTER UPDATE ON PAYMENTS
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'Completed' AND OLD.payment_status <> 'Completed' THEN
        INSERT INTO TRANSACTIONS (amount, order_id, payment_id)
        VALUES (NEW.amount_paid, NEW.order_id, NEW.payment_id);
    END IF;
END$$

-- ------------------------------------------------------------
-- 6. BEFORE UPDATE ON SHIPMENTS — a shipment can't move to
--    'Shipped' (or beyond) without a tracking number on file.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS before_shipment_require_tracking$$
CREATE TRIGGER before_shipment_require_tracking
BEFORE UPDATE ON SHIPMENTS
FOR EACH ROW
BEGIN
    IF NEW.status IN ('Shipped','Out for Delivery','Delivered')
       AND (NEW.tracking_number IS NULL OR NEW.tracking_number = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A tracking number is required before advancing shipment status.';
    END IF;
END$$

-- ------------------------------------------------------------
-- 7. AFTER UPDATE ON SHIPMENTS — auto-log every status change and
--    keep the parent ORDER's status in sync.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_shipment_status_change$$
CREATE TRIGGER after_shipment_status_change
AFTER UPDATE ON SHIPMENTS
FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO TRACKING_LOGS (shipment_id, location, status, remarks)
        VALUES (NEW.shipment_id, 'Seller Hub', NEW.status, CONCAT('Status changed to ', NEW.status));

        UPDATE ORDERS SET status = NEW.status WHERE order_id = NEW.order_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- 7b. AFTER UPDATE ON ORDERS — notify the buyer any time their
--     order's status changes (covers the sync from trigger #7 above
--     AND any other manual status change), so this is the single
--     place that owns "tell the buyer their order moved forward."
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_order_status_change_notify_buyer$$
CREATE TRIGGER after_order_status_change_notify_buyer
AFTER UPDATE ON ORDERS
FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
        VALUES (
            NEW.buyer_id,
            CONCAT('Order Update: ', NEW.status),
            CONCAT('Order #', NEW.order_id, ' is now "', NEW.status, '".'),
            'ORDER'
        );
    END IF;
END$$

-- ------------------------------------------------------------
-- 8. Late-shipment flagging — a scheduled EVENT, not a trigger,
--    since "48 hours have now passed with no shipment" is a fact
--    about elapsed wall-clock time, not something that happens on
--    a row insert/update. Runs hourly; auto-issues a PENALTIES row
--    (which then cascades through trigger #9 below) the first time
--    an order crosses the 48-hour mark with no SHIPMENTS row yet.
--    A "[LATE-SHIP-ORDER-#id]" tag in the reason text is how it
--    avoids flagging the same order twice on the next hourly run
--    (PENALTIES has no order_id column to key off of directly).
-- ------------------------------------------------------------
SET GLOBAL event_scheduler = ON$$

DROP EVENT IF EXISTS flag_late_shipments$$
CREATE EVENT flag_late_shipments
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO PENALTIES (seller_id, reason, penalty_type)
    SELECT o.seller_id,
           CONCAT('[LATE-SHIP-ORDER-#', o.order_id, '] Order not shipped within 48 hours of payment.'),
           'Selling Suspension'
    FROM ORDERS o
    JOIN PAYMENTS p   ON p.order_id = o.order_id AND p.payment_status = 'Completed'
    LEFT JOIN SHIPMENTS s ON s.order_id = o.order_id
    WHERE o.status = 'Preparing'
      AND s.shipment_id IS NULL
      AND o.order_date < DATE_SUB(NOW(), INTERVAL 48 HOUR)
      AND NOT EXISTS (
          SELECT 1 FROM PENALTIES pe
          WHERE pe.seller_id = o.seller_id
            AND pe.reason LIKE CONCAT('%[LATE-SHIP-ORDER-#', o.order_id, ']%')
      );
END$$

-- ------------------------------------------------------------
-- 9. AFTER INSERT ON PENALTIES — enforce the escalating penalty
--    structure: 1st = flag only, 2nd = 30-day selling suspension +
--    wallet freeze, 3rd+ = permanent ban.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_penalty_insert_escalate$$
CREATE TRIGGER after_penalty_insert_escalate
AFTER INSERT ON PENALTIES
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.seller_id IS NOT NULL THEN
        UPDATE SELLER SET offense_count = offense_count + 1 WHERE seller_id = NEW.seller_id;
        SELECT offense_count INTO v_count FROM SELLER WHERE seller_id = NEW.seller_id;

        IF v_count = 2 THEN
            UPDATE SELLER
               SET seller_status = 'Suspended',
                   wallet_frozen_until = DATE_ADD(NOW(), INTERVAL 30 DAY)
             WHERE seller_id = NEW.seller_id;
        ELSEIF v_count >= 3 THEN
            UPDATE SELLER SET seller_status = 'Banned' WHERE seller_id = NEW.seller_id;
        END IF;

        INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
        VALUES (NEW.seller_id, 'Penalty Issued', CONCAT('Reason: ', NEW.reason), 'SYSTEM');
    END IF;
END$$

-- ------------------------------------------------------------
-- 10. AFTER UPDATE ON DISPUTES — 3+ resolved misrepresentation
--     disputes against the same seller auto-issues a penalty,
--     which then cascades through trigger #9 above.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_dispute_resolved_check_pattern$$
CREATE TRIGGER after_dispute_resolved_check_pattern
AFTER UPDATE ON DISPUTES
FOR EACH ROW
BEGIN
    DECLARE v_valid_count INT;

    IF NEW.status = 'Resolved' AND OLD.status <> 'Resolved'
       AND NEW.reason LIKE '%misrepresent%' THEN

        SELECT COUNT(*) INTO v_valid_count
          FROM DISPUTES
         WHERE seller_id = NEW.seller_id
           AND status = 'Resolved'
           AND reason LIKE '%misrepresent%';

        IF v_valid_count >= 3 THEN
            INSERT INTO PENALTIES (seller_id, reason, penalty_type)
            VALUES (NEW.seller_id, 'Repeated item misrepresentation (3+ resolved disputes)', 'Selling Suspension');
        END IF;
    END IF;
END$$

-- ------------------------------------------------------------
-- 11. BEFORE UPDATE ON AUTHENTICATION — a status can't move to
--     Verified/Rejected without an admin attached.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS before_authentication_require_admin$$
CREATE TRIGGER before_authentication_require_admin
BEFORE UPDATE ON AUTHENTICATION
FOR EACH ROW
BEGIN
    IF NEW.authentication_status IN ('Verified','Rejected') AND NEW.verified_by_admin_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An admin must be attached to verify or reject an authentication request.';
    END IF;
    IF NEW.authentication_status IN ('Verified','Rejected') AND NEW.date_verified IS NULL THEN
        SET NEW.date_verified = NOW();
    END IF;
END$$

-- ------------------------------------------------------------
-- 12. AFTER UPDATE ON AUTHENTICATION — the luxury-item workflow:
--     Verified => auto-post the listing (is_active = 1).
--     Rejected => keep the listing inactive and notify the seller.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_authentication_status_change$$
CREATE TRIGGER after_authentication_status_change
AFTER UPDATE ON AUTHENTICATION
FOR EACH ROW
BEGIN
    IF NEW.authentication_status <> OLD.authentication_status THEN
        IF NEW.authentication_status = 'Verified' THEN
            UPDATE LISTINGS SET is_active = TRUE WHERE listing_id = NEW.listing_id;

            INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
            SELECT l.seller_id, 'Item Authenticated', CONCAT('"', l.title, '" passed authentication and is now live.'), 'SYSTEM'
              FROM LISTINGS l WHERE l.listing_id = NEW.listing_id;

        ELSEIF NEW.authentication_status = 'Rejected' THEN
            UPDATE LISTINGS SET is_active = FALSE WHERE listing_id = NEW.listing_id;

            INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
            SELECT l.seller_id, 'Authentication Rejected',
                   CONCAT('"', l.title, '" failed authentication', IFNULL(CONCAT(': ', NEW.remarks), '.')), 'SYSTEM'
              FROM LISTINGS l WHERE l.listing_id = NEW.listing_id;
        END IF;
    END IF;
END$$

-- ------------------------------------------------------------
-- 13. AFTER INSERT ON LISTINGS — seed a LISTING_ANALYTICS row so
--     the seller dashboards (Performance/Optimization reports)
--     always have something to aggregate against.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_listing_insert_seed_analytics$$
CREATE TRIGGER after_listing_insert_seed_analytics
AFTER INSERT ON LISTINGS
FOR EACH ROW
BEGIN
    INSERT INTO LISTING_ANALYTICS (listing_id, view_count, follower_count, completeness_score)
    VALUES (NEW.listing_id, 0, 0,
            -- baseline completeness: title/category/condition/size/product_line already required at insert time
            60.00);
END$$

-- ------------------------------------------------------------
-- 14. AFTER INSERT ON LISTING_IMAGES — recompute the listing's
--     photo_score (and roll it into completeness_score) every time
--     a new photo is attached. 3+ photos = full marks.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_listing_image_insert_update_score$$
CREATE TRIGGER after_listing_image_insert_update_score
AFTER INSERT ON LISTING_IMAGES
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    DECLARE v_score DECIMAL(5,2);

    SELECT COUNT(*) INTO v_count FROM LISTING_IMAGES WHERE listing_id = NEW.listing_id;
    SET v_score = LEAST(100, v_count * 33.33);

    UPDATE LISTING_ANALYTICS
       SET photo_score = v_score,
           completeness_score = LEAST(100, (IFNULL(photo_score,0) + IFNULL(details_score,60) + IFNULL(condition_score,60) + IFNULL(shipping_score,60) + IFNULL(pricing_score,60)) / 5)
     WHERE listing_id = NEW.listing_id;
END$$

-- ------------------------------------------------------------
-- 15. BEFORE INSERT ON REVIEWS — one review per order, no dupes.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS before_review_prevent_duplicate$$
CREATE TRIGGER before_review_prevent_duplicate
BEFORE INSERT ON REVIEWS
FOR EACH ROW
BEGIN
    DECLARE v_existing INT;
    SELECT COUNT(*) INTO v_existing FROM REVIEWS WHERE order_id = NEW.order_id AND deleted_at IS NULL;
    IF v_existing > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This order has already been reviewed.';
    END IF;
END$$

-- ------------------------------------------------------------
-- 16. AFTER INSERT ON SELLER_AWARDS — congratulate the seller.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_seller_award_notify$$
CREATE TRIGGER after_seller_award_notify
AFTER INSERT ON SELLER_AWARDS
FOR EACH ROW
BEGIN
    INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
    VALUES (NEW.seller_id, 'You earned an award!', NEW.reason, 'SYSTEM');
END$$

-- ================================================================
-- STORED PROCEDURES
-- ------------------------------------------------------------
-- These wrap the business logic that used to be written out as raw,
-- duplicated SQL in the PHP files (the same "close an auction and
-- pick a winner" logic existed only in one place before, but things
-- like "resolve a dispute" or "suspend a seller" have several call
-- sites). Putting them here means every caller gets the exact same
-- behavior, and the trigger chain (offense escalation, notifications,
-- etc.) still does its job same as always — these procedures don't
-- duplicate what the triggers already do, they just do the INSERT/
-- UPDATE and let the triggers react to it, same as the PHP code did.
-- ================================================================

-- 1. Close an auction, pick the highest bidder, create their order.
DROP PROCEDURE IF EXISTS sp_close_auction$$
CREATE PROCEDURE sp_close_auction(IN p_auction_id INT)
BEGIN
    DECLARE v_listing_id INT;
    DECLARE v_seller_id INT;
    DECLARE v_title VARCHAR(200);
    DECLARE v_winner_buyer_id INT;
    DECLARE v_winner_username VARCHAR(48);
    DECLARE v_winner_bid DECIMAL(10,2);
    DECLARE v_order_id INT;

    SELECT a.listing_id, l.seller_id, l.title INTO v_listing_id, v_seller_id, v_title
    FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id = l.listing_id
    WHERE a.auction_id = p_auction_id;

    UPDATE AUCTIONS SET status = 'Closed' WHERE auction_id = p_auction_id;

    SELECT b.buyer_id, bu.username, b.bid_amount INTO v_winner_buyer_id, v_winner_username, v_winner_bid
    FROM BIDDINGS b JOIN BUYER bu ON b.buyer_id = bu.buyer_id
    WHERE b.auction_id = p_auction_id AND b.is_deleted = 0
    ORDER BY b.bid_amount DESC LIMIT 1;

    IF v_winner_buyer_id IS NOT NULL THEN
        INSERT INTO ORDERS (listing_id, buyer_id, seller_id) VALUES (v_listing_id, v_winner_buyer_id, v_seller_id);
        SET v_order_id = LAST_INSERT_ID();

        INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
        VALUES (v_winner_buyer_id, 'You Won the Auction!',
                CONCAT('Congratulations! You won "', v_title, '" with a bid of PHP ', v_winner_bid, '. Please proceed to checkout.'), 'AUCTION');
        INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type)
        VALUES (v_seller_id, 'Auction Closed', CONCAT('Your auction for "', v_title, '" ended. Winner: @', v_winner_username, '.'), 'AUCTION');
    END IF;
END$$

-- 2. Mark an order shipped — inserts the shipment as Preparing, then
--    updates to Shipped, which is what fires the tracking-log +
--    order-status-sync trigger.
DROP PROCEDURE IF EXISTS sp_ship_order$$
CREATE PROCEDURE sp_ship_order(IN p_order_id INT, IN p_courier_id INT, IN p_tracking_number VARCHAR(100))
BEGIN
    DECLARE v_shipment_id INT;
    DECLARE v_buyer_id INT;
    DECLARE v_title VARCHAR(200);

    INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (p_order_id, p_courier_id, p_tracking_number, 'Preparing');
    SET v_shipment_id = LAST_INSERT_ID();
    UPDATE SHIPMENTS SET status = 'Shipped', shipped_date = NOW() WHERE shipment_id = v_shipment_id;

    SELECT o.buyer_id, l.title INTO v_buyer_id, v_title
    FROM ORDERS o JOIN LISTINGS l ON o.listing_id = l.listing_id WHERE o.order_id = p_order_id;

    INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
    VALUES (v_buyer_id, 'Your Order Has Shipped!', CONCAT('Your order #', p_order_id, ' has been shipped! Tracking: ', p_tracking_number), 'ORDER');
END$$

-- 3. Resolve an order dispute (Full/Partial Refund), optionally
--    penalizing the seller.
DROP PROCEDURE IF EXISTS sp_resolve_dispute$$
CREATE PROCEDURE sp_resolve_dispute(IN p_dispute_id INT, IN p_admin_id INT, IN p_resolution_type VARCHAR(20), IN p_penalize_seller BOOLEAN)
BEGIN
    DECLARE v_buyer_id INT; DECLARE v_seller_id INT; DECLARE v_reason VARCHAR(255);

    SELECT buyer_id, seller_id, reason INTO v_buyer_id, v_seller_id, v_reason FROM DISPUTES WHERE dispute_id = p_dispute_id;

    UPDATE DISPUTES SET status = 'Resolved', resolution_type = p_resolution_type, assigned_admin_id = p_admin_id, resolved_at = NOW()
    WHERE dispute_id = p_dispute_id;

    INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
    VALUES (v_buyer_id, CONCAT('Dispute Resolved - ', p_resolution_type),
            CONCAT('Your dispute #', p_dispute_id, ' has been resolved (', LOWER(p_resolution_type), '). Your refund will be processed within 24 hours.'), 'ORDER');

    IF p_penalize_seller THEN
        INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (v_seller_id, CONCAT('Dispute #', p_dispute_id, ' resolved against seller: ', v_reason), 'Selling Suspension');
    END IF;

    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, CONCAT('Resolved dispute (', p_resolution_type, ')'), 'DISPUTES', p_dispute_id, 'Open', 'Resolved');
END$$

-- 4. Reject an order dispute.
DROP PROCEDURE IF EXISTS sp_reject_dispute$$
CREATE PROCEDURE sp_reject_dispute(IN p_dispute_id INT, IN p_admin_id INT)
BEGIN
    DECLARE v_buyer_id INT;
    SELECT buyer_id INTO v_buyer_id FROM DISPUTES WHERE dispute_id = p_dispute_id;

    UPDATE DISPUTES SET status = 'Rejected', assigned_admin_id = p_admin_id, resolved_at = NOW() WHERE dispute_id = p_dispute_id;

    INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type)
    VALUES (v_buyer_id, 'Dispute Rejected', CONCAT('Your dispute #', p_dispute_id, ' was reviewed and rejected - no policy violation was found.'), 'ORDER');

    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, 'Rejected dispute', 'DISPUTES', p_dispute_id, 'Open', 'Rejected');
END$$

-- 5. Uphold a listing fraud report — take the listing down and
--    penalize the seller.
DROP PROCEDURE IF EXISTS sp_uphold_fraud_report$$
CREATE PROCEDURE sp_uphold_fraud_report(IN p_fraud_flag_id INT, IN p_admin_id INT)
BEGIN
    DECLARE v_listing_id INT; DECLARE v_seller_id INT; DECLARE v_signals VARCHAR(255);
    SELECT listing_id, seller_id, signals_detected INTO v_listing_id, v_seller_id, v_signals FROM FRAUD_FLAGS WHERE fraud_flag_id = p_fraud_flag_id;

    IF v_listing_id IS NOT NULL THEN
        UPDATE LISTINGS SET is_active = 0 WHERE listing_id = v_listing_id;
    END IF;
    IF v_seller_id IS NOT NULL THEN
        INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (v_seller_id, CONCAT('Reported listing upheld: ', v_signals), 'Selling Suspension');
    END IF;

    UPDATE FRAUD_FLAGS SET status = 'Resolved', reviewed_by_admin_id = p_admin_id WHERE fraud_flag_id = p_fraud_flag_id;
    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, 'Upheld listing report - listing taken down, seller penalized', 'FRAUD_FLAGS', p_fraud_flag_id, 'Pending', 'Resolved');
END$$

-- 6. Dismiss a listing fraud report — no action taken.
DROP PROCEDURE IF EXISTS sp_dismiss_fraud_report$$
CREATE PROCEDURE sp_dismiss_fraud_report(IN p_fraud_flag_id INT, IN p_admin_id INT)
BEGIN
    UPDATE FRAUD_FLAGS SET status = 'Reviewed', reviewed_by_admin_id = p_admin_id WHERE fraud_flag_id = p_fraud_flag_id;
    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, 'Dismissed listing report - no violation found', 'FRAUD_FLAGS', p_fraud_flag_id, 'Pending', 'Reviewed');
END$$

-- 7. Approve (Verify) or reject a luxury authenticity request.
--    before_authentication_require_admin / after_authentication_status_change
--    (triggers 10 & 11) still do the actual is_active flip + seller
--    notification - this just performs the UPDATE + audit log.
DROP PROCEDURE IF EXISTS sp_review_authentication$$
CREATE PROCEDURE sp_review_authentication(IN p_listing_id INT, IN p_admin_id INT, IN p_status VARCHAR(20), IN p_remarks VARCHAR(255))
BEGIN
    UPDATE AUTHENTICATION SET authentication_status = p_status, verified_by_admin_id = p_admin_id, remarks = p_remarks
    WHERE listing_id = p_listing_id;

    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, CONCAT('Set authenticity status to ', p_status), 'AUTHENTICATION', p_listing_id, 'Pending', p_status);
END$$

-- 8. Issue a penalty. after_penalty_insert_escalate handles the
--    offense-count/suspension/ban escalation and seller notification.
DROP PROCEDURE IF EXISTS sp_issue_penalty$$
CREATE PROCEDURE sp_issue_penalty(IN p_seller_id INT, IN p_admin_id INT, IN p_reason VARCHAR(255), IN p_penalty_type VARCHAR(30))
BEGIN
    INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (p_seller_id, p_reason, p_penalty_type);
    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, CONCAT('Issued penalty: ', p_reason), 'PENALTIES', p_seller_id, NULL, p_penalty_type);
END$$

-- 9. Issue a seller award. after_seller_award_notify handles the
--    congratulatory notification.
DROP PROCEDURE IF EXISTS sp_issue_award$$
CREATE PROCEDURE sp_issue_award(IN p_seller_id INT, IN p_admin_id INT, IN p_reason VARCHAR(255), IN p_award_type VARCHAR(30))
BEGIN
    INSERT INTO SELLER_AWARDS (seller_id, reason, award_type, status) VALUES (p_seller_id, p_reason, p_award_type, 'Active');
    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, CONCAT('Issued award: ', p_reason), 'SELLER_AWARDS', p_seller_id, NULL, p_award_type);
END$$

-- 10. Batch-expire penalties/awards whose period_end (or a year from
--     issued_at for awards, which have no period_end column) has
--     passed. Meant to be run on a schedule (or manually by an admin).
DROP PROCEDURE IF EXISTS sp_expire_stale_penalties_and_awards$$
CREATE PROCEDURE sp_expire_stale_penalties_and_awards()
BEGIN
    UPDATE PENALTIES SET status = 'Expired' WHERE status = 'Active' AND period_end IS NOT NULL AND period_end < NOW();
    UPDATE SELLER_AWARDS SET status = 'Expired' WHERE status = 'Active' AND issued_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
END$$

-- 11. Suspend / ban / reactivate a seller or buyer account, with an
--     audit log entry - used by admin/users.php instead of writing
--     the same UPDATE + AUDIT_LOGS insert pattern four different ways.
DROP PROCEDURE IF EXISTS sp_set_account_status$$
CREATE PROCEDURE sp_set_account_status(IN p_table_name VARCHAR(10), IN p_account_id INT, IN p_new_status VARCHAR(20), IN p_admin_id INT)
BEGIN
    IF p_table_name = 'SELLER' THEN
        UPDATE SELLER SET seller_status = p_new_status WHERE seller_id = p_account_id;
    ELSE
        UPDATE BUYER SET buyer_status = p_new_status WHERE buyer_id = p_account_id;
    END IF;
    INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value)
    VALUES (p_admin_id, CONCAT('Set account status to ', p_new_status), p_table_name, p_account_id, NULL, p_new_status);
END$$

-- 12. Soft-delete a listing (archiving rule: never hard-delete
--     something ORDERS might reference).
DROP PROCEDURE IF EXISTS sp_soft_delete_listing$$
CREATE PROCEDURE sp_soft_delete_listing(IN p_listing_id INT, IN p_seller_id INT)
BEGIN
    UPDATE LISTINGS SET deleted_at = NOW(), is_active = 0 WHERE listing_id = p_listing_id AND seller_id = p_seller_id;
END$$

-- 13. Seller dashboard summary — one call instead of five separate
--     COUNT/SUM queries scattered across seller/dashboard.php.
DROP PROCEDURE IF EXISTS sp_seller_dashboard_stats$$
CREATE PROCEDURE sp_seller_dashboard_stats(IN p_seller_id INT)
BEGIN
    SELECT
        (SELECT COALESCE(SUM(p.amount_paid),0) FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.seller_id=p_seller_id AND p.payment_status='Completed') AS total_revenue,
        (SELECT COUNT(*) FROM LISTINGS WHERE seller_id=p_seller_id AND is_active=1 AND deleted_at IS NULL) AS active_listings,
        (SELECT COUNT(*) FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id WHERE l.seller_id=p_seller_id AND a.status='Active') AS active_auctions,
        (SELECT COUNT(*) FROM ORDERS o LEFT JOIN SHIPMENTS s ON o.order_id=s.order_id WHERE o.seller_id=p_seller_id AND o.status='Preparing' AND s.shipment_id IS NULL) AS pending_shipments,
        (SELECT COALESCE(AVG(rating),0) FROM REVIEWS WHERE seller_id=p_seller_id AND deleted_at IS NULL) AS avg_rating,
        (SELECT COUNT(*) FROM AUTHENTICATION au JOIN LISTINGS l ON au.listing_id=l.listing_id WHERE l.seller_id=p_seller_id AND au.authentication_status='Pending') AS pending_authenticity;
END$$

-- 14. Admin platform-wide KPI summary — one call instead of the ten
--     separate COUNT queries in admin/dashboard.php.
DROP PROCEDURE IF EXISTS sp_admin_platform_stats$$
CREATE PROCEDURE sp_admin_platform_stats()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM SELLER) AS total_sellers,
        (SELECT COUNT(*) FROM BUYER) AS total_buyers,
        (SELECT COUNT(*) FROM SELLER WHERE seller_status='Suspended') AS suspended_sellers,
        (SELECT COUNT(*) FROM AUCTIONS WHERE status='Active') AS active_auctions,
        (SELECT COUNT(*) FROM DISPUTES WHERE status='Open') AS open_disputes,
        (SELECT COUNT(*) FROM FRAUD_FLAGS WHERE status='Pending') AS pending_reports,
        (SELECT COUNT(*) FROM AUTHENTICATION WHERE authentication_status='Pending') AS pending_authenticity,
        (SELECT COALESCE(SUM(amount_paid),0) FROM PAYMENTS WHERE payment_status='Completed') AS total_revenue;
END$$

-- 15. Top customers by spending, for one seller (Sales Drivers report).
DROP PROCEDURE IF EXISTS sp_top_customers_for_seller$$
CREATE PROCEDURE sp_top_customers_for_seller(IN p_seller_id INT, IN p_limit INT)
BEGIN
    SELECT bu.username, COALESCE(SUM(p.amount_paid),0) AS total
    FROM BUYER bu
    JOIN ORDERS o ON o.buyer_id = bu.buyer_id AND o.seller_id = p_seller_id
    JOIN PAYMENTS p ON p.order_id = o.order_id AND p.payment_status = 'Completed'
    GROUP BY bu.buyer_id, bu.username
    ORDER BY total DESC
    LIMIT p_limit;
END$$

-- 16. Revenue by PARENT category, for one seller (Overview donut chart
--     groups into ~7 broad slices — Tops/Bottoms/Footwear/etc — not
--     23 individual subcategories, which would be unreadable in a donut).
DROP PROCEDURE IF EXISTS sp_revenue_by_category$$
CREATE PROCEDURE sp_revenue_by_category(IN p_seller_id INT)
BEGIN
    SELECT pc.parent_category AS name, COALESCE(SUM(p.amount_paid),0) AS total
    FROM LISTINGS l
    JOIN CATEGORIES c ON l.category_id = c.category_id
    JOIN PARENT_CATEGORIES pc ON c.parent_category_id = pc.parent_category_id
    JOIN ORDERS o ON o.listing_id = l.listing_id
    JOIN PAYMENTS p ON p.order_id = o.order_id AND p.payment_status = 'Completed'
    WHERE l.seller_id = p_seller_id
    GROUP BY pc.parent_category
    ORDER BY total DESC
    LIMIT 8;
END$$

-- 17. Monthly revenue trend, for one seller (Overview line chart /
--     Forecast baseline). p_months controls the lookback window.
DROP PROCEDURE IF EXISTS sp_monthly_revenue_trend$$
CREATE PROCEDURE sp_monthly_revenue_trend(IN p_seller_id INT, IN p_months INT)
BEGIN
    SELECT DATE_FORMAT(p.payment_date, '%b %Y') AS mo, YEAR(p.payment_date) AS yr, MONTH(p.payment_date) AS mn,
           SUM(p.amount_paid) AS total
    FROM PAYMENTS p
    JOIN ORDERS o ON p.order_id = o.order_id
    WHERE o.seller_id = p_seller_id AND p.payment_status = 'Completed'
      AND p.payment_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH)
    GROUP BY yr, mn, mo
    ORDER BY yr, mn;
END$$

-- 18. Checkout one listing: creates the ORDER, then the matching
--     Completed PAYMENT for it. after_order_insert_deactivate_listing
--     still handles deactivating the listing + notifying the seller;
--     after_payment_insert_create_transaction still handles writing
--     the TRANSACTIONS ledger row + notifying the buyer. This
--     procedure does not duplicate either — it's the single place
--     that pairs "create the order" with "pay for it" atomically, so
--     a multi-item cart checkout can call it once per selected item
--     (each item always gets its own order + its own payment — there
--     is no "combined payment across items" at the schema level,
--     same-shop or not, since PAYMENTS.order_id is one-to-one).
DROP PROCEDURE IF EXISTS sp_checkout_listing$$
CREATE PROCEDURE sp_checkout_listing(
    IN p_listing_id INT, IN p_buyer_id INT, IN p_seller_id INT,
    IN p_amount DECIMAL(10,2), IN p_payment_method VARCHAR(10), IN p_gateway_ref VARCHAR(255)
)
BEGIN
    DECLARE v_order_id INT;

    INSERT INTO ORDERS (listing_id, buyer_id, seller_id) VALUES (p_listing_id, p_buyer_id, p_seller_id);
    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO PAYMENTS (payment_method, amount_paid, payment_status, gateway_reference_token, order_id)
    VALUES (p_payment_method, p_amount, 'Completed', p_gateway_ref, v_order_id);

    DELETE FROM CART_ITEMS WHERE buyer_id = p_buyer_id AND listing_id = p_listing_id;

    -- Caller reads the new order_id via LAST_INSERT_ID() on the
    -- connection right after this CALL returns (same session, same
    -- value) instead of an OUT parameter - PDO with native prepared
    -- statements (ATTR_EMULATE_PREPARES=false) is unreliable with
    -- CALL(...,@sessionvar) OUT-parameter patterns in some driver
    -- versions, so this avoids that entirely for the common case of
    -- "I just need the ID that got created."
END$$

-- 19. Pay for an ORDER that already exists (the "Buy Now" flow creates
--     the order immediately, then the buyer pays for it separately at
--     checkout) — the counterpart to sp_checkout_listing above for
--     when there's no order left to create, just a payment to record.
DROP PROCEDURE IF EXISTS sp_pay_for_order$$
CREATE PROCEDURE sp_pay_for_order(
    IN p_order_id INT, IN p_listing_id INT, IN p_buyer_id INT,
    IN p_amount DECIMAL(10,2), IN p_payment_method VARCHAR(10), IN p_gateway_ref VARCHAR(255)
)
BEGIN
    INSERT INTO PAYMENTS (payment_method, amount_paid, payment_status, gateway_reference_token, order_id)
    VALUES (p_payment_method, p_amount, 'Completed', p_gateway_ref, p_order_id);

    DELETE FROM CART_ITEMS WHERE buyer_id = p_buyer_id AND listing_id = p_listing_id;
END$$

DELIMITER ;