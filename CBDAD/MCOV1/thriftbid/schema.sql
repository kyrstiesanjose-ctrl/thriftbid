
CREATE DATABASE IF NOT EXISTS thriftbid_db2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE thriftbid_db2;

SET FOREIGN_KEY_CHECKS = 0;


-- 1. USERS
CREATE TABLE IF NOT EXISTS USERS (
    user_id       INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(40)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone_number  VARCHAR(15)  DEFAULT NULL,
    address       VARCHAR(255) DEFAULT NULL,
    is_verified   BOOLEAN      DEFAULT FALSE,
    role          ENUM('admin','seller','buyer') DEFAULT 'buyer',
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

-- 2. SELLER (extends USERS for seller-specific data)
CREATE TABLE IF NOT EXISTS SELLER (
    seller_id           INT         NOT NULL AUTO_INCREMENT,
    user_id             INT         NOT NULL UNIQUE,
    store_loc           VARCHAR(100) DEFAULT NULL,
    offense_count       INT          DEFAULT 0,
    wallet_frozen_until DATETIME     DEFAULT NULL,
    PRIMARY KEY (seller_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);

-- 3. BUYER (extends USERS for buyer-specific data)
CREATE TABLE IF NOT EXISTS BUYER (
    buyer_id         INT          NOT NULL AUTO_INCREMENT,
    user_id          INT          NOT NULL UNIQUE,
    shipping_address VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (buyer_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);

-- 4. CATEGORIES
CREATE TABLE IF NOT EXISTS CATEGORIES (
    category_id INT         NOT NULL AUTO_INCREMENT,
    name        ENUM(
        'Tops', 
        'Bottoms', 
        'Dresses & Co-ords', 
        'Outerwear', 
        'Footwear', 
        'Bags & Purses', 
        'Accessories', 
        'Headwear', 
        'Luxury Designer Items', 
        'Vintage Collectibles', 
        'Home & Lifestyle Items', 
        'Aesthetic Bundles'
    ) NOT NULL, -- Updated to your exact ENUM categories
    PRIMARY KEY (category_id)
);


-- 5. LISTINGS (3 types: fixed price, non-live auction, live auction — distinguished by AUCTIONS row)
CREATE TABLE IF NOT EXISTS LISTINGS (
    listing_id     INT            NOT NULL AUTO_INCREMENT,
    title          VARCHAR(200)   NOT NULL,
    description    TEXT,
    price          DECIMAL(10,2)  DEFAULT 0.00,
    item_condition ENUM('Brand New', 'Like New', 'Lightly Used', 'Well Used', 'Heavily Used') NOT NULL,
    size           VARCHAR(20)    DEFAULT NULL, -- Removed default 'Free Size' (defaults to NULL now)
    image_url      VARCHAR(500)   DEFAULT NULL,
    is_active      BOOLEAN        DEFAULT TRUE,
    category_id    INT            NOT NULL,
    seller_id      INT            NOT NULL,
    created_at     DATETIME       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (listing_id),
    FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id),
    FOREIGN KEY (seller_id)   REFERENCES SELLER(seller_id)
);

-- 6. AUCTIONS (present = auction/live, absent = fixed-price buy now)
CREATE TABLE IF NOT EXISTS AUCTIONS (
    auction_id          INT            NOT NULL AUTO_INCREMENT,
    start_bid           DECIMAL(10,2)  NOT NULL,
    min_increment       DECIMAL(10,2)  DEFAULT 10.00,
    current_highest_bid DECIMAL(10,2)  DEFAULT 0.00,
    start_time          DATETIME       NOT NULL,
    end_time            DATETIME       NOT NULL,
    status              ENUM('Active','Closed') DEFAULT 'Active',
    listing_type        ENUM('auction','live')  DEFAULT 'auction',
    extension_count     INT            DEFAULT 0,
    listing_id          INT            NOT NULL UNIQUE,
    PRIMARY KEY (auction_id),
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id)
);

-- 7. BIDDINGS
CREATE TABLE IF NOT EXISTS BIDDINGS (
    bidding_id  INT            NOT NULL AUTO_INCREMENT,
    bid_amount  DECIMAL(10,2)  NOT NULL,
    bid_time    DATETIME       DEFAULT CURRENT_TIMESTAMP,
    auction_id  INT            NOT NULL,
    buyer_id    INT            NOT NULL,
    PRIMARY KEY (bidding_id),
    FOREIGN KEY (auction_id) REFERENCES AUCTIONS(auction_id),
    FOREIGN KEY (buyer_id)   REFERENCES BUYER(buyer_id)
);

-- 8. BUNDLES
CREATE TABLE IF NOT EXISTS BUNDLES (
    bundle_id    INT            NOT NULL AUTO_INCREMENT,
    seller_id    INT            NOT NULL,
    bundle_name  VARCHAR(100)   NOT NULL,
    bundle_price DECIMAL(10,2)  DEFAULT 0.00,
    created_at   DATETIME       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bundle_id),
    FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- 9. ORDERS
CREATE TABLE IF NOT EXISTS ORDERS (
    order_id   INT      NOT NULL AUTO_INCREMENT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status     ENUM('Preparing','Shipped','Out for Delivery','Delivered') DEFAULT 'Preparing',
    listing_id INT      NOT NULL,
    buyer_id   INT      NOT NULL,
    seller_id  INT      NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id),
    FOREIGN KEY (buyer_id)   REFERENCES BUYER(buyer_id),
    FOREIGN KEY (seller_id)  REFERENCES SELLER(seller_id)
);

-- 10. PAYMENTS
CREATE TABLE IF NOT EXISTS PAYMENTS (
    payment_id     INT            NOT NULL AUTO_INCREMENT,
    payment_method ENUM('GCash','Bank') NOT NULL,
    amount_paid    DECIMAL(10,2)  NOT NULL,
    payment_status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    payment_date   DATETIME       DEFAULT CURRENT_TIMESTAMP,
    order_id       INT            NOT NULL,
    PRIMARY KEY (payment_id),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
);

-- 11. TRANSACTIONS
CREATE TABLE IF NOT EXISTS TRANSACTIONS (
    transaction_id   INT            NOT NULL AUTO_INCREMENT,
    amount           DECIMAL(10,2)  NOT NULL,
    transaction_date DATETIME       DEFAULT CURRENT_TIMESTAMP,
    order_id         INT            NOT NULL,
    payment_id       INT            NOT NULL,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (order_id)   REFERENCES ORDERS(order_id),
    FOREIGN KEY (payment_id) REFERENCES PAYMENTS(payment_id)
);

-- 12. WALLET TRANSACTIONS
CREATE TABLE IF NOT EXISTS WALLET_TRANSACTIONS (
    wallet_transaction_id INT            NOT NULL AUTO_INCREMENT,
    user_id                INT            NOT NULL,
    amount                 DECIMAL(10,2)  NOT NULL DEFAULT 0,
    transaction_type      ENUM('Hold','Refund','Release') NOT NULL,
    transaction_date      DATETIME DEFAULT CURRENT_TIMESTAMP,
    status                ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    PRIMARY KEY (wallet_transaction_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 13. REVIEWS
CREATE TABLE IF NOT EXISTS REVIEWS (
    review_id   INT NOT NULL AUTO_INCREMENT,
    buyer_id    INT NOT NULL,
    seller_id   INT NOT NULL,
    order_id    INT NOT NULL,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    FOREIGN KEY (buyer_id)  REFERENCES BUYER(buyer_id),
    FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id),
    FOREIGN KEY (order_id)  REFERENCES ORDERS(order_id)
);

-- 14. DISPUTES
CREATE TABLE IF NOT EXISTS DISPUTES (
    dispute_id  INT          NOT NULL AUTO_INCREMENT,
    order_id    INT          NOT NULL,
    buyer_id    INT          NOT NULL,
    seller_id   INT          NOT NULL,
    reason      VARCHAR(255) NOT NULL,
    status      ENUM('Open','Resolved','Rejected') DEFAULT 'Open',
    opened_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME DEFAULT NULL,
    PRIMARY KEY (dispute_id),
    FOREIGN KEY (order_id)  REFERENCES ORDERS(order_id),
    FOREIGN KEY (buyer_id)  REFERENCES BUYER(buyer_id),
    FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- 15. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS NOTIFICATIONS (
    notification_id   INT          NOT NULL AUTO_INCREMENT,
    user_id           INT          NOT NULL,
    title             VARCHAR(100) NOT NULL,
    message           TEXT,
    notification_type VARCHAR(50)  DEFAULT 'SYSTEM',
    is_read           BOOLEAN      DEFAULT FALSE,
    created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);

-- 16. COURIERS
CREATE TABLE IF NOT EXISTS COURIERS (
    courier_id   INT         NOT NULL AUTO_INCREMENT,
    courier_name VARCHAR(50) NOT NULL,
    contact_no   VARCHAR(20),
    PRIMARY KEY (courier_id)
);

-- 17. SHIPMENTS
CREATE TABLE IF NOT EXISTS SHIPMENTS (
    shipment_id     INT         NOT NULL AUTO_INCREMENT,
    order_id        INT         NOT NULL UNIQUE,
    courier_id      INT         NOT NULL,
    tracking_number VARCHAR(50),
    status          ENUM('Preparing','Shipped','Delivered','Returned') DEFAULT 'Preparing',
    shipped_date    DATETIME    DEFAULT NULL,
    delivered_date  DATETIME    DEFAULT NULL,
    PRIMARY KEY (shipment_id),
    FOREIGN KEY (order_id)   REFERENCES ORDERS(order_id),
    FOREIGN KEY (courier_id) REFERENCES COURIERS(courier_id)
);

-- 18. TRACKING LOGS
CREATE TABLE IF NOT EXISTS TRACKING_LOGS (
    tracking_id INT          NOT NULL AUTO_INCREMENT,
    shipment_id INT          NOT NULL,
    location    VARCHAR(100),
    status      VARCHAR(50),
    updated_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tracking_id),
    FOREIGN KEY (shipment_id) REFERENCES SHIPMENTS(shipment_id)
);

-- 19. REPORTS
CREATE TABLE IF NOT EXISTS REPORTS (
    report_id    INT         NOT NULL AUTO_INCREMENT,
    report_type  VARCHAR(50) NOT NULL,
    period_start DATETIME,
    period_end   DATETIME,
    generated_at DATETIME    DEFAULT CURRENT_TIMESTAMP,
    listing_id   INT         DEFAULT NULL,
    order_id     INT         DEFAULT NULL,
    auction_id   INT         DEFAULT NULL,
    PRIMARY KEY (report_id),
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id),
    FOREIGN KEY (order_id)   REFERENCES ORDERS(order_id),
    FOREIGN KEY (auction_id) REFERENCES AUCTIONS(auction_id)
);

-- 20. PENALTIES (seller violations)
CREATE TABLE IF NOT EXISTS PENALTIES (
    penalty_id INT          NOT NULL AUTO_INCREMENT,
    seller_id  INT          NOT NULL,
    reason     VARCHAR(255) NOT NULL,
    status     ENUM('Active','Served','Expired') DEFAULT 'Active',
    issued_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    period_end DATETIME DEFAULT NULL,
    PRIMARY KEY (penalty_id),
    FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- 21. AWARDS (seller recognitions)
CREATE TABLE IF NOT EXISTS AWARDS (
    award_id   INT          NOT NULL AUTO_INCREMENT,
    seller_id  INT          NOT NULL,
    reason     VARCHAR(255) NOT NULL,
    status     ENUM('Active','Expired') DEFAULT 'Active',
    issued_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    period_end DATETIME DEFAULT NULL,
    PRIMARY KEY (award_id),
    FOREIGN KEY (seller_id) REFERENCES SELLER(seller_id)
);

-- 22. FRAUD FLAGS
CREATE TABLE IF NOT EXISTS FRAUD_FLAGS (
    fraud_flag_id INT          NOT NULL AUTO_INCREMENT,
    auction_id    INT          DEFAULT NULL,
    listing_id    INT          DEFAULT NULL,
    buyer_id      INT          DEFAULT NULL,
    seller_id     INT          DEFAULT NULL,
    reason        VARCHAR(255) NOT NULL,
    status        ENUM('Pending','Reviewed','Resolved') DEFAULT 'Pending',
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fraud_flag_id),
    FOREIGN KEY (auction_id) REFERENCES AUCTIONS(auction_id),
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id),
    FOREIGN KEY (buyer_id)   REFERENCES BUYER(buyer_id),
    FOREIGN KEY (seller_id)  REFERENCES SELLER(seller_id)
);

-- 23. WATCHLIST
CREATE TABLE IF NOT EXISTS WATCHLIST (
    watchlist_id INT      NOT NULL AUTO_INCREMENT,
    buyer_id     INT      NOT NULL,
    listing_id   INT      NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (watchlist_id),
    UNIQUE KEY uq_watchlist (buyer_id, listing_id),
    FOREIGN KEY (buyer_id)   REFERENCES BUYER(buyer_id),
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id)
);

-- 24. CART_ITEMS
CREATE TABLE IF NOT EXISTS CART_ITEMS (
    cart_item_id INT      NOT NULL AUTO_INCREMENT,
    user_id      INT      NOT NULL,
    listing_id   INT      NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cart_item_id),
    UNIQUE KEY uq_cart (user_id, listing_id),
    FOREIGN KEY (user_id)    REFERENCES USERS(user_id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES LISTINGS(listing_id) ON DELETE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- TRIGGERS
-- ============================================================


DELIMITER $$

-- Anti-snipe: if bid placed in last 2 min, extend by 2 min (max 10x = +20 min)
CREATE TRIGGER anti_snipe_extension
AFTER INSERT ON BIDDINGS
FOR EACH ROW
BEGIN
    DECLARE v_end   DATETIME;
    DECLARE v_exts  INT;
    SELECT end_time, extension_count INTO v_end, v_exts
    FROM AUCTIONS WHERE auction_id = NEW.auction_id;
    IF TIMESTAMPDIFF(SECOND, NOW(), v_end) <= 120 AND v_exts < 10 THEN
        UPDATE AUCTIONS
        SET end_time        = DATE_ADD(end_time, INTERVAL 2 MINUTE),
            extension_count = extension_count + 1
        WHERE auction_id = NEW.auction_id;
    END IF;
END$$

-- Update current highest bid automatically on every new bid
CREATE TRIGGER update_highest_bid
AFTER INSERT ON BIDDINGS
FOR EACH ROW
BEGIN
    UPDATE AUCTIONS
    SET current_highest_bid = NEW.bid_amount
    WHERE auction_id = NEW.auction_id
      AND NEW.bid_amount > current_highest_bid;
END$$

DELIMITER ;