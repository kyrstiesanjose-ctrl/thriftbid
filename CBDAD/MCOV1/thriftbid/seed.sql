-- ============================================================
-- ThriftBid - Expanded Seed Data (2025 - 2026)
-- ------------------------------------------------------------
-- Run AFTER schema.sql (tables + triggers must already exist).
-- All demo accounts use the password: Password123!
--
-- This is a much larger dataset than the earlier seed.sql:
--   - 5 admins, 6 sellers, 8 buyers
--   - 10-15+ listings in every one of the 23 categories
--   - Order/payment/shipment/review history spread across
--     Jan 2025 - Jul 2026 (with a Sep-Dec sales bump each year,
--     matching the "BER months" seasonality the Forecast report
--     talks about)
--   - Enough auctions/bids, disputes, penalties, awards, and
--     fraud flags to exercise every report and admin screen
--
-- IMAGES: listing photos are external placeholder URLs for this
-- seed data only (see the note in the previous seed.sql, a SQL
-- script has no device to upload a real local file from). Real
-- sellers still upload from their device via create-listing.php,
-- which saves to /uploads/listings/ locally.
-- ============================================================

USE thriftbid_db2;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- ADMIN (password: Password123!)
-- ------------------------------------------------------------
INSERT INTO ADMIN (username, first_name, last_name, email, password_hash) VALUES
('admin_root', 'Admin', 'Root', 'admin@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a'),
('admin_mod1', 'Jane', 'Ramos', 'mod1@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a'),
('admin_mod2', 'Carlo', 'Diaz', 'mod2@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a'),
('admin_mod3', 'Sophia', 'Lim', 'mod3@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a'),
('admin_mod4', 'Marco', 'Reyes', 'mod4@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a');

-- ------------------------------------------------------------
-- SELLER (password: Password123!)
-- ------------------------------------------------------------
INSERT INTO SELLER (username, shop_name, password_hash, email, cellphone_number, is_verified, ig_follower_count, seller_status, offense_count) VALUES
('seller_leila', 'Leila\'s Closet', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'seller_leila@thriftbid.com', '09171234561', 1, 6200, 'Active', 0),
('thrift_marco', 'Marco Thrift Finds', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'marco@thriftbid.com', '09171234562', 1, 3400, 'Active', 0),
('vintage_crys', 'Crys Vintage Rack', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'crys@thriftbid.com', '09171234563', 1, 1200, 'Active', 0),
('closet_jhen', NULL, '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'jhen@thriftbid.com', '09171234564', 0, 850, 'Active', 0),
('preloved_ken', 'Preloved by Ken', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'ken@thriftbid.com', '09171234565', 1, 2100, 'Active', 0),
('rack_aya', NULL, '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'aya@thriftbid.com', '09171234566', 1, 400, 'Active', 0);

-- ------------------------------------------------------------
-- BUYER (password: Password123!)
-- ------------------------------------------------------------
INSERT INTO BUYER (username, first_name, last_name, password_hash, email, cellphone_number, is_verified, buyer_status) VALUES
('ana_delacruz', 'Ana', 'De la Cruz', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'ana_delacruz@thriftbid.com', '09201234561', 1, 'Active'),
('kai_rowan', 'Kai', 'Rowan', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'kai_rowan@thriftbid.com', '09201234562', 1, 'Active'),
('james_parker', 'James', 'Parker', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'james_parker@thriftbid.com', '09201234563', 1, 'Active'),
('riley_avery', 'Riley', 'Avery', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'riley_avery@thriftbid.com', '09201234564', 0, 'Active'),
('liza_magsaysay', 'Liza', 'Magsaysay', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'liza_magsaysay@thriftbid.com', '09201234565', 1, 'Active'),
('saige_fuentes', 'Saige', 'Fuentes', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'saige_fuentes@thriftbid.com', '09201234566', 1, 'Active'),
('john_cruz', 'John', 'Cruz', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'john_cruz@thriftbid.com', '09201234567', 1, 'Active'),
('mira_santos', 'Mira', 'Santos', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'mira_santos@thriftbid.com', '09201234568', 1, 'Active');

-- ------------------------------------------------------------
-- ADDRESSES
-- ------------------------------------------------------------
INSERT INTO ADDRESSES (user_id, user_type, street_address, city, province, zip_code, is_default) VALUES
(1, 'Seller', '10 Session Rd', 'Baguio City', 'Benguet', '2600', 1),
(2, 'Seller', '11 Session Rd', 'Quezon City', 'Metro Manila', '1100', 1),
(3, 'Seller', '12 Session Rd', 'Cebu City', 'Cebu', '6000', 1),
(4, 'Seller', '13 Session Rd', 'Davao City', 'Davao del Sur', '8000', 1),
(5, 'Seller', '14 Session Rd', 'Iloilo City', 'Iloilo', '5000', 1),
(6, 'Seller', '15 Session Rd', 'Makati City', 'Metro Manila', '1200', 1),
(1, 'Buyer', '20 Katipunan Ave', 'Cebu City', 'Cebu', '6000', 1),
(2, 'Buyer', '21 Katipunan Ave', 'Davao City', 'Davao del Sur', '8000', 1),
(3, 'Buyer', '22 Katipunan Ave', 'Iloilo City', 'Iloilo', '5000', 1),
(4, 'Buyer', '23 Katipunan Ave', 'Makati City', 'Metro Manila', '1200', 1),
(5, 'Buyer', '24 Katipunan Ave', 'Baguio City', 'Benguet', '2600', 1),
(6, 'Buyer', '25 Katipunan Ave', 'Quezon City', 'Metro Manila', '1100', 1),
(7, 'Buyer', '26 Katipunan Ave', 'Cebu City', 'Cebu', '6000', 1),
(8, 'Buyer', '27 Katipunan Ave', 'Davao City', 'Davao del Sur', '8000', 1);

-- ------------------------------------------------------------
-- PARENT_CATEGORIES (7 rows, one per parent group)
-- ------------------------------------------------------------
INSERT INTO PARENT_CATEGORIES (parent_category) VALUES
('Tops'),
('Bottoms'),
('Dresses & Co_ords'),
('Footwear'),
('Bags & Purses'),
('Accessories'),
('Others');

-- ------------------------------------------------------------
-- CATEGORIES (each row's parent_category_id is a real FK)
-- ------------------------------------------------------------
INSERT INTO CATEGORIES (name, parent_category_id) VALUES
('Blouse', 1),
('Sleeveless', 1),
('Long sleeve', 1),
('Shirt', 1),
('Shorts', 2),
('Skirts', 2),
('Pants', 2),
('Dress', 3),
('Co-ords', 3),
('Athleisure', 3),
('Heels', 4),
('Sneakers', 4),
('Running shoes', 4),
('Boots', 4),
('Flats', 4),
('Sandals', 4),
('Bags & Purses', 5),
('Accessories', 6),
('Earrings', 6),
('Rings', 6),
('Necklace', 6),
('Bracelet', 6),
('Aesthetic Bundles', 7);

-- ------------------------------------------------------------
-- CATEGORY_SIZES
-- ------------------------------------------------------------
INSERT INTO CATEGORY_SIZES (category_id, size_value) VALUES
(1, 'XS'),
(1, 'S'),
(1, 'M'),
(1, 'L'),
(1, 'XL'),
(2, 'XS'),
(2, 'S'),
(2, 'M'),
(2, 'L'),
(3, 'S'),
(3, 'M'),
(3, 'L'),
(3, 'XL'),
(4, 'S'),
(4, 'M'),
(4, 'L'),
(4, 'XL'),
(4, 'XXL'),
(5, '26'),
(5, '27'),
(5, '28'),
(5, '29'),
(5, '30'),
(6, 'S'),
(6, 'M'),
(6, 'L'),
(7, '27'),
(7, '28'),
(7, '29'),
(7, '30'),
(7, '31'),
(7, '32'),
(7, '34'),
(8, 'XS'),
(8, 'S'),
(8, 'M'),
(8, 'L'),
(9, 'S'),
(9, 'M'),
(9, 'L'),
(10, 'XS'),
(10, 'S'),
(10, 'M'),
(10, 'L'),
(11, '35.5'),
(11, '36'),
(11, '37'),
(11, '38'),
(11, '39'),
(12, '36'),
(12, '37'),
(12, '38'),
(12, '39'),
(12, '40'),
(12, '41'),
(12, '42'),
(12, '43'),
(13, '37'),
(13, '38'),
(13, '39'),
(13, '40'),
(13, '41'),
(13, '42'),
(14, '36'),
(14, '37'),
(14, '38'),
(14, '39'),
(14, '40'),
(15, '35.5'),
(15, '36'),
(15, '37'),
(15, '38'),
(16, '36'),
(16, '37'),
(16, '38'),
(16, '39'),
(17, 'Mini'),
(17, 'Small'),
(17, 'Medium'),
(17, 'Large'),
(18, 'One Size'),
(19, 'One Size'),
(20, '5'),
(20, '6'),
(20, '7'),
(20, '8'),
(20, '9'),
(21, 'One Size'),
(22, 'One Size'),
(23, 'One Size');

-- ------------------------------------------------------------
-- BRANDS
-- ------------------------------------------------------------
INSERT INTO BRANDS (brand_name) VALUES
('Nike'),
('Adidas'),
('Gucci'),
('Converse'),
('ZARA'),
('Uniqlo'),
('Louis Vuitton'),
('H&M'),
('Levi\'s'),
('Dr. Martens'),
('Coach'),
('Bershka'),
('Shein'),
('Dior'),
('Unbranded');

-- ------------------------------------------------------------
-- PRODUCT_LINES
-- ------------------------------------------------------------
INSERT INTO PRODUCT_LINES (brand_id, line_name, tier, estimated_price_min, estimated_price_max) VALUES
(14, 'Lady Dior Bag', 'High', 120000, 350000),
(14, 'Saddle Bag', 'High', 95000, 260000),
(7, 'Neverfull Tote', 'High', 85000, 160000),
(7, 'Speedy Monogram', 'High', 70000, 140000),
(3, 'GG Marmont', 'High', 65000, 140000),
(3, 'Ophidia Series', 'High', 50000, 110000),
(7, 'LV Trainer Sneaker', 'High', 75000, 140000),
(7, 'LV Runner Sneaker', 'High', 60000, 110000),
(3, 'Gucci Ace Sneaker', 'High', 35000, 65000),
(3, 'Gucci Rhyton Sneaker', 'High', 40000, 75000),
(14, 'Dior B23 High-Top Sneaker', 'High', 65000, 130000),
(11, 'Tabby Collection', 'Mid', 18000, 38000),
(11, 'Signature Canvas Series', 'Mid', 10000, 25000),
(1, 'Air Jordan', 'Mid', 5500, 15000),
(1, 'Nike Dunk', 'Mid', 4000, 8500),
(1, 'Air Force 1', 'Mid', 3500, 6500),
(10, '1460 8-Eye Boot', 'Mid', 4500, 9500),
(2, 'Samba', 'Mid', 3200, 6000),
(9, '501 Original Denim', 'Mid', 2200, 5500),
(5, 'Studio Collection', 'Low', 2500, 7500),
(5, 'Zara Woman', 'Low', 800, 3500),
(4, 'Run Star Hike', 'Low', 3500, 6000),
(4, 'Chuck Taylor All Star', 'Low', 1800, 3500),
(8, 'Premium Selection', 'Low', 1800, 6500),
(6, 'HEATTECH Line', 'Low', 500, 1900),
(6, 'AIRism Apparel', 'Low', 400, 1500),
(12, 'Going Out Collection', 'Low', 600, 3000),
(13, 'Shein Basics', 'Low', 100, 900),
(1, 'Generic Vintage Nike', 'Mid', 800, 4000),
(5, 'Generic Zara', 'Low', 300, 2000),
(15, 'Generic / No Brand', 'Unbranded', 50, 1500),
(1, 'Unknown', 'Unbranded', 0, 0),
(2, 'Unknown', 'Unbranded', 0, 0),
(3, 'Unknown', 'Unbranded', 0, 0),
(4, 'Unknown', 'Unbranded', 0, 0),
(6, 'Unknown', 'Unbranded', 0, 0),
(7, 'Unknown', 'Unbranded', 0, 0),
(8, 'Unknown', 'Unbranded', 0, 0),
(9, 'Unknown', 'Unbranded', 0, 0),
(10, 'Unknown', 'Unbranded', 0, 0),
(11, 'Unknown', 'Unbranded', 0, 0),
(12, 'Unknown', 'Unbranded', 0, 0),
(14, 'Unknown', 'Unbranded', 0, 0);

-- ------------------------------------------------------------
-- COURIERS
-- ------------------------------------------------------------
INSERT INTO COURIERS (courier_name) VALUES ('J&T Express'),('LBC'),('Ninja Van'),('Grab Express');

-- ------------------------------------------------------------
-- LISTINGS (10-15+ per category = 299 total) + LISTING_IMAGES
-- ------------------------------------------------------------
INSERT INTO LISTINGS (title, description, price, original_price, condition_grade, color, material, target_gender, made_in, is_active, created_at, category_id, seller_id, product_line_id, size_id) VALUES
('Classic Blouse', 'A lightly used blouse from Unbranded. Well-maintained and true to size, see photos for details.', 517.33, 1031.21, 'Lightly Used', 'White', 'Rayon', 'Women', 'Philippines', 1, '2025-08-12 07:32:00', 1, 1, 31, 1),
('Minimalist Shein Blouse', 'A well used blouse from Shein. Well-maintained and true to size, see photos for details.', 79.43, 224.38, 'Well Used', 'Red', 'Cotton', 'Women', 'China', 1, '2025-12-19 19:16:00', 1, 3, 28, 1),
('Y2K ZARA Blouse', 'A well used blouse from ZARA. Well-maintained and true to size, see photos for details.', 408.34, 1281.5, 'Well Used', 'Black', 'Polyester', 'Unisex', 'China', 1, '2025-04-14 12:17:00', 1, 5, 30, 3),
('Timeless H&M Blouse', 'A lightly used blouse from H&M. Well-maintained and true to size, see photos for details.', 1688.05, 4310.46, 'Lightly Used', 'Green', 'Silk', 'Women', 'Indonesia', 1, '2025-08-13 21:20:00', 1, 6, 24, 3),
('Limited Edition Bershka Blouse', NULL, 759.26, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-05-27 12:56:00', 1, 3, 42, 1),
('Vintage H&M Blouse', 'A like new blouse from H&M. Well-maintained and true to size, see photos for details.', 3442.66, 6019.77, 'Like New', 'Brown', 'Polyester', 'Women', 'China', 1, '2025-04-23 04:40:00', 1, 3, 24, 2),
('Timeless Bershka Blouse', NULL, 474.03, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-04-28 21:56:00', 1, 5, 42, 4),
('Limited Edition Blouse', 'A like new blouse from Unbranded. Well-maintained and true to size, see photos for details.', 929.76, 1459.24, 'Like New', 'Yellow', 'Cotton', 'Unisex', 'France', 1, '2026-06-04 19:12:00', 1, 3, 31, 1),
('Retro Shein Blouse', NULL, 655.5, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-09-03 01:15:00', 1, 3, 28, 4),
('Limited Edition ZARA Blouse', NULL, 286.46, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-05-02 17:10:00', 1, 6, 30, 4),
('Timeless Shein Blouse', NULL, 142.8, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-11-16 12:42:00', 1, 5, 28, 4),
('Timeless Bershka Blouse', 'A like new blouse from Bershka. Well-maintained and true to size, see photos for details.', 467.68, 771.89, 'Like New', 'Brown', 'Rayon', 'Women', 'China', 1, '2025-03-02 07:04:00', 1, 5, 42, 4),
('Y2K Uniqlo Blouse', 'A like new blouse from Uniqlo. Well-maintained and true to size, see photos for details.', 861.43, 1429.07, 'Like New', 'Green', 'Polyester', 'Unisex', 'Japan', 1, '2025-04-07 03:42:00', 1, 6, 36, 4),
('Y2K Sleeveless', NULL, 813.52, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-07-14 17:28:00', 2, 1, 31, 6),
('Everyday Bershka Sleeveless', NULL, 198.13, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-04-11 01:41:00', 2, 2, 42, 8),
('Retro ZARA Sleeveless', 'A lightly used sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 693.29, 1834.15, 'Lightly Used', 'Black', 'Silk', 'Women', 'South Korea', 1, '2026-03-10 22:46:00', 2, 2, 30, 7),
('Y2K ZARA Sleeveless', 'A lightly used sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 416.07, 953.57, 'Lightly Used', 'Beige', 'Cotton', 'Men', 'Indonesia', 1, '2026-02-18 03:56:00', 2, 5, 21, 6),
('Signature Uniqlo Sleeveless', 'A like new sleeveless from Uniqlo. Well-maintained and true to size, see photos for details.', 320.22, 575.0, 'Like New', 'Cream', 'Cotton', 'Women', 'India', 1, '2025-04-13 02:34:00', 2, 2, 36, 8),
('Retro ZARA Sleeveless', 'A like new sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 908.02, 1339.85, 'Like New', 'Multicolor', 'Rayon', 'Women', 'Bangladesh', 1, '2025-04-17 04:16:00', 2, 2, 30, 8),
('Vintage Uniqlo Sleeveless', 'A lightly used sleeveless from Uniqlo. Well-maintained and true to size, see photos for details.', 375.39, 955.95, 'Lightly Used', 'Black', 'Cotton', 'Men', 'France', 1, '2025-01-04 10:49:00', 2, 5, 26, 7),
('Oversized Shein Sleeveless', 'A lightly used sleeveless from Shein. Well-maintained and true to size, see photos for details.', 245.03, 652.82, 'Lightly Used', 'Black', 'Linen', 'Men', 'Vietnam', 1, '2025-05-11 01:19:00', 2, 6, 28, 9),
('Preloved Sleeveless', NULL, 196.18, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-08-31 05:51:00', 2, 1, 31, 8),
('Classic Bershka Sleeveless', 'A lightly used sleeveless from Bershka. Well-maintained and true to size, see photos for details.', 509.78, 1048.11, 'Lightly Used', 'Navy', 'Polyester', 'Women', 'Thailand', 1, '2026-01-27 01:54:00', 2, 1, 42, 7),
('Minimalist Uniqlo Sleeveless', 'A brand new sleeveless from Uniqlo. Well-maintained and true to size, see photos for details.', 1033.03, 1463.58, 'Brand New', 'Multicolor', 'Rayon', 'Women', 'Bangladesh', 1, '2025-01-29 03:56:00', 2, 2, 26, 7),
('Everyday Shein Sleeveless', 'A lightly used sleeveless from Shein. Well-maintained and true to size, see photos for details.', 182.86, 408.16, 'Lightly Used', 'Blue', 'Cotton', 'Men', 'Philippines', 1, '2026-07-06 21:46:00', 2, 4, 28, 8),
('Oversized Shein Sleeveless', 'A lightly used sleeveless from Shein. Well-maintained and true to size, see photos for details.', 169.11, 360.95, 'Lightly Used', 'Yellow', 'Polyester', 'Women', 'Indonesia', 1, '2025-06-28 19:36:00', 2, 3, 28, 6),
('Everyday H&M Long sleeve', 'A lightly used long sleeve from H&M. Well-maintained and true to size, see photos for details.', 2838.13, 5530.56, 'Lightly Used', 'Navy', 'Polyester', 'Men', 'France', 1, '2025-12-10 02:52:00', 3, 4, 24, 12),
('Oversized H&M Long sleeve', 'A like new long sleeve from H&M. Well-maintained and true to size, see photos for details.', 310.88, 541.04, 'Like New', 'Multicolor', 'Rayon', 'Women', 'Thailand', 1, '2026-05-22 12:15:00', 3, 1, 38, 10),
('Minimalist H&M Long sleeve', 'A brand new long sleeve from H&M. Well-maintained and true to size, see photos for details.', 826.96, 1020.58, 'Brand New', 'Multicolor', 'Rayon', 'Kids', 'India', 1, '2026-03-30 19:52:00', 3, 2, 38, 13),
('Classic ZARA Long sleeve', 'A well used long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 335.18, 1047.78, 'Well Used', 'Brown', 'Linen', 'Women', 'Bangladesh', 1, '2025-05-22 04:14:00', 3, 2, 30, 12),
('Oversized Bershka Long sleeve', 'A lightly used long sleeve from Bershka. Well-maintained and true to size, see photos for details.', 491.32, 975.18, 'Lightly Used', 'Gray', 'Cotton', 'Unisex', 'India', 1, '2026-05-04 00:22:00', 3, 3, 42, 13),
('Vintage H&M Long sleeve', 'A lightly used long sleeve from H&M. Well-maintained and true to size, see photos for details.', 684.91, 1447.68, 'Lightly Used', 'Green', 'Polyester', 'Kids', 'Bangladesh', 1, '2026-02-08 18:36:00', 3, 3, 38, 13),
('Vintage H&M Long sleeve', 'A like new long sleeve from H&M. Well-maintained and true to size, see photos for details.', 2086.01, 3107.81, 'Like New', 'Pink', 'Linen', 'Unisex', 'South Korea', 1, '2026-07-07 01:22:00', 3, 1, 24, 12),
('Signature H&M Long sleeve', 'A lightly used long sleeve from H&M. Well-maintained and true to size, see photos for details.', 1722.65, 4450.66, 'Lightly Used', 'Navy', 'Linen', 'Unisex', 'Vietnam', 1, '2025-04-28 05:19:00', 3, 2, 24, 10),
('Classic Bershka Long sleeve', 'A brand new long sleeve from Bershka. Well-maintained and true to size, see photos for details.', 827.28, 1234.05, 'Brand New', 'Cream', 'Linen', 'Unisex', 'India', 1, '2025-02-12 11:34:00', 3, 6, 42, 11),
('Limited Edition Bershka Long sleeve', 'A lightly used long sleeve from Bershka. Well-maintained and true to size, see photos for details.', 669.84, 1564.47, 'Lightly Used', 'Beige', 'Silk', 'Women', 'Bangladesh', 1, '2025-10-04 19:51:00', 3, 4, 42, 10),
('Retro H&M Long sleeve', 'A well used long sleeve from H&M. Well-maintained and true to size, see photos for details.', 977.81, 3381.06, 'Well Used', 'Red', 'Polyester', 'Women', 'USA', 1, '2025-12-15 08:56:00', 3, 1, 24, 12),
('Y2K Bershka Long sleeve', 'A lightly used long sleeve from Bershka. Well-maintained and true to size, see photos for details.', 515.6, 1063.53, 'Lightly Used', 'White', 'Linen', 'Women', 'Thailand', 1, '2025-11-10 21:37:00', 3, 4, 42, 11),
('Cropped ZARA Long sleeve', 'A like new long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 1046.89, 1651.98, 'Like New', 'Cream', 'Polyester', 'Women', 'Thailand', 1, '2025-10-11 23:37:00', 3, 6, 21, 13),
('Signature H&M Shirt', 'A brand new shirt from H&M. Well-maintained and true to size, see photos for details.', 3474.35, 4400.79, 'Brand New', 'Beige', 'Silk', 'Women', 'Philippines', 1, '2025-10-19 15:30:00', 4, 2, 24, 16),
('Y2K Bershka Shirt', 'A lightly used shirt from Bershka. Well-maintained and true to size, see photos for details.', 466.76, 1299.75, 'Lightly Used', 'Beige', 'Rayon', 'Unisex', 'China', 1, '2025-05-02 17:48:00', 4, 1, 42, 14),
('Y2K H&M Shirt', 'A like new shirt from H&M. Well-maintained and true to size, see photos for details.', 3360.73, 6253.67, 'Like New', 'Brown', 'Linen', 'Men', 'Vietnam', 1, '2025-06-27 17:04:00', 4, 5, 24, 17),
('Oversized Shirt', 'A brand new shirt from Unbranded. Well-maintained and true to size, see photos for details.', 106.74, 153.21, 'Brand New', 'Blue', 'Rayon', 'Men', 'Italy', 1, '2025-04-28 17:14:00', 4, 4, 31, 16),
('Cropped ZARA Shirt', 'A lightly used shirt from ZARA. Well-maintained and true to size, see photos for details.', 829.69, 2065.48, 'Lightly Used', 'Pink', 'Linen', 'Women', 'South Korea', 1, '2025-03-24 19:02:00', 4, 3, 21, 18),
('Cropped ZARA Shirt', 'A lightly used shirt from ZARA. Well-maintained and true to size, see photos for details.', 759.93, 1696.42, 'Lightly Used', 'Cream', 'Polyester', 'Women', 'Indonesia', 1, '2025-10-12 05:37:00', 4, 6, 30, 18),
('Retro Bershka Shirt', NULL, 418.9, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-02-15 17:02:00', 4, 3, 42, 16),
('Vintage Uniqlo Shirt', NULL, 590.04, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-07-10 14:26:00', 4, 3, 36, 16),
('Classic ZARA Shirt', 'A lightly used shirt from ZARA. Well-maintained and true to size, see photos for details.', 598.37, 1349.61, 'Lightly Used', 'Blue', 'Silk', 'Unisex', 'South Korea', 1, '2025-01-30 20:38:00', 4, 5, 21, 16),
('Limited Edition Shirt', NULL, 143.83, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-06-07 15:59:00', 4, 4, 31, 14),
('Classic Shirt', 'A lightly used shirt from Unbranded. Well-maintained and true to size, see photos for details.', 352.65, 849.33, 'Lightly Used', 'Gray', 'Rayon', 'Men', 'Vietnam', 1, '2025-10-10 13:21:00', 4, 6, 31, 16),
('Oversized ZARA Shirt', 'A lightly used shirt from ZARA. Well-maintained and true to size, see photos for details.', 478.71, 941.26, 'Lightly Used', 'Brown', 'Polyester', 'Men', 'Italy', 1, '2025-02-14 10:47:00', 4, 4, 30, 18),
('Preloved Uniqlo Shirt', 'A heavily used shirt from Uniqlo. Well-maintained and true to size, see photos for details.', 116.85, 509.68, 'Heavily Used', 'Black', 'Polyester', 'Women', 'Indonesia', 1, '2025-03-18 15:50:00', 4, 2, 26, 18),
('Retro Shorts', 'A heavily used shorts from Unbranded. Well-maintained and true to size, see photos for details.', 140.08, 757.52, 'Heavily Used', 'Gray', 'Denim', 'Women', 'Indonesia', 1, '2025-08-21 23:05:00', 5, 5, 31, 22),
('Preloved Shorts', NULL, 344.64, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-09-08 16:26:00', 5, 3, 31, 19),
('Retro ZARA Shorts', 'A lightly used shorts from ZARA. Well-maintained and true to size, see photos for details.', 514.72, 1146.03, 'Lightly Used', 'Brown', 'Corduroy', 'Men', 'South Korea', 1, '2025-01-10 14:57:00', 5, 2, 30, 19),
('Retro Shein Shorts', 'A lightly used shorts from Shein. Well-maintained and true to size, see photos for details.', 288.13, 782.67, 'Lightly Used', 'Pink', 'Polyester', 'Men', 'Thailand', 1, '2025-01-23 21:25:00', 5, 3, 28, 22),
('Vintage ZARA Shorts', 'A like new shorts from ZARA. Well-maintained and true to size, see photos for details.', 906.47, 1368.02, 'Like New', 'Multicolor', 'Denim', 'Women', 'South Korea', 1, '2026-01-09 23:08:00', 5, 5, 30, 21),
('Retro ZARA Shorts', NULL, 267.6, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-06-18 08:58:00', 5, 2, 30, 20),
('Minimalist H&M Shorts', 'A well used shorts from H&M. Well-maintained and true to size, see photos for details.', 154.75, 475.3, 'Well Used', 'Brown', 'Corduroy', 'Kids', 'Bangladesh', 1, '2025-04-03 12:00:00', 5, 6, 38, 21),
('Limited Edition Shein Shorts', 'A like new shorts from Shein. Well-maintained and true to size, see photos for details.', 449.26, 832.2, 'Like New', 'White', 'Corduroy', 'Unisex', 'France', 1, '2026-02-23 03:08:00', 5, 4, 28, 21),
('Preloved Levi\'s Shorts', 'A well used shorts from Levi\'s. Well-maintained and true to size, see photos for details.', 267.93, 853.64, 'Well Used', 'Navy', 'Corduroy', 'Men', 'Thailand', 1, '2026-03-01 20:06:00', 5, 1, 39, 20),
('Everyday ZARA Shorts', NULL, 94.85, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2026-01-03 01:25:00', 5, 4, 30, 22),
('Y2K ZARA Shorts', 'A brand new shorts from ZARA. Well-maintained and true to size, see photos for details.', 276.63, 385.98, 'Brand New', 'Beige', 'Cotton', 'Women', 'Bangladesh', 1, '2025-08-10 07:21:00', 5, 1, 30, 22),
('Preloved ZARA Shorts', 'A well used shorts from ZARA. Well-maintained and true to size, see photos for details.', 141.58, 524.07, 'Well Used', 'Cream', 'Cotton', 'Men', 'Philippines', 1, '2025-09-29 01:08:00', 5, 5, 30, 21),
('Vintage H&M Shorts', 'A like new shorts from H&M. Well-maintained and true to size, see photos for details.', 683.21, 1345.42, 'Like New', 'Cream', 'Polyester', 'Women', 'Philippines', 1, '2026-05-06 12:27:00', 5, 5, 38, 23),
('Retro Bershka Skirts', 'A brand new skirts from Bershka. Well-maintained and true to size, see photos for details.', 736.71, 969.77, 'Brand New', 'Red', 'Corduroy', 'Kids', 'Bangladesh', 1, '2026-04-10 16:38:00', 6, 5, 42, 24),
('Cropped Shein Skirts', 'A like new skirts from Shein. Well-maintained and true to size, see photos for details.', 194.71, 350.04, 'Like New', 'Blue', 'Polyester', 'Kids', 'Indonesia', 1, '2025-03-10 02:53:00', 6, 2, 28, 25),
('Oversized Bershka Skirts', NULL, 709.93, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-12-29 21:48:00', 6, 2, 42, 26),
('Classic ZARA Skirts', 'A like new skirts from ZARA. Well-maintained and true to size, see photos for details.', 1390.46, 2573.19, 'Like New', 'White', 'Polyester', 'Unisex', 'USA', 1, '2025-10-13 18:14:00', 6, 3, 21, 26),
('Limited Edition Bershka Skirts', 'A well used skirts from Bershka. Well-maintained and true to size, see photos for details.', 135.22, 563.27, 'Well Used', 'Multicolor', 'Corduroy', 'Women', 'Thailand', 1, '2025-02-01 02:47:00', 6, 6, 42, 25),
('Vintage H&M Skirts', NULL, 331.95, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-06-09 05:48:00', 6, 3, 38, 25),
('Limited Edition ZARA Skirts', 'A lightly used skirts from ZARA. Well-maintained and true to size, see photos for details.', 291.31, 666.47, 'Lightly Used', 'Red', 'Corduroy', 'Women', 'Indonesia', 1, '2026-05-14 16:42:00', 6, 3, 30, 25),
('Classic ZARA Skirts', NULL, 247.43, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-01-08 15:47:00', 6, 2, 30, 25),
('Vintage H&M Skirts', 'A lightly used skirts from H&M. Well-maintained and true to size, see photos for details.', 418.53, 902.85, 'Lightly Used', 'Red', 'Denim', 'Women', 'Thailand', 1, '2026-03-23 00:29:00', 6, 2, 38, 25),
('Cropped Shein Skirts', NULL, 121.38, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-01-06 02:27:00', 6, 3, 28, 24),
('Everyday H&M Skirts', 'A lightly used skirts from H&M. Well-maintained and true to size, see photos for details.', 564.26, 1183.47, 'Lightly Used', 'Brown', 'Polyester', 'Unisex', 'China', 1, '2025-04-27 16:32:00', 6, 4, 38, 26),
('Cropped H&M Skirts', 'A like new skirts from H&M. Well-maintained and true to size, see photos for details.', 342.25, 537.58, 'Like New', 'White', 'Cotton', 'Kids', 'Indonesia', 1, '2026-04-21 18:48:00', 6, 1, 38, 24),
('Classic ZARA Skirts', NULL, 535.0, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-11-14 14:28:00', 6, 4, 30, 25),
('Vintage Levi\'s Pants', 'A like new pants from Levi\'s. Well-maintained and true to size, see photos for details.', 451.84, 744.47, 'Like New', 'Pink', 'Corduroy', 'Men', 'Thailand', 1, '2026-04-06 18:41:00', 7, 3, 39, 33),
('Limited Edition Levi\'s Pants', NULL, 503.44, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-06-26 01:15:00', 7, 4, 39, 27),
('Limited Edition Bershka Pants', 'A lightly used pants from Bershka. Well-maintained and true to size, see photos for details.', 860.29, 2068.7, 'Lightly Used', 'Cream', 'Polyester', 'Men', 'Philippines', 1, '2025-12-09 02:21:00', 7, 5, 42, 31),
('Classic Pants', 'A brand new pants from Unbranded. Well-maintained and true to size, see photos for details.', 390.48, 499.84, 'Brand New', 'Multicolor', 'Corduroy', 'Women', 'Thailand', 1, '2025-11-14 17:24:00', 7, 2, 31, 29),
('Everyday Levi\'s Pants', 'A like new pants from Levi\'s. Well-maintained and true to size, see photos for details.', 745.21, 1378.03, 'Like New', 'Beige', 'Cotton', 'Women', 'China', 1, '2026-07-07 23:56:00', 7, 3, 39, 29),
('Retro ZARA Pants', 'A lightly used pants from ZARA. Well-maintained and true to size, see photos for details.', 545.44, 1526.01, 'Lightly Used', 'Red', 'Cotton', 'Kids', 'India', 1, '2026-04-05 07:34:00', 7, 2, 30, 33),
('Signature Uniqlo Pants', 'A heavily used pants from Uniqlo. Well-maintained and true to size, see photos for details.', 174.25, 1050.83, 'Heavily Used', 'Yellow', 'Corduroy', 'Kids', 'Italy', 1, '2025-05-22 08:03:00', 7, 6, 36, 31),
('Vintage Levi\'s Pants', 'A lightly used pants from Levi\'s. Well-maintained and true to size, see photos for details.', 376.94, 746.74, 'Lightly Used', 'Green', 'Polyester', 'Unisex', 'Japan', 1, '2026-02-10 16:23:00', 7, 2, 39, 29),
('Preloved ZARA Pants', NULL, 302.01, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-02-09 09:58:00', 7, 1, 30, 29),
('Y2K ZARA Pants', 'A lightly used pants from ZARA. Well-maintained and true to size, see photos for details.', 250.26, 666.61, 'Lightly Used', 'Navy', 'Corduroy', 'Women', 'France', 1, '2025-11-05 03:03:00', 7, 6, 30, 30),
('Limited Edition Levi\'s Pants', 'A lightly used pants from Levi\'s. Well-maintained and true to size, see photos for details.', 1107.26, 3161.2, 'Lightly Used', 'Red', 'Cotton', 'Men', 'Vietnam', 1, '2025-03-29 16:23:00', 7, 4, 19, 31),
('Minimalist Levi\'s Pants', 'A heavily used pants from Levi\'s. Well-maintained and true to size, see photos for details.', 694.12, 3337.85, 'Heavily Used', 'Multicolor', 'Denim', 'Unisex', 'Thailand', 1, '2025-05-17 01:22:00', 7, 6, 19, 30),
('Cropped ZARA Pants', 'A well used pants from ZARA. Well-maintained and true to size, see photos for details.', 565.86, 1644.89, 'Well Used', 'Red', 'Polyester', 'Women', 'Bangladesh', 1, '2025-09-17 01:48:00', 7, 1, 30, 32),
('Retro Bershka Dress', 'A lightly used dress from Bershka. Well-maintained and true to size, see photos for details.', 539.69, 1413.69, 'Lightly Used', 'Navy', 'Chiffon', 'Women', 'Bangladesh', 1, '2025-03-26 23:27:00', 8, 1, 27, 36),
('Signature Bershka Dress', 'A like new dress from Bershka. Well-maintained and true to size, see photos for details.', 579.87, 999.95, 'Like New', 'Green', 'Cotton', 'Men', 'USA', 1, '2026-03-22 08:40:00', 8, 1, 27, 34),
('Vintage Dress', 'A heavily used dress from Unbranded. Well-maintained and true to size, see photos for details.', 12.87, 100.46, 'Heavily Used', 'Cream', 'Silk', 'Women', 'India', 1, '2025-06-07 21:28:00', 8, 6, 31, 35),
('Retro Dress', 'A like new dress from Unbranded. Well-maintained and true to size, see photos for details.', 46.72, 87.57, 'Like New', 'Yellow', 'Chiffon', 'Unisex', 'China', 1, '2025-09-24 22:28:00', 8, 3, 31, 37),
('Limited Edition ZARA Dress', NULL, 385.61, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-11-24 21:22:00', 8, 2, 30, 34),
('Limited Edition Dress', NULL, 378.55, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-06-28 11:32:00', 8, 5, 31, 36),
('Classic ZARA Dress', 'A like new dress from ZARA. Well-maintained and true to size, see photos for details.', 597.7, 927.15, 'Like New', 'Yellow', 'Polyester', 'Men', 'China', 1, '2025-11-13 12:45:00', 8, 2, 30, 35),
('Preloved Bershka Dress', 'A lightly used dress from Bershka. Well-maintained and true to size, see photos for details.', 908.52, 2442.68, 'Lightly Used', 'Yellow', 'Cotton', 'Unisex', 'Bangladesh', 1, '2025-11-08 05:10:00', 8, 6, 27, 34),
('Minimalist Bershka Dress', 'A like new dress from Bershka. Well-maintained and true to size, see photos for details.', 1221.33, 2020.34, 'Like New', 'Beige', 'Satin', 'Men', 'India', 1, '2025-02-12 00:05:00', 8, 2, 27, 36),
('Timeless Dress', 'A lightly used dress from Unbranded. Well-maintained and true to size, see photos for details.', 365.23, 750.27, 'Lightly Used', 'Multicolor', 'Chiffon', 'Women', 'China', 1, '2025-03-03 05:28:00', 8, 6, 31, 34),
('Minimalist Dress', 'A well used dress from Unbranded. Well-maintained and true to size, see photos for details.', 151.92, 550.79, 'Well Used', 'Cream', 'Silk', 'Women', 'China', 1, '2025-09-05 14:07:00', 8, 2, 31, 36),
('Cropped ZARA Dress', 'A well used dress from ZARA. Well-maintained and true to size, see photos for details.', 612.33, 1833.93, 'Well Used', 'Gray', 'Silk', 'Women', 'Vietnam', 1, '2026-06-12 14:31:00', 8, 3, 30, 37),
('Classic Dress', 'A like new dress from Unbranded. Well-maintained and true to size, see photos for details.', 597.23, 916.4, 'Like New', 'Multicolor', 'Chiffon', 'Women', 'Philippines', 1, '2026-03-18 04:56:00', 8, 4, 31, 35),
('Preloved Shein Co-ords', 'A lightly used co-ords from Shein. Well-maintained and true to size, see photos for details.', 241.61, 503.4, 'Lightly Used', 'Blue', 'Satin', 'Men', 'China', 1, '2025-04-10 12:23:00', 9, 1, 28, 40),
('Preloved Co-ords', NULL, 916.51, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2026-06-12 04:20:00', 9, 1, 31, 38),
('Oversized H&M Co-ords', 'A lightly used co-ords from H&M. Well-maintained and true to size, see photos for details.', 2057.38, 5131.08, 'Lightly Used', 'Black', 'Silk', 'Women', 'China', 1, '2025-11-12 23:55:00', 9, 4, 24, 40),
('Limited Edition Co-ords', NULL, 486.44, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-09-06 01:36:00', 9, 4, 31, 38),
('Y2K H&M Co-ords', 'A like new co-ords from H&M. Well-maintained and true to size, see photos for details.', 998.76, 1561.79, 'Like New', 'Green', 'Cotton', 'Men', 'Bangladesh', 1, '2025-11-29 21:30:00', 9, 1, 38, 39),
('Signature Co-ords', NULL, 311.61, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-05-11 06:15:00', 9, 3, 31, 40),
('Timeless Co-ords', NULL, 239.0, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2026-05-16 10:30:00', 9, 3, 31, 38),
('Timeless Co-ords', 'A like new co-ords from Unbranded. Well-maintained and true to size, see photos for details.', 830.82, 1236.65, 'Like New', 'Cream', 'Polyester', 'Women', 'France', 1, '2025-03-22 11:59:00', 9, 6, 31, 39),
('Classic Co-ords', 'A lightly used co-ords from Unbranded. Well-maintained and true to size, see photos for details.', 186.27, 401.56, 'Lightly Used', 'Yellow', 'Polyester', 'Men', 'Philippines', 1, '2026-02-28 10:45:00', 9, 3, 31, 40),
('Everyday Shein Co-ords', 'A lightly used co-ords from Shein. Well-maintained and true to size, see photos for details.', 164.12, 356.93, 'Lightly Used', 'Cream', 'Cotton', 'Men', 'Italy', 1, '2025-02-08 05:26:00', 9, 6, 28, 39),
('Everyday H&M Co-ords', 'A well used co-ords from H&M. Well-maintained and true to size, see photos for details.', 1645.14, 6163.74, 'Well Used', 'Green', 'Satin', 'Women', 'Vietnam', 1, '2026-04-25 08:12:00', 9, 6, 24, 39),
('Oversized Bershka Co-ords', 'A brand new co-ords from Bershka. Well-maintained and true to size, see photos for details.', 838.63, 1021.19, 'Brand New', 'Pink', 'Chiffon', 'Women', 'China', 1, '2025-04-08 05:08:00', 9, 6, 27, 38),
('Vintage Shein Co-ords', NULL, 109.71, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-09-25 20:23:00', 9, 2, 28, 39),
('Retro Nike Athleisure', 'A lightly used athleisure from Nike. Well-maintained and true to size, see photos for details.', 1229.22, 2453.9, 'Lightly Used', 'Cream', 'Silk', 'Men', 'Indonesia', 1, '2026-01-12 19:14:00', 10, 6, 32, 41),
('Timeless Athleisure', 'A lightly used athleisure from Unbranded. Well-maintained and true to size, see photos for details.', 537.7, 1154.7, 'Lightly Used', 'Gray', 'Cotton', 'Women', 'Bangladesh', 1, '2026-01-06 02:58:00', 10, 6, 31, 43),
('Preloved Uniqlo Athleisure', 'A like new athleisure from Uniqlo. Well-maintained and true to size, see photos for details.', 933.59, 1807.98, 'Like New', 'Yellow', 'Chiffon', 'Unisex', 'South Korea', 1, '2026-06-10 13:29:00', 10, 5, 36, 44),
('Vintage Uniqlo Athleisure', 'A lightly used athleisure from Uniqlo. Well-maintained and true to size, see photos for details.', 488.79, 1354.6, 'Lightly Used', 'Black', 'Cotton', 'Kids', 'South Korea', 1, '2025-10-21 13:11:00', 10, 1, 36, 42),
('Minimalist Athleisure', NULL, 891.82, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-05-02 05:34:00', 10, 4, 31, 44),
('Timeless Adidas Athleisure', NULL, 728.89, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-07-12 13:34:00', 10, 6, 33, 42),
('Signature Adidas Athleisure', 'A like new athleisure from Adidas. Well-maintained and true to size, see photos for details.', 1564.33, 2481.08, 'Like New', 'White', 'Cotton', 'Unisex', 'Japan', 1, '2025-01-17 07:13:00', 10, 2, 33, 44),
('Limited Edition Nike Athleisure', 'A lightly used athleisure from Nike. Well-maintained and true to size, see photos for details.', 647.8, 1248.43, 'Lightly Used', 'Brown', 'Satin', 'Women', 'India', 1, '2025-11-25 07:19:00', 10, 2, 29, 41),
('Timeless Uniqlo Athleisure', 'A lightly used athleisure from Uniqlo. Well-maintained and true to size, see photos for details.', 845.94, 1641.68, 'Lightly Used', 'Multicolor', 'Chiffon', 'Unisex', 'USA', 1, '2026-03-03 13:09:00', 10, 1, 36, 42),
('Everyday Adidas Athleisure', NULL, 628.69, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-06-27 04:24:00', 10, 3, 33, 42),
('Timeless Uniqlo Athleisure', NULL, 844.65, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-07-15 01:17:00', 10, 2, 36, 43),
('Y2K Nike Athleisure', 'A well used athleisure from Nike. Well-maintained and true to size, see photos for details.', 277.24, 1112.33, 'Well Used', 'Red', 'Silk', 'Kids', 'Philippines', 1, '2025-07-14 23:07:00', 10, 1, 32, 42),
('Cropped Uniqlo Athleisure', 'A lightly used athleisure from Uniqlo. Well-maintained and true to size, see photos for details.', 528.73, 1286.0, 'Lightly Used', 'Green', 'Chiffon', 'Women', 'Thailand', 1, '2025-11-24 06:23:00', 10, 3, 36, 44),
('Limited Edition ZARA Heels', 'A heavily used heels from ZARA. Well-maintained and true to size, see photos for details.', 93.51, 633.53, 'Heavily Used', 'Gray', 'Canvas', 'Women', 'Indonesia', 1, '2025-12-12 08:48:00', 11, 3, 30, 49),
('Vintage Coach Heels', NULL, 964.64, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-06-21 01:53:00', 11, 2, 41, 49),
('Signature ZARA Heels', 'A like new heels from ZARA. Well-maintained and true to size, see photos for details.', 186.49, 315.54, 'Like New', 'Red', 'Leather', 'Men', 'Indonesia', 1, '2026-05-10 21:31:00', 11, 1, 30, 48),
('Y2K ZARA Heels', 'A lightly used heels from ZARA. Well-maintained and true to size, see photos for details.', 843.03, 1670.49, 'Lightly Used', 'White', 'Leather', 'Women', 'Italy', 1, '2026-06-24 08:52:00', 11, 5, 30, 47),
('Oversized Heels', 'A like new heels from Unbranded. Well-maintained and true to size, see photos for details.', 653.12, 997.92, 'Like New', 'Cream', 'Leather', 'Women', 'Japan', 1, '2026-05-03 01:40:00', 11, 4, 31, 49),
('Vintage Heels', NULL, 82.8, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-08-24 06:57:00', 11, 6, 31, 47),
('Oversized Shein Heels', 'A lightly used heels from Shein. Well-maintained and true to size, see photos for details.', 120.42, 243.48, 'Lightly Used', 'Black', 'Canvas', 'Men', 'Thailand', 1, '2025-03-20 09:10:00', 11, 1, 28, 45),
('Vintage ZARA Heels', 'A brand new heels from ZARA. Well-maintained and true to size, see photos for details.', 706.55, 879.01, 'Brand New', 'Gray', 'Synthetic', 'Kids', 'USA', 1, '2025-10-07 14:31:00', 11, 5, 30, 47),
('Oversized Coach Heels', 'A lightly used heels from Coach. Well-maintained and true to size, see photos for details.', 1109.6, 2284.68, 'Lightly Used', 'Navy', 'Leather', 'Women', 'Vietnam', 1, '2025-06-07 23:24:00', 11, 6, 41, 49),
('Everyday Shein Heels', 'A well used heels from Shein. Well-maintained and true to size, see photos for details.', 136.65, 459.07, 'Well Used', 'Pink', 'Leather', 'Women', 'USA', 1, '2025-04-06 19:38:00', 11, 4, 28, 47),
('Oversized Heels', NULL, 214.33, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-06-23 04:17:00', 11, 1, 31, 49),
('Cropped Shein Heels', 'A brand new heels from Shein. Well-maintained and true to size, see photos for details.', 524.43, 726.13, 'Brand New', 'Brown', 'Synthetic', 'Men', 'Italy', 1, '2025-04-20 04:19:00', 11, 4, 28, 46),
('Retro Shein Heels', NULL, 280.02, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-11-25 19:44:00', 11, 4, 28, 47),
('Cropped Louis Vuitton Sneakers', NULL, 439.7, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-09-06 10:24:00', 12, 3, 37, 52),
('Cropped Sneakers', 'A like new sneakers from Unbranded. Well-maintained and true to size, see photos for details.', 622.07, 1038.48, 'Like New', 'Navy', 'Synthetic', 'Unisex', 'Italy', 1, '2025-10-26 22:04:00', 12, 4, 31, 55),
('Signature Converse Sneakers', NULL, 1379.21, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-05-06 18:25:00', 12, 2, 35, 54),
('Everyday Gucci Sneakers', NULL, 1198.56, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-03-29 03:49:00', 12, 6, 34, 56),
('Retro Dior Sneakers', 'A like new sneakers from Dior. Well-maintained and true to size, see photos for details.', 71551.96, 127842.72, 'Like New', 'Cream', 'Synthetic', 'Women', 'China', 0, '2025-08-16 16:47:00', 12, 6, 11, 55),
('Cropped Louis Vuitton Sneakers', 'A like new sneakers from Louis Vuitton. Well-maintained and true to size, see photos for details.', 54652.22, 106027.38, 'Like New', 'Navy', 'Canvas', 'Women', 'USA', 0, '2025-07-31 16:30:00', 12, 4, 8, 52),
('Limited Edition Louis Vuitton Sneakers', NULL, 1031.36, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-04-22 21:51:00', 12, 3, 37, 51),
('Oversized Dior Sneakers', 'A lightly used sneakers from Dior. Well-maintained and true to size, see photos for details.', 33538.22, 80070.61, 'Lightly Used', 'Beige', 'Canvas', 'Men', 'Japan', 0, '2025-01-30 23:39:00', 12, 2, 11, 52),
('Everyday Dior Sneakers', NULL, 2311.11, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-07-11 11:20:00', 12, 2, 43, 53),
('Cropped Louis Vuitton Sneakers', 'A lightly used sneakers from Louis Vuitton. Well-maintained and true to size, see photos for details.', 929.59, 2234.23, 'Lightly Used', 'Pink', 'Rubber', 'Women', 'USA', 1, '2025-06-26 21:45:00', 12, 1, 37, 54),
('Cropped Adidas Sneakers', 'A like new sneakers from Adidas. Well-maintained and true to size, see photos for details.', 2663.74, 4630.31, 'Like New', 'Beige', 'Rubber', 'Women', 'Vietnam', 1, '2026-07-05 22:58:00', 12, 3, 18, 51),
('Limited Edition Adidas Sneakers', 'A well used sneakers from Adidas. Well-maintained and true to size, see photos for details.', 1249.56, 4341.08, 'Well Used', 'Brown', 'Synthetic', 'Kids', 'Bangladesh', 1, '2026-05-22 13:43:00', 12, 2, 33, 55),
('Everyday Adidas Sneakers', 'A well used sneakers from Adidas. Well-maintained and true to size, see photos for details.', 1145.97, 4705.3, 'Well Used', 'Green', 'Rubber', 'Men', 'South Korea', 1, '2026-06-08 03:36:00', 12, 1, 18, 50),
('Cropped Running shoes', 'A lightly used running shoes from Unbranded. Well-maintained and true to size, see photos for details.', 250.42, 481.68, 'Lightly Used', 'Green', 'Suede', 'Women', 'China', 1, '2025-05-01 07:13:00', 13, 1, 31, 63),
('Limited Edition Nike Running shoes', 'A like new running shoes from Nike. Well-maintained and true to size, see photos for details.', 8179.86, 14800.5, 'Like New', 'Gray', 'Suede', 'Kids', 'Bangladesh', 1, '2025-04-08 04:48:00', 13, 1, 14, 62),
('Cropped Nike Running shoes', 'A like new running shoes from Nike. Well-maintained and true to size, see photos for details.', 1613.98, 3070.8, 'Like New', 'Multicolor', 'Suede', 'Men', 'Japan', 1, '2025-03-19 20:50:00', 13, 2, 32, 63),
('Cropped Adidas Running shoes', NULL, 1788.44, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-01-02 02:50:00', 13, 4, 33, 60),
('Cropped Nike Running shoes', 'A lightly used running shoes from Nike. Well-maintained and true to size, see photos for details.', 4704.97, 10878.35, 'Lightly Used', 'Red', 'Leather', 'Women', 'Indonesia', 1, '2025-01-17 03:59:00', 13, 4, 14, 59),
('Retro Adidas Running shoes', NULL, 927.09, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-04-06 20:23:00', 13, 2, 33, 63),
('Y2K Nike Running shoes', 'A well used running shoes from Nike. Well-maintained and true to size, see photos for details.', 4038.07, 12396.89, 'Well Used', 'Pink', 'Leather', 'Men', 'Philippines', 1, '2026-05-04 02:08:00', 13, 3, 14, 63),
('Limited Edition Nike Running shoes', 'A like new running shoes from Nike. Well-maintained and true to size, see photos for details.', 3668.96, 6480.41, 'Like New', 'Blue', 'Canvas', 'Women', 'Vietnam', 1, '2025-05-27 02:33:00', 13, 4, 14, 63),
('Minimalist Running shoes', 'A well used running shoes from Unbranded. Well-maintained and true to size, see photos for details.', 41.13, 175.7, 'Well Used', 'Cream', 'Leather', 'Men', 'Japan', 1, '2026-03-16 10:50:00', 13, 6, 31, 59),
('Everyday Nike Running shoes', 'A lightly used running shoes from Nike. Well-maintained and true to size, see photos for details.', 2105.98, 4261.9, 'Lightly Used', 'Multicolor', 'Suede', 'Women', 'India', 1, '2025-07-13 23:25:00', 13, 5, 32, 62),
('Oversized Nike Running shoes', 'A lightly used running shoes from Nike. Well-maintained and true to size, see photos for details.', 636.94, 1548.27, 'Lightly Used', 'Red', 'Canvas', 'Women', 'India', 1, '2026-01-10 17:43:00', 13, 2, 32, 61),
('Classic Running shoes', 'A like new running shoes from Unbranded. Well-maintained and true to size, see photos for details.', 481.07, 784.59, 'Like New', 'Yellow', 'Synthetic', 'Women', 'Japan', 1, '2026-07-04 17:39:00', 13, 1, 31, 58),
('Classic Nike Running shoes', 'A heavily used running shoes from Nike. Well-maintained and true to size, see photos for details.', 1457.03, 8446.61, 'Heavily Used', 'Brown', 'Leather', 'Women', 'Japan', 1, '2026-04-10 19:38:00', 13, 5, 14, 59),
('Timeless Dr. Martens Boots', 'A lightly used boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 1930.8, 3996.62, 'Lightly Used', 'Navy', 'Suede', 'Women', 'Vietnam', 1, '2025-10-03 23:56:00', 14, 6, 40, 65),
('Everyday Boots', NULL, 565.69, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-01-04 01:31:00', 14, 5, 31, 64),
('Timeless Boots', NULL, 242.63, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-06-06 00:02:00', 14, 2, 31, 66),
('Vintage Dr. Martens Boots', NULL, 1716.9, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-03-06 07:20:00', 14, 1, 40, 67),
('Retro Boots', 'A like new boots from Unbranded. Well-maintained and true to size, see photos for details.', 199.91, 310.05, 'Like New', 'Black', 'Synthetic', 'Women', 'South Korea', 1, '2025-11-15 10:05:00', 14, 6, 31, 66),
('Preloved Boots', 'A like new boots from Unbranded. Well-maintained and true to size, see photos for details.', 957.44, 1496.79, 'Like New', 'Navy', 'Rubber', 'Unisex', 'Italy', 1, '2025-01-07 13:01:00', 14, 6, 31, 68),
('Y2K Dr. Martens Boots', NULL, 657.95, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-03-06 15:03:00', 14, 6, 40, 67),
('Minimalist Boots', NULL, 255.66, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-04-15 23:05:00', 14, 1, 31, 64),
('Minimalist Dr. Martens Boots', 'A brand new boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 3991.2, 5683.86, 'Brand New', 'Red', 'Synthetic', 'Men', 'Thailand', 1, '2025-11-22 14:17:00', 14, 6, 17, 67),
('Classic Dr. Martens Boots', 'A like new boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 5010.03, 9323.17, 'Like New', 'Blue', 'Synthetic', 'Women', 'China', 1, '2025-06-11 21:19:00', 14, 2, 17, 64),
('Classic Dr. Martens Boots', 'A lightly used boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 1949.44, 4655.41, 'Lightly Used', 'Green', 'Rubber', 'Men', 'Italy', 1, '2026-04-19 03:51:00', 14, 3, 17, 67),
('Limited Edition Dr. Martens Boots', 'A well used boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 1899.12, 7411.62, 'Well Used', 'White', 'Leather', 'Kids', 'Italy', 1, '2026-03-31 04:05:00', 14, 2, 17, 65),
('Vintage Dr. Martens Boots', 'A well used boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 1341.33, 5364.04, 'Well Used', 'Beige', 'Suede', 'Women', 'Vietnam', 1, '2025-09-09 20:18:00', 14, 5, 17, 67),
('Minimalist Shein Flats', 'A lightly used flats from Shein. Well-maintained and true to size, see photos for details.', 155.35, 299.32, 'Lightly Used', 'Yellow', 'Leather', 'Kids', 'Thailand', 1, '2026-05-07 17:50:00', 15, 4, 28, 70),
('Y2K ZARA Flats', 'A lightly used flats from ZARA. Well-maintained and true to size, see photos for details.', 379.05, 777.59, 'Lightly Used', 'Green', 'Rubber', 'Women', 'India', 1, '2025-06-13 03:15:00', 15, 1, 30, 71),
('Preloved Shein Flats', 'A like new flats from Shein. Well-maintained and true to size, see photos for details.', 234.73, 387.03, 'Like New', 'Navy', 'Suede', 'Unisex', 'India', 1, '2025-07-12 15:34:00', 15, 2, 28, 70),
('Signature ZARA Flats', 'A brand new flats from ZARA. Well-maintained and true to size, see photos for details.', 1200.0, 1670.96, 'Brand New', 'Beige', 'Suede', 'Women', 'Vietnam', 1, '2025-05-26 03:54:00', 15, 2, 30, 70),
('Timeless Shein Flats', 'A like new flats from Shein. Well-maintained and true to size, see photos for details.', 493.57, 733.47, 'Like New', 'Multicolor', 'Suede', 'Women', 'Bangladesh', 1, '2026-01-01 07:42:00', 15, 3, 28, 71),
('Signature ZARA Flats', NULL, 231.11, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-02-03 05:38:00', 15, 6, 30, 69),
('Limited Edition Flats', 'A heavily used flats from Unbranded. Well-maintained and true to size, see photos for details.', 93.99, 395.09, 'Heavily Used', 'Beige', 'Leather', 'Unisex', 'Indonesia', 1, '2025-12-10 14:00:00', 15, 2, 31, 69),
('Cropped Shein Flats', 'A brand new flats from Shein. Well-maintained and true to size, see photos for details.', 604.61, 807.64, 'Brand New', 'Pink', 'Suede', 'Women', 'China', 1, '2025-08-19 05:28:00', 15, 1, 28, 69),
('Cropped Shein Flats', 'A brand new flats from Shein. Well-maintained and true to size, see photos for details.', 446.04, 537.64, 'Brand New', 'White', 'Suede', 'Men', 'India', 1, '2025-02-01 13:41:00', 15, 3, 28, 69),
('Cropped ZARA Flats', 'A heavily used flats from ZARA. Well-maintained and true to size, see photos for details.', 221.55, 1423.02, 'Heavily Used', 'White', 'Leather', 'Women', 'Bangladesh', 1, '2025-06-07 01:23:00', 15, 3, 30, 70),
('Cropped Flats', 'A like new flats from Unbranded. Well-maintained and true to size, see photos for details.', 858.39, 1466.73, 'Like New', 'White', 'Suede', 'Unisex', 'South Korea', 1, '2025-09-29 02:41:00', 15, 6, 31, 72),
('Everyday ZARA Flats', 'A like new flats from ZARA. Well-maintained and true to size, see photos for details.', 663.87, 1259.22, 'Like New', 'Navy', 'Leather', 'Women', 'USA', 1, '2026-02-28 18:14:00', 15, 4, 30, 69),
('Everyday Shein Flats', NULL, 77.03, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-05-31 03:48:00', 15, 3, 28, 69),
('Classic ZARA Sandals', 'A well used sandals from ZARA. Well-maintained and true to size, see photos for details.', 215.59, 643.26, 'Well Used', 'Beige', 'Rubber', 'Women', 'Thailand', 1, '2025-03-31 12:35:00', 16, 2, 30, 74),
('Oversized Sandals', 'A like new sandals from Unbranded. Well-maintained and true to size, see photos for details.', 836.47, 1391.15, 'Like New', 'White', 'Suede', 'Unisex', 'USA', 1, '2025-09-28 12:41:00', 16, 5, 31, 76),
('Timeless Shein Sandals', NULL, 254.73, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2026-05-02 08:57:00', 16, 2, 28, 76),
('Y2K ZARA Sandals', NULL, 1096.34, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-05-18 09:47:00', 16, 3, 30, 75),
('Classic Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 331.91, 692.76, 'Lightly Used', 'Red', 'Leather', 'Women', 'Vietnam', 1, '2025-11-15 22:32:00', 16, 3, 28, 76),
('Limited Edition ZARA Sandals', 'A brand new sandals from ZARA. Well-maintained and true to size, see photos for details.', 623.87, 765.76, 'Brand New', 'Yellow', 'Synthetic', 'Men', 'China', 1, '2025-02-01 07:23:00', 16, 1, 30, 74),
('Y2K Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 69.18, 139.72, 'Lightly Used', 'Cream', 'Canvas', 'Unisex', 'Indonesia', 1, '2025-07-31 08:41:00', 16, 2, 28, 75),
('Cropped Sandals', 'A like new sandals from Unbranded. Well-maintained and true to size, see photos for details.', 680.08, 1083.47, 'Like New', 'Blue', 'Synthetic', 'Unisex', 'USA', 1, '2025-09-16 06:29:00', 16, 2, 31, 73),
('Y2K Sandals', 'A like new sandals from Unbranded. Well-maintained and true to size, see photos for details.', 641.22, 978.86, 'Like New', 'Blue', 'Suede', 'Women', 'Bangladesh', 1, '2025-02-28 19:25:00', 16, 6, 31, 75),
('Cropped Shein Sandals', 'A like new sandals from Shein. Well-maintained and true to size, see photos for details.', 297.88, 557.63, 'Like New', 'Navy', 'Canvas', 'Men', 'Indonesia', 1, '2026-01-03 16:19:00', 16, 4, 28, 76),
('Timeless Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 431.28, 857.54, 'Lightly Used', 'Multicolor', 'Leather', 'Women', 'Italy', 1, '2025-11-11 13:50:00', 16, 2, 28, 75),
('Everyday ZARA Sandals', 'A well used sandals from ZARA. Well-maintained and true to size, see photos for details.', 145.07, 421.07, 'Well Used', 'Yellow', 'Leather', 'Unisex', 'Japan', 1, '2025-11-02 13:03:00', 16, 4, 30, 73),
('Minimalist Shein Sandals', NULL, 125.7, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-07-01 10:40:00', 16, 5, 28, 76),
('Classic Gucci Bags & Purses', NULL, 1549.74, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-05-13 19:27:00', 17, 4, 34, 79),
('Limited Edition Coach Bags & Purses', 'A like new bags & purses from Coach. Well-maintained and true to size, see photos for details.', 16019.29, 24251.03, 'Like New', 'Cream', 'Canvas', 'Women', 'Philippines', 1, '2025-09-12 07:44:00', 17, 4, 13, 80),
('Timeless ZARA Bags & Purses', NULL, 445.71, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-06-17 19:33:00', 17, 5, 30, 79),
('Oversized Coach Bags & Purses', NULL, 1136.83, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-01-20 07:14:00', 17, 6, 41, 78),
('Limited Edition Louis Vuitton Bags & Purses', 'A lightly used bags & purses from Louis Vuitton. Well-maintained and true to size, see photos for details.', 51914.55, 113139.43, 'Lightly Used', 'Cream', 'Leather', 'Men', 'Philippines', 0, '2025-04-21 20:53:00', 17, 6, 3, 77),
('Preloved ZARA Bags & Purses', 'A lightly used bags & purses from ZARA. Well-maintained and true to size, see photos for details.', 133.13, 315.82, 'Lightly Used', 'White', 'Nylon', 'Men', 'Thailand', 1, '2026-03-05 03:32:00', 17, 3, 30, 80),
('Oversized Louis Vuitton Bags & Purses', NULL, 1188.63, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-10-30 05:02:00', 17, 5, 37, 78),
('Everyday Louis Vuitton Bags & Purses', 'A like new bags & purses from Louis Vuitton. Well-maintained and true to size, see photos for details.', 2702.47, 4155.46, 'Like New', 'Multicolor', 'Suede', 'Women', 'China', 1, '2025-03-18 23:46:00', 17, 6, 37, 80),
('Minimalist Dior Bags & Purses', NULL, 3309.96, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-11-17 13:47:00', 17, 3, 43, 80),
('Preloved Gucci Bags & Purses', 'A well used bags & purses from Gucci. Well-maintained and true to size, see photos for details.', 36669.96, 103671.66, 'Well Used', 'Blue', 'Leather', 'Women', 'USA', 1, '2025-04-27 12:25:00', 17, 1, 6, 77),
('Classic Bags & Purses', NULL, 960.55, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-03-03 18:30:00', 17, 2, 31, 77),
('Oversized Louis Vuitton Bags & Purses', 'A well used bags & purses from Louis Vuitton. Well-maintained and true to size, see photos for details.', 1305.24, 4055.82, 'Well Used', 'Beige', 'Suede', 'Unisex', 'China', 1, '2026-03-28 01:04:00', 17, 5, 37, 80),
('Limited Edition ZARA Bags & Purses', NULL, 518.04, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-01-30 04:53:00', 17, 5, 30, 77),
('Everyday ZARA Accessories', 'A lightly used accessories from ZARA. Well-maintained and true to size, see photos for details.', 185.26, 427.27, 'Lightly Used', 'Brown', 'Synthetic', 'Kids', 'Philippines', 1, '2025-08-17 17:41:00', 18, 6, 30, 81),
('Vintage H&M Accessories', 'A brand new accessories from H&M. Well-maintained and true to size, see photos for details.', 704.09, 832.12, 'Brand New', 'Navy', 'Metal', 'Women', 'Japan', 1, '2026-07-17 00:52:00', 18, 5, 38, 81),
('Signature H&M Accessories', NULL, 282.89, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-04-30 22:42:00', 18, 3, 38, 81),
('Preloved Accessories', 'A brand new accessories from Unbranded. Well-maintained and true to size, see photos for details.', 1056.42, 1253.33, 'Brand New', 'Blue', 'Synthetic', 'Men', 'Philippines', 1, '2026-05-20 04:52:00', 18, 4, 31, 81),
('Oversized ZARA Accessories', NULL, 559.31, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-02-17 20:53:00', 18, 4, 30, 81),
('Timeless H&M Accessories', 'A heavily used accessories from H&M. Well-maintained and true to size, see photos for details.', 311.72, 1672.43, 'Heavily Used', 'Pink', 'Glass', 'Unisex', 'Vietnam', 1, '2025-06-27 23:52:00', 18, 4, 38, 81),
('Minimalist Accessories', NULL, 176.59, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-10-29 14:51:00', 18, 4, 31, 81),
('Timeless ZARA Accessories', 'A well used accessories from ZARA. Well-maintained and true to size, see photos for details.', 197.19, 641.51, 'Well Used', 'Blue', 'Synthetic', 'Unisex', 'Vietnam', 1, '2025-07-02 16:34:00', 18, 4, 30, 81),
('Retro Accessories', 'A well used accessories from Unbranded. Well-maintained and true to size, see photos for details.', 20.82, 86.64, 'Well Used', 'Multicolor', 'Metal', 'Women', 'Vietnam', 1, '2025-09-14 04:53:00', 18, 6, 31, 81),
('Retro H&M Accessories', 'A lightly used accessories from H&M. Well-maintained and true to size, see photos for details.', 513.8, 1323.77, 'Lightly Used', 'Multicolor', 'Glass', 'Women', 'Thailand', 1, '2025-02-18 12:24:00', 18, 4, 38, 81),
('Signature ZARA Accessories', NULL, 465.34, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-07-14 23:38:00', 18, 5, 30, 81),
('Timeless Accessories', NULL, 81.14, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-06-11 03:24:00', 18, 2, 31, 81),
('Signature H&M Accessories', 'A like new accessories from H&M. Well-maintained and true to size, see photos for details.', 397.26, 710.03, 'Like New', 'Navy', 'Leather', 'Women', 'USA', 1, '2025-02-22 20:39:00', 18, 3, 38, 81),
('Y2K Earrings', 'A well used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 46.01, 183.32, 'Well Used', 'Brown', 'Synthetic', 'Women', 'France', 1, '2026-06-28 15:35:00', 19, 2, 31, 82),
('Timeless Earrings', NULL, 117.1, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-10-17 00:58:00', 19, 1, 31, 82),
('Limited Edition ZARA Earrings', 'A like new earrings from ZARA. Well-maintained and true to size, see photos for details.', 1013.59, 1911.96, 'Like New', 'Cream', 'Metal', 'Men', 'Italy', 1, '2025-08-07 21:27:00', 19, 4, 30, 82),
('Oversized Earrings', 'A lightly used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 534.57, 1201.61, 'Lightly Used', 'Gray', 'Leather', 'Unisex', 'Japan', 1, '2026-04-07 20:25:00', 19, 1, 31, 82),
('Signature Earrings', 'A well used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 54.33, 155.25, 'Well Used', 'White', 'Synthetic', 'Unisex', 'France', 1, '2025-03-30 09:48:00', 19, 6, 31, 82),
('Limited Edition Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 566.05, 841.3, 'Like New', 'Beige', 'Synthetic', 'Men', 'Thailand', 1, '2026-01-18 00:35:00', 19, 5, 31, 82),
('Limited Edition Earrings', NULL, 230.49, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-06-09 04:10:00', 19, 3, 31, 82),
('Retro Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 839.92, 1285.76, 'Like New', 'Yellow', 'Glass', 'Men', 'China', 1, '2025-03-10 08:06:00', 19, 5, 31, 82),
('Signature Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 296.83, 510.79, 'Like New', 'Gray', 'Synthetic', 'Men', 'Vietnam', 1, '2026-01-09 10:27:00', 19, 6, 31, 82),
('Everyday Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 311.24, 530.77, 'Like New', 'Green', 'Synthetic', 'Unisex', 'South Korea', 1, '2025-04-22 05:41:00', 19, 6, 31, 82),
('Signature Earrings', NULL, 322.38, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2026-02-19 18:13:00', 19, 6, 31, 82),
('Limited Edition ZARA Earrings', 'A lightly used earrings from ZARA. Well-maintained and true to size, see photos for details.', 229.61, 527.6, 'Lightly Used', 'White', 'Glass', 'Women', 'Philippines', 1, '2025-09-02 19:43:00', 19, 5, 30, 82),
('Y2K Earrings', 'A lightly used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 449.42, 1154.13, 'Lightly Used', 'Blue', 'Synthetic', 'Women', 'Indonesia', 1, '2026-06-15 11:24:00', 19, 5, 31, 82),
('Classic Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 397.33, 889.02, 'Lightly Used', 'Pink', 'Glass', 'Women', 'Indonesia', 1, '2026-06-14 08:24:00', 20, 6, 31, 87),
('Everyday ZARA Rings', NULL, 729.29, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-10-15 06:09:00', 20, 4, 30, 87),
('Limited Edition Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 472.61, 1094.37, 'Lightly Used', 'Green', 'Glass', 'Women', 'Vietnam', 1, '2026-02-25 00:15:00', 20, 3, 31, 87),
('Cropped Rings', 'A brand new rings from Unbranded. Well-maintained and true to size, see photos for details.', 700.99, 919.07, 'Brand New', 'Black', 'Synthetic', 'Unisex', 'Italy', 1, '2026-04-28 15:10:00', 20, 5, 31, 84),
('Classic ZARA Rings', 'A well used rings from ZARA. Well-maintained and true to size, see photos for details.', 224.68, 955.29, 'Well Used', 'Brown', 'Glass', 'Unisex', 'India', 1, '2025-07-01 15:57:00', 20, 2, 30, 85),
('Timeless Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 186.17, 382.76, 'Lightly Used', 'Cream', 'Glass', 'Women', 'Thailand', 1, '2025-04-11 13:08:00', 20, 6, 31, 86),
('Everyday ZARA Rings', NULL, 235.47, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-01-08 12:41:00', 20, 3, 30, 84),
('Y2K ZARA Rings', 'A like new rings from ZARA. Well-maintained and true to size, see photos for details.', 1010.42, 1753.46, 'Like New', 'Red', 'Synthetic', 'Kids', 'Japan', 1, '2026-02-28 17:50:00', 20, 4, 30, 85),
('Oversized ZARA Rings', 'A well used rings from ZARA. Well-maintained and true to size, see photos for details.', 443.92, 1571.28, 'Well Used', 'Navy', 'Leather', 'Women', 'Bangladesh', 1, '2025-12-13 17:39:00', 20, 5, 30, 85),
('Vintage Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 441.5, 933.09, 'Lightly Used', 'Pink', 'Synthetic', 'Men', 'India', 1, '2025-06-29 20:31:00', 20, 4, 31, 87),
('Minimalist Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 263.72, 571.62, 'Lightly Used', 'Beige', 'Metal', 'Kids', 'Japan', 1, '2026-02-09 12:37:00', 20, 5, 31, 87),
('Vintage ZARA Rings', 'A well used rings from ZARA. Well-maintained and true to size, see photos for details.', 234.78, 770.06, 'Well Used', 'Brown', 'Glass', 'Unisex', 'India', 1, '2025-09-25 05:26:00', 20, 6, 30, 87),
('Vintage ZARA Rings', 'A like new rings from ZARA. Well-maintained and true to size, see photos for details.', 1023.84, 1608.94, 'Like New', 'Cream', 'Glass', 'Men', 'India', 1, '2026-05-09 03:16:00', 20, 5, 30, 87),
('Cropped ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 264.13, 722.04, 'Lightly Used', 'Multicolor', 'Synthetic', 'Women', 'Vietnam', 1, '2025-11-18 11:13:00', 21, 4, 30, 88),
('Limited Edition Necklace', 'A well used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 340.73, 1262.69, 'Well Used', 'Cream', 'Metal', 'Women', 'China', 1, '2026-05-20 19:00:00', 21, 6, 31, 88),
('Signature ZARA Necklace', NULL, 113.87, NULL, 'Heavily Used', NULL, NULL, NULL, NULL, 1, '2025-05-12 01:33:00', 21, 4, 30, 88),
('Vintage ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 308.14, 597.16, 'Lightly Used', 'Navy', 'Glass', 'Women', 'Philippines', 1, '2025-08-04 12:37:00', 21, 5, 30, 88),
('Retro Necklace', 'A like new necklace from Unbranded. Well-maintained and true to size, see photos for details.', 182.5, 316.67, 'Like New', 'Pink', 'Synthetic', 'Women', 'Japan', 1, '2026-04-07 05:36:00', 21, 5, 31, 88),
('Limited Edition Necklace', 'A well used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 320.82, 1120.89, 'Well Used', 'Black', 'Leather', 'Women', 'Vietnam', 1, '2026-06-14 17:46:00', 21, 5, 31, 88),
('Cropped ZARA Necklace', NULL, 861.42, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-12-09 08:23:00', 21, 1, 30, 88),
('Minimalist ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 595.69, 1329.48, 'Lightly Used', 'Multicolor', 'Leather', 'Kids', 'France', 1, '2025-11-29 21:32:00', 21, 3, 30, 88),
('Y2K ZARA Necklace', 'A well used necklace from ZARA. Well-maintained and true to size, see photos for details.', 310.95, 1017.09, 'Well Used', 'Pink', 'Metal', 'Women', 'USA', 1, '2025-11-18 10:41:00', 21, 6, 30, 88),
('Classic ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 726.8, 1425.44, 'Lightly Used', 'Navy', 'Metal', 'Women', 'Japan', 1, '2025-04-08 02:59:00', 21, 6, 30, 88),
('Timeless Necklace', NULL, 428.16, NULL, 'Brand New', NULL, NULL, NULL, NULL, 1, '2025-10-18 14:40:00', 21, 3, 31, 88),
('Timeless Necklace', 'A brand new necklace from Unbranded. Well-maintained and true to size, see photos for details.', 388.67, 521.54, 'Brand New', 'Yellow', 'Synthetic', 'Women', 'Vietnam', 1, '2026-07-07 05:37:00', 21, 5, 31, 88),
('Vintage Necklace', 'A like new necklace from Unbranded. Well-maintained and true to size, see photos for details.', 32.42, 50.13, 'Like New', 'Beige', 'Synthetic', 'Women', 'Bangladesh', 1, '2026-05-19 15:19:00', 21, 1, 31, 88),
('Timeless Bracelet', NULL, 372.66, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-02-04 12:14:00', 22, 5, 31, 89),
('Retro Bracelet', NULL, 439.5, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-10-19 20:47:00', 22, 4, 31, 89),
('Everyday ZARA Bracelet', 'A like new bracelet from ZARA. Well-maintained and true to size, see photos for details.', 466.8, 762.63, 'Like New', 'Brown', 'Synthetic', 'Women', 'Philippines', 1, '2025-01-23 05:06:00', 22, 2, 30, 89),
('Vintage Bracelet', 'A brand new bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 1111.91, 1497.05, 'Brand New', 'Cream', 'Metal', 'Women', 'Vietnam', 1, '2025-09-30 12:04:00', 22, 1, 31, 89),
('Y2K Bracelet', NULL, 277.3, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2026-04-17 23:49:00', 22, 1, 31, 89),
('Y2K Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 501.01, 1129.85, 'Lightly Used', 'White', 'Synthetic', 'Women', 'France', 1, '2026-01-05 01:55:00', 22, 4, 31, 89),
('Y2K Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 417.21, 892.56, 'Lightly Used', 'Navy', 'Leather', 'Women', 'China', 1, '2025-06-11 15:05:00', 22, 2, 31, 89),
('Cropped Bracelet', NULL, 759.25, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-07-17 00:44:00', 22, 2, 31, 89),
('Minimalist ZARA Bracelet', 'A like new bracelet from ZARA. Well-maintained and true to size, see photos for details.', 747.32, 1250.34, 'Like New', 'Green', 'Leather', 'Men', 'Bangladesh', 1, '2025-11-28 23:29:00', 22, 6, 30, 89),
('Vintage ZARA Bracelet', NULL, 550.74, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-01-08 19:15:00', 22, 3, 30, 89),
('Limited Edition Bracelet', 'A like new bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 150.68, 273.49, 'Like New', 'Pink', 'Synthetic', 'Women', 'Bangladesh', 1, '2025-03-10 01:53:00', 22, 6, 31, 89),
('Signature Bracelet', 'A brand new bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 758.18, 1003.99, 'Brand New', 'Navy', 'Synthetic', 'Women', 'Italy', 1, '2025-03-14 00:59:00', 22, 4, 31, 89),
('Everyday Bracelet', NULL, 41.22, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-02-11 23:04:00', 22, 3, 31, 89),
('Oversized Aesthetic Bundles', 'A like new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 442.89, 812.98, 'Like New', 'Multicolor', 'Cotton', 'Men', 'Bangladesh', 1, '2025-04-19 20:36:00', 23, 2, 31, 90),
('Limited Edition Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 706.6, 1403.6, 'Lightly Used', 'Yellow', 'Polyester', 'Unisex', 'Japan', 1, '2026-03-17 23:20:00', 23, 5, 31, 90),
('Y2K Aesthetic Bundles', 'A brand new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 679.4, 800.53, 'Brand New', 'Blue', 'Cotton', 'Women', 'Italy', 1, '2025-11-19 00:49:00', 23, 4, 31, 90),
('Retro Aesthetic Bundles', NULL, 225.16, NULL, 'Like New', NULL, NULL, NULL, NULL, 1, '2025-04-05 18:25:00', 23, 2, 31, 90),
('Timeless Aesthetic Bundles', 'A well used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 315.68, 1049.91, 'Well Used', 'White', 'Mixed', 'Men', 'Philippines', 1, '2026-01-26 02:49:00', 23, 6, 31, 90),
('Limited Edition Aesthetic Bundles', NULL, 639.29, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2026-01-27 01:19:00', 23, 1, 31, 90),
('Retro Aesthetic Bundles', 'A like new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 926.58, 1458.01, 'Like New', 'Gray', 'Mixed', 'Women', 'Japan', 1, '2026-02-08 04:08:00', 23, 5, 31, 90),
('Everyday Aesthetic Bundles', NULL, 89.14, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-07-22 15:25:00', 23, 1, 31, 90),
('Minimalist Aesthetic Bundles', 'A like new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 460.55, 885.23, 'Like New', 'Pink', 'Polyester', 'Women', 'Italy', 1, '2025-12-19 19:41:00', 23, 2, 31, 90),
('Preloved Aesthetic Bundles', NULL, 181.27, NULL, 'Lightly Used', NULL, NULL, NULL, NULL, 1, '2025-03-29 03:47:00', 23, 5, 31, 90),
('Classic Aesthetic Bundles', NULL, 22.17, NULL, 'Well Used', NULL, NULL, NULL, NULL, 1, '2025-11-09 14:30:00', 23, 5, 31, 90),
('Signature Aesthetic Bundles', 'A like new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 647.0, 953.41, 'Like New', 'Navy', 'Mixed', 'Men', 'Japan', 1, '2026-06-24 01:16:00', 23, 2, 31, 90),
('Oversized Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 510.91, 1011.32, 'Lightly Used', 'Red', 'Cotton', 'Women', 'Indonesia', 1, '2025-08-25 12:32:00', 23, 1, 31, 90),
('Nike Air Jordan 1 Retro High "Chicago"', 'Grail tier Air Jordan 1 in the original black, white, and red colorway that started it all in 1985. Authenticated preloved pair with minimal creasing, full original box included.', 28500.0, 32000.0, 'Like New', 'Black', 'Leather', 'Unisex', 'Vietnam', 0, '2025-07-23 16:29:00', 12, 1, 14, 50),
('Nike Air Jordan 1 Retro High "Bred Toe"', 'Highly sought after Bred Toe colorway. Lightly worn with visible love on the toe box, priced accordingly below mint condition resale comps.', 21000.0, 26000.0, 'Lightly Used', 'Red', 'Leather', 'Unisex', 'Vietnam', 0, '2025-01-23 01:15:00', 12, 2, 14, 51),
('Nike Air Jordan 13 Retro "Black Cat"', 'Cult favorite Jordan 13 in the stealthy Black Cat colorway. Rare full family size run from a private collection, sold as is with authenticity guarantee.', 18500.0, 21000.0, 'Like New', 'Black', 'Leather', 'Unisex', 'Vietnam', 0, '2026-06-27 09:21:00', 12, 3, 14, 52),
('Nike Air Force 1 \'07 "Triple White"', 'The everyday icon. Clean triple white Air Force 1, freshly deep cleaned, minor sole yellowing consistent with age.', 5800.0, 6500.0, 'Lightly Used', 'White', 'Leather', 'Unisex', 'Vietnam', 0, '2026-05-17 12:47:00', 12, 4, 16, 53),
('Nike Air Force 1 Low "Premium Collab Edition"', 'Limited premium AF1 build with upgraded leather and collab style detailing. Deadstock condition, worn twice for photos only.', 8200.0, 9800.0, 'Brand New', 'Black', 'Leather', 'Unisex', 'Vietnam', 0, '2025-06-10 00:22:00', 12, 5, 16, 54),
('Louis Vuitton Trainer Sneaker, Monogram', 'Structured LV Trainer with monogram detailing and a chunky sole. Comes with dust bag and authenticity card, a true grail crossover between streetwear and luxury.', 98000.0, 125000.0, 'Like New', 'Brown', 'Leather', 'Unisex', 'France', 0, '2025-12-27 11:40:00', 12, 6, 7, 55),
('Louis Vuitton LV Runner Sneaker', 'Sporty LV Runner with signature branding along the midsole. Well loved but structurally sound, priced fairly for the wear shown.', 67000.0, 89000.0, 'Well Used', 'Black', 'Leather', 'Unisex', 'France', 0, '2025-11-06 07:32:00', 12, 1, 8, 56),
('Gucci Ace Sneaker, Web Stripe', 'Clean low top Ace sneaker with the signature green and red web stripe. Minimalist leather build, barely worn.', 42000.0, 52000.0, 'Like New', 'White', 'Leather', 'Unisex', 'Italy', 0, '2025-10-10 01:40:00', 12, 2, 9, 57),
('Gucci Rhyton Sneaker, Chunky Sole', 'Statement chunky sole Rhyton sneaker. The distressed look upper is factory finish, not wear, authenticated and boxed.', 48500.0, 58000.0, 'Brand New', 'White', 'Leather', 'Unisex', 'Italy', 0, '2025-09-21 12:56:00', 12, 3, 10, 50),
('Dior B23 High-Top Sneaker, Oblique Canvas', 'Signature Dior Oblique canvas high top with leather trim. One of the most recognized silhouettes in modern luxury streetwear.', 72000.0, 95000.0, 'Like New', 'Beige', 'Leather', 'Unisex', 'Italy', 0, '2025-01-31 17:17:00', 12, 4, 11, 51);

INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(1, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(1, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(2, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(2, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(2, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(3, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(3, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(3, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(3, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(4, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(4, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(4, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(5, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(6, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(6, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(6, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(7, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(8, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(8, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(8, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(9, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(10, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(11, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(12, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(12, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(12, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(13, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(13, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(13, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(13, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(14, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(15, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(16, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(16, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(16, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(16, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(16, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(17, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(18, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(18, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(18, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(19, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(19, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(19, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(20, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(20, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(20, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(21, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(21, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(21, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(21, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(22, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(23, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(23, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(23, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(23, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(24, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(24, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(24, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(24, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(25, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(25, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(25, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(25, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(25, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(26, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(27, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(27, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(27, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(28, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(28, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(28, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(29, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(30, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(31, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(32, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(32, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(32, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(32, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(32, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(33, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(33, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(33, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(34, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(34, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(34, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(35, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(35, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(35, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(35, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(37, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(38, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(38, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(38, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(38, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(39, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(39, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(39, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(39, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(39, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(40, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(40, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(40, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(40, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(42, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(42, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(42, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(46, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(49, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(53, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(53, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(53, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(53, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(54, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(55, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(55, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(55, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(55, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(56, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(56, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(56, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(56, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(57, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(57, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(57, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(58, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(59, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(60, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(60, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(60, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(61, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(61, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(61, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(61, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(62, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(63, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(63, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(63, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(64, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(64, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(64, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(64, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(64, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(65, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(65, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(65, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(66, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(66, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(66, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(66, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(67, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(67, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(67, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(68, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(69, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(69, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(69, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(69, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(70, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(71, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(72, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(73, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(74, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(74, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(74, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(75, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(76, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(76, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(76, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(77, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(77, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(77, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(77, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(77, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(78, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(79, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(79, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(79, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(80, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(81, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(81, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(81, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(82, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(82, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(82, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(82, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(82, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(83, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(83, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(83, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(83, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(83, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(84, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(84, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(84, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(85, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(85, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(85, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(85, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(85, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(86, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(86, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(86, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(87, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(88, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(88, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(88, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(89, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(89, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(89, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(90, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(90, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(90, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(90, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(90, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(91, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(91, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(91, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(91, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(91, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(92, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(93, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(93, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(93, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(94, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(94, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(94, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(94, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(95, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(95, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(95, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(96, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(97, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(98, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(98, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(99, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(99, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(99, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(99, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(100, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(100, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(100, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(101, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(102, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(102, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(102, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(102, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(103, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(103, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(103, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(103, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(104, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(104, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(104, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(104, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(105, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(105, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(105, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(105, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(106, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(107, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(107, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(107, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(107, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(107, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(108, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(109, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(110, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(111, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(112, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(112, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(112, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(112, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(114, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(114, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(114, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(115, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(115, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(115, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(116, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(116, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(116, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(116, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(117, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(118, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(118, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(118, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(120, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(120, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(121, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(121, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(121, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(122, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(123, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(124, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(124, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(124, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(125, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(125, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(125, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(126, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(126, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(126, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(126, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(127, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(128, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(129, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(129, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(129, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(129, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(129, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(130, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(130, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(130, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(130, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(131, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(131, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(131, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(131, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(132, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(133, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(133, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(133, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(134, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(134, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(134, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(134, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(135, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(135, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(135, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(136, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(137, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(137, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(137, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(137, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(137, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(139, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(139, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(139, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(139, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(140, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(140, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(140, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(140, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(141, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(142, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(142, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(142, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(143, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(144, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 1),
(145, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(145, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(145, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(145, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(146, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(147, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(148, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(148, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(148, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(148, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(148, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(149, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 1),
(149, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(149, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(150, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(151, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(151, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(151, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(151, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(152, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(153, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(153, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(153, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(153, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(154, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(154, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(154, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(155, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 1),
(155, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(155, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(155, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(156, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 1),
(156, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(156, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(157, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(157, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(158, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(158, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(158, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(158, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(159, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(159, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(159, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(160, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(161, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(161, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(161, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(162, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(163, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(163, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(163, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(163, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(163, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(164, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(164, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(164, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(164, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(164, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(165, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(165, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(165, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(166, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(166, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(166, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(166, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(167, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(167, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(167, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(168, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(168, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(168, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(169, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(169, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(169, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(170, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(170, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(170, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(171, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(172, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(173, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(174, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(174, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(174, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(174, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(174, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(175, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(175, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(175, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(176, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(177, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(178, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(178, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(178, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(179, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(179, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(179, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(179, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(179, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(180, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(180, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(180, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(181, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(181, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(181, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(181, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(182, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(182, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(182, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(182, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(183, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(183, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(183, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(183, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(184, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(184, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(184, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(184, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(184, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(185, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(185, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(185, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(185, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(186, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(186, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(186, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(186, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(186, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(187, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(188, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(189, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(189, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(189, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(189, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(190, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(190, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(190, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(191, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(191, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(191, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(192, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(192, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(192, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(193, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(193, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(193, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(193, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(193, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(194, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(194, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(194, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(194, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(194, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(195, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(196, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(196, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(196, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(196, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(197, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(198, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(199, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(201, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(201, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(201, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(201, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(202, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(202, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(202, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(202, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(204, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(204, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(205, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(205, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(205, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(206, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(206, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(206, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(206, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(207, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(207, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(207, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(208, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(209, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(210, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(210, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(210, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(210, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(211, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(212, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(213, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 1),
(213, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(213, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(213, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(213, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 0),
(214, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(214, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(214, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(214, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(214, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(215, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(216, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(216, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(216, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(217, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(218, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 1),
(218, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(218, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(218, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(219, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(220, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(220, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(220, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(220, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(221, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(222, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(222, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(222, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(222, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(223, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(223, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(223, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(224, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(225, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(225, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(225, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(225, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(225, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(226, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(227, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(227, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(227, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(228, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(229, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(230, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(230, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(230, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(231, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(231, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(232, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(233, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(234, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(235, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(235, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(236, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(237, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(237, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(237, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(238, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(238, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(238, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(238, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(239, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(239, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(239, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(239, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(240, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(240, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(240, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(240, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(240, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(241, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(242, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(242, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(242, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(243, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(243, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(243, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(244, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(244, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(244, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(244, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(244, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(245, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(246, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(246, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(246, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(247, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(247, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(248, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(248, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(248, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(249, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(250, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(250, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(250, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(251, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(251, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(251, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(252, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(253, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(253, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(253, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(253, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(254, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(255, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(255, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(255, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(255, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(255, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(256, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(257, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(257, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(257, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(257, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(259, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(259, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(259, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(259, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(259, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(260, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(260, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(260, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(261, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(261, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(261, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(261, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(261, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(262, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(262, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(262, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(262, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(262, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(263, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(265, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(265, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(265, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(266, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(267, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(268, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(268, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(268, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(268, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(270, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(270, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(270, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(270, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(271, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(273, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(274, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(275, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(276, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(276, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(277, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(278, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(279, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(279, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(279, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(279, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(279, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(280, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(280, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(280, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(280, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(280, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(281, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(282, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(282, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(282, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(282, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(283, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(284, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(284, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(284, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(285, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(285, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(285, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(286, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(287, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(287, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(287, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(287, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(288, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(288, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(289, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(289, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(289, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(289, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(289, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(290, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(291, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(291, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(291, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(292, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(293, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(293, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(293, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(293, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(294, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(295, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(295, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(295, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(296, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(297, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(298, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(298, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(298, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(299, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(299, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(299, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(299, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(299, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(300, 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800', 1),
(301, 'https://images.unsplash.com/photo-1565571323165-ab0ee8e01666?w=800', 1),
(302, 'https://images.unsplash.com/photo-1533681018184-68bd1d883b97?w=800', 1),
(303, 'https://images.unsplash.com/photo-1626379637476-f78d1d86b9f3?w=800', 1),
(304, 'https://images.unsplash.com/photo-1579338559194-a162d19bf842?w=800', 1),
(305, 'https://images.unsplash.com/photo-1639572600664-28a2a01ce860?w=800', 1),
(306, 'https://images.unsplash.com/photo-1516478177764-9fe5bd7e9717?w=800', 1),
(307, 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=800', 1),
(308, 'https://images.unsplash.com/photo-1615743472612-93b21e520fad?w=800', 1),
(309, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800', 1);

-- ------------------------------------------------------------
-- AUTHENTICATION (luxury items)
-- ------------------------------------------------------------
INSERT INTO AUTHENTICATION (listing_id, authentication_status, remarks) VALUES
(148, 'Pending', 'Certificate of authenticity submitted by seller.'),
(149, 'Pending', 'Certificate of authenticity submitted by seller.'),
(151, 'Pending', 'No certificate provided, item verified against original box.'),
(213, 'Pending', 'Certificate of authenticity submitted by seller.'),
(300, 'Pending', 'Certificate of authenticity submitted by seller.'),
(301, 'Pending', 'No certificate provided, item verified against original box.'),
(302, 'Pending', 'Certificate of authenticity submitted by seller.'),
(303, 'Pending', 'Certificate of authenticity submitted by seller.'),
(304, 'Pending', 'No certificate provided, item verified against original box.'),
(305, 'Pending', 'Certificate of authenticity submitted by seller.'),
(306, 'Pending', 'Certificate of authenticity submitted by seller.'),
(307, 'Pending', 'No certificate provided, item verified against original box.'),
(308, 'Pending', 'Certificate of authenticity submitted by seller.'),
(309, 'Pending', 'Certificate of authenticity submitted by seller.');

-- Admin already reviewed some of these (fires the authenticity trigger: auto-post on Verified)
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=1, date_verified='2026-03-07 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=149;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=1, date_verified='2026-01-26 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=151;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=2, date_verified='2026-02-12 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=300;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=2, date_verified='2026-02-08 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=301;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=3, date_verified='2026-01-24 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=303;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=1, date_verified='2026-05-21 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=304;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=1, date_verified='2026-04-03 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=306;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=3, date_verified='2026-05-18 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=307;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=2, date_verified='2026-02-22 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=309;

-- (Luxury listings seeded: 14 total; roughly 1/3 left Pending for the admin queue)

-- ------------------------------------------------------------
-- AUCTIONS + BIDDINGS
-- ------------------------------------------------------------
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (271.1, 20, 271.1, '2026-04-06 18:41:00', '2027-07-19 15:00:00', 'Active', 79);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(330.85, '2026-04-07 08:41:00', 1, 1),
(377.73, '2026-04-08 05:41:00', 1, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-08 11:41:00' WHERE auction_id=1;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (422.45, 21.12, 422.45, '2026-07-17 00:52:00', '2027-07-19 15:00:00', 'Active', 223);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(476.03, '2026-07-17 14:52:00', 2, 3),
(512.72, '2026-07-18 04:52:00', 2, 4),
(568.49, '2026-07-19 06:52:00', 2, 6),
(607.66, '2026-07-20 01:52:00', 2, 5),
(631.52, '2026-07-20 18:52:00', 2, 8),
(658.32, '2026-07-21 18:52:00', 2, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-21 21:52:00' WHERE auction_id=2;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2422.84, 121.14, 2422.84, '2026-05-04 02:08:00', '2027-07-19 15:00:00', 'Active', 163);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2720.78, '2026-05-05 10:08:00', 3, 4),
(2970.07, '2026-05-05 14:08:00', 3, 6),
(3208.39, '2026-05-06 14:08:00', 3, 2),
(3476.06, '2026-05-07 17:08:00', 3, 5),
(3836.16, '2026-05-08 04:08:00', 3, 1),
(4060.77, '2026-05-09 09:08:00', 3, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-09 12:08:00' WHERE auction_id=3;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (145.58, 20, 145.58, '2026-06-06 00:02:00', '2027-07-19 15:00:00', 'Active', 172);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(190.85, '2026-06-07 05:02:00', 4, 6),
(243.17, '2026-06-08 11:02:00', 4, 2),
(287.55, '2026-06-09 11:02:00', 4, 5),
(319.17, '2026-06-09 19:02:00', 4, 8),
(339.23, '2026-06-09 21:02:00', 4, 4),
(377.83, '2026-06-11 00:02:00', 4, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-11 01:02:00' WHERE auction_id=4;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (238.36, 20, 238.36, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 13 HOUR), 'Active', 234);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(262.61, '2026-07-18 00:00:00', 5, 6),
(286.63, '2026-07-18 03:00:00', 5, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (448.39, 22.42, 448.39, '2025-11-28 23:29:00', '2027-07-19 15:00:00', 'Active', 282);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(495.47, '2025-11-30 10:29:00', 6, 5),
(518.16, '2025-12-01 09:29:00', 6, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-01 12:29:00' WHERE auction_id=6;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (425.96, 21.3, 425.96, '2025-12-29 21:48:00', '2027-07-19 15:00:00', 'Active', 68);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(467.67, '2025-12-31 01:48:00', 7, 1),
(522.93, '2025-12-31 23:48:00', 7, 7),
(550.01, '2026-01-01 05:48:00', 7, 2),
(598.03, '2026-01-02 11:48:00', 7, 6),
(656.19, '2026-01-03 17:48:00', 7, 3),
(691.77, '2026-01-04 20:48:00', 7, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-05 00:48:00' WHERE auction_id=7;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (549.91, 27.5, 549.91, '2026-07-16 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 18 HOUR), 'Active', 106);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(579.23, '2026-07-18 14:00:00', 8, 1),
(614.44, '2026-07-18 15:00:00', 8, 2),
(651.27, '2026-07-18 19:00:00', 8, 5),
(696.0, '2026-07-18 21:00:00', 8, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (199.17, 20, 199.17, '2025-06-09 05:48:00', '2027-07-19 15:00:00', 'Active', 71);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(220.44, '2025-06-10 08:48:00', 9, 3),
(243.91, '2025-06-11 14:48:00', 9, 5),
(273.42, '2025-06-12 06:48:00', 9, 1),
(326.6, '2025-06-12 17:48:00', 9, 8),
(355.25, '2025-06-13 04:48:00', 9, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-13 06:48:00' WHERE auction_id=9;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (53.48, 20, 53.48, '2025-07-22 15:25:00', '2027-07-19 15:00:00', 'Active', 294);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(93.72, '2025-07-24 02:25:00', 10, 4),
(133.03, '2025-07-24 20:25:00', 10, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-24 22:25:00' WHERE auction_id=10;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (358.34, 20, 358.34, '2026-03-18 04:56:00', '2027-07-19 15:00:00', 'Active', 104);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(405.41, '2026-03-18 19:56:00', 11, 5),
(433.62, '2026-03-18 22:56:00', 11, 7),
(471.99, '2026-03-19 22:56:00', 11, 3),
(526.58, '2026-03-20 03:56:00', 11, 2),
(546.74, '2026-03-20 06:56:00', 11, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-20 12:56:00' WHERE auction_id=11;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (189.41, 20, 189.41, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 14 HOUR), 'Active', 291);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (556.25, 27.81, 556.25, '2026-07-16 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 0 HOUR), 'Active', 162);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(589.41, '2026-07-19 01:00:00', 13, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (19.45, 20, 19.45, '2026-05-19 15:19:00', '2027-07-19 15:00:00', 'Active', 273);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(40.06, '2026-05-20 14:19:00', 14, 2),
(82.45, '2026-05-20 19:19:00', 14, 3),
(110.71, '2026-05-21 08:19:00', 14, 8),
(152.68, '2026-05-21 18:19:00', 14, 6),
(178.34, '2026-05-22 18:19:00', 14, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-22 21:19:00' WHERE auction_id=14;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (81.13, 20, 81.13, '2025-02-01 02:47:00', '2027-07-19 15:00:00', 'Active', 70);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(122.75, '2025-02-01 11:47:00', 15, 5),
(147.95, '2025-02-02 04:47:00', 15, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-02 10:47:00' WHERE auction_id=15;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (633.85, 31.69, 633.85, '2026-05-20 04:52:00', '2027-07-19 15:00:00', 'Active', 225);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(676.88, '2026-05-21 08:52:00', 16, 2),
(765.06, '2026-05-22 06:52:00', 16, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-22 12:52:00' WHERE auction_id=16;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (72.83, 20, 72.83, '2026-01-06 02:27:00', '2027-07-19 15:00:00', 'Active', 75);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(131.78, '2026-01-07 06:27:00', 17, 6),
(182.36, '2026-01-08 02:27:00', 17, 7),
(207.63, '2026-01-09 06:27:00', 17, 2),
(259.72, '2026-01-10 06:27:00', 17, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-10 10:27:00' WHERE auction_id=17;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (516.17, 25.81, 516.17, '2025-12-09 02:21:00', '2027-07-19 15:00:00', 'Active', 81);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(562.22, '2025-12-10 08:21:00', 18, 8),
(635.38, '2025-12-10 20:21:00', 18, 4),
(701.91, '2025-12-12 02:21:00', 18, 2),
(744.48, '2025-12-12 19:21:00', 18, 6),
(771.85, '2025-12-13 12:21:00', 18, 5),
(803.49, '2025-12-14 05:21:00', 18, 3),
(853.11, '2025-12-14 12:21:00', 18, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-14 15:21:00' WHERE auction_id=18;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1263.59, 63.18, 1263.59, '2025-07-13 23:25:00', '2027-07-19 15:00:00', 'Active', 166);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1367.95, '2025-07-14 23:25:00', 19, 2),
(1440.09, '2025-07-15 10:25:00', 19, 4),
(1570.59, '2025-07-16 00:25:00', 19, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-16 05:25:00' WHERE auction_id=19;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (496.37, 24.82, 496.37, '2025-02-12 11:34:00', '2027-07-19 15:00:00', 'Active', 35);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(538.1, '2025-02-13 17:34:00', 20, 3),
(597.37, '2025-02-14 08:34:00', 20, 4),
(661.12, '2025-02-14 23:34:00', 20, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-15 04:34:00' WHERE auction_id=20;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (667.15, 33.36, 667.15, '2025-09-30 12:04:00', '2027-07-19 15:00:00', 'Active', 277);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(749.84, '2025-10-01 14:04:00', 21, 3),
(821.51, '2025-10-02 07:04:00', 21, 6),
(862.5, '2025-10-03 04:04:00', 21, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-03 08:04:00' WHERE auction_id=21;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (160.76, 20, 160.76, '2026-03-01 20:06:00', '2027-07-19 15:00:00', 'Active', 61);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(213.32, '2026-03-03 09:06:00', 22, 3),
(266.11, '2026-03-03 21:06:00', 22, 8),
(305.88, '2026-03-04 20:06:00', 22, 4),
(328.34, '2026-03-05 04:06:00', 22, 1),
(381.02, '2026-03-06 10:06:00', 22, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-06 15:06:00' WHERE auction_id=22;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (28.03, 20, 28.03, '2026-07-16 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 14 HOUR), 'Active', 95);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(65.58, '2026-07-17 18:00:00', 23, 8),
(96.99, '2026-07-18 00:00:00', 23, 2),
(123.08, '2026-07-18 04:00:00', 23, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (455.55, 22.78, 455.55, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 2 HOUR), 'Active', 281);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(486.74, '2026-07-19 12:00:00', 24, 7),
(531.57, '2026-07-19 13:00:00', 24, 8),
(570.37, '2026-07-19 14:36:00', 24, 2),
(612.77, '2026-07-19 14:20:00', 24, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (330.44, 20, 330.44, '2026-01-08 19:15:00', '2027-07-19 15:00:00', 'Active', 283);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(372.24, '2026-01-10 01:15:00', 25, 7),
(399.18, '2026-01-10 07:15:00', 25, 6),
(426.71, '2026-01-10 21:15:00', 25, 3),
(480.44, '2026-01-11 10:15:00', 25, 4),
(534.04, '2026-01-11 16:15:00', 25, 5),
(565.58, '2026-01-12 21:15:00', 25, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-13 03:15:00' WHERE auction_id=25;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (415.97, 20.8, 415.97, '2026-03-10 22:46:00', '2027-07-19 15:00:00', 'Active', 16);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(473.58, '2026-03-12 09:46:00', 26, 1),
(512.55, '2026-03-12 15:46:00', 26, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-12 16:46:00' WHERE auction_id=26;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (382.16, 20, 382.16, '2026-01-10 17:43:00', '2027-07-19 15:00:00', 'Active', 167);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(409.35, '2026-01-11 21:43:00', 27, 8),
(446.31, '2026-01-13 01:43:00', 27, 7),
(484.31, '2026-01-13 14:43:00', 27, 6),
(513.34, '2026-01-14 05:43:00', 27, 5),
(557.52, '2026-01-15 01:43:00', 27, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-15 05:43:00' WHERE auction_id=27;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1621.48, 81.07, 1621.48, '2026-07-16 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 13 HOUR), 'Active', 216);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (713.18, 35.66, 713.18, '2025-10-30 05:02:00', '2027-07-19 15:00:00', 'Active', 215);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(785.71, '2025-10-31 07:02:00', 29, 6),
(884.84, '2025-10-31 11:02:00', 29, 1),
(937.99, '2025-11-01 09:02:00', 29, 5),
(1026.55, '2025-11-02 08:02:00', 29, 4),
(1067.78, '2025-11-03 06:02:00', 29, 7),
(1141.9, '2025-11-04 02:02:00', 29, 8),
(1199.85, '2025-11-04 05:02:00', 29, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-04 08:02:00' WHERE auction_id=29;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (968.39, 48.42, 968.39, '2026-07-15 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 14 HOUR), 'Active', 159);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1024.92, '2026-07-18 22:00:00', 30, 6),
(1118.03, '2026-07-19 04:00:00', 30, 4),
(1181.17, '2026-07-19 09:00:00', 30, 3),
(1242.2, '2026-07-19 13:50:00', 30, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (308.28, 20, 308.28, '2025-02-18 12:24:00', '2027-07-19 15:00:00', 'Active', 231);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(331.58, '2025-02-19 14:24:00', 31, 1),
(354.65, '2025-02-20 17:24:00', 31, 6),
(385.76, '2025-02-20 23:24:00', 31, 3),
(430.39, '2025-02-21 09:24:00', 31, 5),
(484.7, '2025-02-21 11:24:00', 31, 8),
(534.36, '2025-02-22 08:24:00', 31, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-22 10:24:00' WHERE auction_id=31;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (128.6, 20, 128.6, '2026-07-17 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 11 HOUR), 'Active', 141);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(164.59, '2026-07-19 00:00:00', 32, 4),
(191.45, '2026-07-19 01:00:00', 32, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (321.0, 20, 321.0, '2026-07-15 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 4 HOUR), 'Active', 78);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(355.52, '2026-07-18 08:00:00', 33, 7),
(379.74, '2026-07-18 14:00:00', 33, 2),
(416.58, '2026-07-18 15:00:00', 33, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (227.13, 20, 227.13, '2025-06-28 11:32:00', '2027-07-19 15:00:00', 'Active', 97);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(263.08, '2025-06-29 06:32:00', 34, 1),
(302.13, '2025-06-30 08:32:00', 34, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-30 13:32:00' WHERE auction_id=34;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (308.83, 20, 308.83, '2025-01-10 14:57:00', '2027-07-19 15:00:00', 'Active', 55);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(344.11, '2025-01-11 10:57:00', 35, 7),
(402.58, '2025-01-12 09:57:00', 35, 4),
(460.81, '2025-01-12 14:57:00', 35, 3),
(517.52, '2025-01-13 12:57:00', 35, 2),
(551.67, '2025-01-14 17:57:00', 35, 8),
(588.94, '2025-01-15 15:57:00', 35, 1),
(643.27, '2025-01-16 03:57:00', 35, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-16 06:57:00' WHERE auction_id=35;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (555.95, 27.8, 555.95, '2026-07-15 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 20 HOUR), 'Active', 293);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(605.17, '2026-07-18 02:00:00', 36, 4),
(642.35, '2026-07-18 08:00:00', 36, 6),
(697.76, '2026-07-18 11:00:00', 36, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (300.61, 20, 300.61, '2026-01-05 01:55:00', '2027-07-19 15:00:00', 'Active', 279);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(338.45, '2026-01-05 21:55:00', 37, 1),
(387.46, '2026-01-06 07:55:00', 37, 7),
(415.18, '2026-01-06 09:55:00', 37, 8),
(459.96, '2026-01-06 12:55:00', 37, 6),
(517.5, '2026-01-07 11:55:00', 37, 4),
(573.26, '2026-01-07 19:55:00', 37, 5),
(631.28, '2026-01-08 17:55:00', 37, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-08 18:55:00' WHERE auction_id=37;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (488.11, 24.41, 488.11, '2025-07-14 17:28:00', '2027-07-19 15:00:00', 'Active', 14);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(521.52, '2025-07-15 16:28:00', 38, 3),
(568.73, '2025-07-15 20:28:00', 38, 4),
(624.33, '2025-07-16 06:28:00', 38, 6),
(686.3, '2025-07-17 06:28:00', 38, 5),
(754.81, '2025-07-18 08:28:00', 38, 2),
(816.82, '2025-07-18 18:28:00', 38, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-18 20:28:00' WHERE auction_id=38;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (72.25, 20, 72.25, '2025-03-20 09:10:00', '2027-07-19 15:00:00', 'Active', 137);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(132.09, '2025-03-21 01:10:00', 39, 7),
(190.31, '2025-03-21 11:10:00', 39, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-21 13:10:00' WHERE auction_id=39;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (322.62, 20, 322.62, '2026-01-06 02:58:00', '2027-07-19 15:00:00', 'Active', 119);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(346.96, '2026-01-07 05:58:00', 40, 7),
(397.71, '2026-01-07 13:58:00', 40, 2),
(442.27, '2026-01-07 18:58:00', 40, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-07 22:58:00' WHERE auction_id=40;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (687.58, 34.38, 687.58, '2026-06-08 03:36:00', '2027-07-19 15:00:00', 'Active', 156);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(739.19, '2026-06-09 07:36:00', 41, 2),
(774.86, '2026-06-10 00:36:00', 41, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-10 02:36:00' WHERE auction_id=41;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (269.56, 20, 269.56, '2026-07-17 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 8 HOUR), 'Active', 60);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(299.87, '2026-07-19 14:00:00', 42, 7),
(329.43, '2026-07-19 14:42:00', 42, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (158.23, 20, 158.23, '2026-02-09 12:37:00', '2027-07-19 15:00:00', 'Active', 258);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(183.08, '2026-02-10 15:37:00', 43, 7),
(240.48, '2026-02-11 04:37:00', 43, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-11 07:37:00' WHERE auction_id=43;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (3006.02, 150.3, 3006.02, '2025-06-11 21:19:00', '2027-07-19 15:00:00', 'Active', 179);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(3217.38, '2025-06-13 03:19:00', 44, 2),
(3379.5, '2025-06-13 17:19:00', 44, 3),
(3728.42, '2025-06-14 04:19:00', 44, 5),
(4087.9, '2025-06-15 10:19:00', 44, 7),
(4270.29, '2025-06-16 10:19:00', 44, 1),
(4528.58, '2025-06-16 14:19:00', 44, 8),
(4944.98, '2025-06-17 06:19:00', 44, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-17 12:19:00' WHERE auction_id=44;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (284.42, 20, 284.42, '2025-04-28 21:56:00', '2027-07-19 15:00:00', 'Active', 7);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(323.99, '2025-04-29 05:56:00', 45, 1),
(375.7, '2025-04-30 03:56:00', 45, 6),
(408.01, '2025-04-30 22:56:00', 45, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-01 02:56:00' WHERE auction_id=45;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (323.81, 20, 323.81, '2025-03-26 23:27:00', '2027-07-19 15:00:00', 'Active', 92);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(345.52, '2025-03-27 16:27:00', 46, 6),
(373.99, '2025-03-28 14:27:00', 46, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-28 20:27:00' WHERE auction_id=46;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (147.02, 20, 147.02, '2025-05-11 01:19:00', '2027-07-19 15:00:00', 'Active', 21);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(193.17, '2025-05-12 02:19:00', 47, 3),
(249.46, '2025-05-12 23:19:00', 47, 6),
(271.29, '2025-05-13 23:19:00', 47, 5),
(317.24, '2025-05-14 01:19:00', 47, 2),
(344.13, '2025-05-14 04:19:00', 47, 1),
(400.32, '2025-05-15 08:19:00', 47, 4),
(452.07, '2025-05-16 00:19:00', 47, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-16 05:19:00' WHERE auction_id=47;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1169.66, 58.48, 1169.66, '2026-07-18 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 3 HOUR), 'Active', 180);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1247.87, '2026-07-18 13:00:00', 48, 4),
(1346.02, '2026-07-18 16:00:00', 48, 1),
(1411.56, '2026-07-18 22:00:00', 48, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (408.05, 20.4, 408.05, '2025-09-16 06:29:00', '2027-07-19 15:00:00', 'Active', 203);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(452.65, '2025-09-16 19:29:00', 49, 6),
(475.63, '2025-09-17 05:29:00', 49, 7),
(501.79, '2025-09-17 20:29:00', 49, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-17 22:29:00' WHERE auction_id=49;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (437.33, 21.87, 437.33, '2026-07-12 13:34:00', '2027-07-19 15:00:00', 'Active', 123);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(485.99, '2026-07-14 02:34:00', 50, 4),
(514.76, '2026-07-15 08:34:00', 50, 5),
(557.93, '2026-07-15 10:34:00', 50, 1),
(580.12, '2026-07-15 14:34:00', 50, 2),
(632.9, '2026-07-16 10:34:00', 50, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-16 13:34:00' WHERE auction_id=50;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (250.33, 20, 250.33, '2025-06-11 15:05:00', '2027-07-19 15:00:00', 'Active', 280);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(279.9, '2025-06-12 05:05:00', 51, 3),
(324.32, '2025-06-12 08:05:00', 51, 2),
(368.17, '2025-06-13 08:05:00', 51, 7),
(408.17, '2025-06-13 12:05:00', 51, 8),
(453.26, '2025-06-14 15:05:00', 51, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-14 18:05:00' WHERE auction_id=51;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (166.34, 20, 166.34, '2025-07-14 23:07:00', '2027-07-19 15:00:00', 'Active', 129);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(220.85, '2025-07-16 00:07:00', 52, 4),
(261.15, '2025-07-16 16:07:00', 52, 2),
(311.96, '2025-07-17 15:07:00', 52, 1),
(340.28, '2025-07-17 18:07:00', 52, 5),
(368.03, '2025-07-18 21:07:00', 52, 6),
(394.0, '2025-07-20 02:07:00', 52, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-20 06:07:00' WHERE auction_id=52;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (310.82, 20, 310.82, '2026-01-30 04:53:00', '2027-07-19 15:00:00', 'Active', 221);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(344.19, '2026-01-31 12:53:00', 53, 1),
(399.79, '2026-02-01 04:53:00', 53, 8),
(421.52, '2026-02-02 05:53:00', 53, 6),
(443.62, '2026-02-03 00:53:00', 53, 3),
(470.66, '2026-02-04 03:53:00', 53, 5),
(491.82, '2026-02-04 21:53:00', 53, 7),
(516.46, '2026-02-06 03:53:00', 53, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-06 05:53:00' WHERE auction_id=53;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (4907.92, 245.4, 4907.92, '2025-04-08 04:48:00', '2027-07-19 15:00:00', 'Active', 158);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(5535.64, '2025-04-08 20:48:00', 54, 7),
(5892.84, '2025-04-09 05:48:00', 54, 2),
(6500.33, '2025-04-10 10:48:00', 54, 6),
(6843.87, '2025-04-11 16:48:00', 54, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-11 18:48:00' WHERE auction_id=54;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (293.27, 20, 293.27, '2025-10-21 13:11:00', '2027-07-19 15:00:00', 'Active', 121);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(328.76, '2025-10-21 22:11:00', 55, 1),
(367.07, '2025-10-22 06:11:00', 55, 4),
(412.35, '2025-10-22 16:11:00', 55, 2),
(440.44, '2025-10-22 22:11:00', 55, 6),
(461.72, '2025-10-23 18:11:00', 55, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-23 19:11:00' WHERE auction_id=55;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (720.0, 36.0, 720.0, '2025-05-26 03:54:00', '2027-07-19 15:00:00', 'Active', 186);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(799.46, '2025-05-27 11:54:00', 56, 8),
(892.67, '2025-05-28 08:54:00', 56, 4),
(993.87, '2025-05-29 04:54:00', 56, 2),
(1099.72, '2025-05-30 09:54:00', 56, 3),
(1152.26, '2025-05-31 00:54:00', 56, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-31 05:54:00' WHERE auction_id=56;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1158.48, 57.92, 1158.48, '2026-07-15 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 18 HOUR), 'Active', 170);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1259.04, '2026-07-18 09:00:00', 57, 5),
(1331.31, '2026-07-18 13:00:00', 57, 1),
(1422.79, '2026-07-18 18:00:00', 57, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (231.37, 20, 231.37, '2026-07-15 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 0 HOUR), 'Active', 96);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (359.02, 20, 359.02, '2026-07-15 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 1 HOUR), 'Active', 48);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(388.93, '2026-07-18 07:00:00', 59, 7),
(420.1, '2026-07-18 08:00:00', 59, 4),
(453.96, '2026-07-18 12:00:00', 59, 6),
(492.96, '2026-07-18 14:00:00', 59, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (388.2, 20, 388.2, '2026-06-24 01:16:00', '2027-07-19 15:00:00', 'Active', 298);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(420.39, '2026-06-25 12:16:00', 60, 2),
(458.76, '2026-06-26 08:16:00', 60, 1),
(508.65, '2026-06-26 10:16:00', 60, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-26 14:16:00' WHERE auction_id=60;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (732.8, 36.64, 732.8, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 5 HOUR), 'Active', 100);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(783.54, '2026-07-19 12:00:00', 61, 1),
(832.38, '2026-07-19 13:00:00', 61, 7),
(879.89, '2026-07-19 13:32:00', 61, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (507.56, 25.38, 507.56, '2026-03-03 13:09:00', '2027-07-19 15:00:00', 'Active', 126);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(580.26, '2026-03-04 19:09:00', 62, 2),
(653.62, '2026-03-05 18:09:00', 62, 5),
(697.48, '2026-03-05 21:09:00', 62, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-05 22:09:00' WHERE auction_id=62;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (535.09, 26.75, 535.09, '2025-05-02 05:34:00', '2027-07-19 15:00:00', 'Active', 122);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(603.23, '2025-05-02 23:34:00', 63, 1),
(682.48, '2025-05-03 08:34:00', 63, 3),
(738.1, '2025-05-04 06:34:00', 63, 7),
(790.45, '2025-05-05 08:34:00', 63, 2),
(848.24, '2025-05-06 08:34:00', 63, 8),
(886.21, '2025-05-07 09:34:00', 63, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-07 11:34:00' WHERE auction_id=63;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (401.9, 20.1, 401.9, '2025-10-04 19:51:00', '2027-07-19 15:00:00', 'Active', 36);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(435.88, '2025-10-05 18:51:00', 64, 7),
(476.14, '2025-10-06 22:51:00', 64, 3),
(501.17, '2025-10-07 22:51:00', 64, 1),
(542.65, '2025-10-09 02:51:00', 64, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-09 07:51:00' WHERE auction_id=64;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2016.44, 100.82, 2016.44, '2025-06-27 17:04:00', '2027-07-19 15:00:00', 'Active', 42);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2196.04, '2025-06-28 02:04:00', 65, 2),
(2355.01, '2025-06-28 06:04:00', 65, 8),
(2477.88, '2025-06-28 16:04:00', 65, 4),
(2601.29, '2025-06-28 22:04:00', 65, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-29 02:04:00' WHERE auction_id=65;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (211.59, 20, 211.59, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 20 HOUR), 'Active', 50);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(250.22, '2026-07-18 04:00:00', 66, 7),
(277.15, '2026-07-18 08:00:00', 66, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (160.56, 20, 160.56, '2026-07-17 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 9 HOUR), 'Active', 58);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (393.3, 20, 393.3, '2026-07-16 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 16 HOUR), 'Active', 9);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(423.02, '2026-07-18 20:00:00', 68, 6),
(456.96, '2026-07-19 01:00:00', 68, 8),
(485.87, '2026-07-19 04:00:00', 68, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (144.97, 20, 144.97, '2025-04-10 12:23:00', '2027-07-19 15:00:00', 'Active', 105);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(179.85, '2025-04-11 07:23:00', 69, 3),
(230.64, '2025-04-11 10:23:00', 69, 7),
(256.57, '2025-04-11 21:23:00', 69, 8),
(294.81, '2025-04-12 04:23:00', 69, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-12 09:23:00' WHERE auction_id=69;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (657.8, 32.89, 657.8, '2026-07-17 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 5 HOUR), 'Active', 199);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(694.54, '2026-07-18 22:00:00', 70, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1012.83, 50.64, 1012.83, '2025-08-13 21:20:00', '2027-07-19 15:00:00', 'Active', 4);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1095.57, '2025-08-14 21:20:00', 71, 5),
(1161.19, '2025-08-15 13:20:00', 71, 3),
(1266.51, '2025-08-15 20:20:00', 71, 2),
(1371.2, '2025-08-16 01:20:00', 71, 6),
(1515.06, '2025-08-16 15:20:00', 71, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-16 19:20:00' WHERE auction_id=71;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (454.91, 22.75, 454.91, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 4 HOUR), 'Active', 285);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(498.04, '2026-07-18 09:00:00', 72, 6),
(535.96, '2026-07-18 14:00:00', 72, 8),
(575.28, '2026-07-18 18:00:00', 72, 7),
(605.74, '2026-07-18 19:00:00', 72, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (383.57, 20, 383.57, '2026-07-18 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 4 HOUR), 'Active', 292);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(420.39, '2026-07-17 23:00:00', 73, 1),
(447.54, '2026-07-18 02:00:00', 73, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (543.88, 27.19, 543.88, '2026-01-09 23:08:00', '2027-07-19 15:00:00', 'Active', 57);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(600.35, '2026-01-10 17:08:00', 74, 4),
(664.36, '2026-01-10 21:08:00', 74, 5),
(744.62, '2026-01-11 11:08:00', 74, 7),
(782.38, '2026-01-11 23:08:00', 74, 2),
(842.37, '2026-01-12 17:08:00', 74, 3),
(920.86, '2026-01-13 16:08:00', 74, 1),
(967.68, '2026-01-13 22:08:00', 74, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-14 04:08:00' WHERE auction_id=74;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (398.32, 20, 398.32, '2026-02-28 18:14:00', '2027-07-19 15:00:00', 'Active', 194);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(457.42, '2026-03-02 04:14:00', 75, 1),
(499.86, '2026-03-02 12:14:00', 75, 3),
(548.97, '2026-03-03 04:14:00', 75, 7),
(598.63, '2026-03-03 19:14:00', 75, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-03 23:14:00' WHERE auction_id=75;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (574.46, 28.72, 574.46, '2025-01-07 13:01:00', '2027-07-19 15:00:00', 'Active', 175);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(630.44, '2025-01-08 23:01:00', 76, 7),
(689.33, '2025-01-09 11:01:00', 76, 6),
(721.85, '2025-01-10 07:01:00', 76, 4),
(794.0, '2025-01-10 11:01:00', 76, 2),
(823.1, '2025-01-11 09:01:00', 76, 1),
(904.34, '2025-01-12 00:01:00', 76, 8),
(943.11, '2025-01-12 16:01:00', 76, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-12 22:01:00' WHERE auction_id=76;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (70.11, 20, 70.11, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 6 HOUR), 'Active', 52);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(106.57, '2026-07-19 11:00:00', 77, 5),
(143.26, '2026-07-19 14:00:00', 77, 8),
(173.14, '2026-07-19 13:51:00', 77, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (501.88, 25.09, 501.88, '2025-09-28 12:41:00', '2027-07-19 15:00:00', 'Active', 197);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(574.94, '2025-09-29 21:41:00', 78, 3),
(631.97, '2025-09-30 02:41:00', 78, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-30 08:41:00' WHERE auction_id=78;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (84.05, 20, 84.05, '2025-08-21 23:05:00', '2027-07-19 15:00:00', 'Active', 53);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(128.01, '2025-08-22 14:05:00', 79, 4),
(171.25, '2025-08-23 10:05:00', 79, 1),
(208.69, '2025-08-23 20:05:00', 79, 7),
(253.81, '2025-08-24 13:05:00', 79, 3),
(312.78, '2025-08-25 17:05:00', 79, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-25 18:05:00' WHERE auction_id=79;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (249.64, 20, 249.64, '2026-02-18 03:56:00', '2027-07-19 15:00:00', 'Active', 17);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(288.08, '2026-02-19 09:56:00', 80, 1),
(313.5, '2026-02-19 16:56:00', 80, 7),
(335.62, '2026-02-20 05:56:00', 80, 3),
(372.4, '2026-02-20 18:56:00', 80, 2),
(394.35, '2026-02-21 05:56:00', 80, 8),
(435.53, '2026-02-21 09:56:00', 80, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-21 14:56:00' WHERE auction_id=80;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (251.34, 20, 251.34, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 3 HOUR), 'Active', 46);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(285.05, '2026-07-18 23:00:00', 81, 6),
(312.3, '2026-07-19 04:00:00', 81, 7),
(343.9, '2026-07-19 06:00:00', 81, 3),
(364.16, '2026-07-19 11:00:00', 81, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (111.76, 20, 111.76, '2026-02-28 10:45:00', '2027-07-19 15:00:00', 'Active', 113);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(151.9, '2026-03-01 17:45:00', 82, 7),
(179.44, '2026-03-02 23:45:00', 82, 3),
(221.79, '2026-03-03 23:45:00', 82, 2),
(275.05, '2026-03-04 17:45:00', 82, 1),
(328.89, '2026-03-05 17:45:00', 82, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-05 22:45:00' WHERE auction_id=82;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2822.98, 141.15, 2822.98, '2025-01-17 03:59:00', '2027-07-19 15:00:00', 'Active', 161);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(3224.81, '2025-01-17 23:59:00', 83, 2),
(3464.26, '2025-01-18 23:59:00', 83, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-19 02:59:00' WHERE auction_id=83;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (320.74, 20, 320.74, '2026-07-16 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 16 HOUR), 'Active', 238);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(355.63, '2026-07-19 10:00:00', 84, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (134.81, 20, 134.81, '2025-07-01 15:57:00', '2027-07-19 15:00:00', 'Active', 252);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(171.8, '2025-07-02 19:57:00', 85, 3),
(223.16, '2025-07-02 23:57:00', 85, 6),
(243.91, '2025-07-03 16:57:00', 85, 2),
(294.2, '2025-07-03 19:57:00', 85, 8),
(322.05, '2025-07-03 22:57:00', 85, 7),
(373.77, '2025-07-04 16:57:00', 85, 1),
(417.5, '2025-07-05 09:57:00', 85, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-05 10:57:00' WHERE auction_id=85;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (327.26, 20, 327.26, '2026-04-05 07:34:00', '2027-07-19 15:00:00', 'Active', 84);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(355.48, '2026-04-06 23:34:00', 86, 1),
(383.48, '2026-04-07 22:34:00', 86, 7),
(417.54, '2026-04-08 02:34:00', 86, 8),
(443.36, '2026-04-09 03:34:00', 86, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-09 06:34:00' WHERE auction_id=86;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (737.53, 36.88, 737.53, '2026-01-12 19:14:00', '2027-07-19 15:00:00', 'Active', 118);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(781.72, '2026-01-13 17:14:00', 87, 4),
(874.9, '2026-01-14 11:14:00', 87, 5),
(927.79, '2026-01-14 19:14:00', 87, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-14 22:14:00' WHERE auction_id=87;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (84.95, 20, 84.95, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 0 HOUR), 'Active', 64);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(118.91, '2026-07-18 13:00:00', 88, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (186.97, 20, 186.97, '2026-05-11 06:15:00', '2027-07-19 15:00:00', 'Active', 110);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(246.22, '2026-05-12 03:15:00', 89, 3),
(274.79, '2026-05-12 12:15:00', 89, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-12 16:15:00' WHERE auction_id=89;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (407.64, 20.38, 407.64, '2026-07-15 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 3 HOUR), 'Active', 289);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (41.51, 20, 41.51, '2025-07-31 08:41:00', '2027-07-19 15:00:00', 'Active', 202);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(74.63, '2025-07-31 15:41:00', 91, 5),
(110.02, '2025-08-01 07:41:00', 91, 8),
(154.04, '2025-08-01 18:41:00', 91, 6),
(201.52, '2025-08-02 22:41:00', 91, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-03 02:41:00' WHERE auction_id=91;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (85.68, 20, 85.68, '2025-11-16 12:42:00', '2027-07-19 15:00:00', 'Active', 11);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(120.38, '2025-11-17 01:42:00', 92, 7),
(180.33, '2025-11-17 18:42:00', 92, 2),
(227.21, '2025-11-18 08:42:00', 92, 1),
(264.73, '2025-11-19 07:42:00', 92, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-19 13:42:00' WHERE auction_id=92;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (436.08, 21.8, 436.08, '2025-04-08 02:59:00', '2027-07-19 15:00:00', 'Active', 270);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(473.74, '2025-04-08 12:59:00', 93, 7),
(510.3, '2025-04-09 09:59:00', 93, 6),
(568.9, '2025-04-09 23:59:00', 93, 5),
(596.05, '2025-04-11 03:59:00', 93, 1),
(636.37, '2025-04-11 20:59:00', 93, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-11 23:59:00' WHERE auction_id=93;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (132.93, 20, 132.93, '2025-06-07 01:23:00', '2027-07-19 15:00:00', 'Active', 192);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(183.65, '2025-06-07 09:23:00', 94, 7),
(208.54, '2025-06-08 02:23:00', 94, 3),
(248.43, '2025-06-09 00:23:00', 94, 4),
(306.13, '2025-06-09 02:23:00', 94, 5),
(330.11, '2025-06-09 05:23:00', 94, 6),
(383.32, '2025-06-09 22:23:00', 94, 2),
(430.44, '2025-06-10 05:23:00', 94, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-10 09:23:00' WHERE auction_id=94;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (358.62, 20, 358.62, '2025-11-13 12:45:00', '2027-07-19 15:00:00', 'Active', 98);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(409.03, '2025-11-14 13:45:00', 95, 5),
(459.09, '2025-11-15 15:45:00', 95, 8),
(498.78, '2025-11-16 07:45:00', 95, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-16 09:45:00' WHERE auction_id=95;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (138.67, 20, 138.67, '2025-02-03 05:38:00', '2027-07-19 15:00:00', 'Active', 188);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(198.3, '2025-02-04 12:38:00', 96, 5),
(254.9, '2025-02-05 02:38:00', 96, 8),
(292.9, '2025-02-06 07:38:00', 96, 3),
(327.95, '2025-02-06 23:38:00', 96, 7),
(349.39, '2025-02-07 06:38:00', 96, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-07 11:38:00' WHERE auction_id=96;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (135.1, 20, 135.1, '2026-07-15 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 15 HOUR), 'Active', 290);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(164.85, '2026-07-18 11:00:00', 97, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (219.14, 20, 219.14, '2025-03-03 05:28:00', '2027-07-19 15:00:00', 'Active', 101);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(249.68, '2025-03-04 08:28:00', 98, 8),
(308.51, '2025-03-05 05:28:00', 98, 4),
(355.57, '2025-03-06 07:28:00', 98, 5),
(414.68, '2025-03-06 19:28:00', 98, 2),
(437.14, '2025-03-07 15:28:00', 98, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-07 16:28:00' WHERE auction_id=98;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1073.06, 53.65, 1073.06, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 23 HOUR), 'Active', 160);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1145.23, '2026-07-18 10:00:00', 99, 7),
(1220.98, '2026-07-18 11:00:00', 99, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (90.41, 20, 90.41, '2025-03-10 01:53:00', '2027-07-19 15:00:00', 'Active', 284);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(113.81, '2025-03-11 11:53:00', 100, 4),
(136.43, '2025-03-11 22:53:00', 100, 6),
(161.01, '2025-03-12 05:53:00', 100, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-12 06:53:00' WHERE auction_id=100;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (719.14, 35.96, 719.14, '2025-03-29 03:49:00', '2027-07-19 15:00:00', 'Active', 147);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(805.15, '2025-03-30 00:49:00', 101, 7),
(842.71, '2025-03-30 12:49:00', 101, 5),
(905.84, '2025-03-31 02:49:00', 101, 8),
(964.99, '2025-03-31 07:49:00', 101, 4),
(1059.08, '2025-03-31 12:49:00', 101, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-31 18:49:00' WHERE auction_id=101;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (140.87, 20, 140.87, '2025-09-25 05:26:00', '2027-07-19 15:00:00', 'Active', 259);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(180.75, '2025-09-26 14:26:00', 102, 6),
(239.71, '2025-09-26 18:26:00', 102, 2),
(293.33, '2025-09-27 13:26:00', 102, 5),
(321.89, '2025-09-27 23:26:00', 102, 3),
(343.79, '2025-09-28 19:26:00', 102, 8),
(379.87, '2025-09-29 04:26:00', 102, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-29 09:26:00' WHERE auction_id=102;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (423.93, 21.2, 423.93, '2026-07-16 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 3 HOUR), 'Active', 138);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(455.21, '2026-07-18 03:00:00', 103, 2),
(483.77, '2026-07-18 04:00:00', 103, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (391.87, 20, 391.87, '2026-05-03 01:40:00', '2027-07-19 15:00:00', 'Active', 135);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(419.87, '2026-05-03 21:40:00', 104, 5),
(449.92, '2026-05-04 15:40:00', 104, 4),
(488.05, '2026-05-05 17:40:00', 104, 6),
(529.95, '2026-05-06 23:40:00', 104, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-07 00:40:00' WHERE auction_id=104;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (288.64, 20, 288.64, '2026-07-17 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 15 HOUR), 'Active', 168);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(325.7, '2026-07-17 23:00:00', 105, 5),
(364.39, '2026-07-18 05:00:00', 105, 6),
(396.93, '2026-07-18 10:00:00', 105, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (227.43, 20, 227.43, '2025-06-13 03:15:00', '2027-07-19 15:00:00', 'Active', 184);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(260.18, '2025-06-14 14:15:00', 106, 3),
(316.63, '2025-06-15 12:15:00', 106, 2),
(344.77, '2025-06-16 03:15:00', 106, 7),
(375.45, '2025-06-16 14:15:00', 106, 8),
(421.29, '2025-06-17 00:15:00', 106, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-17 06:15:00' WHERE auction_id=106;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (171.88, 20, 171.88, '2026-05-02 17:10:00', '2027-07-19 15:00:00', 'Active', 10);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(201.7, '2026-05-03 22:10:00', 107, 2),
(234.12, '2026-05-04 15:10:00', 107, 8),
(276.51, '2026-05-05 06:10:00', 107, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-05 10:10:00' WHERE auction_id=107;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (505.82, 25.29, 505.82, '2026-06-24 08:52:00', '2027-07-19 15:00:00', 'Active', 134);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(558.96, '2026-06-25 17:52:00', 108, 3),
(627.37, '2026-06-26 18:52:00', 108, 1),
(677.23, '2026-06-26 20:52:00', 108, 8),
(705.32, '2026-06-28 02:52:00', 108, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-28 03:52:00' WHERE auction_id=108;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (186.53, 20, 186.53, '2026-05-22 12:15:00', '2027-07-19 15:00:00', 'Active', 28);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(232.83, '2026-05-23 03:15:00', 109, 7),
(268.71, '2026-05-24 07:15:00', 109, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-24 13:15:00' WHERE auction_id=109;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (503.18, 25.16, 503.18, '2025-04-08 05:08:00', '2027-07-19 15:00:00', 'Active', 116);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(540.32, '2025-04-08 12:08:00', 110, 2),
(604.39, '2025-04-09 00:08:00', 110, 5),
(646.12, '2025-04-09 20:08:00', 110, 6),
(708.38, '2025-04-10 23:08:00', 110, 7),
(771.2, '2025-04-11 08:08:00', 110, 3),
(843.43, '2025-04-11 16:08:00', 110, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-11 18:08:00' WHERE auction_id=110;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (65.83, 20, 65.83, '2025-09-25 20:23:00', '2027-07-19 15:00:00', 'Active', 117);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(105.44, '2025-09-26 10:23:00', 111, 8),
(153.42, '2025-09-26 15:23:00', 111, 4),
(186.08, '2025-09-27 06:23:00', 111, 3),
(225.07, '2025-09-27 15:23:00', 111, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-27 18:23:00' WHERE auction_id=111;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (87.04, 20, 87.04, '2025-11-02 13:03:00', '2027-07-19 15:00:00', 'Active', 207);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(143.74, '2025-11-04 00:03:00', 112, 6),
(173.33, '2025-11-04 19:03:00', 112, 7),
(208.72, '2025-11-05 17:03:00', 112, 3),
(267.06, '2025-11-06 06:03:00', 112, 1),
(323.19, '2025-11-07 05:03:00', 112, 5),
(348.07, '2025-11-08 10:03:00', 112, 8),
(377.53, '2025-11-09 02:03:00', 112, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-09 06:03:00' WHERE auction_id=112;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (165.98, 20, 165.98, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 8 HOUR), 'Active', 63);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (111.89, 20, 111.89, '2026-05-10 21:31:00', '2027-07-19 15:00:00', 'Active', 133);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(148.14, '2026-05-11 11:31:00', 114, 8),
(179.1, '2026-05-11 15:31:00', 114, 6),
(232.03, '2026-05-12 08:31:00', 114, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-12 12:31:00' WHERE auction_id=114;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (129.35, 20, 129.35, '2026-07-15 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 22 HOUR), 'Active', 196);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (91.15, 20, 91.15, '2025-09-05 14:07:00', '2027-07-19 15:00:00', 'Active', 102);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(112.24, '2025-09-06 05:07:00', 116, 2),
(157.89, '2025-09-06 12:07:00', 116, 3),
(203.1, '2025-09-07 15:07:00', 116, 4),
(248.74, '2025-09-07 17:07:00', 116, 5),
(284.77, '2025-09-08 15:07:00', 116, 7),
(316.99, '2025-09-09 11:07:00', 116, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-09 12:07:00' WHERE auction_id=116;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (296.14, 20, 296.14, '2026-01-01 07:42:00', '2027-07-19 15:00:00', 'Active', 187);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(351.08, '2026-01-01 21:42:00', 117, 3),
(381.51, '2026-01-02 20:42:00', 117, 7),
(425.23, '2026-01-03 08:42:00', 117, 5),
(477.21, '2026-01-03 16:42:00', 117, 4),
(500.59, '2026-01-04 05:42:00', 117, 8),
(527.87, '2026-01-05 11:42:00', 117, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-05 15:42:00' WHERE auction_id=117;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (168.01, 20, 168.01, '2025-11-25 19:44:00', '2027-07-19 15:00:00', 'Active', 143);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(195.94, '2025-11-27 03:44:00', 118, 4),
(250.01, '2025-11-27 06:44:00', 118, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-27 10:44:00' WHERE auction_id=118;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (32.6, 20, 32.6, '2025-03-30 09:48:00', '2027-07-19 15:00:00', 'Active', 239);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(57.29, '2025-03-31 19:48:00', 119, 3),
(98.32, '2025-04-01 21:48:00', 119, 1),
(155.12, '2025-04-02 13:48:00', 119, 8),
(208.21, '2025-04-03 06:48:00', 119, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-03 07:48:00' WHERE auction_id=119;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (140.84, 20, 140.84, '2026-07-16 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 8 HOUR), 'Active', 185);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(172.84, '2026-07-19 00:00:00', 120, 7),
(207.37, '2026-07-19 02:00:00', 120, 2),
(235.74, '2026-07-19 06:00:00', 120, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (24.68, 20, 24.68, '2026-07-16 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 9 HOUR), 'Active', 165);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(52.07, '2026-07-19 01:00:00', 121, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (516.86, 25.84, 516.86, '2025-04-07 03:42:00', '2027-07-19 15:00:00', 'Active', 13);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(587.74, '2025-04-08 06:42:00', 122, 1),
(634.13, '2025-04-08 14:42:00', 122, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-08 20:42:00' WHERE auction_id=122;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (86.3, 20, 86.3, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 8 HOUR), 'Active', 49);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (263.7, 20, 263.7, '2025-10-19 20:47:00', '2027-07-19 15:00:00', 'Active', 275);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(322.39, '2025-10-21 04:47:00', 124, 4),
(370.77, '2025-10-22 07:47:00', 124, 8),
(392.59, '2025-10-22 17:47:00', 124, 3),
(432.77, '2025-10-23 07:47:00', 124, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-23 10:47:00' WHERE auction_id=124;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (22001.98, 1100.1, 22001.98, '2025-04-27 12:25:00', '2027-07-19 15:00:00', 'Active', 218);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(23475.82, '2025-04-28 10:25:00', 125, 1),
(26622.83, '2025-04-29 16:25:00', 125, 5),
(28752.81, '2025-04-29 20:25:00', 125, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-29 23:25:00' WHERE auction_id=125;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (93.21, 20, 93.21, '2026-05-07 17:50:00', '2027-07-19 15:00:00', 'Active', 183);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(148.08, '2026-05-09 05:50:00', 126, 2),
(179.32, '2026-05-09 18:50:00', 126, 3),
(236.37, '2026-05-10 05:50:00', 126, 1),
(292.48, '2026-05-10 15:50:00', 126, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-10 20:50:00' WHERE auction_id=126;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (516.85, 25.84, 516.85, '2025-12-09 08:23:00', '2027-07-19 15:00:00', 'Active', 267);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(586.77, '2025-12-10 16:23:00', 127, 3),
(645.51, '2025-12-11 08:23:00', 127, 8),
(674.1, '2025-12-11 14:23:00', 127, 6),
(702.76, '2025-12-11 21:23:00', 127, 4),
(730.45, '2025-12-12 07:23:00', 127, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-12 09:23:00' WHERE auction_id=127;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (251.12, 20, 251.12, '2026-03-23 00:29:00', '2027-07-19 15:00:00', 'Active', 74);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(290.84, '2026-03-24 13:29:00', 128, 1),
(339.63, '2026-03-24 19:29:00', 128, 4),
(364.58, '2026-03-24 23:29:00', 128, 3),
(392.73, '2026-03-25 10:29:00', 128, 5),
(419.96, '2026-03-25 17:29:00', 128, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-25 23:29:00' WHERE auction_id=128;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (614.3, 30.72, 614.3, '2026-07-17 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 21 HOUR), 'Active', 260);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(673.3, '2026-07-18 10:00:00', 129, 1),
(727.62, '2026-07-18 16:00:00', 129, 5),
(761.24, '2026-07-18 19:00:00', 129, 7),
(792.76, '2026-07-19 01:00:00', 129, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (64.04, 20, 64.04, '2026-07-16 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 12 HOUR), 'Active', 43);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(85.66, '2026-07-19 13:49:00', 130, 2),
(114.74, '2026-07-19 13:34:00', 130, 7),
(147.9, '2026-07-19 14:45:00', 130, 3),
(181.02, '2026-07-19 14:09:00', 130, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (599.26, 29.96, 599.26, '2026-07-17 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 4 HOUR), 'Active', 109);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (338.56, 20, 338.56, '2025-04-27 16:32:00', '2027-07-19 15:00:00', 'Active', 76);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(373.82, '2025-04-28 16:32:00', 132, 2),
(404.03, '2025-04-29 01:32:00', 132, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-29 05:32:00' WHERE auction_id=132;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (199.15, 20, 199.15, '2025-11-15 22:32:00', '2027-07-19 15:00:00', 'Active', 200);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(245.04, '2025-11-17 01:32:00', 133, 3),
(271.21, '2025-11-17 12:32:00', 133, 4),
(310.84, '2025-11-18 03:32:00', 133, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-18 09:32:00' WHERE auction_id=133;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (204.44, 20, 204.44, '2026-07-16 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 4 HOUR), 'Active', 262);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (266.35, 20, 266.35, '2025-12-13 17:39:00', '2027-07-19 15:00:00', 'Active', 256);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(316.61, '2025-12-14 22:39:00', 135, 8),
(351.34, '2025-12-15 05:39:00', 135, 4),
(388.7, '2025-12-15 20:39:00', 135, 7),
(412.42, '2025-12-16 14:39:00', 135, 3),
(446.09, '2025-12-17 06:39:00', 135, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-17 12:39:00' WHERE auction_id=135;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (586.69, 29.33, 586.69, '2025-12-15 08:56:00', '2027-07-19 15:00:00', 'Active', 37);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(620.66, '2025-12-16 18:56:00', 136, 3),
(678.01, '2025-12-17 00:56:00', 136, 4),
(765.07, '2025-12-17 23:56:00', 136, 5),
(847.36, '2025-12-19 03:56:00', 136, 6),
(891.28, '2025-12-19 18:56:00', 136, 1),
(937.94, '2025-12-19 21:56:00', 136, 2),
(999.59, '2025-12-20 00:56:00', 136, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-20 05:56:00' WHERE auction_id=136;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (178.1, 20, 178.1, '2026-01-09 10:27:00', '2027-07-19 15:00:00', 'Active', 243);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(208.29, '2026-01-09 20:27:00', 137, 2),
(259.04, '2026-01-09 22:27:00', 137, 4),
(283.6, '2026-01-10 21:27:00', 137, 6),
(322.12, '2026-01-12 00:27:00', 137, 5),
(349.41, '2026-01-12 14:27:00', 137, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-12 15:27:00' WHERE auction_id=137;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (56.39, 20, 56.39, '2025-12-10 14:00:00', '2027-07-19 15:00:00', 'Active', 189);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(115.06, '2025-12-12 01:00:00', 138, 5),
(167.46, '2025-12-12 09:00:00', 138, 3),
(194.86, '2025-12-13 10:00:00', 138, 8),
(254.15, '2025-12-13 20:00:00', 138, 4),
(309.01, '2025-12-14 01:00:00', 138, 6),
(346.36, '2025-12-14 03:00:00', 138, 7),
(366.59, '2025-12-14 08:00:00', 138, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-14 09:00:00' WHERE auction_id=138;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (619.82, 30.99, 619.82, '2025-01-29 03:56:00', '2027-07-19 15:00:00', 'Active', 24);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(689.14, '2025-01-30 05:56:00', 139, 7),
(742.49, '2025-01-31 04:56:00', 139, 8),
(833.18, '2025-02-01 03:56:00', 139, 6),
(888.65, '2025-02-01 14:56:00', 139, 5),
(925.07, '2025-02-01 20:56:00', 139, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-01 21:56:00' WHERE auction_id=139;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (238.4, 20, 238.4, '2026-06-14 08:24:00', '2027-07-19 15:00:00', 'Active', 248);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(266.77, '2026-06-15 07:24:00', 140, 4),
(292.58, '2026-06-15 16:24:00', 140, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-15 20:24:00' WHERE auction_id=140;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (496.18, 24.81, 496.18, '2026-03-30 19:52:00', '2027-07-19 15:00:00', 'Active', 29);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(526.77, '2026-04-01 02:52:00', 141, 8),
(559.14, '2026-04-02 02:52:00', 141, 2),
(606.04, '2026-04-02 19:52:00', 141, 4),
(654.25, '2026-04-04 00:52:00', 141, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-04 04:52:00' WHERE auction_id=141;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (354.02, 20, 354.02, '2026-07-10 14:26:00', '2027-07-19 15:00:00', 'Active', 47);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(399.24, '2026-07-11 16:26:00', 142, 7),
(436.51, '2026-07-12 07:26:00', 142, 1),
(490.45, '2026-07-13 08:26:00', 142, 3),
(533.6, '2026-07-14 09:26:00', 142, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-14 14:26:00' WHERE auction_id=142;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (557.75, 27.89, 557.75, '2025-06-26 21:45:00', '2027-07-19 15:00:00', 'Active', 153);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(625.48, '2025-06-27 19:45:00', 143, 8),
(654.43, '2025-06-28 15:45:00', 143, 5),
(699.94, '2025-06-28 19:45:00', 143, 7),
(742.77, '2025-06-29 17:45:00', 143, 6),
(793.93, '2025-06-30 10:45:00', 143, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-30 11:45:00' WHERE auction_id=143;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (81.99, 20, 81.99, '2025-04-06 19:38:00', '2027-07-19 15:00:00', 'Active', 140);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(109.68, '2025-04-07 20:38:00', 144, 6),
(147.2, '2025-04-08 14:38:00', 144, 4),
(175.99, '2025-04-09 13:38:00', 144, 8),
(209.56, '2025-04-10 10:38:00', 144, 7),
(263.7, '2025-04-11 10:38:00', 144, 1),
(309.98, '2025-04-11 16:38:00', 144, 5),
(365.31, '2025-04-12 17:38:00', 144, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-12 23:38:00' WHERE auction_id=144;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (437.57, 21.88, 437.57, '2026-07-17 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 15 HOUR), 'Active', 249);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(470.02, '2026-07-17 18:00:00', 145, 4),
(496.26, '2026-07-17 23:00:00', 145, 3),
(528.91, '2026-07-18 03:00:00', 145, 6),
(571.42, '2026-07-18 07:00:00', 145, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (374.32, 20, 374.32, '2025-02-01 07:23:00', '2027-07-19 15:00:00', 'Active', 201);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(408.6, '2025-02-01 19:23:00', 146, 1),
(435.59, '2025-02-03 00:23:00', 146, 8),
(491.37, '2025-02-03 03:23:00', 146, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-03 04:23:00' WHERE auction_id=146;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (187.03, 20, 187.03, '2025-06-27 23:52:00', '2027-07-19 15:00:00', 'Active', 227);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(238.43, '2025-06-29 07:52:00', 147, 4),
(260.3, '2025-06-30 13:52:00', 147, 1),
(302.58, '2025-07-01 19:52:00', 147, 5),
(328.63, '2025-07-02 19:52:00', 147, 2),
(383.58, '2025-07-03 16:52:00', 147, 8),
(430.36, '2025-07-04 16:52:00', 147, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-04 17:52:00' WHERE auction_id=147;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (447.13, 22.36, 447.13, '2026-07-18 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 3 HOUR), 'Active', 83);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(472.13, '2026-07-17 20:00:00', 148, 1),
(514.86, '2026-07-17 22:00:00', 148, 5),
(553.51, '2026-07-18 04:00:00', 148, 8),
(585.74, '2026-07-18 09:00:00', 148, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1985.98, 99.3, 1985.98, '2025-11-17 13:47:00', '2027-07-19 15:00:00', 'Active', 217);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2151.73, '2025-11-18 01:47:00', 149, 3),
(2275.45, '2025-11-18 09:47:00', 149, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-18 13:47:00' WHERE auction_id=149;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (606.25, 30.31, 606.25, '2026-07-15 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 7 HOUR), 'Active', 255);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(639.14, '2026-07-19 03:00:00', 150, 5),
(691.13, '2026-07-19 07:00:00', 150, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (576.33, 28.82, 576.33, '2026-03-03 18:30:00', '2027-07-19 15:00:00', 'Active', 219);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(658.06, '2026-03-05 07:30:00', 151, 4),
(713.32, '2026-03-06 12:30:00', 151, 2),
(771.89, '2026-03-07 11:30:00', 151, 5),
(821.56, '2026-03-07 13:30:00', 151, 8),
(875.89, '2026-03-08 15:30:00', 151, 7),
(905.28, '2026-03-09 18:30:00', 151, 1),
(963.92, '2026-03-09 22:30:00', 151, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-09 23:30:00' WHERE auction_id=151;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (420.59, 21.03, 420.59, '2026-04-28 15:10:00', '2027-07-19 15:00:00', 'Active', 251);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(469.39, '2026-04-29 14:10:00', 152, 7),
(496.77, '2026-04-30 10:10:00', 152, 1),
(520.23, '2026-05-01 08:10:00', 152, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-01 14:10:00' WHERE auction_id=152;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (339.63, 20, 339.63, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 12 HOUR), 'Active', 240);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(377.63, '2026-07-18 22:00:00', 153, 6),
(416.04, '2026-07-19 04:00:00', 153, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (263.82, 20, 263.82, '2025-09-06 10:24:00', '2027-07-19 15:00:00', 'Active', 144);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(300.0, '2025-09-07 05:24:00', 154, 4),
(355.24, '2025-09-07 09:24:00', 154, 5),
(376.72, '2025-09-07 21:24:00', 154, 7),
(412.32, '2025-09-08 22:24:00', 154, 6),
(461.92, '2025-09-09 04:24:00', 154, 8),
(502.74, '2025-09-09 23:24:00', 154, 3),
(534.1, '2025-09-10 03:24:00', 154, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-10 08:24:00' WHERE auction_id=154;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (280.08, 20, 280.08, '2025-01-23 05:06:00', '2027-07-19 15:00:00', 'Active', 276);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(310.43, '2025-01-24 19:06:00', 155, 3),
(361.4, '2025-01-25 20:06:00', 155, 1),
(398.31, '2025-01-26 14:06:00', 155, 7),
(422.73, '2025-01-26 17:06:00', 155, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-26 20:06:00' WHERE auction_id=155;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (409.93, 20.5, 409.93, '2026-05-06 12:27:00', '2027-07-19 15:00:00', 'Active', 65);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(442.65, '2026-05-07 21:27:00', 156, 2),
(463.36, '2026-05-08 09:27:00', 156, 1),
(524.16, '2026-05-09 12:27:00', 156, 6),
(575.24, '2026-05-10 08:27:00', 156, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-10 13:27:00' WHERE auction_id=156;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (618.82, 30.94, 618.82, '2026-07-16 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 11 HOUR), 'Active', 150);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(665.84, '2026-07-18 12:00:00', 157, 3),
(700.04, '2026-07-18 17:00:00', 157, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (27.61, 20, 27.61, '2026-06-28 15:35:00', '2027-07-19 15:00:00', 'Active', 235);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(50.89, '2026-06-29 01:35:00', 158, 8),
(87.89, '2026-06-29 07:35:00', 158, 1),
(126.94, '2026-06-29 23:35:00', 158, 2),
(150.06, '2026-06-30 22:35:00', 158, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-01 03:35:00' WHERE auction_id=158;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (410.95, 20.55, 410.95, '2026-02-08 18:36:00', '2027-07-19 15:00:00', 'Active', 32);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(472.46, '2026-02-10 01:36:00', 159, 7),
(531.28, '2026-02-10 18:36:00', 159, 8),
(581.9, '2026-02-11 09:36:00', 159, 3),
(636.31, '2026-02-11 15:36:00', 159, 5),
(677.65, '2026-02-12 08:36:00', 159, 4),
(727.43, '2026-02-12 14:36:00', 159, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-12 20:36:00' WHERE auction_id=159;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (357.41, 20, 357.41, '2026-07-17 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 22 HOUR), 'Active', 268);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(396.29, '2026-07-19 03:00:00', 160, 8),
(434.72, '2026-07-19 04:00:00', 160, 1),
(466.75, '2026-07-19 08:00:00', 160, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (201.11, 20, 201.11, '2025-05-22 04:14:00', '2027-07-19 15:00:00', 'Active', 30);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(235.97, '2025-05-22 19:14:00', 161, 5),
(268.1, '2025-05-23 12:14:00', 161, 1),
(289.22, '2025-05-23 18:14:00', 161, 8),
(314.91, '2025-05-24 14:14:00', 161, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-24 18:14:00' WHERE auction_id=161;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (152.84, 20, 152.84, '2026-07-17 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 9 HOUR), 'Active', 198);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(175.29, '2026-07-19 13:00:00', 162, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (347.92, 20, 347.92, '2026-03-22 08:40:00', '2027-07-19 15:00:00', 'Active', 93);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(380.31, '2026-03-23 10:40:00', 163, 7),
(436.32, '2026-03-24 13:40:00', 163, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-24 17:40:00' WHERE auction_id=163;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (117.71, 20, 117.71, '2026-07-17 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 4 HOUR), 'Active', 22);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(155.04, '2026-07-19 04:00:00', 164, 8),
(176.83, '2026-07-19 09:00:00', 164, 7),
(210.12, '2026-07-19 13:00:00', 164, 4),
(237.86, '2026-07-19 14:07:00', 164, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (545.11, 27.26, 545.11, '2025-11-08 05:10:00', '2027-07-19 15:00:00', 'Active', 99);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(606.72, '2025-11-09 17:10:00', 165, 8),
(672.55, '2025-11-10 12:10:00', 165, 6),
(734.98, '2025-11-11 10:10:00', 165, 3),
(792.74, '2025-11-11 18:10:00', 165, 1),
(872.08, '2025-11-12 13:10:00', 165, 2),
(930.79, '2025-11-12 16:10:00', 165, 7),
(1010.24, '2025-11-13 10:10:00', 165, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-13 12:10:00' WHERE auction_id=165;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (280.06, 20, 280.06, '2025-05-02 17:48:00', '2027-07-19 15:00:00', 'Active', 41);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(307.25, '2025-05-03 04:48:00', 166, 2),
(338.25, '2025-05-03 12:48:00', 166, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-03 14:48:00' WHERE auction_id=166;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (192.49, 20, 192.49, '2026-06-14 17:46:00', '2027-07-19 15:00:00', 'Active', 266);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(229.97, '2026-06-15 14:46:00', 167, 6),
(250.93, '2026-06-16 08:46:00', 167, 4),
(283.63, '2026-06-16 18:46:00', 167, 5),
(307.27, '2026-06-16 23:46:00', 167, 1),
(348.94, '2026-06-17 10:46:00', 167, 7),
(374.7, '2026-06-17 20:46:00', 167, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-17 21:46:00' WHERE auction_id=167;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (384.73, 20, 384.73, '2025-02-28 19:25:00', '2027-07-19 15:00:00', 'Active', 204);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(433.26, '2025-03-01 07:25:00', 168, 3),
(468.86, '2025-03-01 19:25:00', 168, 1),
(494.56, '2025-03-03 01:25:00', 168, 5),
(527.53, '2025-03-03 15:25:00', 168, 8),
(585.19, '2025-03-04 21:25:00', 168, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-04 22:25:00' WHERE auction_id=168;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2065.6, 103.28, 2065.6, '2025-04-23 04:40:00', '2027-07-19 15:00:00', 'Active', 6);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2181.4, '2025-04-24 01:40:00', 169, 4),
(2398.93, '2025-04-24 05:40:00', 169, 8),
(2602.22, '2025-04-24 20:40:00', 169, 5),
(2836.36, '2025-04-26 02:40:00', 169, 6),
(2943.49, '2025-04-26 21:40:00', 169, 7),
(3245.79, '2025-04-27 20:40:00', 169, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-27 21:40:00' WHERE auction_id=169;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (56.11, 20, 56.11, '2026-07-15 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 9 HOUR), 'Active', 131);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(80.18, '2026-07-18 04:00:00', 170, 2),
(107.65, '2026-07-18 06:00:00', 170, 7),
(143.29, '2026-07-18 11:00:00', 170, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (578.78, 28.94, 578.78, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 14 HOUR), 'Active', 132);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (314.66, 20, 314.66, '2026-07-17 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 9 HOUR), 'Active', 142);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (874.22, 43.71, 874.22, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 8 HOUR), 'Active', 169);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(943.51, '2026-07-19 02:00:00', 173, 6),
(999.52, '2026-07-19 04:00:00', 173, 7),
(1075.54, '2026-07-19 09:00:00', 173, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (148.46, 20, 148.46, '2025-01-08 15:47:00', '2027-07-19 15:00:00', 'Active', 73);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(201.68, '2025-01-09 18:47:00', 174, 7),
(243.94, '2025-01-10 04:47:00', 174, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-10 08:47:00' WHERE auction_id=174;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (498.49, 24.92, 498.49, '2025-03-22 11:59:00', '2027-07-19 15:00:00', 'Active', 112);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(535.67, '2025-03-23 04:59:00', 175, 6),
(577.62, '2025-03-23 20:59:00', 175, 8),
(650.34, '2025-03-24 08:59:00', 175, 3),
(676.05, '2025-03-25 08:59:00', 175, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-25 10:59:00' WHERE auction_id=175;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (104.55, 20, 104.55, '2025-05-22 08:03:00', '2027-07-19 15:00:00', 'Active', 85);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(141.08, '2025-05-23 17:03:00', 176, 1),
(188.94, '2025-05-24 10:03:00', 176, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-24 14:03:00' WHERE auction_id=176;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (143.4, 20, 143.4, '2026-05-16 10:30:00', '2027-07-19 15:00:00', 'Active', 111);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(177.72, '2026-05-17 03:30:00', 177, 2),
(231.29, '2026-05-18 06:30:00', 177, 5),
(279.17, '2026-05-18 08:30:00', 177, 1),
(304.16, '2026-05-18 21:30:00', 177, 4),
(361.61, '2026-05-19 13:30:00', 177, 6),
(381.98, '2026-05-20 14:30:00', 177, 8),
(402.77, '2026-05-21 00:30:00', 177, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-21 06:30:00' WHERE auction_id=177;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (225.23, 20, 225.23, '2025-01-04 10:49:00', '2027-07-19 15:00:00', 'Active', 20);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(246.7, '2025-01-05 09:49:00', 178, 5),
(302.88, '2025-01-06 09:49:00', 178, 7),
(347.12, '2025-01-06 11:49:00', 178, 6),
(374.96, '2025-01-07 15:49:00', 178, 2),
(420.5, '2025-01-07 20:49:00', 178, 8),
(475.3, '2025-01-08 16:49:00', 178, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-08 21:49:00' WHERE auction_id=178;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (111.7, 20, 111.7, '2025-04-11 13:08:00', '2027-07-19 15:00:00', 'Active', 253);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(161.54, '2025-04-11 22:08:00', 179, 3),
(191.92, '2025-04-12 18:08:00', 179, 1),
(246.14, '2025-04-14 00:08:00', 179, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-14 05:08:00' WHERE auction_id=179;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (193.43, 20, 193.43, '2026-02-19 18:13:00', '2027-07-19 15:00:00', 'Active', 245);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(250.95, '2026-02-20 17:13:00', 180, 1),
(297.87, '2026-02-21 15:13:00', 180, 6),
(319.94, '2026-02-22 03:13:00', 180, 7),
(357.24, '2026-02-22 18:13:00', 180, 5),
(388.2, '2026-02-23 17:13:00', 180, 3),
(428.93, '2026-02-24 10:13:00', 180, 4),
(463.39, '2026-02-25 12:13:00', 180, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-25 13:13:00' WHERE auction_id=180;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (544.81, 27.24, 544.81, '2025-04-17 04:16:00', '2027-07-19 15:00:00', 'Active', 19);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(576.51, '2025-04-18 06:16:00', 181, 8),
(647.75, '2025-04-19 07:16:00', 181, 3),
(687.28, '2025-04-20 07:16:00', 181, 1),
(737.61, '2025-04-20 11:16:00', 181, 4),
(814.81, '2025-04-20 19:16:00', 181, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-20 21:16:00' WHERE auction_id=181;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (305.87, 20, 305.87, '2026-01-27 01:54:00', '2027-07-19 15:00:00', 'Active', 23);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(335.76, '2026-01-27 23:54:00', 182, 2),
(365.29, '2026-01-28 11:54:00', 182, 1),
(418.59, '2026-01-29 15:54:00', 182, 4),
(451.93, '2026-01-30 18:54:00', 182, 6),
(481.4, '2026-01-30 22:54:00', 182, 7),
(532.43, '2026-01-31 19:54:00', 182, 3),
(569.97, '2026-02-01 00:54:00', 182, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-01 06:54:00' WHERE auction_id=182;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (233.2, 20, 233.2, '2026-07-07 05:37:00', '2027-07-19 15:00:00', 'Active', 272);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(265.73, '2026-07-08 17:37:00', 183, 1),
(313.46, '2026-07-09 20:37:00', 183, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-09 22:37:00' WHERE auction_id=183;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (141.28, 20, 141.28, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 1 HOUR), 'Active', 254);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(162.32, '2026-07-18 03:00:00', 184, 7),
(190.35, '2026-07-18 08:00:00', 184, 1),
(225.39, '2026-07-18 10:00:00', 184, 8),
(262.68, '2026-07-18 16:00:00', 184, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (827.53, 41.38, 827.53, '2026-05-06 18:25:00', '2027-07-19 15:00:00', 'Active', 146);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(922.78, '2026-05-07 23:25:00', 185, 7),
(1028.96, '2026-05-08 15:25:00', 185, 4),
(1113.14, '2026-05-09 11:25:00', 185, 8),
(1170.45, '2026-05-09 16:25:00', 185, 5),
(1212.85, '2026-05-10 16:25:00', 185, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-10 17:25:00' WHERE auction_id=185;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (206.78, 20, 206.78, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 18 HOUR), 'Active', 54);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(235.67, '2026-07-17 21:00:00', 186, 5),
(258.42, '2026-07-17 22:00:00', 186, 3),
(279.63, '2026-07-18 01:00:00', 186, 4),
(311.32, '2026-07-18 06:00:00', 186, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2084.61, 104.23, 2084.61, '2026-07-17 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 9 HOUR), 'Active', 40);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2251.73, '2026-07-18 18:00:00', 187, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (12.49, 20, 12.49, '2025-09-14 04:53:00', '2027-07-19 15:00:00', 'Active', 230);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(52.77, '2025-09-15 12:53:00', 188, 3),
(95.15, '2025-09-15 15:53:00', 188, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-15 19:53:00' WHERE auction_id=188;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (7.72, 20, 7.72, '2025-06-07 21:28:00', '2027-07-19 15:00:00', 'Active', 94);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(35.29, '2025-06-08 20:28:00', 189, 4),
(83.08, '2025-06-09 12:28:00', 189, 7),
(127.07, '2025-06-10 00:28:00', 189, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-10 05:28:00' WHERE auction_id=189;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (119.95, 20, 119.95, '2026-07-15 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 9 HOUR), 'Active', 174);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(157.47, '2026-07-18 06:00:00', 190, 3),
(187.39, '2026-07-18 07:00:00', 190, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (48.68, 20, 48.68, '2026-06-11 03:24:00', '2027-07-19 15:00:00', 'Active', 233);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(83.72, '2026-06-12 05:24:00', 191, 4),
(111.09, '2026-06-12 07:24:00', 191, 8),
(145.6, '2026-06-12 11:24:00', 191, 5),
(179.92, '2026-06-13 06:24:00', 191, 2),
(204.53, '2026-06-13 17:24:00', 191, 6),
(242.15, '2026-06-14 15:24:00', 191, 7),
(285.58, '2026-06-15 17:24:00', 191, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-15 20:24:00' WHERE auction_id=191;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (13.3, 20, 13.3, '2026-07-16 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 6 HOUR), 'Active', 297);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(47.68, '2026-07-18 21:00:00', 192, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (75.42, 20, 75.42, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 5 HOUR), 'Active', 208);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (49.68, 20, 49.68, '2026-07-17 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 0 HOUR), 'Active', 136);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(78.8, '2026-07-18 18:00:00', 194, 2),
(114.99, '2026-07-19 00:00:00', 194, 3),
(138.42, '2026-07-19 05:00:00', 194, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (223.6, 20, 223.6, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 13 HOUR), 'Active', 274);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (783.14, 39.16, 783.14, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 6 HOUR), 'Active', 220);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(839.12, '2026-07-18 02:00:00', 196, 7),
(887.86, '2026-07-18 03:00:00', 196, 6),
(956.9, '2026-07-18 08:00:00', 196, 3),
(1003.47, '2026-07-18 13:00:00', 196, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (101.47, 20, 101.47, '2025-06-28 19:36:00', '2027-07-19 15:00:00', 'Active', 26);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(153.29, '2025-06-30 11:36:00', 197, 6),
(178.35, '2025-07-01 05:36:00', 197, 2),
(237.09, '2025-07-02 11:36:00', 197, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-02 15:36:00' WHERE auction_id=197;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (310.4, 20, 310.4, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 21 HOUR), 'Active', 1);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(345.42, '2026-07-17 20:00:00', 198, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (302.06, 20, 302.06, '2025-06-26 01:15:00', '2027-07-19 15:00:00', 'Active', 80);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(360.29, '2025-06-27 06:15:00', 199, 3),
(391.02, '2025-06-27 20:15:00', 199, 8),
(436.54, '2025-06-28 23:15:00', 199, 6),
(479.9, '2025-06-29 02:15:00', 199, 7),
(508.19, '2025-06-30 08:15:00', 199, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-30 10:15:00' WHERE auction_id=199;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1251.61, 62.58, 1251.61, '2026-07-16 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 6 HOUR), 'Active', 33);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1330.12, '2026-07-18 12:00:00', 200, 7),
(1401.11, '2026-07-18 13:00:00', 200, 5),
(1482.15, '2026-07-18 18:00:00', 200, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (47.66, 20, 47.66, '2025-12-19 19:16:00', '2027-07-19 15:00:00', 'Active', 2);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(86.36, '2025-12-20 18:16:00', 201, 1),
(121.06, '2025-12-21 11:16:00', 201, 4),
(153.74, '2025-12-22 01:16:00', 201, 5),
(174.73, '2025-12-22 17:16:00', 201, 6),
(204.08, '2025-12-23 15:16:00', 201, 3),
(227.12, '2025-12-24 21:16:00', 201, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-24 22:16:00' WHERE auction_id=201;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (92.85, 20, 92.85, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 17 HOUR), 'Active', 59);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(114.28, '2026-07-19 04:00:00', 202, 4),
(145.2, '2026-07-19 07:00:00', 202, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (267.43, 20, 267.43, '2026-06-17 19:33:00', '2027-07-19 15:00:00', 'Active', 211);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(315.66, '2026-06-18 05:33:00', 203, 5),
(375.6, '2026-06-19 07:33:00', 203, 3),
(424.25, '2026-06-20 02:33:00', 203, 6),
(480.75, '2026-06-20 04:33:00', 203, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-20 07:33:00' WHERE auction_id=203;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2201.38, 110.07, 2201.38, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 12 HOUR), 'Active', 164);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2336.43, '2026-07-19 02:00:00', 204, 3),
(2469.6, '2026-07-19 04:00:00', 204, 7),
(2636.45, '2026-07-19 09:00:00', 204, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (105.95, 20, 105.95, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 10 HOUR), 'Active', 228);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(130.14, '2026-07-18 12:00:00', 205, 4),
(167.2, '2026-07-18 13:00:00', 205, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (506.79, 25.34, 506.79, '2025-07-15 01:17:00', '2027-07-19 15:00:00', 'Active', 128);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(549.35, '2025-07-15 22:17:00', 206, 3),
(596.27, '2025-07-17 00:17:00', 206, 8),
(642.05, '2025-07-18 02:17:00', 206, 6),
(702.39, '2025-07-18 13:17:00', 206, 1),
(744.26, '2025-07-18 15:17:00', 206, 4),
(798.36, '2025-07-18 18:17:00', 206, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-18 20:17:00' WHERE auction_id=206;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (108.76, 20, 108.76, '2026-07-15 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 18 HOUR), 'Active', 296);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(136.49, '2026-07-18 04:00:00', 207, 4),
(158.66, '2026-07-18 09:00:00', 207, 8),
(197.9, '2026-07-18 15:00:00', 207, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (267.62, 20, 267.62, '2026-07-18 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 5 HOUR), 'Active', 191);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(288.16, '2026-07-18 05:00:00', 208, 3),
(309.55, '2026-07-18 09:00:00', 208, 1),
(335.23, '2026-07-18 11:00:00', 208, 6),
(361.05, '2026-07-18 16:00:00', 208, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (294.79, 20, 294.79, '2026-05-04 00:22:00', '2027-07-19 15:00:00', 'Active', 31);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(321.66, '2026-05-05 06:22:00', 209, 6),
(378.05, '2026-05-05 20:22:00', 209, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-05 22:22:00' WHERE auction_id=209;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (362.77, 20, 362.77, '2025-08-19 05:28:00', '2027-07-19 15:00:00', 'Active', 190);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(417.59, '2025-08-19 19:28:00', 210, 8),
(454.88, '2025-08-20 19:28:00', 210, 6),
(501.47, '2025-08-21 02:28:00', 210, 1),
(545.62, '2025-08-21 13:28:00', 210, 4),
(589.12, '2025-08-22 07:28:00', 210, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-22 13:28:00' WHERE auction_id=210;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (24.73, 20, 24.73, '2025-02-11 23:04:00', '2027-07-19 15:00:00', 'Active', 286);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(77.71, '2025-02-12 22:04:00', 211, 3),
(130.01, '2025-02-13 16:04:00', 211, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-13 19:04:00' WHERE auction_id=211;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (166.38, 20, 166.38, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 14 HOUR), 'Active', 278);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1234.43, 61.72, 1234.43, '2025-11-12 23:55:00', '2027-07-19 15:00:00', 'Active', 107);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1397.79, '2025-11-14 14:55:00', 213, 6),
(1481.13, '2025-11-14 23:55:00', 213, 8),
(1565.02, '2025-11-15 20:55:00', 213, 7),
(1717.25, '2025-11-16 12:55:00', 213, 3),
(1826.45, '2025-11-17 11:55:00', 213, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-17 13:55:00' WHERE auction_id=213;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (269.65, 20, 269.65, '2026-06-15 11:24:00', '2027-07-19 15:00:00', 'Active', 247);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(318.71, '2026-06-17 05:24:00', 214, 1),
(347.4, '2026-06-17 22:24:00', 214, 2),
(383.85, '2026-06-19 00:24:00', 214, 7),
(425.96, '2026-06-19 13:24:00', 214, 3),
(449.02, '2026-06-19 18:24:00', 214, 5),
(489.2, '2026-06-20 20:24:00', 214, 4),
(522.24, '2026-06-21 12:24:00', 214, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-21 14:24:00' WHERE auction_id=214;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (335.59, 20, 335.59, '2025-02-17 20:53:00', '2027-07-19 15:00:00', 'Active', 226);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(381.14, '2025-02-18 21:53:00', 215, 8),
(431.13, '2025-02-19 11:53:00', 215, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-19 14:53:00' WHERE auction_id=215;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (804.8, 40.24, 804.8, '2026-07-18 15:00:00', (NOW() + INTERVAL 4 DAY + INTERVAL 1 HOUR), 'Active', 182);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(858.2, '2026-07-19 08:00:00', 216, 2),
(917.12, '2026-07-19 12:00:00', 216, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (205.35, 20, 205.35, '2026-04-21 18:48:00', '2027-07-19 15:00:00', 'Active', 77);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(232.17, '2026-04-21 23:48:00', 217, 4),
(276.45, '2026-04-22 06:48:00', 217, 6),
(308.22, '2026-04-23 01:48:00', 217, 8),
(357.88, '2026-04-23 08:48:00', 217, 2),
(380.98, '2026-04-24 10:48:00', 217, 7),
(401.43, '2026-04-24 20:48:00', 217, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-24 22:48:00' WHERE auction_id=217;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (306.55, 20, 306.55, '2025-08-25 12:32:00', '2027-07-19 15:00:00', 'Active', 299);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(344.23, '2025-08-25 19:32:00', 218, 1),
(397.69, '2025-08-26 22:32:00', 218, 6),
(438.6, '2025-08-27 21:32:00', 218, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-28 03:32:00' WHERE auction_id=218;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (416.47, 20.82, 416.47, '2025-05-17 01:22:00', '2027-07-19 15:00:00', 'Active', 90);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(469.45, '2025-05-18 04:22:00', 219, 8),
(498.67, '2025-05-18 13:22:00', 219, 1),
(535.09, '2025-05-18 22:22:00', 219, 5),
(564.24, '2025-05-19 00:22:00', 219, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-19 04:22:00' WHERE auction_id=219;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (158.48, 20, 158.48, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 6 HOUR), 'Active', 261);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(181.84, '2026-07-17 18:00:00', 220, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (423.96, 21.2, 423.96, '2026-03-17 23:20:00', '2027-07-19 15:00:00', 'Active', 288);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(484.78, '2026-03-18 17:20:00', 221, 2),
(545.79, '2026-03-18 22:20:00', 221, 7),
(576.84, '2026-03-19 03:20:00', 221, 3),
(613.16, '2026-03-19 10:20:00', 221, 6),
(635.0, '2026-03-20 08:20:00', 221, 8),
(669.61, '2026-03-20 22:20:00', 221, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-21 00:20:00' WHERE auction_id=221;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (70.26, 20, 70.26, '2025-10-17 00:58:00', '2027-07-19 15:00:00', 'Active', 236);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(102.32, '2025-10-18 04:58:00', 222, 5),
(142.3, '2025-10-18 09:58:00', 222, 6),
(190.8, '2025-10-19 12:58:00', 222, 8),
(250.42, '2025-10-20 17:58:00', 222, 3),
(293.19, '2025-10-21 03:58:00', 222, 1),
(351.55, '2025-10-22 00:58:00', 222, 4),
(384.52, '2025-10-22 22:58:00', 222, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-23 04:58:00' WHERE auction_id=222;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (174.79, 20, 174.79, '2026-05-14 16:42:00', '2027-07-19 15:00:00', 'Active', 72);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(219.13, '2026-05-15 13:42:00', 223, 3),
(257.09, '2026-05-16 07:42:00', 223, 8),
(302.71, '2026-05-16 16:42:00', 223, 2),
(342.85, '2026-05-17 16:42:00', 223, 7),
(402.39, '2026-05-18 01:42:00', 223, 4),
(423.24, '2026-05-19 03:42:00', 223, 1),
(479.11, '2026-05-19 14:42:00', 223, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-19 16:42:00' WHERE auction_id=223;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1702.88, 85.14, 1702.88, '2026-07-18 15:00:00', (NOW() + INTERVAL 5 DAY + INTERVAL 2 HOUR), 'Active', 27);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1813.27, '2026-07-18 05:00:00', 224, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (265.73, 20, 265.73, '2025-04-19 20:36:00', '2027-07-19 15:00:00', 'Active', 287);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(296.86, '2025-04-20 21:36:00', 225, 1),
(348.34, '2025-04-21 00:36:00', 225, 2),
(389.17, '2025-04-21 15:36:00', 225, 6),
(435.09, '2025-04-22 02:36:00', 225, 5),
(485.11, '2025-04-22 11:36:00', 225, 4),
(538.99, '2025-04-22 23:36:00', 225, 3),
(572.7, '2025-04-23 07:36:00', 225, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-23 12:36:00' WHERE auction_id=225;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1030.14, 51.51, 1030.14, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 21 HOUR), 'Active', 173);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1114.09, '2026-07-18 07:00:00', 226, 7),
(1210.41, '2026-07-18 08:00:00', 226, 5),
(1311.04, '2026-07-18 09:00:00', 226, 3),
(1395.23, '2026-07-18 11:00:00', 226, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (987.08, 49.35, 987.08, '2026-07-17 15:00:00', (NOW() + INTERVAL 2 DAY + INTERVAL 2 HOUR), 'Active', 115);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1072.21, '2026-07-18 10:00:00', 227, 4),
(1129.66, '2026-07-18 12:00:00', 227, 2),
(1191.1, '2026-07-18 14:00:00', 227, 5),
(1270.35, '2026-07-18 17:00:00', 227, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (557.86, 27.89, 557.86, '2026-06-04 19:12:00', '2027-07-19 15:00:00', 'Active', 8);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(606.82, '2026-06-05 19:12:00', 228, 4),
(659.33, '2026-06-06 13:12:00', 228, 3),
(721.21, '2026-06-07 04:12:00', 228, 8),
(791.51, '2026-06-08 08:12:00', 228, 1),
(872.6, '2026-06-09 01:12:00', 228, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-09 02:12:00' WHERE auction_id=228;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (455.96, 22.8, 455.96, '2025-10-12 05:37:00', '2027-07-19 15:00:00', 'Active', 45);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(485.73, '2025-10-13 15:37:00', 229, 5),
(516.54, '2025-10-14 05:37:00', 229, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-14 09:37:00' WHERE auction_id=229;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (455.56, 22.78, 455.56, '2026-05-27 12:56:00', '2027-07-19 15:00:00', 'Active', 5);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(485.39, '2026-05-28 00:56:00', 230, 8),
(508.36, '2026-05-29 05:56:00', 230, 1),
(553.95, '2026-05-30 06:56:00', 230, 3),
(593.78, '2026-05-30 20:56:00', 230, 2),
(658.73, '2026-05-31 10:56:00', 230, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-31 16:56:00' WHERE auction_id=230;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (834.28, 41.71, 834.28, '2025-10-13 18:14:00', '2027-07-19 15:00:00', 'Active', 69);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(953.75, '2025-10-14 08:14:00', 231, 2),
(1011.66, '2025-10-14 23:14:00', 231, 4),
(1133.21, '2025-10-16 01:14:00', 231, 1),
(1251.09, '2025-10-17 02:14:00', 231, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-17 05:14:00' WHERE auction_id=231;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (442.03, 22.1, 442.03, '2026-07-18 15:00:00', (NOW() + INTERVAL 3 DAY + INTERVAL 22 HOUR), 'Active', 66);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(474.69, '2026-07-18 22:00:00', 232, 7),
(510.73, '2026-07-19 04:00:00', 232, 6),
(533.45, '2026-07-19 10:00:00', 232, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (283.57, 20, 283.57, '2026-02-25 00:15:00', '2027-07-19 15:00:00', 'Active', 250);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(327.66, '2026-02-26 03:15:00', 233, 8),
(381.32, '2026-02-26 05:15:00', 233, 6),
(405.99, '2026-02-26 09:15:00', 233, 2),
(451.77, '2026-02-26 23:15:00', 233, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-27 03:15:00' WHERE auction_id=233;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (929.84, 46.49, 929.84, '2026-07-17 15:00:00', (NOW() + INTERVAL 1 DAY + INTERVAL 16 HOUR), 'Active', 209);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1008.49, '2026-07-18 23:00:00', 234, 3),
(1099.97, '2026-07-19 05:00:00', 234, 7),
(1187.68, '2026-07-19 10:00:00', 234, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (9611.57, 480.58, 9611.57, '2025-09-12 07:44:00', '2027-07-19 15:00:00', 'Active', 210);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(10350.72, '2025-09-12 18:44:00', 235, 2),
(11725.2, '2025-09-13 08:44:00', 235, 1),
(12877.64, '2025-09-13 10:44:00', 235, 6),
(14306.91, '2025-09-14 14:44:00', 235, 5),
(15260.11, '2025-09-14 19:44:00', 235, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-14 20:44:00' WHERE auction_id=235;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (628.13, 31.41, 628.13, '2025-10-11 23:37:00', '2027-07-19 15:00:00', 'Active', 39);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(667.98, '2025-10-13 04:37:00', 236, 5),
(710.82, '2025-10-13 09:37:00', 236, 6),
(770.54, '2025-10-14 13:37:00', 236, 4),
(815.3, '2025-10-14 21:37:00', 236, 2),
(850.42, '2025-10-15 04:37:00', 236, 8),
(932.66, '2025-10-15 12:37:00', 236, 7),
(980.36, '2025-10-16 18:37:00', 236, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-16 22:37:00' WHERE auction_id=236;
-- (Auctions seeded: 236; ~70% historical/closed with a declared winner, ~30% currently Active)

-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
INSERT INTO ORDERS (order_date, status, listing_id, buyer_id, seller_id) VALUES
('2025-11-19 21:50:00', 'Out for Delivery', 206, 1, 2),
((NOW() - INTERVAL 3 HOUR), 'Preparing', 205, 1, 4),
((NOW() - INTERVAL 25 HOUR), 'Preparing', 38, 2, 4),
('2026-07-17 02:00:00', 'Out for Delivery', 265, 5, 5),
('2026-02-02 06:41:00', 'Out for Delivery', 295, 7, 2),
((NOW() - INTERVAL 26 HOUR), 'Preparing', 62, 6, 4),
('2025-07-16 06:19:00', 'Cancelled', 34, 7, 2),
('2026-07-19 14:00:00', 'Delivered', 103, 6, 3),
('2025-10-01 00:31:00', 'Delivered', 257, 7, 4),
('2026-07-18 03:00:00', 'Cancelled', 127, 2, 3),
('2025-05-12 09:02:00', 'Shipped', 44, 4, 3),
('2025-11-22 14:48:00', 'Shipped', 91, 8, 1),
('2026-07-19 12:00:00', 'Shipped', 25, 1, 4),
('2026-07-17 21:00:00', 'Shipped', 120, 1, 5),
('2025-05-19 22:04:00', 'Delivered', 12, 4, 5),
((NOW() - INTERVAL 31 HOUR), 'Preparing', 193, 2, 6),
('2026-02-07 15:03:00', 'Delivered', 88, 2, 6),
((NOW() - INTERVAL 33 HOUR), 'Preparing', 155, 4, 2),
((NOW() - INTERVAL 20 HOUR), 'Preparing', 157, 1, 1),
('2025-12-11 00:41:00', 'Cancelled', 269, 8, 6),
('2026-04-09 07:41:00', 'Delivered', 79, 8, 3),
('2026-07-18 04:00:00', 'Delivered', 223, 1, 5),
('2026-05-09 21:08:00', 'Delivered', 163, 8, 3),
('2026-06-11 08:02:00', 'Out for Delivery', 172, 3, 2),
('2025-12-01 23:29:00', 'Shipped', 282, 3, 6),
('2026-01-05 02:48:00', 'Delivered', 68, 5, 2),
('2025-06-13 10:48:00', 'Delivered', 71, 7, 3),
('2025-07-25 05:25:00', 'Out for Delivery', 294, 1, 1),
('2026-03-21 08:56:00', 'Delivered', 104, 1, 4),
((NOW() - INTERVAL 25 HOUR), 'Preparing', 273, 7, 1),
('2025-02-02 12:47:00', 'Out for Delivery', 70, 8, 6),
('2026-05-23 03:52:00', 'Delivered', 225, 4, 4),
('2026-01-10 14:27:00', 'Delivered', 75, 5, 3),
('2025-12-15 03:21:00', 'Delivered', 81, 7, 5),
((NOW() - INTERVAL 8 HOUR), 'Preparing', 166, 6, 5),
('2025-02-15 15:34:00', 'Shipped', 35, 7, 6),
((NOW() - INTERVAL 32 HOUR), 'Preparing', 277, 7, 1),
('2026-03-06 16:06:00', 'Delivered', 61, 5, 1),
('2026-01-13 08:15:00', 'Out for Delivery', 283, 2, 3),
((NOW() - INTERVAL 37 HOUR), 'Preparing', 16, 2, 2),
('2026-01-15 13:43:00', 'Out for Delivery', 167, 4, 2),
('2025-11-05 02:02:00', 'Shipped', 215, 2, 5),
('2025-02-23 05:24:00', 'Shipped', 231, 2, 4),
('2025-06-30 21:32:00', 'Delivered', 97, 2, 5),
('2025-01-16 15:57:00', 'Out for Delivery', 55, 5, 2),
('2026-01-08 22:55:00', 'Out for Delivery', 279, 3, 4),
('2025-07-18 23:28:00', 'Delivered', 14, 1, 1),
('2025-03-22 04:10:00', 'Shipped', 137, 4, 1),
('2026-01-08 07:58:00', 'Shipped', 119, 6, 6),
((NOW() - INTERVAL 15 HOUR), 'Preparing', 156, 5, 1),
('2026-02-11 17:37:00', 'Delivered', 258, 6, 5),
('2025-06-17 19:19:00', 'Delivered', 179, 6, 2),
('2025-05-01 03:56:00', 'Delivered', 7, 5, 5),
('2025-03-29 13:27:00', 'Delivered', 92, 7, 1),
('2025-05-16 11:19:00', 'Out for Delivery', 21, 8, 6),
((NOW() - INTERVAL 8 HOUR), 'Preparing', 203, 2, 2),
('2026-07-17 03:34:00', 'Shipped', 123, 6, 6),
('2025-06-15 06:05:00', 'Delivered', 280, 4, 2),
('2025-07-20 22:07:00', 'Delivered', 129, 3, 1),
('2026-02-06 20:53:00', 'Delivered', 221, 2, 5),
('2025-04-11 21:48:00', 'Out for Delivery', 158, 3, 1),
('2025-10-24 04:11:00', 'Delivered', 121, 7, 1),
('2025-05-31 21:54:00', 'Shipped', 186, 6, 2),
('2026-06-27 05:16:00', 'Delivered', 298, 4, 2),
('2026-03-06 11:09:00', 'Delivered', 126, 3, 1),
('2025-05-07 22:34:00', 'Delivered', 122, 6, 4),
('2025-10-09 17:51:00', 'Out for Delivery', 36, 6, 4),
((NOW() - INTERVAL 9 HOUR), 'Preparing', 42, 1, 5),
('2025-04-12 15:23:00', 'Delivered', 105, 2, 1),
('2025-08-17 00:20:00', 'Shipped', 4, 1, 6),
('2026-01-14 18:08:00', 'Delivered', 57, 8, 5),
('2026-03-04 09:14:00', 'Delivered', 194, 6, 4),
('2025-01-13 17:01:00', 'Delivered', 175, 3, 6),
('2025-09-30 18:41:00', 'Delivered', 197, 8, 5),
('2025-08-26 06:05:00', 'Delivered', 53, 8, 5),
((NOW() - INTERVAL 15 HOUR), 'Preparing', 17, 4, 5),
('2026-03-06 02:45:00', 'Delivered', 113, 6, 3),
('2025-01-19 07:59:00', 'Delivered', 161, 7, 4),
('2025-07-05 19:57:00', 'Shipped', 252, 5, 2),
('2026-04-10 01:34:00', 'Delivered', 84, 6, 2),
('2026-01-15 04:14:00', 'Shipped', 118, 7, 6),
((NOW() - INTERVAL 3 HOUR), 'Preparing', 110, 7, 3),
('2025-08-03 10:41:00', 'Shipped', 202, 1, 2),
('2025-11-19 16:42:00', 'Delivered', 11, 4, 5),
('2025-04-12 18:59:00', 'Cancelled', 270, 2, 6),
('2025-06-11 05:23:00', 'Delivered', 192, 8, 3),
('2025-11-16 19:45:00', 'Cancelled', 98, 7, 2),
('2025-02-07 21:38:00', 'Out for Delivery', 188, 1, 6),
('2025-03-07 21:28:00', 'Delivered', 101, 1, 6),
((NOW() - INTERVAL 32 HOUR), 'Preparing', 284, 3, 6),
('2025-04-01 01:49:00', 'Delivered', 147, 3, 6),
('2025-09-29 12:26:00', 'Cancelled', 259, 7, 6),
('2026-05-07 17:40:00', 'Delivered', 135, 8, 4),
((NOW() - INTERVAL 10 HOUR), 'Preparing', 184, 4, 1),
((NOW() - INTERVAL 14 HOUR), 'Preparing', 10, 7, 6),
((NOW() - INTERVAL 15 HOUR), 'Preparing', 134, 6, 5),
('2026-05-24 18:15:00', 'Out for Delivery', 28, 3, 1),
('2025-04-11 22:08:00', 'Delivered', 116, 8, 6),
((NOW() - INTERVAL 12 HOUR), 'Preparing', 117, 5, 2),
((NOW() - INTERVAL 26 HOUR), 'Preparing', 207, 4, 4),
('2026-05-13 02:31:00', 'Delivered', 133, 3, 1),
((NOW() - INTERVAL 11 HOUR), 'Preparing', 102, 8, 2),
('2026-01-06 10:42:00', 'Cancelled', 187, 2, 3),
('2025-11-28 06:44:00', 'Delivered', 143, 1, 4),
('2025-04-03 15:48:00', 'Delivered', 239, 2, 6),
('2025-04-09 09:42:00', 'Shipped', 13, 4, 6),
('2025-10-23 23:47:00', 'Cancelled', 275, 5, 4),
('2025-04-30 16:25:00', 'Out for Delivery', 218, 2, 1),
('2026-05-11 05:50:00', 'Delivered', 183, 8, 4),
('2025-12-13 00:23:00', 'Delivered', 267, 2, 1),
('2026-03-26 16:29:00', 'Delivered', 74, 7, 2),
('2025-04-29 08:32:00', 'Out for Delivery', 76, 5, 4),
('2025-11-18 19:32:00', 'Delivered', 200, 7, 3),
((NOW() - INTERVAL 26 HOUR), 'Preparing', 256, 6, 5),
('2025-12-20 09:56:00', 'Delivered', 37, 8, 1),
('2026-01-12 18:27:00', 'Delivered', 243, 3, 6),
((NOW() - INTERVAL 4 HOUR), 'Preparing', 189, 2, 2),
((NOW() - INTERVAL 20 HOUR), 'Preparing', 24, 4, 2),
('2026-06-16 14:24:00', 'Delivered', 248, 7, 6),
('2026-04-04 23:52:00', 'Delivered', 29, 6, 2),
('2026-07-15 00:26:00', 'Delivered', 47, 8, 3),
('2025-07-01 03:45:00', 'Out for Delivery', 153, 4, 1),
('2025-04-13 12:38:00', 'Delivered', 140, 2, 4),
('2025-02-03 15:23:00', 'Delivered', 201, 3, 1),
('2025-07-05 08:52:00', 'Delivered', 227, 6, 4),
('2025-11-19 03:47:00', 'Out for Delivery', 217, 6, 3),
('2026-03-10 10:30:00', 'Out for Delivery', 219, 6, 2),
('2026-05-02 07:10:00', 'Delivered', 251, 4, 5),
('2025-09-11 02:24:00', 'Out for Delivery', 144, 2, 3),
('2025-01-27 05:06:00', 'Shipped', 276, 5, 2),
('2026-05-11 07:27:00', 'Shipped', 65, 7, 5),
('2026-07-01 16:35:00', 'Cancelled', 235, 4, 2),
('2026-02-13 13:36:00', 'Delivered', 32, 6, 3),
('2025-05-24 20:14:00', 'Cancelled', 30, 2, 2),
('2026-03-25 09:40:00', 'Delivered', 93, 4, 1),
((NOW() - INTERVAL 4 HOUR), 'Preparing', 99, 5, 6),
('2025-05-04 09:48:00', 'Delivered', 41, 6, 1),
('2026-06-18 02:46:00', 'Cancelled', 266, 8, 5),
('2025-03-05 00:25:00', 'Delivered', 204, 2, 6),
('2025-04-28 05:40:00', 'Delivered', 6, 1, 3),
('2025-01-10 15:47:00', 'Cancelled', 73, 6, 2),
('2025-03-25 11:59:00', 'Shipped', 112, 4, 6),
('2025-05-25 08:03:00', 'Shipped', 85, 6, 6),
('2026-05-21 18:30:00', 'Cancelled', 111, 3, 3),
('2025-01-09 13:49:00', 'Shipped', 20, 4, 5),
('2025-04-14 14:08:00', 'Delivered', 253, 5, 6),
('2026-02-25 21:13:00', 'Delivered', 245, 2, 6),
('2025-04-21 08:16:00', 'Delivered', 19, 2, 2),
('2026-02-01 21:54:00', 'Delivered', 23, 8, 1),
('2026-07-10 00:37:00', 'Out for Delivery', 272, 8, 5),
('2026-05-11 12:25:00', 'Cancelled', 146, 1, 2),
('2025-09-16 07:53:00', 'Shipped', 230, 1, 6),
('2025-06-11 00:28:00', 'Delivered', 94, 1, 6),
('2026-06-15 22:24:00', 'Out for Delivery', 233, 3, 2),
((NOW() - INTERVAL 6 HOUR), 'Preparing', 26, 1, 3),
('2025-07-01 01:15:00', 'Out for Delivery', 80, 4, 4),
((NOW() - INTERVAL 25 HOUR), 'Preparing', 2, 2, 3),
('2026-06-20 17:33:00', 'Delivered', 211, 7, 5),
('2025-07-19 01:17:00', 'Shipped', 128, 7, 2),
('2026-05-06 02:22:00', 'Delivered', 31, 5, 3),
('2025-08-23 04:28:00', 'Delivered', 190, 2, 1),
('2025-02-14 14:04:00', 'Delivered', 286, 4, 3),
('2025-11-18 08:55:00', 'Delivered', 107, 4, 4),
('2026-06-21 23:24:00', 'Shipped', 247, 8, 5),
('2025-02-20 03:53:00', 'Delivered', 226, 1, 4),
('2026-04-25 13:48:00', 'Delivered', 77, 5, 1),
('2025-08-28 07:32:00', 'Shipped', 299, 5, 1),
('2025-05-19 05:22:00', 'Shipped', 90, 7, 6),
('2026-03-21 15:20:00', 'Delivered', 288, 5, 5),
('2025-10-23 17:58:00', 'Out for Delivery', 236, 7, 1),
((NOW() - INTERVAL 12 HOUR), 'Preparing', 72, 6, 3),
('2025-04-23 14:36:00', 'Delivered', 287, 7, 2),
('2026-06-09 15:12:00', 'Cancelled', 8, 7, 3),
('2025-10-14 19:37:00', 'Out for Delivery', 45, 8, 6),
('2026-06-01 04:56:00', 'Delivered', 5, 4, 3),
('2025-10-17 22:14:00', 'Delivered', 69, 6, 3),
('2026-02-27 22:15:00', 'Delivered', 250, 3, 3),
('2025-09-15 10:44:00', 'Out for Delivery', 210, 3, 4),
((NOW() - INTERVAL 35 HOUR), 'Preparing', 39, 1, 6);

-- (Orders seeded: 179)

-- ------------------------------------------------------------
-- PAYMENTS (fires after_payment_insert_create_transaction automatically)
-- ------------------------------------------------------------
INSERT INTO PAYMENTS (payment_method, amount_paid, payment_status, gateway_reference_token, payment_date, order_id) VALUES
('Bank', 431.28, 'Completed', 'SIM-7A22612356', '2025-11-19 23:50:00', 1),
('GCash', 515.6, 'Completed', 'SIM-C3C26BCDC2', (NOW() - INTERVAL 19 HOUR), 3),
('GCash', 182.5, 'Completed', 'SIM-92F209AE92', '2026-07-17 03:00:00', 4),
('Bank', 460.55, 'Completed', 'SIM-C1F893254A', '2026-02-02 09:41:00', 5),
('Bank', 612.33, 'Completed', 'SIM-7DC23E502E', '2026-07-19 16:00:00', 8),
('GCash', 441.5, 'Completed', 'SIM-0BE052B595', '2025-10-01 06:31:00', 9),
('Bank', 829.69, 'Completed', 'SIM-342C7F609D', '2025-05-12 11:02:00', 11),
('GCash', 565.86, 'Completed', 'SIM-240FB86C6E', '2025-11-22 17:48:00', 12),
('Bank', 182.86, 'Completed', 'SIM-9D96B2836B', '2026-07-19 13:00:00', 13),
('Bank', 933.59, 'Completed', 'SIM-238C90F592', '2026-07-18 00:00:00', 14),
('Bank', 467.68, 'Completed', 'SIM-1CA2CC05A5', '2025-05-20 03:04:00', 15),
('GCash', 858.39, 'Completed', 'SIM-4011F1E925', (NOW() - INTERVAL 25 HOUR), 16),
('Bank', 250.26, 'Completed', 'SIM-4BE674BDB3', '2026-02-07 17:03:00', 17),
('GCash', 451.84, 'Completed', 'SIM-9025129850', '2026-04-09 11:41:00', 21),
('GCash', 704.09, 'Completed', 'SIM-85555D5978', '2026-07-18 09:00:00', 22),
('GCash', 4038.07, 'Completed', 'SIM-39482DB729', '2026-05-10 02:08:00', 23),
('Bank', 242.63, 'Completed', 'SIM-0FB8D26BEE', '2026-06-11 12:02:00', 24),
('GCash', 747.32, 'Completed', 'SIM-53DE847A13', '2025-12-02 01:29:00', 25),
('GCash', 709.93, 'Completed', 'SIM-F3FFA8CFB1', '2026-01-05 06:48:00', 26),
('GCash', 331.95, 'Completed', 'SIM-08A6E1FF82', '2025-06-13 11:48:00', 27),
('GCash', 89.14, 'Completed', 'SIM-941C5A85BE', '2025-07-25 08:25:00', 28),
('Bank', 597.23, 'Completed', 'SIM-0FA4999B11', '2026-03-21 10:56:00', 29),
('Bank', 32.42, 'Completed', 'SIM-660557C96C', (NOW() - INTERVAL 23 HOUR), 30),
('GCash', 135.22, 'Completed', 'SIM-6D4F950E16', '2025-02-02 15:47:00', 31),
('GCash', 1056.42, 'Completed', 'SIM-5CEBE54016', '2026-05-23 05:52:00', 32),
('GCash', 121.38, 'Completed', 'SIM-D74CB0EDCA', '2026-01-10 15:27:00', 33),
('GCash', 860.29, 'Completed', 'SIM-70259D0A0A', '2025-12-15 05:21:00', 34),
('Bank', 827.28, 'Completed', 'SIM-95D8CA4FEE', '2025-02-15 18:34:00', 36),
('GCash', 1111.91, 'Completed', 'SIM-E1FB446CF6', (NOW() - INTERVAL 28 HOUR), 37),
('Bank', 267.93, 'Completed', 'SIM-DE3BB43A98', '2026-03-06 22:06:00', 38),
('GCash', 550.74, 'Completed', 'SIM-58B2F59D5A', '2026-01-13 10:15:00', 39),
('Bank', 636.94, 'Completed', 'SIM-8672FF4B01', '2026-01-15 18:43:00', 41),
('GCash', 1188.63, 'Completed', 'SIM-CE9E9A9D71', '2025-11-05 07:02:00', 42),
('GCash', 513.8, 'Completed', 'SIM-C6060ECCD5', '2025-02-23 10:24:00', 43),
('Bank', 378.55, 'Completed', 'SIM-25E7EEBD2E', '2025-07-01 02:32:00', 44),
('GCash', 514.72, 'Completed', 'SIM-9EC7A99DB4', '2025-01-16 21:57:00', 45),
('Bank', 501.01, 'Completed', 'SIM-F98EC8E94A', '2026-01-09 04:55:00', 46),
('GCash', 813.52, 'Completed', 'SIM-5EEA479355', '2025-07-19 02:28:00', 47),
('Bank', 120.42, 'Completed', 'SIM-7427DE366C', '2025-03-22 10:10:00', 48),
('Bank', 537.7, 'Completed', 'SIM-F8BCC7D154', '2026-01-08 09:58:00', 49),
('GCash', 263.72, 'Completed', 'SIM-74DC01405C', '2026-02-11 19:37:00', 51),
('GCash', 5010.03, 'Completed', 'SIM-0A764ADBC4', '2025-06-17 20:19:00', 52),
('GCash', 474.03, 'Completed', 'SIM-9B5F5D131C', '2025-05-01 04:56:00', 53),
('Bank', 539.69, 'Completed', 'SIM-CA54B7BE27', '2025-03-29 16:27:00', 54),
('GCash', 245.03, 'Completed', 'SIM-8A0C4D8087', '2025-05-16 13:19:00', 55),
('GCash', 728.89, 'Completed', 'SIM-D9EBFF8BAC', '2026-07-17 05:34:00', 57),
('Bank', 417.21, 'Completed', 'SIM-34C4E7FB84', '2025-06-15 10:05:00', 58),
('GCash', 277.24, 'Completed', 'SIM-6796CC1697', '2025-07-21 01:07:00', 59),
('Bank', 518.04, 'Completed', 'SIM-9EB9C0F050', '2026-02-06 21:53:00', 60),
('Bank', 8179.86, 'Completed', 'SIM-C9802212DB', '2025-04-12 03:48:00', 61),
('Bank', 488.79, 'Completed', 'SIM-266DBFD7F1', '2025-10-24 10:11:00', 62),
('GCash', 1200.0, 'Completed', 'SIM-AF777EC798', '2025-05-31 23:54:00', 63),
('GCash', 647.0, 'Completed', 'SIM-7AC950A9F5', '2026-06-27 07:16:00', 64),
('GCash', 845.94, 'Completed', 'SIM-13CCCDA706', '2026-03-06 17:09:00', 65),
('GCash', 891.82, 'Completed', 'SIM-55E0F65EC8', '2025-05-08 02:34:00', 66),
('GCash', 669.84, 'Completed', 'SIM-2A74827825', '2025-10-09 18:51:00', 67),
('Bank', 241.61, 'Completed', 'SIM-929CD3DC52', '2025-04-12 17:23:00', 69),
('Bank', 1688.05, 'Completed', 'SIM-1400AF0EBF', '2025-08-17 01:20:00', 70),
('GCash', 906.47, 'Completed', 'SIM-DCBDA8DD8D', '2026-01-14 21:08:00', 71),
('GCash', 663.87, 'Completed', 'SIM-36AF9AFE0D', '2026-03-04 10:14:00', 72),
('Bank', 957.44, 'Completed', 'SIM-95B05B6C30', '2025-01-13 21:01:00', 73),
('GCash', 836.47, 'Completed', 'SIM-EC18B58646', '2025-09-30 23:41:00', 74),
('Bank', 140.08, 'Completed', 'SIM-1CE39A54D9', '2025-08-26 08:05:00', 75),
('Bank', 416.07, 'Completed', 'SIM-BA6E76811C', (NOW() - INTERVAL 13 HOUR), 76),
('GCash', 186.27, 'Completed', 'SIM-B3FB519961', '2026-03-06 05:45:00', 77),
('GCash', 4704.97, 'Completed', 'SIM-91FE034123', '2025-01-19 09:59:00', 78),
('Bank', 224.68, 'Completed', 'SIM-B0189A9A65', '2025-07-05 22:57:00', 79),
('GCash', 545.44, 'Completed', 'SIM-CB037D74F1', '2026-04-10 06:34:00', 80),
('Bank', 1229.22, 'Completed', 'SIM-BCB9000BF3', '2026-01-15 09:14:00', 81),
('Bank', 69.18, 'Completed', 'SIM-B129CD396A', '2025-08-03 16:41:00', 83),
('Bank', 142.8, 'Completed', 'SIM-9DDA60ECCE', '2025-11-19 19:42:00', 84),
('Bank', 221.55, 'Completed', 'SIM-710D8CA809', '2025-06-11 06:23:00', 86),
('GCash', 231.11, 'Completed', 'SIM-D912690837', '2025-02-08 00:38:00', 88),
('GCash', 365.23, 'Completed', 'SIM-B43F9955FC', '2025-03-08 02:28:00', 89),
('Bank', 1198.56, 'Completed', 'SIM-7B902A17C1', '2025-04-01 03:49:00', 91),
('GCash', 653.12, 'Completed', 'SIM-A5D563DDD4', '2026-05-07 22:40:00', 93),
('Bank', 379.05, 'Completed', 'SIM-A8275410F2', (NOW() - INTERVAL 7 HOUR), 94),
('GCash', 286.46, 'Completed', 'SIM-81F2C0E444', (NOW() - INTERVAL 11 HOUR), 95),
('GCash', 843.03, 'Completed', 'SIM-6B430168B1', (NOW() - INTERVAL 14 HOUR), 96),
('GCash', 310.88, 'Completed', 'SIM-47D62B79F6', '2026-05-24 23:15:00', 97),
('Bank', 838.63, 'Completed', 'SIM-8460962E4E', '2025-04-12 02:08:00', 98),
('GCash', 109.71, 'Completed', 'SIM-A8AA6725FC', (NOW() - INTERVAL 8 HOUR), 99),
('GCash', 145.07, 'Completed', 'SIM-2030A80905', (NOW() - INTERVAL 22 HOUR), 100),
('Bank', 186.49, 'Completed', 'SIM-20B624674E', '2026-05-13 06:31:00', 101),
('GCash', 151.92, 'Completed', 'SIM-BAA6C3293A', (NOW() - INTERVAL 8 HOUR), 102),
('GCash', 280.02, 'Completed', 'SIM-946C4DD756', '2025-11-28 12:44:00', 104),
('Bank', 54.33, 'Completed', 'SIM-4E8443B13B', '2025-04-03 19:48:00', 105),
('Bank', 861.43, 'Completed', 'SIM-8B1F701AB9', '2025-04-09 12:42:00', 106),
('GCash', 36669.96, 'Completed', 'SIM-40F86CAC33', '2025-04-30 17:25:00', 108),
('GCash', 155.35, 'Completed', 'SIM-99132C58DA', '2026-05-11 06:50:00', 109),
('GCash', 861.42, 'Completed', 'SIM-DF8ACB5CED', '2025-12-13 01:23:00', 110),
('Bank', 418.53, 'Completed', 'SIM-5416098ED7', '2026-03-26 17:29:00', 111),
('Bank', 564.26, 'Completed', 'SIM-9B63CD5013', '2025-04-29 14:32:00', 112),
('Bank', 331.91, 'Completed', 'SIM-3303F4BCA2', '2025-11-18 22:32:00', 113),
('Bank', 443.92, 'Completed', 'SIM-0B60CDDFCF', (NOW() - INTERVAL 23 HOUR), 114),
('Bank', 977.81, 'Completed', 'SIM-55D3FDBEDD', '2025-12-20 10:56:00', 115),
('Bank', 296.83, 'Completed', 'SIM-596434407D', '2026-01-12 23:27:00', 116),
('Bank', 397.33, 'Completed', 'SIM-0BCF03E479', '2026-06-16 15:24:00', 119),
('Bank', 826.96, 'Completed', 'SIM-C9A22FA170', '2026-04-05 03:52:00', 120),
('Bank', 590.04, 'Completed', 'SIM-FFB61AE914', '2026-07-15 03:26:00', 121),
('Bank', 929.59, 'Completed', 'SIM-9BD7C975DB', '2025-07-01 04:45:00', 122),
('Bank', 136.65, 'Completed', 'SIM-72A5A8AAEE', '2025-04-13 18:38:00', 123),
('Bank', 623.87, 'Completed', 'SIM-ECC1C76890', '2025-02-03 21:23:00', 124),
('GCash', 311.72, 'Completed', 'SIM-2D11E61B65', '2025-07-05 12:52:00', 125),
('GCash', 3309.96, 'Completed', 'SIM-45DB9AAD7D', '2025-11-19 06:47:00', 126),
('Bank', 960.55, 'Completed', 'SIM-D3276E1C28', '2026-03-10 11:30:00', 127),
('Bank', 700.99, 'Completed', 'SIM-013D0B0493', '2026-05-02 09:10:00', 128),
('GCash', 439.7, 'Completed', 'SIM-1BBA1E12FB', '2025-09-11 03:24:00', 129),
('GCash', 466.8, 'Completed', 'SIM-FD00F1FA08', '2025-01-27 10:06:00', 130),
('Bank', 683.21, 'Completed', 'SIM-DCE32BADBB', '2026-05-11 09:27:00', 131),
('Bank', 684.91, 'Completed', 'SIM-D2E8500D75', '2026-02-13 14:36:00', 133),
('GCash', 579.87, 'Completed', 'SIM-CD45EAC835', '2026-03-25 13:40:00', 135),
('GCash', 908.52, 'Completed', 'SIM-C4CF1940A9', (NOW() - INTERVAL 0 HOUR), 136),
('GCash', 466.76, 'Completed', 'SIM-473931DB73', '2025-05-04 10:48:00', 137),
('GCash', 641.22, 'Completed', 'SIM-2CCBE5159E', '2025-03-05 03:25:00', 139),
('Bank', 3442.66, 'Completed', 'SIM-FAF586783B', '2025-04-28 09:40:00', 140),
('GCash', 830.82, 'Completed', 'SIM-C0D9FA350D', '2025-03-25 17:59:00', 142),
('GCash', 174.25, 'Completed', 'SIM-80BE42898C', '2025-05-25 09:03:00', 143),
('Bank', 375.39, 'Completed', 'SIM-8009EA2F30', '2025-01-09 19:49:00', 145),
('Bank', 186.17, 'Completed', 'SIM-E9141C934E', '2025-04-14 18:08:00', 146),
('GCash', 322.38, 'Completed', 'SIM-6AAE3AE04A', '2026-02-26 00:13:00', 147),
('GCash', 908.02, 'Completed', 'SIM-FE746CBE9D', '2025-04-21 11:16:00', 148),
('GCash', 509.78, 'Completed', 'SIM-EA8D400888', '2026-02-02 02:54:00', 149),
('Bank', 388.67, 'Completed', 'SIM-C086C6E0DE', '2026-07-10 05:37:00', 150),
('Bank', 20.82, 'Completed', 'SIM-2080C1F851', '2025-09-16 10:53:00', 152),
('Bank', 12.87, 'Completed', 'SIM-00A29063ED', '2025-06-11 04:28:00', 153),
('Bank', 81.14, 'Completed', 'SIM-C23E600A67', '2026-06-16 03:24:00', 154),
('GCash', 503.44, 'Completed', 'SIM-A74FBE1FA5', '2025-07-01 02:15:00', 156),
('GCash', 79.43, 'Completed', 'SIM-5229C84C45', (NOW() - INTERVAL 19 HOUR), 157),
('Bank', 445.71, 'Completed', 'SIM-3DBC82DBA2', '2026-06-20 18:33:00', 158),
('GCash', 844.65, 'Completed', 'SIM-8E1CD7E314', '2025-07-19 05:17:00', 159),
('Bank', 491.32, 'Completed', 'SIM-CAC5D25D1E', '2026-05-06 03:22:00', 160),
('Bank', 604.61, 'Completed', 'SIM-FE0617CEB0', '2025-08-23 05:28:00', 161),
('Bank', 41.22, 'Completed', 'SIM-A4418FC81A', '2025-02-14 19:04:00', 162),
('Bank', 2057.38, 'Completed', 'SIM-27D822CC43', '2025-11-18 10:55:00', 163),
('GCash', 449.42, 'Completed', 'SIM-E6E0840143', '2026-06-22 03:24:00', 164),
('Bank', 559.31, 'Completed', 'SIM-CF9F30A7CB', '2025-02-20 08:53:00', 165),
('Bank', 342.25, 'Completed', 'SIM-816965D8C8', '2026-04-25 14:48:00', 166),
('GCash', 510.91, 'Completed', 'SIM-AEA51F4ACB', '2025-08-28 11:32:00', 167),
('Bank', 694.12, 'Completed', 'SIM-C42D14D502', '2025-05-19 09:22:00', 168),
('GCash', 706.6, 'Completed', 'SIM-344D68F02B', '2026-03-21 17:20:00', 169),
('Bank', 117.1, 'Completed', 'SIM-DD72F87614', '2025-10-23 19:58:00', 170),
('GCash', 291.31, 'Completed', 'SIM-C2B1A2A7E7', (NOW() - INTERVAL 7 HOUR), 171),
('Bank', 442.89, 'Completed', 'SIM-B79B37820A', '2025-04-23 18:36:00', 172),
('GCash', 759.93, 'Completed', 'SIM-3894A0D8AD', '2025-10-15 01:37:00', 174),
('Bank', 759.26, 'Completed', 'SIM-848DB9856A', '2026-06-01 10:56:00', 175),
('Bank', 1390.46, 'Completed', 'SIM-33B29EAA24', '2025-10-17 23:14:00', 176),
('Bank', 472.61, 'Completed', 'SIM-E79AA66274', '2026-02-28 02:15:00', 177),
('GCash', 16019.29, 'Completed', 'SIM-2A6500C189', '2025-09-15 16:44:00', 178);

-- (Payments seeded: 149)

-- ------------------------------------------------------------
-- SHIPMENTS (insert-then-update so after_shipment_status_change fires)
-- ------------------------------------------------------------
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (1, 2, 'TRK1001', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-21 19:50:00' WHERE order_id=1;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=1;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (4, 2, 'TRK1002', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-18 06:00:00' WHERE order_id=4;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=4;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (5, 1, 'TRK1003', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-03 21:41:00' WHERE order_id=5;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=5;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (8, 1, 'TRK1004', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-21 01:00:00' WHERE order_id=8;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=8;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=8;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (9, 1, 'TRK1005', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-01 19:31:00' WHERE order_id=9;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=9;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=9;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (11, 3, 'TRK1006', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-13 09:02:00' WHERE order_id=11;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (12, 3, 'TRK1007', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-24 02:48:00' WHERE order_id=12;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (13, 2, 'TRK1008', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-21 16:00:00' WHERE order_id=13;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (14, 1, 'TRK1009', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-18 15:00:00' WHERE order_id=14;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (15, 3, 'TRK1010', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-22 02:04:00' WHERE order_id=15;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=15;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=15;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (17, 3, 'TRK1011', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-09 07:03:00' WHERE order_id=17;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=17;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=17;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (21, 3, 'TRK1012', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-11 09:41:00' WHERE order_id=21;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=21;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=21;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (22, 3, 'TRK1013', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-20 10:00:00' WHERE order_id=22;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=22;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=22;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (23, 1, 'TRK1014', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-10 23:08:00' WHERE order_id=23;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=23;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=23;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (24, 4, 'TRK1015', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-12 15:02:00' WHERE order_id=24;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=24;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (25, 2, 'TRK1016', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-04 03:29:00' WHERE order_id=25;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (26, 3, 'TRK1017', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-06 06:48:00' WHERE order_id=26;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=26;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=26;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (27, 2, 'TRK1018', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-14 07:48:00' WHERE order_id=27;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=27;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=27;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (28, 4, 'TRK1019', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-26 00:25:00' WHERE order_id=28;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=28;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (29, 1, 'TRK1020', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-22 21:56:00' WHERE order_id=29;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=29;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=29;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (31, 3, 'TRK1021', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-03 06:47:00' WHERE order_id=31;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=31;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (32, 4, 'TRK1022', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-24 22:52:00' WHERE order_id=32;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=32;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=32;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (33, 4, 'TRK1023', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-11 11:27:00' WHERE order_id=33;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=33;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=33;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (34, 2, 'TRK1024', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-17 11:21:00' WHERE order_id=34;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=34;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=34;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (36, 3, 'TRK1025', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-16 22:34:00' WHERE order_id=36;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (38, 3, 'TRK1026', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-08 00:06:00' WHERE order_id=38;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=38;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=38;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (39, 3, 'TRK1027', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-15 09:15:00' WHERE order_id=39;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=39;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (41, 3, 'TRK1028', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-17 17:43:00' WHERE order_id=41;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=41;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (42, 1, 'TRK1029', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-06 13:02:00' WHERE order_id=42;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (43, 4, 'TRK1030', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-25 04:24:00' WHERE order_id=43;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (44, 4, 'TRK1031', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-03 06:32:00' WHERE order_id=44;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=44;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=44;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (45, 3, 'TRK1032', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-18 01:57:00' WHERE order_id=45;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=45;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (46, 2, 'TRK1033', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-09 18:55:00' WHERE order_id=46;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=46;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (47, 3, 'TRK1034', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-19 23:28:00' WHERE order_id=47;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=47;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=47;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (48, 3, 'TRK1035', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-24 07:10:00' WHERE order_id=48;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (49, 4, 'TRK1036', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-09 16:58:00' WHERE order_id=49;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (51, 3, 'TRK1037', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-13 12:37:00' WHERE order_id=51;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=51;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=51;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (52, 1, 'TRK1038', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-18 23:19:00' WHERE order_id=52;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=52;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=52;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (53, 3, 'TRK1039', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-02 12:56:00' WHERE order_id=53;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=53;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=53;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (54, 1, 'TRK1040', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-31 05:27:00' WHERE order_id=54;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=54;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=54;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (55, 3, 'TRK1041', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-19 01:19:00' WHERE order_id=55;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=55;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (57, 2, 'TRK1042', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-18 18:34:00' WHERE order_id=57;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (58, 1, 'TRK1043', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-17 06:05:00' WHERE order_id=58;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=58;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=58;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (59, 1, 'TRK1044', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-22 19:07:00' WHERE order_id=59;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=59;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=59;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (60, 3, 'TRK1045', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-08 15:53:00' WHERE order_id=60;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=60;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=60;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (61, 2, 'TRK1046', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-13 13:48:00' WHERE order_id=61;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=61;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (62, 1, 'TRK1047', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-25 09:11:00' WHERE order_id=62;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=62;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=62;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (63, 2, 'TRK1048', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-03 07:54:00' WHERE order_id=63;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (64, 3, 'TRK1049', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-28 12:16:00' WHERE order_id=64;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=64;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=64;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (65, 1, 'TRK1050', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-07 23:09:00' WHERE order_id=65;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=65;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=65;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (66, 3, 'TRK1051', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-10 18:34:00' WHERE order_id=66;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=66;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=66;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (67, 2, 'TRK1052', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-11 06:51:00' WHERE order_id=67;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=67;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (69, 4, 'TRK1053', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-14 02:23:00' WHERE order_id=69;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=69;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=69;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (70, 2, 'TRK1054', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-19 02:20:00' WHERE order_id=70;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (71, 3, 'TRK1055', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-16 10:08:00' WHERE order_id=71;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=71;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=71;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (72, 3, 'TRK1056', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-05 06:14:00' WHERE order_id=72;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=72;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=72;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (73, 3, 'TRK1057', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-15 15:01:00' WHERE order_id=73;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=73;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=73;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (74, 4, 'TRK1058', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-02 19:41:00' WHERE order_id=74;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=74;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=74;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (75, 3, 'TRK1059', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-27 05:05:00' WHERE order_id=75;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=75;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=75;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (77, 1, 'TRK1060', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-07 15:45:00' WHERE order_id=77;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=77;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=77;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (78, 3, 'TRK1061', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-20 20:59:00' WHERE order_id=78;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=78;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=78;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (79, 2, 'TRK1062', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-08 07:57:00' WHERE order_id=79;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (80, 1, 'TRK1063', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-11 00:34:00' WHERE order_id=80;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=80;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=80;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (81, 4, 'TRK1064', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-18 01:14:00' WHERE order_id=81;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (83, 1, 'TRK1065', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-05 08:41:00' WHERE order_id=83;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (84, 4, 'TRK1066', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-22 05:42:00' WHERE order_id=84;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=84;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=84;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (86, 3, 'TRK1067', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-12 23:23:00' WHERE order_id=86;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=86;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=86;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (88, 3, 'TRK1068', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-10 00:38:00' WHERE order_id=88;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=88;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (89, 2, 'TRK1069', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-10 00:28:00' WHERE order_id=89;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=89;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=89;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (91, 2, 'TRK1070', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-03 16:49:00' WHERE order_id=91;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=91;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=91;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (93, 1, 'TRK1071', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-09 20:40:00' WHERE order_id=93;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=93;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=93;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (97, 3, 'TRK1072', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-27 07:15:00' WHERE order_id=97;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=97;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (98, 4, 'TRK1073', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-13 19:08:00' WHERE order_id=98;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=98;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=98;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (101, 2, 'TRK1074', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-15 13:31:00' WHERE order_id=101;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=101;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=101;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (104, 2, 'TRK1075', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-29 19:44:00' WHERE order_id=104;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=104;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=104;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (105, 1, 'TRK1076', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-04 21:48:00' WHERE order_id=105;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=105;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=105;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (106, 2, 'TRK1077', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-12 00:42:00' WHERE order_id=106;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (108, 2, 'TRK1078', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-02 05:25:00' WHERE order_id=108;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=108;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (109, 2, 'TRK1079', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-12 13:50:00' WHERE order_id=109;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=109;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=109;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (110, 4, 'TRK1080', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-13 22:23:00' WHERE order_id=110;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=110;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=110;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (111, 1, 'TRK1081', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-27 16:29:00' WHERE order_id=111;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=111;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=111;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (112, 4, 'TRK1082', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-01 10:32:00' WHERE order_id=112;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=112;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (113, 4, 'TRK1083', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-20 20:32:00' WHERE order_id=113;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=113;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=113;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (115, 3, 'TRK1084', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-22 12:56:00' WHERE order_id=115;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=115;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=115;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (116, 1, 'TRK1085', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-13 10:27:00' WHERE order_id=116;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=116;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=116;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (119, 4, 'TRK1086', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-19 00:24:00' WHERE order_id=119;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=119;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=119;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (120, 4, 'TRK1087', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-07 05:52:00' WHERE order_id=120;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=120;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=120;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (121, 2, 'TRK1088', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-16 22:26:00' WHERE order_id=121;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=121;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=121;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (122, 1, 'TRK1089', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-02 00:45:00' WHERE order_id=122;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=122;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (123, 3, 'TRK1090', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-15 17:38:00' WHERE order_id=123;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=123;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=123;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (124, 2, 'TRK1091', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-06 10:23:00' WHERE order_id=124;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=124;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=124;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (125, 1, 'TRK1092', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-06 19:52:00' WHERE order_id=125;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=125;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=125;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (126, 1, 'TRK1093', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-21 16:47:00' WHERE order_id=126;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=126;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (127, 4, 'TRK1094', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-12 02:30:00' WHERE order_id=127;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=127;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (128, 3, 'TRK1095', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-03 10:10:00' WHERE order_id=128;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=128;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=128;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (129, 2, 'TRK1096', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-13 09:24:00' WHERE order_id=129;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=129;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (130, 3, 'TRK1097', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-28 10:06:00' WHERE order_id=130;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (131, 3, 'TRK1098', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-12 08:27:00' WHERE order_id=131;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (133, 3, 'TRK1099', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-15 09:36:00' WHERE order_id=133;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=133;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=133;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (135, 2, 'TRK1100', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-26 23:40:00' WHERE order_id=135;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=135;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=135;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (137, 1, 'TRK1101', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-06 08:48:00' WHERE order_id=137;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=137;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=137;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (139, 1, 'TRK1102', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-06 18:25:00' WHERE order_id=139;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=139;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=139;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (140, 2, 'TRK1103', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-29 13:40:00' WHERE order_id=140;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=140;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=140;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (142, 2, 'TRK1104', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-26 14:59:00' WHERE order_id=142;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (143, 1, 'TRK1105', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-27 01:03:00' WHERE order_id=143;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (145, 3, 'TRK1106', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-12 03:49:00' WHERE order_id=145;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (146, 4, 'TRK1107', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-16 15:08:00' WHERE order_id=146;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=146;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=146;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (147, 1, 'TRK1108', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-27 06:13:00' WHERE order_id=147;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=147;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=147;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (148, 3, 'TRK1109', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-22 05:16:00' WHERE order_id=148;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=148;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=148;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (149, 1, 'TRK1110', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-03 09:54:00' WHERE order_id=149;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=149;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=149;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (150, 1, 'TRK1111', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-11 13:37:00' WHERE order_id=150;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=150;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (152, 3, 'TRK1112', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-18 02:53:00' WHERE order_id=152;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (153, 1, 'TRK1113', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-12 09:28:00' WHERE order_id=153;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=153;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=153;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (154, 3, 'TRK1114', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-17 15:24:00' WHERE order_id=154;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=154;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (156, 1, 'TRK1115', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-01 20:15:00' WHERE order_id=156;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=156;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (158, 4, 'TRK1116', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-22 16:33:00' WHERE order_id=158;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=158;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=158;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (159, 4, 'TRK1117', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-20 13:17:00' WHERE order_id=159;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (160, 2, 'TRK1118', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-08 06:22:00' WHERE order_id=160;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=160;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=160;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (161, 1, 'TRK1119', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-26 00:28:00' WHERE order_id=161;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=161;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=161;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (162, 1, 'TRK1120', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-16 07:04:00' WHERE order_id=162;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=162;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=162;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (163, 2, 'TRK1121', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-19 08:55:00' WHERE order_id=163;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=163;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=163;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (164, 3, 'TRK1122', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-24 07:24:00' WHERE order_id=164;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (165, 2, 'TRK1123', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-22 04:53:00' WHERE order_id=165;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=165;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=165;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (166, 2, 'TRK1124', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-27 03:48:00' WHERE order_id=166;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=166;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=166;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (167, 4, 'TRK1125', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-30 22:32:00' WHERE order_id=167;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (168, 4, 'TRK1126', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-21 08:22:00' WHERE order_id=168;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (169, 4, 'TRK1127', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-23 00:20:00' WHERE order_id=169;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=169;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=169;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (170, 3, 'TRK1128', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-25 21:58:00' WHERE order_id=170;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=170;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (172, 2, 'TRK1129', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-25 08:36:00' WHERE order_id=172;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=172;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=172;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (174, 3, 'TRK1130', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-16 01:37:00' WHERE order_id=174;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=174;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (175, 4, 'TRK1131', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-03 00:56:00' WHERE order_id=175;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=175;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=175;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (176, 4, 'TRK1132', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-19 01:14:00' WHERE order_id=176;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=176;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=176;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (177, 2, 'TRK1133', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-01 13:15:00' WHERE order_id=177;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=177;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=177;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (178, 3, 'TRK1134', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-17 11:44:00' WHERE order_id=178;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=178;
-- (Shipments progressed for 134 orders)

-- ------------------------------------------------------------
-- REVIEWS
-- ------------------------------------------------------------
INSERT INTO REVIEWS (buyer_id, seller_id, order_id, rating, review_text, review_date) VALUES
(6, 3, 8, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2026-07-19 06:00:00'),
(4, 5, 15, 4, 'Seller was very responsive and packed it well.', '2025-05-23 22:04:00'),
(2, 6, 17, 5, 'Smooth transaction, item as pictured.', '2026-02-15 15:03:00'),
(8, 3, 21, 3, 'Item was okay but took a while to arrive.', '2026-04-22 07:41:00'),
(1, 5, 22, 4, 'Item was exactly as described, fast shipping too!', '2026-07-19 12:00:00'),
(5, 2, 26, 5, 'Smooth transaction, item as pictured.', '2026-01-10 02:48:00'),
(1, 4, 29, 5, 'Great quality for the price, would buy again.', '2026-03-29 08:56:00'),
(5, 3, 33, 4, 'Seller was very responsive and packed it well.', '2026-01-18 14:27:00'),
(5, 1, 38, 5, 'Great quality for the price, would buy again.', '2026-03-09 16:06:00'),
(2, 5, 44, 5, 'Smooth transaction, item as pictured.', '2025-07-06 21:32:00'),
(1, 1, 47, 3, 'Item was okay but took a while to arrive.', '2025-07-26 23:28:00'),
(6, 5, 51, 5, 'Great quality for the price, would buy again.', '2026-02-15 17:37:00'),
(6, 2, 52, 5, 'Exceeded expectations, looks brand new.', '2025-07-02 19:19:00'),
(5, 5, 53, 4, 'Seller was very responsive and packed it well.', '2025-05-06 03:56:00'),
(7, 1, 54, 4, 'Exceeded expectations, looks brand new.', '2025-04-01 13:27:00'),
(4, 2, 58, 3, 'Decent but sizing ran a bit small.', '2025-06-22 06:05:00'),
(3, 1, 59, 4, 'Exceeded expectations, looks brand new.', '2025-07-29 22:07:00'),
(3, 1, 65, 4, 'Seller was very responsive and packed it well.', '2026-03-17 11:09:00'),
(6, 4, 66, 5, 'Smooth transaction, item as pictured.', '2025-05-25 22:34:00'),
(2, 1, 69, 5, 'Great quality for the price, would buy again.', '2025-04-28 15:23:00'),
(6, 4, 72, 2, 'Decent but sizing ran a bit small.', '2026-03-23 09:14:00'),
(3, 6, 73, 5, 'Exceeded expectations, looks brand new.', '2025-01-28 17:01:00'),
(7, 4, 78, 4, 'Item was exactly as described, fast shipping too!', '2025-02-03 07:59:00'),
(4, 5, 84, 4, 'Item was exactly as described, fast shipping too!', '2025-12-01 16:42:00'),
(8, 3, 86, 3, 'Item was okay but took a while to arrive.', '2025-06-17 05:23:00'),
(3, 6, 91, 2, 'Decent but sizing ran a bit small.', '2025-04-11 01:49:00'),
(8, 4, 93, 5, 'Exceeded expectations, looks brand new.', '2026-05-26 17:40:00'),
(1, 4, 104, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-12-14 06:44:00'),
(2, 6, 105, 5, 'Great quality for the price, would buy again.', '2025-04-07 15:48:00'),
(8, 4, 109, 4, 'Exceeded expectations, looks brand new.', '2026-05-14 05:50:00'),
(2, 1, 110, 5, 'Smooth transaction, item as pictured.', '2025-12-31 00:23:00'),
(7, 2, 111, 5, 'Great quality for the price, would buy again.', '2026-04-08 16:29:00'),
(7, 3, 113, 4, 'Smooth transaction, item as pictured.', '2025-11-23 19:32:00'),
(3, 6, 116, 5, 'Great quality for the price, would buy again.', '2026-01-15 18:27:00'),
(7, 6, 119, 4, 'Great quality for the price, would buy again.', '2026-06-25 14:24:00'),
(6, 2, 120, 1, 'Item was okay but took a while to arrive.', '2026-04-20 23:52:00'),
(8, 3, 121, 4, 'Smooth transaction, item as pictured.', '2026-07-19 10:00:00'),
(3, 1, 124, 5, 'Seller was very responsive and packed it well.', '2025-02-09 15:23:00'),
(6, 4, 125, 5, 'Seller was very responsive and packed it well.', '2025-07-24 08:52:00'),
(4, 5, 128, 3, 'Decent but sizing ran a bit small.', '2026-05-10 07:10:00'),
(6, 3, 133, 4, 'Great quality for the price, would buy again.', '2026-02-27 13:36:00'),
(4, 1, 135, 5, 'Exceeded expectations, looks brand new.', '2026-04-03 09:40:00'),
(2, 6, 147, 4, 'Exceeded expectations, looks brand new.', '2026-02-28 21:13:00'),
(2, 2, 148, 5, 'Exceeded expectations, looks brand new.', '2025-04-26 08:16:00'),
(1, 6, 153, 4, 'Great quality for the price, would buy again.', '2025-06-17 00:28:00'),
(7, 5, 158, 5, 'Item was exactly as described, fast shipping too!', '2026-07-07 17:33:00'),
(2, 1, 161, 4, 'Great quality for the price, would buy again.', '2025-09-06 04:28:00'),
(1, 4, 165, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-03-04 03:53:00'),
(5, 1, 166, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2026-05-15 13:48:00'),
(5, 5, 169, 4, 'Item was exactly as described, fast shipping too!', '2026-03-28 15:20:00'),
(7, 2, 172, 5, 'Great quality for the price, would buy again.', '2025-05-04 14:36:00'),
(6, 3, 176, 4, 'Exceeded expectations, looks brand new.', '2025-10-30 22:14:00');

-- (Reviews seeded: 52)

-- ------------------------------------------------------------
-- DISPUTES
-- ------------------------------------------------------------
INSERT INTO DISPUTES (order_id, buyer_id, seller_id, reason, opened_at) VALUES
(17, 2, 6, 'Item misrepresented in listing #1, condition did not match photos.', '2026-02-23 15:00:00'),
(73, 3, 6, 'Item misrepresented in listing #2, condition did not match photos.', '2025-11-14 15:00:00'),
(89, 1, 6, 'Item misrepresented in listing #3, condition did not match photos.', '2026-03-29 15:00:00'),
(125, 6, 4, 'Item arrived with a small tear not disclosed in the listing.', '2025-10-23 15:00:00'),
(172, 7, 2, 'Wrong item color received.', '2026-07-07 15:00:00'),
(77, 6, 3, 'Package arrived significantly later than expected.', '2025-12-20 15:00:00'),
(157, 2, 3, 'Item does not match the size listed.', '2025-12-13 15:00:00'),
(32, 4, 4, 'Missing accessory that was shown in listing photos.', '2026-06-13 15:00:00'),
(8, 6, 3, 'Item smells strongly of smoke, not mentioned in description.', '2026-06-11 15:00:00'),
(127, 6, 2, 'Buyer claims item was never received despite tracking showing delivered.', '2026-04-07 15:00:00'),
(82, 7, 3, 'Seller sent a different item than what was ordered.', '2025-10-31 15:00:00'),
(141, 6, 2, 'Authenticity of branded item is in question.', '2026-04-30 15:00:00'),
(10, 2, 3, 'Buyer requesting refund due to change of mind (outside policy).', '2026-02-28 15:00:00'),
(131, 7, 5, 'Item arrived with visible stains not shown in photos.', '2026-06-02 15:00:00');

-- Resolve/reject the seeded disputes via UPDATE so status-change triggers fire correctly
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2026-02-26 15:00:00' WHERE dispute_id=1;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2025-11-15 15:00:00' WHERE dispute_id=2;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2026-04-08 15:00:00' WHERE dispute_id=3;
UPDATE DISPUTES SET status='Under Review', assigned_admin_id=1 WHERE dispute_id=5;
UPDATE DISPUTES SET status='Resolved', resolution_type='Partial Refund', assigned_admin_id=2, resolved_at='2025-12-21 15:00:00' WHERE dispute_id=6;
UPDATE DISPUTES SET status='Resolved', resolution_type='Partial Refund', assigned_admin_id=1, resolved_at='2025-12-22 15:00:00' WHERE dispute_id=7;
UPDATE DISPUTES SET status='Rejected', assigned_admin_id=2, resolved_at='2026-06-19 15:00:00' WHERE dispute_id=8;
UPDATE DISPUTES SET status='Under Review', assigned_admin_id=3 WHERE dispute_id=10;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2025-11-08 15:00:00' WHERE dispute_id=11;
UPDATE DISPUTES SET status='Rejected', assigned_admin_id=1, resolved_at='2026-05-02 15:00:00' WHERE dispute_id=12;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2026-03-02 15:00:00' WHERE dispute_id=13;
-- (Disputes seeded: 14, including a 3-strike misrepresentation pattern against seller_id=6)

-- ------------------------------------------------------------
-- PENALTIES (standalone, in addition to the dispute-triggered one above)
-- ------------------------------------------------------------
INSERT INTO PENALTIES (seller_id, reason, penalty_type, issued_at) VALUES
(4, 'Shipped 10 hours past the 48-hour window', 'Selling Suspension', '2026-05-20 15:00:00'),
(6, 'Listing photos did not match delivered item', 'Bidding Suspension', '2026-06-24 15:00:00');

-- ------------------------------------------------------------
-- SELLER_AWARDS
-- ------------------------------------------------------------
INSERT INTO SELLER_AWARDS (seller_id, award_type, reason, status, issued_at) VALUES
(1, 'Top Seller Badge', 'Top Seller of the Month, June 2026', 'Active', '2026-06-19 15:00:00'),
(1, 'Fee Discount', 'Loyalty reward for 50+ completed orders', 'Active', '2026-04-20 15:00:00'),
(3, 'Top Seller Badge', 'Top Seller of the Month, March 2026', 'Expired', '2026-03-21 15:00:00'),
(5, 'Fee Discount', 'Consistently high seller rating', 'Active', '2026-07-04 15:00:00');

-- ------------------------------------------------------------
-- FRAUD_FLAGS
-- ------------------------------------------------------------
INSERT INTO FRAUD_FLAGS (listing_id, buyer_id, seller_id, signals_detected, status) VALUES
(11, 3, 5, 'Photos look reused from another online marketplace listing.', 'Pending'),
(87, 5, 1, 'Price is suspiciously below market value for this brand.', 'Pending'),
(6, 1, 3, 'Buyer reports item never matched the description.', 'Pending'),
(112, 7, 6, 'Multiple reports of delayed responses from this seller.', 'Reviewed'),
(192, 5, 3, 'Listing may be duplicated across two accounts.', 'Reviewed'),
(236, 3, 1, 'Suspected counterfeit branded item, no verifiable serial number.', 'Resolved'),
(42, 5, 5, 'Same product photos found on an unrelated resale site.', 'Resolved'),
(127, 3, 3, 'Buyer flagged seller for requesting off-platform payment.', 'Pending'),
(158, 6, 1, 'Listing description copied from another seller\'s item.', 'Reviewed'),
(98, 7, 2, 'Unusual bidding pattern detected (possible shill bidding).', 'Pending');

-- ------------------------------------------------------------
-- CURRENCY_RATES (seed cache)
-- ------------------------------------------------------------
-- Dated YESTERDAY, not CURDATE(), on purpose: currency.php's
-- getLiveCurrencyRates() only calls the real exchange-rate API
-- when there's no cached row for *today* yet. A row seeded for
-- today would satisfy that check immediately on import, so the
-- live API would never fire on the exact day you import this
-- file, only from the next day onward. Seeding it a day behind
-- keeps a safe fallback available while still letting the very
-- first real page load after import trigger a genuine live fetch.

INSERT INTO CURRENCY_RATES (base_currency, target_currency, exchange_rate, recorded_date) VALUES
('PHP','USD',0.0175, DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
('PHP','KRW',23.50,  DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- ------------------------------------------------------------
-- LISTING_ANALYTICS, fill in realistic variation on top of the trigger-seeded baseline
-- ------------------------------------------------------------
UPDATE LISTING_ANALYTICS SET view_count=236, follower_count=3134, details_score=56.37, condition_score=59.96, shipping_score=98.55, pricing_score=55.56, view_to_bid_score=10.51, completeness_score=ROUND((IFNULL(photo_score,60)+56.37+59.96+98.55+55.56)/5,2) WHERE listing_id=1;
UPDATE LISTING_ANALYTICS SET view_count=99, follower_count=8076, details_score=61.31, condition_score=68.18, shipping_score=84.07, pricing_score=71.38, view_to_bid_score=18.5, completeness_score=ROUND((IFNULL(photo_score,60)+61.31+68.18+84.07+71.38)/5,2) WHERE listing_id=2;
UPDATE LISTING_ANALYTICS SET view_count=708, follower_count=2843, details_score=42.2, condition_score=91.74, shipping_score=57.0, pricing_score=72.28, view_to_bid_score=5.82, completeness_score=ROUND((IFNULL(photo_score,60)+42.2+91.74+57.0+72.28)/5,2) WHERE listing_id=3;
UPDATE LISTING_ANALYTICS SET view_count=724, follower_count=7158, details_score=60.82, condition_score=90.55, shipping_score=85.74, pricing_score=52.45, view_to_bid_score=15.84, completeness_score=ROUND((IFNULL(photo_score,60)+60.82+90.55+85.74+52.45)/5,2) WHERE listing_id=4;
UPDATE LISTING_ANALYTICS SET view_count=520, follower_count=9087, details_score=89.79, condition_score=89.71, shipping_score=36.35, pricing_score=86.4, view_to_bid_score=6.79, completeness_score=ROUND((IFNULL(photo_score,60)+89.79+89.71+36.35+86.4)/5,2) WHERE listing_id=5;
UPDATE LISTING_ANALYTICS SET view_count=483, follower_count=4323, details_score=41.89, condition_score=55.76, shipping_score=76.08, pricing_score=51.19, view_to_bid_score=4.37, completeness_score=ROUND((IFNULL(photo_score,60)+41.89+55.76+76.08+51.19)/5,2) WHERE listing_id=6;
UPDATE LISTING_ANALYTICS SET view_count=605, follower_count=5341, details_score=62.34, condition_score=68.9, shipping_score=71.19, pricing_score=42.03, view_to_bid_score=15.88, completeness_score=ROUND((IFNULL(photo_score,60)+62.34+68.9+71.19+42.03)/5,2) WHERE listing_id=7;
UPDATE LISTING_ANALYTICS SET view_count=649, follower_count=5929, details_score=92.16, condition_score=50.39, shipping_score=59.5, pricing_score=60.08, view_to_bid_score=14.78, completeness_score=ROUND((IFNULL(photo_score,60)+92.16+50.39+59.5+60.08)/5,2) WHERE listing_id=8;
UPDATE LISTING_ANALYTICS SET view_count=107, follower_count=3115, details_score=94.79, condition_score=65.31, shipping_score=62.68, pricing_score=51.17, view_to_bid_score=1.95, completeness_score=ROUND((IFNULL(photo_score,60)+94.79+65.31+62.68+51.17)/5,2) WHERE listing_id=9;
UPDATE LISTING_ANALYTICS SET view_count=636, follower_count=7528, details_score=75.61, condition_score=84.72, shipping_score=81.17, pricing_score=68.41, view_to_bid_score=6.49, completeness_score=ROUND((IFNULL(photo_score,60)+75.61+84.72+81.17+68.41)/5,2) WHERE listing_id=10;
UPDATE LISTING_ANALYTICS SET view_count=745, follower_count=6164, details_score=76.06, condition_score=74.13, shipping_score=58.08, pricing_score=42.41, view_to_bid_score=20.54, completeness_score=ROUND((IFNULL(photo_score,60)+76.06+74.13+58.08+42.41)/5,2) WHERE listing_id=11;
UPDATE LISTING_ANALYTICS SET view_count=244, follower_count=8356, details_score=46.47, condition_score=71.29, shipping_score=48.86, pricing_score=74.65, view_to_bid_score=13.66, completeness_score=ROUND((IFNULL(photo_score,60)+46.47+71.29+48.86+74.65)/5,2) WHERE listing_id=12;
UPDATE LISTING_ANALYTICS SET view_count=172, follower_count=8441, details_score=49.98, condition_score=65.03, shipping_score=71.78, pricing_score=81.86, view_to_bid_score=12.24, completeness_score=ROUND((IFNULL(photo_score,60)+49.98+65.03+71.78+81.86)/5,2) WHERE listing_id=13;
UPDATE LISTING_ANALYTICS SET view_count=586, follower_count=2336, details_score=47.79, condition_score=66.66, shipping_score=97.19, pricing_score=98.22, view_to_bid_score=7.84, completeness_score=ROUND((IFNULL(photo_score,60)+47.79+66.66+97.19+98.22)/5,2) WHERE listing_id=14;
UPDATE LISTING_ANALYTICS SET view_count=789, follower_count=2367, details_score=88.09, condition_score=72.94, shipping_score=41.57, pricing_score=40.05, view_to_bid_score=4.52, completeness_score=ROUND((IFNULL(photo_score,60)+88.09+72.94+41.57+40.05)/5,2) WHERE listing_id=15;
UPDATE LISTING_ANALYTICS SET view_count=181, follower_count=4986, details_score=58.45, condition_score=59.23, shipping_score=90.04, pricing_score=66.19, view_to_bid_score=16.34, completeness_score=ROUND((IFNULL(photo_score,60)+58.45+59.23+90.04+66.19)/5,2) WHERE listing_id=16;
UPDATE LISTING_ANALYTICS SET view_count=162, follower_count=11268, details_score=73.32, condition_score=88.78, shipping_score=30.35, pricing_score=49.56, view_to_bid_score=3.55, completeness_score=ROUND((IFNULL(photo_score,60)+73.32+88.78+30.35+49.56)/5,2) WHERE listing_id=17;
UPDATE LISTING_ANALYTICS SET view_count=568, follower_count=11302, details_score=63.64, condition_score=60.62, shipping_score=63.06, pricing_score=62.58, view_to_bid_score=11.0, completeness_score=ROUND((IFNULL(photo_score,60)+63.64+60.62+63.06+62.58)/5,2) WHERE listing_id=18;
UPDATE LISTING_ANALYTICS SET view_count=253, follower_count=1619, details_score=63.25, condition_score=65.92, shipping_score=95.47, pricing_score=63.99, view_to_bid_score=8.21, completeness_score=ROUND((IFNULL(photo_score,60)+63.25+65.92+95.47+63.99)/5,2) WHERE listing_id=19;
UPDATE LISTING_ANALYTICS SET view_count=294, follower_count=11105, details_score=83.82, condition_score=71.23, shipping_score=57.57, pricing_score=44.3, view_to_bid_score=11.51, completeness_score=ROUND((IFNULL(photo_score,60)+83.82+71.23+57.57+44.3)/5,2) WHERE listing_id=20;
UPDATE LISTING_ANALYTICS SET view_count=763, follower_count=9658, details_score=41.61, condition_score=94.28, shipping_score=42.47, pricing_score=54.11, view_to_bid_score=8.93, completeness_score=ROUND((IFNULL(photo_score,60)+41.61+94.28+42.47+54.11)/5,2) WHERE listing_id=21;
UPDATE LISTING_ANALYTICS SET view_count=518, follower_count=76, details_score=76.63, condition_score=87.58, shipping_score=94.02, pricing_score=78.73, view_to_bid_score=4.33, completeness_score=ROUND((IFNULL(photo_score,60)+76.63+87.58+94.02+78.73)/5,2) WHERE listing_id=22;
UPDATE LISTING_ANALYTICS SET view_count=197, follower_count=774, details_score=52.67, condition_score=71.77, shipping_score=53.77, pricing_score=79.24, view_to_bid_score=10.23, completeness_score=ROUND((IFNULL(photo_score,60)+52.67+71.77+53.77+79.24)/5,2) WHERE listing_id=23;
UPDATE LISTING_ANALYTICS SET view_count=296, follower_count=5146, details_score=63.21, condition_score=91.06, shipping_score=32.44, pricing_score=97.51, view_to_bid_score=10.15, completeness_score=ROUND((IFNULL(photo_score,60)+63.21+91.06+32.44+97.51)/5,2) WHERE listing_id=24;
UPDATE LISTING_ANALYTICS SET view_count=172, follower_count=6574, details_score=80.94, condition_score=91.71, shipping_score=62.54, pricing_score=44.96, view_to_bid_score=15.56, completeness_score=ROUND((IFNULL(photo_score,60)+80.94+91.71+62.54+44.96)/5,2) WHERE listing_id=25;
UPDATE LISTING_ANALYTICS SET view_count=108, follower_count=10795, details_score=91.75, condition_score=90.18, shipping_score=30.86, pricing_score=59.14, view_to_bid_score=13.28, completeness_score=ROUND((IFNULL(photo_score,60)+91.75+90.18+30.86+59.14)/5,2) WHERE listing_id=26;
UPDATE LISTING_ANALYTICS SET view_count=398, follower_count=11294, details_score=67.28, condition_score=74.31, shipping_score=97.19, pricing_score=64.1, view_to_bid_score=17.31, completeness_score=ROUND((IFNULL(photo_score,60)+67.28+74.31+97.19+64.1)/5,2) WHERE listing_id=27;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=7012, details_score=55.52, condition_score=81.71, shipping_score=72.25, pricing_score=88.15, view_to_bid_score=10.73, completeness_score=ROUND((IFNULL(photo_score,60)+55.52+81.71+72.25+88.15)/5,2) WHERE listing_id=28;
UPDATE LISTING_ANALYTICS SET view_count=386, follower_count=7808, details_score=82.72, condition_score=92.21, shipping_score=98.02, pricing_score=46.7, view_to_bid_score=5.17, completeness_score=ROUND((IFNULL(photo_score,60)+82.72+92.21+98.02+46.7)/5,2) WHERE listing_id=29;
UPDATE LISTING_ANALYTICS SET view_count=439, follower_count=8761, details_score=85.58, condition_score=93.52, shipping_score=35.6, pricing_score=40.42, view_to_bid_score=20.94, completeness_score=ROUND((IFNULL(photo_score,60)+85.58+93.52+35.6+40.42)/5,2) WHERE listing_id=30;
UPDATE LISTING_ANALYTICS SET view_count=729, follower_count=9719, details_score=55.47, condition_score=75.74, shipping_score=73.02, pricing_score=92.33, view_to_bid_score=10.42, completeness_score=ROUND((IFNULL(photo_score,60)+55.47+75.74+73.02+92.33)/5,2) WHERE listing_id=31;
UPDATE LISTING_ANALYTICS SET view_count=480, follower_count=4665, details_score=42.39, condition_score=93.39, shipping_score=62.22, pricing_score=43.0, view_to_bid_score=13.79, completeness_score=ROUND((IFNULL(photo_score,60)+42.39+93.39+62.22+43.0)/5,2) WHERE listing_id=32;
UPDATE LISTING_ANALYTICS SET view_count=383, follower_count=4184, details_score=65.54, condition_score=83.75, shipping_score=83.68, pricing_score=41.41, view_to_bid_score=6.98, completeness_score=ROUND((IFNULL(photo_score,60)+65.54+83.75+83.68+41.41)/5,2) WHERE listing_id=33;
UPDATE LISTING_ANALYTICS SET view_count=305, follower_count=5897, details_score=65.02, condition_score=72.34, shipping_score=50.84, pricing_score=42.14, view_to_bid_score=3.79, completeness_score=ROUND((IFNULL(photo_score,60)+65.02+72.34+50.84+42.14)/5,2) WHERE listing_id=34;
UPDATE LISTING_ANALYTICS SET view_count=754, follower_count=649, details_score=71.88, condition_score=69.81, shipping_score=42.27, pricing_score=72.1, view_to_bid_score=4.08, completeness_score=ROUND((IFNULL(photo_score,60)+71.88+69.81+42.27+72.1)/5,2) WHERE listing_id=35;
UPDATE LISTING_ANALYTICS SET view_count=153, follower_count=10419, details_score=69.61, condition_score=94.64, shipping_score=54.18, pricing_score=67.48, view_to_bid_score=14.15, completeness_score=ROUND((IFNULL(photo_score,60)+69.61+94.64+54.18+67.48)/5,2) WHERE listing_id=36;
UPDATE LISTING_ANALYTICS SET view_count=755, follower_count=8627, details_score=74.14, condition_score=52.03, shipping_score=52.86, pricing_score=42.3, view_to_bid_score=13.99, completeness_score=ROUND((IFNULL(photo_score,60)+74.14+52.03+52.86+42.3)/5,2) WHERE listing_id=37;
UPDATE LISTING_ANALYTICS SET view_count=746, follower_count=10499, details_score=88.75, condition_score=55.06, shipping_score=65.88, pricing_score=83.52, view_to_bid_score=8.42, completeness_score=ROUND((IFNULL(photo_score,60)+88.75+55.06+65.88+83.52)/5,2) WHERE listing_id=38;
UPDATE LISTING_ANALYTICS SET view_count=657, follower_count=4997, details_score=65.35, condition_score=51.12, shipping_score=96.53, pricing_score=55.41, view_to_bid_score=14.88, completeness_score=ROUND((IFNULL(photo_score,60)+65.35+51.12+96.53+55.41)/5,2) WHERE listing_id=39;
UPDATE LISTING_ANALYTICS SET view_count=86, follower_count=7151, details_score=97.91, condition_score=89.68, shipping_score=69.96, pricing_score=99.7, view_to_bid_score=14.12, completeness_score=ROUND((IFNULL(photo_score,60)+97.91+89.68+69.96+99.7)/5,2) WHERE listing_id=40;
UPDATE LISTING_ANALYTICS SET view_count=557, follower_count=4043, details_score=81.66, condition_score=52.44, shipping_score=70.13, pricing_score=52.91, view_to_bid_score=20.68, completeness_score=ROUND((IFNULL(photo_score,60)+81.66+52.44+70.13+52.91)/5,2) WHERE listing_id=41;
UPDATE LISTING_ANALYTICS SET view_count=286, follower_count=11336, details_score=86.7, condition_score=63.84, shipping_score=77.0, pricing_score=76.28, view_to_bid_score=20.15, completeness_score=ROUND((IFNULL(photo_score,60)+86.7+63.84+77.0+76.28)/5,2) WHERE listing_id=42;
UPDATE LISTING_ANALYTICS SET view_count=699, follower_count=4718, details_score=56.36, condition_score=70.36, shipping_score=31.31, pricing_score=64.86, view_to_bid_score=4.16, completeness_score=ROUND((IFNULL(photo_score,60)+56.36+70.36+31.31+64.86)/5,2) WHERE listing_id=43;
UPDATE LISTING_ANALYTICS SET view_count=278, follower_count=7626, details_score=75.94, condition_score=98.79, shipping_score=52.27, pricing_score=53.28, view_to_bid_score=1.87, completeness_score=ROUND((IFNULL(photo_score,60)+75.94+98.79+52.27+53.28)/5,2) WHERE listing_id=44;
UPDATE LISTING_ANALYTICS SET view_count=337, follower_count=3671, details_score=43.82, condition_score=64.39, shipping_score=79.84, pricing_score=89.62, view_to_bid_score=13.55, completeness_score=ROUND((IFNULL(photo_score,60)+43.82+64.39+79.84+89.62)/5,2) WHERE listing_id=45;
UPDATE LISTING_ANALYTICS SET view_count=655, follower_count=9802, details_score=59.73, condition_score=69.45, shipping_score=95.09, pricing_score=40.75, view_to_bid_score=8.48, completeness_score=ROUND((IFNULL(photo_score,60)+59.73+69.45+95.09+40.75)/5,2) WHERE listing_id=46;
UPDATE LISTING_ANALYTICS SET view_count=359, follower_count=7330, details_score=49.11, condition_score=92.72, shipping_score=64.93, pricing_score=71.93, view_to_bid_score=4.99, completeness_score=ROUND((IFNULL(photo_score,60)+49.11+92.72+64.93+71.93)/5,2) WHERE listing_id=47;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=4239, details_score=64.18, condition_score=83.03, shipping_score=69.99, pricing_score=44.72, view_to_bid_score=11.47, completeness_score=ROUND((IFNULL(photo_score,60)+64.18+83.03+69.99+44.72)/5,2) WHERE listing_id=48;
UPDATE LISTING_ANALYTICS SET view_count=358, follower_count=1411, details_score=52.45, condition_score=99.24, shipping_score=55.84, pricing_score=57.51, view_to_bid_score=7.96, completeness_score=ROUND((IFNULL(photo_score,60)+52.45+99.24+55.84+57.51)/5,2) WHERE listing_id=49;
UPDATE LISTING_ANALYTICS SET view_count=695, follower_count=7707, details_score=41.77, condition_score=81.24, shipping_score=41.67, pricing_score=61.1, view_to_bid_score=10.35, completeness_score=ROUND((IFNULL(photo_score,60)+41.77+81.24+41.67+61.1)/5,2) WHERE listing_id=50;
UPDATE LISTING_ANALYTICS SET view_count=788, follower_count=433, details_score=85.08, condition_score=64.19, shipping_score=82.08, pricing_score=99.38, view_to_bid_score=9.19, completeness_score=ROUND((IFNULL(photo_score,60)+85.08+64.19+82.08+99.38)/5,2) WHERE listing_id=51;
UPDATE LISTING_ANALYTICS SET view_count=555, follower_count=2207, details_score=62.71, condition_score=97.44, shipping_score=38.64, pricing_score=63.74, view_to_bid_score=5.83, completeness_score=ROUND((IFNULL(photo_score,60)+62.71+97.44+38.64+63.74)/5,2) WHERE listing_id=52;
UPDATE LISTING_ANALYTICS SET view_count=118, follower_count=9401, details_score=57.36, condition_score=93.24, shipping_score=83.68, pricing_score=99.06, view_to_bid_score=21.57, completeness_score=ROUND((IFNULL(photo_score,60)+57.36+93.24+83.68+99.06)/5,2) WHERE listing_id=53;
UPDATE LISTING_ANALYTICS SET view_count=568, follower_count=6743, details_score=61.12, condition_score=60.89, shipping_score=93.03, pricing_score=56.73, view_to_bid_score=17.3, completeness_score=ROUND((IFNULL(photo_score,60)+61.12+60.89+93.03+56.73)/5,2) WHERE listing_id=54;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=1780, details_score=79.85, condition_score=84.34, shipping_score=74.32, pricing_score=78.17, view_to_bid_score=11.8, completeness_score=ROUND((IFNULL(photo_score,60)+79.85+84.34+74.32+78.17)/5,2) WHERE listing_id=55;
UPDATE LISTING_ANALYTICS SET view_count=550, follower_count=6475, details_score=53.51, condition_score=70.2, shipping_score=82.98, pricing_score=57.18, view_to_bid_score=20.45, completeness_score=ROUND((IFNULL(photo_score,60)+53.51+70.2+82.98+57.18)/5,2) WHERE listing_id=56;
UPDATE LISTING_ANALYTICS SET view_count=165, follower_count=2960, details_score=64.0, condition_score=50.17, shipping_score=88.09, pricing_score=85.78, view_to_bid_score=14.95, completeness_score=ROUND((IFNULL(photo_score,60)+64.0+50.17+88.09+85.78)/5,2) WHERE listing_id=57;
UPDATE LISTING_ANALYTICS SET view_count=704, follower_count=1660, details_score=63.0, condition_score=82.66, shipping_score=98.2, pricing_score=64.62, view_to_bid_score=14.55, completeness_score=ROUND((IFNULL(photo_score,60)+63.0+82.66+98.2+64.62)/5,2) WHERE listing_id=58;
UPDATE LISTING_ANALYTICS SET view_count=638, follower_count=3723, details_score=48.31, condition_score=81.0, shipping_score=99.92, pricing_score=75.97, view_to_bid_score=16.51, completeness_score=ROUND((IFNULL(photo_score,60)+48.31+81.0+99.92+75.97)/5,2) WHERE listing_id=59;
UPDATE LISTING_ANALYTICS SET view_count=28, follower_count=5375, details_score=76.59, condition_score=58.32, shipping_score=73.78, pricing_score=81.06, view_to_bid_score=21.01, completeness_score=ROUND((IFNULL(photo_score,60)+76.59+58.32+73.78+81.06)/5,2) WHERE listing_id=60;
UPDATE LISTING_ANALYTICS SET view_count=28, follower_count=9902, details_score=93.01, condition_score=82.71, shipping_score=68.64, pricing_score=91.81, view_to_bid_score=18.93, completeness_score=ROUND((IFNULL(photo_score,60)+93.01+82.71+68.64+91.81)/5,2) WHERE listing_id=61;
UPDATE LISTING_ANALYTICS SET view_count=170, follower_count=7550, details_score=62.14, condition_score=93.73, shipping_score=42.26, pricing_score=96.23, view_to_bid_score=20.39, completeness_score=ROUND((IFNULL(photo_score,60)+62.14+93.73+42.26+96.23)/5,2) WHERE listing_id=62;
UPDATE LISTING_ANALYTICS SET view_count=335, follower_count=2223, details_score=57.58, condition_score=94.72, shipping_score=44.49, pricing_score=67.67, view_to_bid_score=6.52, completeness_score=ROUND((IFNULL(photo_score,60)+57.58+94.72+44.49+67.67)/5,2) WHERE listing_id=63;
UPDATE LISTING_ANALYTICS SET view_count=622, follower_count=7318, details_score=99.38, condition_score=89.84, shipping_score=98.1, pricing_score=70.01, view_to_bid_score=3.78, completeness_score=ROUND((IFNULL(photo_score,60)+99.38+89.84+98.1+70.01)/5,2) WHERE listing_id=64;
UPDATE LISTING_ANALYTICS SET view_count=623, follower_count=5477, details_score=92.33, condition_score=95.44, shipping_score=47.14, pricing_score=83.32, view_to_bid_score=2.93, completeness_score=ROUND((IFNULL(photo_score,60)+92.33+95.44+47.14+83.32)/5,2) WHERE listing_id=65;
UPDATE LISTING_ANALYTICS SET view_count=771, follower_count=579, details_score=80.92, condition_score=70.32, shipping_score=66.38, pricing_score=68.21, view_to_bid_score=9.4, completeness_score=ROUND((IFNULL(photo_score,60)+80.92+70.32+66.38+68.21)/5,2) WHERE listing_id=66;
UPDATE LISTING_ANALYTICS SET view_count=432, follower_count=4310, details_score=93.0, condition_score=76.87, shipping_score=80.11, pricing_score=76.42, view_to_bid_score=21.78, completeness_score=ROUND((IFNULL(photo_score,60)+93.0+76.87+80.11+76.42)/5,2) WHERE listing_id=67;
UPDATE LISTING_ANALYTICS SET view_count=736, follower_count=438, details_score=66.31, condition_score=91.39, shipping_score=34.19, pricing_score=88.7, view_to_bid_score=18.48, completeness_score=ROUND((IFNULL(photo_score,60)+66.31+91.39+34.19+88.7)/5,2) WHERE listing_id=68;
UPDATE LISTING_ANALYTICS SET view_count=747, follower_count=703, details_score=61.8, condition_score=85.83, shipping_score=65.81, pricing_score=78.98, view_to_bid_score=10.29, completeness_score=ROUND((IFNULL(photo_score,60)+61.8+85.83+65.81+78.98)/5,2) WHERE listing_id=69;
UPDATE LISTING_ANALYTICS SET view_count=132, follower_count=1747, details_score=48.76, condition_score=63.12, shipping_score=87.77, pricing_score=85.21, view_to_bid_score=3.79, completeness_score=ROUND((IFNULL(photo_score,60)+48.76+63.12+87.77+85.21)/5,2) WHERE listing_id=70;
UPDATE LISTING_ANALYTICS SET view_count=178, follower_count=6054, details_score=64.77, condition_score=66.99, shipping_score=93.91, pricing_score=87.73, view_to_bid_score=5.81, completeness_score=ROUND((IFNULL(photo_score,60)+64.77+66.99+93.91+87.73)/5,2) WHERE listing_id=71;
UPDATE LISTING_ANALYTICS SET view_count=104, follower_count=5457, details_score=78.52, condition_score=53.7, shipping_score=92.94, pricing_score=69.49, view_to_bid_score=6.52, completeness_score=ROUND((IFNULL(photo_score,60)+78.52+53.7+92.94+69.49)/5,2) WHERE listing_id=72;
UPDATE LISTING_ANALYTICS SET view_count=271, follower_count=5660, details_score=57.72, condition_score=72.23, shipping_score=85.12, pricing_score=81.97, view_to_bid_score=13.15, completeness_score=ROUND((IFNULL(photo_score,60)+57.72+72.23+85.12+81.97)/5,2) WHERE listing_id=73;
UPDATE LISTING_ANALYTICS SET view_count=613, follower_count=635, details_score=85.68, condition_score=57.4, shipping_score=50.19, pricing_score=53.26, view_to_bid_score=9.1, completeness_score=ROUND((IFNULL(photo_score,60)+85.68+57.4+50.19+53.26)/5,2) WHERE listing_id=74;
UPDATE LISTING_ANALYTICS SET view_count=376, follower_count=11744, details_score=57.47, condition_score=97.24, shipping_score=41.08, pricing_score=78.03, view_to_bid_score=11.24, completeness_score=ROUND((IFNULL(photo_score,60)+57.47+97.24+41.08+78.03)/5,2) WHERE listing_id=75;
UPDATE LISTING_ANALYTICS SET view_count=455, follower_count=11080, details_score=57.69, condition_score=87.19, shipping_score=78.66, pricing_score=48.79, view_to_bid_score=7.49, completeness_score=ROUND((IFNULL(photo_score,60)+57.69+87.19+78.66+48.79)/5,2) WHERE listing_id=76;
UPDATE LISTING_ANALYTICS SET view_count=398, follower_count=4265, details_score=78.21, condition_score=51.4, shipping_score=44.82, pricing_score=58.18, view_to_bid_score=13.48, completeness_score=ROUND((IFNULL(photo_score,60)+78.21+51.4+44.82+58.18)/5,2) WHERE listing_id=77;
UPDATE LISTING_ANALYTICS SET view_count=270, follower_count=6016, details_score=83.27, condition_score=87.27, shipping_score=99.73, pricing_score=64.35, view_to_bid_score=14.18, completeness_score=ROUND((IFNULL(photo_score,60)+83.27+87.27+99.73+64.35)/5,2) WHERE listing_id=78;
UPDATE LISTING_ANALYTICS SET view_count=179, follower_count=5689, details_score=78.63, condition_score=79.36, shipping_score=65.08, pricing_score=71.4, view_to_bid_score=9.25, completeness_score=ROUND((IFNULL(photo_score,60)+78.63+79.36+65.08+71.4)/5,2) WHERE listing_id=79;
UPDATE LISTING_ANALYTICS SET view_count=501, follower_count=10673, details_score=50.15, condition_score=76.26, shipping_score=42.28, pricing_score=93.83, view_to_bid_score=1.79, completeness_score=ROUND((IFNULL(photo_score,60)+50.15+76.26+42.28+93.83)/5,2) WHERE listing_id=80;
UPDATE LISTING_ANALYTICS SET view_count=71, follower_count=5659, details_score=53.49, condition_score=60.32, shipping_score=40.51, pricing_score=76.52, view_to_bid_score=16.44, completeness_score=ROUND((IFNULL(photo_score,60)+53.49+60.32+40.51+76.52)/5,2) WHERE listing_id=81;
UPDATE LISTING_ANALYTICS SET view_count=127, follower_count=10699, details_score=51.82, condition_score=74.94, shipping_score=69.86, pricing_score=78.32, view_to_bid_score=1.75, completeness_score=ROUND((IFNULL(photo_score,60)+51.82+74.94+69.86+78.32)/5,2) WHERE listing_id=82;
UPDATE LISTING_ANALYTICS SET view_count=769, follower_count=8637, details_score=93.89, condition_score=87.07, shipping_score=55.45, pricing_score=41.97, view_to_bid_score=14.34, completeness_score=ROUND((IFNULL(photo_score,60)+93.89+87.07+55.45+41.97)/5,2) WHERE listing_id=83;
UPDATE LISTING_ANALYTICS SET view_count=342, follower_count=8363, details_score=44.03, condition_score=77.66, shipping_score=67.43, pricing_score=84.48, view_to_bid_score=19.39, completeness_score=ROUND((IFNULL(photo_score,60)+44.03+77.66+67.43+84.48)/5,2) WHERE listing_id=84;
UPDATE LISTING_ANALYTICS SET view_count=62, follower_count=7367, details_score=74.0, condition_score=62.4, shipping_score=47.93, pricing_score=84.37, view_to_bid_score=15.64, completeness_score=ROUND((IFNULL(photo_score,60)+74.0+62.4+47.93+84.37)/5,2) WHERE listing_id=85;
UPDATE LISTING_ANALYTICS SET view_count=671, follower_count=4065, details_score=53.7, condition_score=85.87, shipping_score=42.42, pricing_score=98.76, view_to_bid_score=6.95, completeness_score=ROUND((IFNULL(photo_score,60)+53.7+85.87+42.42+98.76)/5,2) WHERE listing_id=86;
UPDATE LISTING_ANALYTICS SET view_count=289, follower_count=1546, details_score=84.59, condition_score=86.67, shipping_score=94.22, pricing_score=94.37, view_to_bid_score=4.22, completeness_score=ROUND((IFNULL(photo_score,60)+84.59+86.67+94.22+94.37)/5,2) WHERE listing_id=87;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=1047, details_score=52.46, condition_score=62.2, shipping_score=83.32, pricing_score=68.64, view_to_bid_score=3.51, completeness_score=ROUND((IFNULL(photo_score,60)+52.46+62.2+83.32+68.64)/5,2) WHERE listing_id=88;
UPDATE LISTING_ANALYTICS SET view_count=57, follower_count=5274, details_score=87.4, condition_score=53.65, shipping_score=63.48, pricing_score=66.51, view_to_bid_score=11.26, completeness_score=ROUND((IFNULL(photo_score,60)+87.4+53.65+63.48+66.51)/5,2) WHERE listing_id=89;
UPDATE LISTING_ANALYTICS SET view_count=107, follower_count=8936, details_score=75.36, condition_score=79.91, shipping_score=51.0, pricing_score=40.58, view_to_bid_score=10.31, completeness_score=ROUND((IFNULL(photo_score,60)+75.36+79.91+51.0+40.58)/5,2) WHERE listing_id=90;
UPDATE LISTING_ANALYTICS SET view_count=119, follower_count=11846, details_score=93.19, condition_score=88.87, shipping_score=43.64, pricing_score=88.35, view_to_bid_score=14.1, completeness_score=ROUND((IFNULL(photo_score,60)+93.19+88.87+43.64+88.35)/5,2) WHERE listing_id=91;
UPDATE LISTING_ANALYTICS SET view_count=472, follower_count=58, details_score=55.1, condition_score=70.36, shipping_score=48.95, pricing_score=77.87, view_to_bid_score=8.24, completeness_score=ROUND((IFNULL(photo_score,60)+55.1+70.36+48.95+77.87)/5,2) WHERE listing_id=92;
UPDATE LISTING_ANALYTICS SET view_count=499, follower_count=8474, details_score=57.03, condition_score=82.26, shipping_score=48.49, pricing_score=71.93, view_to_bid_score=8.49, completeness_score=ROUND((IFNULL(photo_score,60)+57.03+82.26+48.49+71.93)/5,2) WHERE listing_id=93;
UPDATE LISTING_ANALYTICS SET view_count=699, follower_count=9245, details_score=70.18, condition_score=81.3, shipping_score=37.8, pricing_score=85.4, view_to_bid_score=5.23, completeness_score=ROUND((IFNULL(photo_score,60)+70.18+81.3+37.8+85.4)/5,2) WHERE listing_id=94;
UPDATE LISTING_ANALYTICS SET view_count=11, follower_count=5279, details_score=93.6, condition_score=75.48, shipping_score=64.71, pricing_score=50.73, view_to_bid_score=17.09, completeness_score=ROUND((IFNULL(photo_score,60)+93.6+75.48+64.71+50.73)/5,2) WHERE listing_id=95;
UPDATE LISTING_ANALYTICS SET view_count=694, follower_count=5041, details_score=45.67, condition_score=93.1, shipping_score=53.97, pricing_score=81.22, view_to_bid_score=18.36, completeness_score=ROUND((IFNULL(photo_score,60)+45.67+93.1+53.97+81.22)/5,2) WHERE listing_id=96;
UPDATE LISTING_ANALYTICS SET view_count=203, follower_count=1831, details_score=85.77, condition_score=60.66, shipping_score=65.12, pricing_score=59.2, view_to_bid_score=12.37, completeness_score=ROUND((IFNULL(photo_score,60)+85.77+60.66+65.12+59.2)/5,2) WHERE listing_id=97;
UPDATE LISTING_ANALYTICS SET view_count=110, follower_count=11268, details_score=58.0, condition_score=80.48, shipping_score=69.97, pricing_score=49.28, view_to_bid_score=4.71, completeness_score=ROUND((IFNULL(photo_score,60)+58.0+80.48+69.97+49.28)/5,2) WHERE listing_id=98;
UPDATE LISTING_ANALYTICS SET view_count=789, follower_count=6541, details_score=87.15, condition_score=92.62, shipping_score=72.71, pricing_score=49.43, view_to_bid_score=21.11, completeness_score=ROUND((IFNULL(photo_score,60)+87.15+92.62+72.71+49.43)/5,2) WHERE listing_id=99;
UPDATE LISTING_ANALYTICS SET view_count=490, follower_count=10756, details_score=75.71, condition_score=70.85, shipping_score=80.85, pricing_score=53.72, view_to_bid_score=6.89, completeness_score=ROUND((IFNULL(photo_score,60)+75.71+70.85+80.85+53.72)/5,2) WHERE listing_id=100;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=6125, details_score=48.7, condition_score=66.69, shipping_score=54.78, pricing_score=84.71, view_to_bid_score=10.72, completeness_score=ROUND((IFNULL(photo_score,60)+48.7+66.69+54.78+84.71)/5,2) WHERE listing_id=101;
UPDATE LISTING_ANALYTICS SET view_count=440, follower_count=9278, details_score=63.61, condition_score=70.86, shipping_score=83.36, pricing_score=64.24, view_to_bid_score=21.36, completeness_score=ROUND((IFNULL(photo_score,60)+63.61+70.86+83.36+64.24)/5,2) WHERE listing_id=102;
UPDATE LISTING_ANALYTICS SET view_count=367, follower_count=10630, details_score=88.32, condition_score=98.75, shipping_score=83.69, pricing_score=41.17, view_to_bid_score=15.94, completeness_score=ROUND((IFNULL(photo_score,60)+88.32+98.75+83.69+41.17)/5,2) WHERE listing_id=103;
UPDATE LISTING_ANALYTICS SET view_count=218, follower_count=10897, details_score=83.0, condition_score=64.74, shipping_score=56.14, pricing_score=59.31, view_to_bid_score=17.71, completeness_score=ROUND((IFNULL(photo_score,60)+83.0+64.74+56.14+59.31)/5,2) WHERE listing_id=104;
UPDATE LISTING_ANALYTICS SET view_count=338, follower_count=9193, details_score=73.6, condition_score=59.97, shipping_score=45.05, pricing_score=70.18, view_to_bid_score=19.06, completeness_score=ROUND((IFNULL(photo_score,60)+73.6+59.97+45.05+70.18)/5,2) WHERE listing_id=105;
UPDATE LISTING_ANALYTICS SET view_count=114, follower_count=1269, details_score=54.59, condition_score=66.27, shipping_score=63.58, pricing_score=83.28, view_to_bid_score=11.13, completeness_score=ROUND((IFNULL(photo_score,60)+54.59+66.27+63.58+83.28)/5,2) WHERE listing_id=106;
UPDATE LISTING_ANALYTICS SET view_count=52, follower_count=10853, details_score=63.4, condition_score=97.99, shipping_score=79.45, pricing_score=54.99, view_to_bid_score=21.73, completeness_score=ROUND((IFNULL(photo_score,60)+63.4+97.99+79.45+54.99)/5,2) WHERE listing_id=107;
UPDATE LISTING_ANALYTICS SET view_count=605, follower_count=6194, details_score=43.56, condition_score=52.81, shipping_score=53.99, pricing_score=72.27, view_to_bid_score=10.48, completeness_score=ROUND((IFNULL(photo_score,60)+43.56+52.81+53.99+72.27)/5,2) WHERE listing_id=108;
UPDATE LISTING_ANALYTICS SET view_count=296, follower_count=1869, details_score=68.31, condition_score=94.04, shipping_score=35.18, pricing_score=98.63, view_to_bid_score=16.52, completeness_score=ROUND((IFNULL(photo_score,60)+68.31+94.04+35.18+98.63)/5,2) WHERE listing_id=109;
UPDATE LISTING_ANALYTICS SET view_count=160, follower_count=2514, details_score=75.39, condition_score=78.7, shipping_score=69.33, pricing_score=66.3, view_to_bid_score=8.22, completeness_score=ROUND((IFNULL(photo_score,60)+75.39+78.7+69.33+66.3)/5,2) WHERE listing_id=110;
UPDATE LISTING_ANALYTICS SET view_count=564, follower_count=10874, details_score=55.64, condition_score=76.55, shipping_score=50.4, pricing_score=41.31, view_to_bid_score=17.33, completeness_score=ROUND((IFNULL(photo_score,60)+55.64+76.55+50.4+41.31)/5,2) WHERE listing_id=111;
UPDATE LISTING_ANALYTICS SET view_count=74, follower_count=11506, details_score=82.68, condition_score=65.7, shipping_score=89.74, pricing_score=94.31, view_to_bid_score=10.64, completeness_score=ROUND((IFNULL(photo_score,60)+82.68+65.7+89.74+94.31)/5,2) WHERE listing_id=112;
UPDATE LISTING_ANALYTICS SET view_count=224, follower_count=3066, details_score=59.28, condition_score=61.38, shipping_score=55.35, pricing_score=51.94, view_to_bid_score=21.41, completeness_score=ROUND((IFNULL(photo_score,60)+59.28+61.38+55.35+51.94)/5,2) WHERE listing_id=113;
UPDATE LISTING_ANALYTICS SET view_count=270, follower_count=4233, details_score=76.22, condition_score=96.63, shipping_score=39.82, pricing_score=78.53, view_to_bid_score=10.26, completeness_score=ROUND((IFNULL(photo_score,60)+76.22+96.63+39.82+78.53)/5,2) WHERE listing_id=114;
UPDATE LISTING_ANALYTICS SET view_count=503, follower_count=836, details_score=89.9, condition_score=53.01, shipping_score=99.28, pricing_score=62.41, view_to_bid_score=13.1, completeness_score=ROUND((IFNULL(photo_score,60)+89.9+53.01+99.28+62.41)/5,2) WHERE listing_id=115;
UPDATE LISTING_ANALYTICS SET view_count=37, follower_count=8311, details_score=92.38, condition_score=66.35, shipping_score=67.72, pricing_score=56.96, view_to_bid_score=8.34, completeness_score=ROUND((IFNULL(photo_score,60)+92.38+66.35+67.72+56.96)/5,2) WHERE listing_id=116;
UPDATE LISTING_ANALYTICS SET view_count=73, follower_count=1287, details_score=73.92, condition_score=98.71, shipping_score=84.64, pricing_score=71.91, view_to_bid_score=17.87, completeness_score=ROUND((IFNULL(photo_score,60)+73.92+98.71+84.64+71.91)/5,2) WHERE listing_id=117;
UPDATE LISTING_ANALYTICS SET view_count=94, follower_count=9453, details_score=95.35, condition_score=80.5, shipping_score=99.51, pricing_score=85.11, view_to_bid_score=17.23, completeness_score=ROUND((IFNULL(photo_score,60)+95.35+80.5+99.51+85.11)/5,2) WHERE listing_id=118;
UPDATE LISTING_ANALYTICS SET view_count=446, follower_count=4586, details_score=67.94, condition_score=94.47, shipping_score=99.6, pricing_score=49.13, view_to_bid_score=8.27, completeness_score=ROUND((IFNULL(photo_score,60)+67.94+94.47+99.6+49.13)/5,2) WHERE listing_id=119;
UPDATE LISTING_ANALYTICS SET view_count=191, follower_count=10664, details_score=74.51, condition_score=72.7, shipping_score=84.68, pricing_score=84.37, view_to_bid_score=20.94, completeness_score=ROUND((IFNULL(photo_score,60)+74.51+72.7+84.68+84.37)/5,2) WHERE listing_id=120;
UPDATE LISTING_ANALYTICS SET view_count=26, follower_count=6627, details_score=74.48, condition_score=50.32, shipping_score=87.98, pricing_score=41.13, view_to_bid_score=6.12, completeness_score=ROUND((IFNULL(photo_score,60)+74.48+50.32+87.98+41.13)/5,2) WHERE listing_id=121;
UPDATE LISTING_ANALYTICS SET view_count=442, follower_count=2515, details_score=55.53, condition_score=61.14, shipping_score=77.22, pricing_score=59.6, view_to_bid_score=10.88, completeness_score=ROUND((IFNULL(photo_score,60)+55.53+61.14+77.22+59.6)/5,2) WHERE listing_id=122;
UPDATE LISTING_ANALYTICS SET view_count=686, follower_count=3332, details_score=86.2, condition_score=78.72, shipping_score=54.83, pricing_score=92.82, view_to_bid_score=19.28, completeness_score=ROUND((IFNULL(photo_score,60)+86.2+78.72+54.83+92.82)/5,2) WHERE listing_id=123;
UPDATE LISTING_ANALYTICS SET view_count=161, follower_count=3144, details_score=86.38, condition_score=60.31, shipping_score=42.71, pricing_score=41.57, view_to_bid_score=13.84, completeness_score=ROUND((IFNULL(photo_score,60)+86.38+60.31+42.71+41.57)/5,2) WHERE listing_id=124;
UPDATE LISTING_ANALYTICS SET view_count=45, follower_count=2136, details_score=72.4, condition_score=97.73, shipping_score=52.92, pricing_score=58.92, view_to_bid_score=6.22, completeness_score=ROUND((IFNULL(photo_score,60)+72.4+97.73+52.92+58.92)/5,2) WHERE listing_id=125;
UPDATE LISTING_ANALYTICS SET view_count=218, follower_count=3354, details_score=58.18, condition_score=71.21, shipping_score=48.98, pricing_score=96.18, view_to_bid_score=5.95, completeness_score=ROUND((IFNULL(photo_score,60)+58.18+71.21+48.98+96.18)/5,2) WHERE listing_id=126;
UPDATE LISTING_ANALYTICS SET view_count=368, follower_count=497, details_score=48.24, condition_score=94.94, shipping_score=60.77, pricing_score=90.05, view_to_bid_score=9.19, completeness_score=ROUND((IFNULL(photo_score,60)+48.24+94.94+60.77+90.05)/5,2) WHERE listing_id=127;
UPDATE LISTING_ANALYTICS SET view_count=459, follower_count=3467, details_score=62.82, condition_score=72.34, shipping_score=57.94, pricing_score=52.34, view_to_bid_score=9.3, completeness_score=ROUND((IFNULL(photo_score,60)+62.82+72.34+57.94+52.34)/5,2) WHERE listing_id=128;
UPDATE LISTING_ANALYTICS SET view_count=132, follower_count=1571, details_score=98.15, condition_score=75.34, shipping_score=70.48, pricing_score=70.99, view_to_bid_score=4.84, completeness_score=ROUND((IFNULL(photo_score,60)+98.15+75.34+70.48+70.99)/5,2) WHERE listing_id=129;
UPDATE LISTING_ANALYTICS SET view_count=219, follower_count=2021, details_score=96.44, condition_score=87.03, shipping_score=55.09, pricing_score=99.72, view_to_bid_score=10.01, completeness_score=ROUND((IFNULL(photo_score,60)+96.44+87.03+55.09+99.72)/5,2) WHERE listing_id=130;
UPDATE LISTING_ANALYTICS SET view_count=220, follower_count=1537, details_score=87.99, condition_score=67.99, shipping_score=47.87, pricing_score=46.72, view_to_bid_score=10.87, completeness_score=ROUND((IFNULL(photo_score,60)+87.99+67.99+47.87+46.72)/5,2) WHERE listing_id=131;
UPDATE LISTING_ANALYTICS SET view_count=12, follower_count=6276, details_score=88.2, condition_score=70.02, shipping_score=90.02, pricing_score=61.28, view_to_bid_score=20.89, completeness_score=ROUND((IFNULL(photo_score,60)+88.2+70.02+90.02+61.28)/5,2) WHERE listing_id=132;
UPDATE LISTING_ANALYTICS SET view_count=71, follower_count=7163, details_score=96.76, condition_score=82.6, shipping_score=46.06, pricing_score=82.07, view_to_bid_score=14.83, completeness_score=ROUND((IFNULL(photo_score,60)+96.76+82.6+46.06+82.07)/5,2) WHERE listing_id=133;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=7772, details_score=40.95, condition_score=98.21, shipping_score=81.07, pricing_score=93.84, view_to_bid_score=2.43, completeness_score=ROUND((IFNULL(photo_score,60)+40.95+98.21+81.07+93.84)/5,2) WHERE listing_id=134;
UPDATE LISTING_ANALYTICS SET view_count=259, follower_count=2955, details_score=73.87, condition_score=56.4, shipping_score=40.9, pricing_score=81.7, view_to_bid_score=17.13, completeness_score=ROUND((IFNULL(photo_score,60)+73.87+56.4+40.9+81.7)/5,2) WHERE listing_id=135;
UPDATE LISTING_ANALYTICS SET view_count=67, follower_count=9818, details_score=88.14, condition_score=93.32, shipping_score=76.27, pricing_score=62.3, view_to_bid_score=10.0, completeness_score=ROUND((IFNULL(photo_score,60)+88.14+93.32+76.27+62.3)/5,2) WHERE listing_id=136;
UPDATE LISTING_ANALYTICS SET view_count=166, follower_count=6918, details_score=50.35, condition_score=96.81, shipping_score=97.57, pricing_score=84.52, view_to_bid_score=18.11, completeness_score=ROUND((IFNULL(photo_score,60)+50.35+96.81+97.57+84.52)/5,2) WHERE listing_id=137;
UPDATE LISTING_ANALYTICS SET view_count=190, follower_count=6031, details_score=92.74, condition_score=55.47, shipping_score=41.37, pricing_score=69.85, view_to_bid_score=7.77, completeness_score=ROUND((IFNULL(photo_score,60)+92.74+55.47+41.37+69.85)/5,2) WHERE listing_id=138;
UPDATE LISTING_ANALYTICS SET view_count=645, follower_count=6164, details_score=94.54, condition_score=63.26, shipping_score=52.48, pricing_score=87.0, view_to_bid_score=8.3, completeness_score=ROUND((IFNULL(photo_score,60)+94.54+63.26+52.48+87.0)/5,2) WHERE listing_id=139;
UPDATE LISTING_ANALYTICS SET view_count=486, follower_count=610, details_score=84.1, condition_score=57.22, shipping_score=58.54, pricing_score=72.37, view_to_bid_score=17.13, completeness_score=ROUND((IFNULL(photo_score,60)+84.1+57.22+58.54+72.37)/5,2) WHERE listing_id=140;
UPDATE LISTING_ANALYTICS SET view_count=744, follower_count=8654, details_score=50.18, condition_score=55.01, shipping_score=54.41, pricing_score=53.36, view_to_bid_score=10.11, completeness_score=ROUND((IFNULL(photo_score,60)+50.18+55.01+54.41+53.36)/5,2) WHERE listing_id=141;
UPDATE LISTING_ANALYTICS SET view_count=72, follower_count=1891, details_score=98.12, condition_score=73.22, shipping_score=59.06, pricing_score=93.89, view_to_bid_score=10.53, completeness_score=ROUND((IFNULL(photo_score,60)+98.12+73.22+59.06+93.89)/5,2) WHERE listing_id=142;
UPDATE LISTING_ANALYTICS SET view_count=622, follower_count=10484, details_score=40.04, condition_score=73.81, shipping_score=92.97, pricing_score=55.41, view_to_bid_score=8.12, completeness_score=ROUND((IFNULL(photo_score,60)+40.04+73.81+92.97+55.41)/5,2) WHERE listing_id=143;
UPDATE LISTING_ANALYTICS SET view_count=557, follower_count=6039, details_score=97.41, condition_score=83.42, shipping_score=36.75, pricing_score=69.57, view_to_bid_score=18.54, completeness_score=ROUND((IFNULL(photo_score,60)+97.41+83.42+36.75+69.57)/5,2) WHERE listing_id=144;
UPDATE LISTING_ANALYTICS SET view_count=589, follower_count=3265, details_score=47.55, condition_score=75.74, shipping_score=86.38, pricing_score=48.56, view_to_bid_score=15.01, completeness_score=ROUND((IFNULL(photo_score,60)+47.55+75.74+86.38+48.56)/5,2) WHERE listing_id=145;
UPDATE LISTING_ANALYTICS SET view_count=766, follower_count=1603, details_score=83.04, condition_score=64.11, shipping_score=73.05, pricing_score=54.99, view_to_bid_score=6.64, completeness_score=ROUND((IFNULL(photo_score,60)+83.04+64.11+73.05+54.99)/5,2) WHERE listing_id=146;
UPDATE LISTING_ANALYTICS SET view_count=752, follower_count=10853, details_score=58.07, condition_score=85.52, shipping_score=62.35, pricing_score=75.45, view_to_bid_score=12.1, completeness_score=ROUND((IFNULL(photo_score,60)+58.07+85.52+62.35+75.45)/5,2) WHERE listing_id=147;
UPDATE LISTING_ANALYTICS SET view_count=278, follower_count=2207, details_score=59.68, condition_score=68.74, shipping_score=40.17, pricing_score=84.18, view_to_bid_score=18.94, completeness_score=ROUND((IFNULL(photo_score,60)+59.68+68.74+40.17+84.18)/5,2) WHERE listing_id=148;
UPDATE LISTING_ANALYTICS SET view_count=770, follower_count=6358, details_score=77.91, condition_score=89.71, shipping_score=98.57, pricing_score=40.86, view_to_bid_score=14.51, completeness_score=ROUND((IFNULL(photo_score,60)+77.91+89.71+98.57+40.86)/5,2) WHERE listing_id=149;
UPDATE LISTING_ANALYTICS SET view_count=248, follower_count=2702, details_score=63.81, condition_score=50.59, shipping_score=63.65, pricing_score=91.46, view_to_bid_score=5.35, completeness_score=ROUND((IFNULL(photo_score,60)+63.81+50.59+63.65+91.46)/5,2) WHERE listing_id=150;
UPDATE LISTING_ANALYTICS SET view_count=596, follower_count=6696, details_score=67.13, condition_score=60.74, shipping_score=73.49, pricing_score=72.75, view_to_bid_score=3.92, completeness_score=ROUND((IFNULL(photo_score,60)+67.13+60.74+73.49+72.75)/5,2) WHERE listing_id=151;
UPDATE LISTING_ANALYTICS SET view_count=291, follower_count=10789, details_score=86.11, condition_score=96.19, shipping_score=53.61, pricing_score=93.55, view_to_bid_score=6.73, completeness_score=ROUND((IFNULL(photo_score,60)+86.11+96.19+53.61+93.55)/5,2) WHERE listing_id=152;
UPDATE LISTING_ANALYTICS SET view_count=504, follower_count=9043, details_score=67.38, condition_score=54.83, shipping_score=89.94, pricing_score=85.8, view_to_bid_score=6.89, completeness_score=ROUND((IFNULL(photo_score,60)+67.38+54.83+89.94+85.8)/5,2) WHERE listing_id=153;
UPDATE LISTING_ANALYTICS SET view_count=379, follower_count=7038, details_score=78.54, condition_score=98.24, shipping_score=38.84, pricing_score=53.63, view_to_bid_score=10.88, completeness_score=ROUND((IFNULL(photo_score,60)+78.54+98.24+38.84+53.63)/5,2) WHERE listing_id=154;
UPDATE LISTING_ANALYTICS SET view_count=118, follower_count=2020, details_score=73.03, condition_score=64.79, shipping_score=91.13, pricing_score=58.42, view_to_bid_score=10.44, completeness_score=ROUND((IFNULL(photo_score,60)+73.03+64.79+91.13+58.42)/5,2) WHERE listing_id=155;
UPDATE LISTING_ANALYTICS SET view_count=89, follower_count=8319, details_score=50.96, condition_score=91.0, shipping_score=91.99, pricing_score=70.65, view_to_bid_score=4.41, completeness_score=ROUND((IFNULL(photo_score,60)+50.96+91.0+91.99+70.65)/5,2) WHERE listing_id=156;
UPDATE LISTING_ANALYTICS SET view_count=701, follower_count=3684, details_score=86.55, condition_score=59.93, shipping_score=82.12, pricing_score=71.53, view_to_bid_score=17.49, completeness_score=ROUND((IFNULL(photo_score,60)+86.55+59.93+82.12+71.53)/5,2) WHERE listing_id=157;
UPDATE LISTING_ANALYTICS SET view_count=581, follower_count=8742, details_score=71.5, condition_score=90.01, shipping_score=55.39, pricing_score=53.83, view_to_bid_score=20.92, completeness_score=ROUND((IFNULL(photo_score,60)+71.5+90.01+55.39+53.83)/5,2) WHERE listing_id=158;
UPDATE LISTING_ANALYTICS SET view_count=548, follower_count=2782, details_score=62.47, condition_score=55.01, shipping_score=41.59, pricing_score=78.06, view_to_bid_score=14.17, completeness_score=ROUND((IFNULL(photo_score,60)+62.47+55.01+41.59+78.06)/5,2) WHERE listing_id=159;
UPDATE LISTING_ANALYTICS SET view_count=774, follower_count=11782, details_score=49.12, condition_score=97.11, shipping_score=72.68, pricing_score=91.5, view_to_bid_score=7.21, completeness_score=ROUND((IFNULL(photo_score,60)+49.12+97.11+72.68+91.5)/5,2) WHERE listing_id=160;
UPDATE LISTING_ANALYTICS SET view_count=415, follower_count=4907, details_score=63.39, condition_score=76.09, shipping_score=59.49, pricing_score=68.59, view_to_bid_score=8.1, completeness_score=ROUND((IFNULL(photo_score,60)+63.39+76.09+59.49+68.59)/5,2) WHERE listing_id=161;
UPDATE LISTING_ANALYTICS SET view_count=743, follower_count=4965, details_score=40.02, condition_score=62.57, shipping_score=68.9, pricing_score=58.7, view_to_bid_score=20.42, completeness_score=ROUND((IFNULL(photo_score,60)+40.02+62.57+68.9+58.7)/5,2) WHERE listing_id=162;
UPDATE LISTING_ANALYTICS SET view_count=632, follower_count=9781, details_score=97.56, condition_score=52.96, shipping_score=58.73, pricing_score=48.63, view_to_bid_score=18.36, completeness_score=ROUND((IFNULL(photo_score,60)+97.56+52.96+58.73+48.63)/5,2) WHERE listing_id=163;
UPDATE LISTING_ANALYTICS SET view_count=787, follower_count=4022, details_score=63.47, condition_score=57.97, shipping_score=59.33, pricing_score=75.48, view_to_bid_score=6.6, completeness_score=ROUND((IFNULL(photo_score,60)+63.47+57.97+59.33+75.48)/5,2) WHERE listing_id=164;
UPDATE LISTING_ANALYTICS SET view_count=363, follower_count=1205, details_score=53.58, condition_score=97.45, shipping_score=39.83, pricing_score=64.09, view_to_bid_score=16.38, completeness_score=ROUND((IFNULL(photo_score,60)+53.58+97.45+39.83+64.09)/5,2) WHERE listing_id=165;
UPDATE LISTING_ANALYTICS SET view_count=604, follower_count=11065, details_score=49.11, condition_score=72.17, shipping_score=77.06, pricing_score=85.64, view_to_bid_score=1.72, completeness_score=ROUND((IFNULL(photo_score,60)+49.11+72.17+77.06+85.64)/5,2) WHERE listing_id=166;
UPDATE LISTING_ANALYTICS SET view_count=125, follower_count=8579, details_score=58.67, condition_score=55.13, shipping_score=74.0, pricing_score=68.27, view_to_bid_score=15.04, completeness_score=ROUND((IFNULL(photo_score,60)+58.67+55.13+74.0+68.27)/5,2) WHERE listing_id=167;
UPDATE LISTING_ANALYTICS SET view_count=310, follower_count=2095, details_score=72.48, condition_score=80.5, shipping_score=40.76, pricing_score=92.81, view_to_bid_score=16.96, completeness_score=ROUND((IFNULL(photo_score,60)+72.48+80.5+40.76+92.81)/5,2) WHERE listing_id=168;
UPDATE LISTING_ANALYTICS SET view_count=742, follower_count=5643, details_score=92.51, condition_score=97.47, shipping_score=32.87, pricing_score=90.28, view_to_bid_score=6.74, completeness_score=ROUND((IFNULL(photo_score,60)+92.51+97.47+32.87+90.28)/5,2) WHERE listing_id=169;
UPDATE LISTING_ANALYTICS SET view_count=646, follower_count=7693, details_score=65.55, condition_score=58.42, shipping_score=79.68, pricing_score=91.93, view_to_bid_score=11.49, completeness_score=ROUND((IFNULL(photo_score,60)+65.55+58.42+79.68+91.93)/5,2) WHERE listing_id=170;
UPDATE LISTING_ANALYTICS SET view_count=303, follower_count=3730, details_score=71.37, condition_score=54.43, shipping_score=81.22, pricing_score=97.58, view_to_bid_score=19.23, completeness_score=ROUND((IFNULL(photo_score,60)+71.37+54.43+81.22+97.58)/5,2) WHERE listing_id=171;
UPDATE LISTING_ANALYTICS SET view_count=252, follower_count=10943, details_score=69.67, condition_score=85.08, shipping_score=60.27, pricing_score=43.4, view_to_bid_score=3.66, completeness_score=ROUND((IFNULL(photo_score,60)+69.67+85.08+60.27+43.4)/5,2) WHERE listing_id=172;
UPDATE LISTING_ANALYTICS SET view_count=793, follower_count=4640, details_score=90.54, condition_score=86.62, shipping_score=93.33, pricing_score=78.42, view_to_bid_score=8.24, completeness_score=ROUND((IFNULL(photo_score,60)+90.54+86.62+93.33+78.42)/5,2) WHERE listing_id=173;
UPDATE LISTING_ANALYTICS SET view_count=687, follower_count=4166, details_score=98.99, condition_score=54.15, shipping_score=37.08, pricing_score=88.36, view_to_bid_score=6.48, completeness_score=ROUND((IFNULL(photo_score,60)+98.99+54.15+37.08+88.36)/5,2) WHERE listing_id=174;
UPDATE LISTING_ANALYTICS SET view_count=511, follower_count=3677, details_score=75.47, condition_score=83.28, shipping_score=37.28, pricing_score=86.86, view_to_bid_score=16.02, completeness_score=ROUND((IFNULL(photo_score,60)+75.47+83.28+37.28+86.86)/5,2) WHERE listing_id=175;
UPDATE LISTING_ANALYTICS SET view_count=579, follower_count=9989, details_score=90.24, condition_score=68.79, shipping_score=66.33, pricing_score=95.51, view_to_bid_score=9.34, completeness_score=ROUND((IFNULL(photo_score,60)+90.24+68.79+66.33+95.51)/5,2) WHERE listing_id=176;
UPDATE LISTING_ANALYTICS SET view_count=621, follower_count=1816, details_score=75.42, condition_score=89.68, shipping_score=96.79, pricing_score=74.54, view_to_bid_score=3.91, completeness_score=ROUND((IFNULL(photo_score,60)+75.42+89.68+96.79+74.54)/5,2) WHERE listing_id=177;
UPDATE LISTING_ANALYTICS SET view_count=787, follower_count=3959, details_score=61.64, condition_score=83.63, shipping_score=93.27, pricing_score=65.31, view_to_bid_score=9.57, completeness_score=ROUND((IFNULL(photo_score,60)+61.64+83.63+93.27+65.31)/5,2) WHERE listing_id=178;
UPDATE LISTING_ANALYTICS SET view_count=767, follower_count=703, details_score=60.84, condition_score=89.41, shipping_score=89.66, pricing_score=74.4, view_to_bid_score=12.22, completeness_score=ROUND((IFNULL(photo_score,60)+60.84+89.41+89.66+74.4)/5,2) WHERE listing_id=179;
UPDATE LISTING_ANALYTICS SET view_count=413, follower_count=10341, details_score=84.66, condition_score=71.59, shipping_score=93.57, pricing_score=52.96, view_to_bid_score=5.21, completeness_score=ROUND((IFNULL(photo_score,60)+84.66+71.59+93.57+52.96)/5,2) WHERE listing_id=180;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=5439, details_score=45.93, condition_score=96.03, shipping_score=86.13, pricing_score=83.74, view_to_bid_score=18.91, completeness_score=ROUND((IFNULL(photo_score,60)+45.93+96.03+86.13+83.74)/5,2) WHERE listing_id=181;
UPDATE LISTING_ANALYTICS SET view_count=264, follower_count=5925, details_score=89.1, condition_score=67.2, shipping_score=98.15, pricing_score=54.92, view_to_bid_score=10.64, completeness_score=ROUND((IFNULL(photo_score,60)+89.1+67.2+98.15+54.92)/5,2) WHERE listing_id=182;
UPDATE LISTING_ANALYTICS SET view_count=53, follower_count=5366, details_score=67.49, condition_score=99.55, shipping_score=48.42, pricing_score=87.62, view_to_bid_score=5.79, completeness_score=ROUND((IFNULL(photo_score,60)+67.49+99.55+48.42+87.62)/5,2) WHERE listing_id=183;
UPDATE LISTING_ANALYTICS SET view_count=794, follower_count=9016, details_score=78.9, condition_score=87.04, shipping_score=82.73, pricing_score=86.86, view_to_bid_score=5.03, completeness_score=ROUND((IFNULL(photo_score,60)+78.9+87.04+82.73+86.86)/5,2) WHERE listing_id=184;
UPDATE LISTING_ANALYTICS SET view_count=516, follower_count=1506, details_score=60.03, condition_score=80.82, shipping_score=81.79, pricing_score=90.17, view_to_bid_score=6.17, completeness_score=ROUND((IFNULL(photo_score,60)+60.03+80.82+81.79+90.17)/5,2) WHERE listing_id=185;
UPDATE LISTING_ANALYTICS SET view_count=318, follower_count=1709, details_score=94.85, condition_score=54.52, shipping_score=58.42, pricing_score=77.31, view_to_bid_score=14.61, completeness_score=ROUND((IFNULL(photo_score,60)+94.85+54.52+58.42+77.31)/5,2) WHERE listing_id=186;
UPDATE LISTING_ANALYTICS SET view_count=779, follower_count=6320, details_score=52.13, condition_score=92.8, shipping_score=63.98, pricing_score=60.22, view_to_bid_score=10.47, completeness_score=ROUND((IFNULL(photo_score,60)+52.13+92.8+63.98+60.22)/5,2) WHERE listing_id=187;
UPDATE LISTING_ANALYTICS SET view_count=375, follower_count=2658, details_score=97.56, condition_score=66.14, shipping_score=37.8, pricing_score=74.91, view_to_bid_score=20.13, completeness_score=ROUND((IFNULL(photo_score,60)+97.56+66.14+37.8+74.91)/5,2) WHERE listing_id=188;
UPDATE LISTING_ANALYTICS SET view_count=722, follower_count=10573, details_score=73.63, condition_score=87.84, shipping_score=67.68, pricing_score=63.88, view_to_bid_score=15.76, completeness_score=ROUND((IFNULL(photo_score,60)+73.63+87.84+67.68+63.88)/5,2) WHERE listing_id=189;
UPDATE LISTING_ANALYTICS SET view_count=208, follower_count=1579, details_score=45.43, condition_score=79.9, shipping_score=91.39, pricing_score=64.28, view_to_bid_score=6.9, completeness_score=ROUND((IFNULL(photo_score,60)+45.43+79.9+91.39+64.28)/5,2) WHERE listing_id=190;
UPDATE LISTING_ANALYTICS SET view_count=738, follower_count=5623, details_score=71.97, condition_score=69.84, shipping_score=94.49, pricing_score=46.22, view_to_bid_score=21.1, completeness_score=ROUND((IFNULL(photo_score,60)+71.97+69.84+94.49+46.22)/5,2) WHERE listing_id=191;
UPDATE LISTING_ANALYTICS SET view_count=305, follower_count=10100, details_score=74.21, condition_score=54.11, shipping_score=99.96, pricing_score=66.55, view_to_bid_score=2.34, completeness_score=ROUND((IFNULL(photo_score,60)+74.21+54.11+99.96+66.55)/5,2) WHERE listing_id=192;
UPDATE LISTING_ANALYTICS SET view_count=566, follower_count=2589, details_score=80.05, condition_score=63.69, shipping_score=64.61, pricing_score=89.99, view_to_bid_score=21.66, completeness_score=ROUND((IFNULL(photo_score,60)+80.05+63.69+64.61+89.99)/5,2) WHERE listing_id=193;
UPDATE LISTING_ANALYTICS SET view_count=256, follower_count=3750, details_score=66.42, condition_score=90.58, shipping_score=40.18, pricing_score=57.81, view_to_bid_score=21.27, completeness_score=ROUND((IFNULL(photo_score,60)+66.42+90.58+40.18+57.81)/5,2) WHERE listing_id=194;
UPDATE LISTING_ANALYTICS SET view_count=631, follower_count=7967, details_score=90.28, condition_score=70.73, shipping_score=68.59, pricing_score=74.09, view_to_bid_score=9.95, completeness_score=ROUND((IFNULL(photo_score,60)+90.28+70.73+68.59+74.09)/5,2) WHERE listing_id=195;
UPDATE LISTING_ANALYTICS SET view_count=536, follower_count=9567, details_score=63.98, condition_score=78.77, shipping_score=93.16, pricing_score=63.23, view_to_bid_score=6.86, completeness_score=ROUND((IFNULL(photo_score,60)+63.98+78.77+93.16+63.23)/5,2) WHERE listing_id=196;
UPDATE LISTING_ANALYTICS SET view_count=377, follower_count=4368, details_score=65.88, condition_score=68.23, shipping_score=94.79, pricing_score=54.08, view_to_bid_score=12.58, completeness_score=ROUND((IFNULL(photo_score,60)+65.88+68.23+94.79+54.08)/5,2) WHERE listing_id=197;
UPDATE LISTING_ANALYTICS SET view_count=83, follower_count=11407, details_score=48.07, condition_score=93.0, shipping_score=99.04, pricing_score=54.81, view_to_bid_score=12.53, completeness_score=ROUND((IFNULL(photo_score,60)+48.07+93.0+99.04+54.81)/5,2) WHERE listing_id=198;
UPDATE LISTING_ANALYTICS SET view_count=136, follower_count=1633, details_score=98.86, condition_score=89.21, shipping_score=65.52, pricing_score=68.54, view_to_bid_score=7.93, completeness_score=ROUND((IFNULL(photo_score,60)+98.86+89.21+65.52+68.54)/5,2) WHERE listing_id=199;
UPDATE LISTING_ANALYTICS SET view_count=623, follower_count=3782, details_score=83.21, condition_score=85.88, shipping_score=75.15, pricing_score=73.24, view_to_bid_score=21.69, completeness_score=ROUND((IFNULL(photo_score,60)+83.21+85.88+75.15+73.24)/5,2) WHERE listing_id=200;
UPDATE LISTING_ANALYTICS SET view_count=481, follower_count=4459, details_score=74.46, condition_score=52.66, shipping_score=73.32, pricing_score=69.83, view_to_bid_score=10.44, completeness_score=ROUND((IFNULL(photo_score,60)+74.46+52.66+73.32+69.83)/5,2) WHERE listing_id=201;
UPDATE LISTING_ANALYTICS SET view_count=180, follower_count=412, details_score=73.6, condition_score=77.95, shipping_score=34.03, pricing_score=60.86, view_to_bid_score=19.29, completeness_score=ROUND((IFNULL(photo_score,60)+73.6+77.95+34.03+60.86)/5,2) WHERE listing_id=202;
UPDATE LISTING_ANALYTICS SET view_count=156, follower_count=1094, details_score=80.92, condition_score=53.27, shipping_score=80.32, pricing_score=74.19, view_to_bid_score=20.92, completeness_score=ROUND((IFNULL(photo_score,60)+80.92+53.27+80.32+74.19)/5,2) WHERE listing_id=203;
UPDATE LISTING_ANALYTICS SET view_count=750, follower_count=501, details_score=82.82, condition_score=74.54, shipping_score=79.3, pricing_score=96.56, view_to_bid_score=21.72, completeness_score=ROUND((IFNULL(photo_score,60)+82.82+74.54+79.3+96.56)/5,2) WHERE listing_id=204;
UPDATE LISTING_ANALYTICS SET view_count=225, follower_count=10892, details_score=67.13, condition_score=76.92, shipping_score=77.23, pricing_score=59.83, view_to_bid_score=13.18, completeness_score=ROUND((IFNULL(photo_score,60)+67.13+76.92+77.23+59.83)/5,2) WHERE listing_id=205;
UPDATE LISTING_ANALYTICS SET view_count=525, follower_count=6720, details_score=48.65, condition_score=76.98, shipping_score=77.69, pricing_score=58.87, view_to_bid_score=1.64, completeness_score=ROUND((IFNULL(photo_score,60)+48.65+76.98+77.69+58.87)/5,2) WHERE listing_id=206;
UPDATE LISTING_ANALYTICS SET view_count=629, follower_count=917, details_score=82.73, condition_score=67.92, shipping_score=38.38, pricing_score=98.64, view_to_bid_score=14.08, completeness_score=ROUND((IFNULL(photo_score,60)+82.73+67.92+38.38+98.64)/5,2) WHERE listing_id=207;
UPDATE LISTING_ANALYTICS SET view_count=547, follower_count=6828, details_score=83.82, condition_score=86.63, shipping_score=47.42, pricing_score=76.09, view_to_bid_score=17.06, completeness_score=ROUND((IFNULL(photo_score,60)+83.82+86.63+47.42+76.09)/5,2) WHERE listing_id=208;
UPDATE LISTING_ANALYTICS SET view_count=188, follower_count=3019, details_score=41.77, condition_score=96.44, shipping_score=81.01, pricing_score=59.91, view_to_bid_score=3.43, completeness_score=ROUND((IFNULL(photo_score,60)+41.77+96.44+81.01+59.91)/5,2) WHERE listing_id=209;
UPDATE LISTING_ANALYTICS SET view_count=418, follower_count=9454, details_score=82.06, condition_score=84.27, shipping_score=86.34, pricing_score=62.88, view_to_bid_score=11.23, completeness_score=ROUND((IFNULL(photo_score,60)+82.06+84.27+86.34+62.88)/5,2) WHERE listing_id=210;
UPDATE LISTING_ANALYTICS SET view_count=356, follower_count=3048, details_score=45.75, condition_score=67.76, shipping_score=79.51, pricing_score=92.74, view_to_bid_score=11.74, completeness_score=ROUND((IFNULL(photo_score,60)+45.75+67.76+79.51+92.74)/5,2) WHERE listing_id=211;
UPDATE LISTING_ANALYTICS SET view_count=193, follower_count=4318, details_score=64.09, condition_score=61.33, shipping_score=98.99, pricing_score=77.98, view_to_bid_score=8.46, completeness_score=ROUND((IFNULL(photo_score,60)+64.09+61.33+98.99+77.98)/5,2) WHERE listing_id=212;
UPDATE LISTING_ANALYTICS SET view_count=774, follower_count=1590, details_score=71.43, condition_score=51.02, shipping_score=72.43, pricing_score=98.92, view_to_bid_score=2.71, completeness_score=ROUND((IFNULL(photo_score,60)+71.43+51.02+72.43+98.92)/5,2) WHERE listing_id=213;
UPDATE LISTING_ANALYTICS SET view_count=387, follower_count=1614, details_score=50.11, condition_score=98.18, shipping_score=67.04, pricing_score=40.28, view_to_bid_score=9.39, completeness_score=ROUND((IFNULL(photo_score,60)+50.11+98.18+67.04+40.28)/5,2) WHERE listing_id=214;
UPDATE LISTING_ANALYTICS SET view_count=33, follower_count=9357, details_score=73.8, condition_score=92.97, shipping_score=96.9, pricing_score=51.31, view_to_bid_score=14.23, completeness_score=ROUND((IFNULL(photo_score,60)+73.8+92.97+96.9+51.31)/5,2) WHERE listing_id=215;
UPDATE LISTING_ANALYTICS SET view_count=191, follower_count=8818, details_score=53.1, condition_score=67.26, shipping_score=91.05, pricing_score=94.76, view_to_bid_score=13.79, completeness_score=ROUND((IFNULL(photo_score,60)+53.1+67.26+91.05+94.76)/5,2) WHERE listing_id=216;
UPDATE LISTING_ANALYTICS SET view_count=592, follower_count=2948, details_score=93.49, condition_score=85.32, shipping_score=91.58, pricing_score=50.65, view_to_bid_score=4.55, completeness_score=ROUND((IFNULL(photo_score,60)+93.49+85.32+91.58+50.65)/5,2) WHERE listing_id=217;
UPDATE LISTING_ANALYTICS SET view_count=460, follower_count=547, details_score=77.32, condition_score=96.76, shipping_score=92.18, pricing_score=87.62, view_to_bid_score=3.97, completeness_score=ROUND((IFNULL(photo_score,60)+77.32+96.76+92.18+87.62)/5,2) WHERE listing_id=218;
UPDATE LISTING_ANALYTICS SET view_count=324, follower_count=4824, details_score=46.47, condition_score=84.15, shipping_score=71.31, pricing_score=50.04, view_to_bid_score=3.54, completeness_score=ROUND((IFNULL(photo_score,60)+46.47+84.15+71.31+50.04)/5,2) WHERE listing_id=219;
UPDATE LISTING_ANALYTICS SET view_count=202, follower_count=9937, details_score=49.32, condition_score=80.66, shipping_score=53.62, pricing_score=67.28, view_to_bid_score=15.0, completeness_score=ROUND((IFNULL(photo_score,60)+49.32+80.66+53.62+67.28)/5,2) WHERE listing_id=220;
UPDATE LISTING_ANALYTICS SET view_count=403, follower_count=7388, details_score=96.64, condition_score=83.44, shipping_score=34.58, pricing_score=54.77, view_to_bid_score=4.4, completeness_score=ROUND((IFNULL(photo_score,60)+96.64+83.44+34.58+54.77)/5,2) WHERE listing_id=221;
UPDATE LISTING_ANALYTICS SET view_count=507, follower_count=3135, details_score=87.64, condition_score=52.08, shipping_score=34.1, pricing_score=98.94, view_to_bid_score=11.35, completeness_score=ROUND((IFNULL(photo_score,60)+87.64+52.08+34.1+98.94)/5,2) WHERE listing_id=222;
UPDATE LISTING_ANALYTICS SET view_count=680, follower_count=11643, details_score=85.28, condition_score=79.56, shipping_score=89.34, pricing_score=45.46, view_to_bid_score=14.92, completeness_score=ROUND((IFNULL(photo_score,60)+85.28+79.56+89.34+45.46)/5,2) WHERE listing_id=223;
UPDATE LISTING_ANALYTICS SET view_count=544, follower_count=9274, details_score=74.51, condition_score=76.6, shipping_score=57.59, pricing_score=72.78, view_to_bid_score=5.62, completeness_score=ROUND((IFNULL(photo_score,60)+74.51+76.6+57.59+72.78)/5,2) WHERE listing_id=224;
UPDATE LISTING_ANALYTICS SET view_count=333, follower_count=2269, details_score=66.87, condition_score=59.9, shipping_score=96.1, pricing_score=65.58, view_to_bid_score=10.42, completeness_score=ROUND((IFNULL(photo_score,60)+66.87+59.9+96.1+65.58)/5,2) WHERE listing_id=225;
UPDATE LISTING_ANALYTICS SET view_count=89, follower_count=8085, details_score=41.43, condition_score=55.22, shipping_score=69.29, pricing_score=76.58, view_to_bid_score=7.77, completeness_score=ROUND((IFNULL(photo_score,60)+41.43+55.22+69.29+76.58)/5,2) WHERE listing_id=226;
UPDATE LISTING_ANALYTICS SET view_count=794, follower_count=4755, details_score=86.25, condition_score=84.95, shipping_score=66.93, pricing_score=42.5, view_to_bid_score=20.91, completeness_score=ROUND((IFNULL(photo_score,60)+86.25+84.95+66.93+42.5)/5,2) WHERE listing_id=227;
UPDATE LISTING_ANALYTICS SET view_count=319, follower_count=9675, details_score=84.87, condition_score=78.56, shipping_score=42.14, pricing_score=58.82, view_to_bid_score=2.48, completeness_score=ROUND((IFNULL(photo_score,60)+84.87+78.56+42.14+58.82)/5,2) WHERE listing_id=228;
UPDATE LISTING_ANALYTICS SET view_count=33, follower_count=823, details_score=98.01, condition_score=69.25, shipping_score=54.62, pricing_score=72.27, view_to_bid_score=18.39, completeness_score=ROUND((IFNULL(photo_score,60)+98.01+69.25+54.62+72.27)/5,2) WHERE listing_id=229;
UPDATE LISTING_ANALYTICS SET view_count=705, follower_count=7157, details_score=84.31, condition_score=76.2, shipping_score=42.48, pricing_score=62.25, view_to_bid_score=15.83, completeness_score=ROUND((IFNULL(photo_score,60)+84.31+76.2+42.48+62.25)/5,2) WHERE listing_id=230;
UPDATE LISTING_ANALYTICS SET view_count=224, follower_count=1666, details_score=67.43, condition_score=59.29, shipping_score=45.51, pricing_score=59.22, view_to_bid_score=16.14, completeness_score=ROUND((IFNULL(photo_score,60)+67.43+59.29+45.51+59.22)/5,2) WHERE listing_id=231;
UPDATE LISTING_ANALYTICS SET view_count=512, follower_count=3437, details_score=74.27, condition_score=80.65, shipping_score=33.17, pricing_score=62.89, view_to_bid_score=19.96, completeness_score=ROUND((IFNULL(photo_score,60)+74.27+80.65+33.17+62.89)/5,2) WHERE listing_id=232;
UPDATE LISTING_ANALYTICS SET view_count=124, follower_count=4808, details_score=40.28, condition_score=62.02, shipping_score=86.95, pricing_score=89.88, view_to_bid_score=21.68, completeness_score=ROUND((IFNULL(photo_score,60)+40.28+62.02+86.95+89.88)/5,2) WHERE listing_id=233;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=3791, details_score=62.31, condition_score=91.89, shipping_score=33.13, pricing_score=48.5, view_to_bid_score=6.55, completeness_score=ROUND((IFNULL(photo_score,60)+62.31+91.89+33.13+48.5)/5,2) WHERE listing_id=234;
UPDATE LISTING_ANALYTICS SET view_count=689, follower_count=4280, details_score=92.92, condition_score=71.14, shipping_score=69.94, pricing_score=91.82, view_to_bid_score=14.34, completeness_score=ROUND((IFNULL(photo_score,60)+92.92+71.14+69.94+91.82)/5,2) WHERE listing_id=235;
UPDATE LISTING_ANALYTICS SET view_count=214, follower_count=10754, details_score=84.2, condition_score=63.63, shipping_score=78.32, pricing_score=64.95, view_to_bid_score=9.98, completeness_score=ROUND((IFNULL(photo_score,60)+84.2+63.63+78.32+64.95)/5,2) WHERE listing_id=236;
UPDATE LISTING_ANALYTICS SET view_count=289, follower_count=3154, details_score=89.0, condition_score=74.41, shipping_score=72.01, pricing_score=77.59, view_to_bid_score=9.61, completeness_score=ROUND((IFNULL(photo_score,60)+89.0+74.41+72.01+77.59)/5,2) WHERE listing_id=237;
UPDATE LISTING_ANALYTICS SET view_count=717, follower_count=7408, details_score=47.73, condition_score=84.47, shipping_score=34.94, pricing_score=46.86, view_to_bid_score=4.76, completeness_score=ROUND((IFNULL(photo_score,60)+47.73+84.47+34.94+46.86)/5,2) WHERE listing_id=238;
UPDATE LISTING_ANALYTICS SET view_count=505, follower_count=1139, details_score=51.0, condition_score=66.37, shipping_score=96.05, pricing_score=55.39, view_to_bid_score=15.46, completeness_score=ROUND((IFNULL(photo_score,60)+51.0+66.37+96.05+55.39)/5,2) WHERE listing_id=239;
UPDATE LISTING_ANALYTICS SET view_count=716, follower_count=6574, details_score=57.09, condition_score=64.32, shipping_score=89.89, pricing_score=55.69, view_to_bid_score=17.1, completeness_score=ROUND((IFNULL(photo_score,60)+57.09+64.32+89.89+55.69)/5,2) WHERE listing_id=240;
UPDATE LISTING_ANALYTICS SET view_count=409, follower_count=3361, details_score=97.01, condition_score=77.74, shipping_score=64.86, pricing_score=47.63, view_to_bid_score=21.91, completeness_score=ROUND((IFNULL(photo_score,60)+97.01+77.74+64.86+47.63)/5,2) WHERE listing_id=241;
UPDATE LISTING_ANALYTICS SET view_count=485, follower_count=7894, details_score=46.56, condition_score=61.43, shipping_score=88.32, pricing_score=51.07, view_to_bid_score=17.13, completeness_score=ROUND((IFNULL(photo_score,60)+46.56+61.43+88.32+51.07)/5,2) WHERE listing_id=242;
UPDATE LISTING_ANALYTICS SET view_count=74, follower_count=4010, details_score=66.16, condition_score=68.55, shipping_score=81.68, pricing_score=66.52, view_to_bid_score=17.27, completeness_score=ROUND((IFNULL(photo_score,60)+66.16+68.55+81.68+66.52)/5,2) WHERE listing_id=243;
UPDATE LISTING_ANALYTICS SET view_count=683, follower_count=8301, details_score=86.01, condition_score=59.45, shipping_score=44.73, pricing_score=59.08, view_to_bid_score=13.16, completeness_score=ROUND((IFNULL(photo_score,60)+86.01+59.45+44.73+59.08)/5,2) WHERE listing_id=244;
UPDATE LISTING_ANALYTICS SET view_count=161, follower_count=5642, details_score=91.57, condition_score=62.54, shipping_score=42.29, pricing_score=67.72, view_to_bid_score=19.98, completeness_score=ROUND((IFNULL(photo_score,60)+91.57+62.54+42.29+67.72)/5,2) WHERE listing_id=245;
UPDATE LISTING_ANALYTICS SET view_count=62, follower_count=6461, details_score=62.8, condition_score=97.34, shipping_score=65.39, pricing_score=53.51, view_to_bid_score=14.36, completeness_score=ROUND((IFNULL(photo_score,60)+62.8+97.34+65.39+53.51)/5,2) WHERE listing_id=246;
UPDATE LISTING_ANALYTICS SET view_count=348, follower_count=10830, details_score=83.27, condition_score=51.27, shipping_score=60.84, pricing_score=90.61, view_to_bid_score=13.83, completeness_score=ROUND((IFNULL(photo_score,60)+83.27+51.27+60.84+90.61)/5,2) WHERE listing_id=247;
UPDATE LISTING_ANALYTICS SET view_count=299, follower_count=9173, details_score=49.67, condition_score=77.36, shipping_score=52.23, pricing_score=46.68, view_to_bid_score=2.84, completeness_score=ROUND((IFNULL(photo_score,60)+49.67+77.36+52.23+46.68)/5,2) WHERE listing_id=248;
UPDATE LISTING_ANALYTICS SET view_count=535, follower_count=8803, details_score=41.05, condition_score=86.02, shipping_score=80.69, pricing_score=59.3, view_to_bid_score=2.29, completeness_score=ROUND((IFNULL(photo_score,60)+41.05+86.02+80.69+59.3)/5,2) WHERE listing_id=249;
UPDATE LISTING_ANALYTICS SET view_count=111, follower_count=11261, details_score=54.02, condition_score=69.06, shipping_score=69.39, pricing_score=88.82, view_to_bid_score=17.26, completeness_score=ROUND((IFNULL(photo_score,60)+54.02+69.06+69.39+88.82)/5,2) WHERE listing_id=250;
UPDATE LISTING_ANALYTICS SET view_count=127, follower_count=3728, details_score=85.73, condition_score=51.76, shipping_score=68.19, pricing_score=41.19, view_to_bid_score=18.39, completeness_score=ROUND((IFNULL(photo_score,60)+85.73+51.76+68.19+41.19)/5,2) WHERE listing_id=251;
UPDATE LISTING_ANALYTICS SET view_count=492, follower_count=9413, details_score=78.69, condition_score=64.12, shipping_score=73.12, pricing_score=66.98, view_to_bid_score=16.84, completeness_score=ROUND((IFNULL(photo_score,60)+78.69+64.12+73.12+66.98)/5,2) WHERE listing_id=252;
UPDATE LISTING_ANALYTICS SET view_count=704, follower_count=8087, details_score=76.76, condition_score=67.26, shipping_score=99.16, pricing_score=67.3, view_to_bid_score=20.35, completeness_score=ROUND((IFNULL(photo_score,60)+76.76+67.26+99.16+67.3)/5,2) WHERE listing_id=253;
UPDATE LISTING_ANALYTICS SET view_count=161, follower_count=7491, details_score=72.19, condition_score=68.01, shipping_score=40.11, pricing_score=78.23, view_to_bid_score=5.07, completeness_score=ROUND((IFNULL(photo_score,60)+72.19+68.01+40.11+78.23)/5,2) WHERE listing_id=254;
UPDATE LISTING_ANALYTICS SET view_count=402, follower_count=4264, details_score=92.92, condition_score=68.4, shipping_score=31.47, pricing_score=88.33, view_to_bid_score=4.45, completeness_score=ROUND((IFNULL(photo_score,60)+92.92+68.4+31.47+88.33)/5,2) WHERE listing_id=255;
UPDATE LISTING_ANALYTICS SET view_count=475, follower_count=6773, details_score=82.64, condition_score=77.07, shipping_score=45.89, pricing_score=64.13, view_to_bid_score=18.72, completeness_score=ROUND((IFNULL(photo_score,60)+82.64+77.07+45.89+64.13)/5,2) WHERE listing_id=256;
UPDATE LISTING_ANALYTICS SET view_count=366, follower_count=3459, details_score=96.51, condition_score=71.06, shipping_score=59.24, pricing_score=84.01, view_to_bid_score=10.6, completeness_score=ROUND((IFNULL(photo_score,60)+96.51+71.06+59.24+84.01)/5,2) WHERE listing_id=257;
UPDATE LISTING_ANALYTICS SET view_count=402, follower_count=7644, details_score=61.81, condition_score=66.3, shipping_score=57.92, pricing_score=83.4, view_to_bid_score=5.72, completeness_score=ROUND((IFNULL(photo_score,60)+61.81+66.3+57.92+83.4)/5,2) WHERE listing_id=258;
UPDATE LISTING_ANALYTICS SET view_count=227, follower_count=11725, details_score=51.46, condition_score=59.73, shipping_score=91.15, pricing_score=79.56, view_to_bid_score=14.19, completeness_score=ROUND((IFNULL(photo_score,60)+51.46+59.73+91.15+79.56)/5,2) WHERE listing_id=259;
UPDATE LISTING_ANALYTICS SET view_count=479, follower_count=9031, details_score=91.75, condition_score=89.6, shipping_score=56.24, pricing_score=58.41, view_to_bid_score=9.55, completeness_score=ROUND((IFNULL(photo_score,60)+91.75+89.6+56.24+58.41)/5,2) WHERE listing_id=260;
UPDATE LISTING_ANALYTICS SET view_count=486, follower_count=1830, details_score=72.57, condition_score=72.62, shipping_score=93.33, pricing_score=97.34, view_to_bid_score=19.34, completeness_score=ROUND((IFNULL(photo_score,60)+72.57+72.62+93.33+97.34)/5,2) WHERE listing_id=261;
UPDATE LISTING_ANALYTICS SET view_count=427, follower_count=883, details_score=51.96, condition_score=66.88, shipping_score=92.29, pricing_score=79.58, view_to_bid_score=20.71, completeness_score=ROUND((IFNULL(photo_score,60)+51.96+66.88+92.29+79.58)/5,2) WHERE listing_id=262;
UPDATE LISTING_ANALYTICS SET view_count=447, follower_count=3004, details_score=96.59, condition_score=51.19, shipping_score=44.45, pricing_score=74.04, view_to_bid_score=5.03, completeness_score=ROUND((IFNULL(photo_score,60)+96.59+51.19+44.45+74.04)/5,2) WHERE listing_id=263;
UPDATE LISTING_ANALYTICS SET view_count=768, follower_count=11201, details_score=73.8, condition_score=57.79, shipping_score=58.13, pricing_score=86.91, view_to_bid_score=5.56, completeness_score=ROUND((IFNULL(photo_score,60)+73.8+57.79+58.13+86.91)/5,2) WHERE listing_id=264;
UPDATE LISTING_ANALYTICS SET view_count=426, follower_count=5235, details_score=68.11, condition_score=93.4, shipping_score=39.14, pricing_score=95.88, view_to_bid_score=7.98, completeness_score=ROUND((IFNULL(photo_score,60)+68.11+93.4+39.14+95.88)/5,2) WHERE listing_id=265;
UPDATE LISTING_ANALYTICS SET view_count=786, follower_count=10082, details_score=71.84, condition_score=81.4, shipping_score=32.47, pricing_score=45.82, view_to_bid_score=2.84, completeness_score=ROUND((IFNULL(photo_score,60)+71.84+81.4+32.47+45.82)/5,2) WHERE listing_id=266;
UPDATE LISTING_ANALYTICS SET view_count=26, follower_count=192, details_score=95.21, condition_score=93.47, shipping_score=53.21, pricing_score=45.4, view_to_bid_score=20.6, completeness_score=ROUND((IFNULL(photo_score,60)+95.21+93.47+53.21+45.4)/5,2) WHERE listing_id=267;
UPDATE LISTING_ANALYTICS SET view_count=370, follower_count=3376, details_score=84.62, condition_score=97.9, shipping_score=51.53, pricing_score=43.96, view_to_bid_score=14.28, completeness_score=ROUND((IFNULL(photo_score,60)+84.62+97.9+51.53+43.96)/5,2) WHERE listing_id=268;
UPDATE LISTING_ANALYTICS SET view_count=328, follower_count=9609, details_score=94.27, condition_score=72.33, shipping_score=53.7, pricing_score=50.51, view_to_bid_score=7.72, completeness_score=ROUND((IFNULL(photo_score,60)+94.27+72.33+53.7+50.51)/5,2) WHERE listing_id=269;
UPDATE LISTING_ANALYTICS SET view_count=580, follower_count=2668, details_score=94.05, condition_score=57.6, shipping_score=59.06, pricing_score=71.94, view_to_bid_score=14.17, completeness_score=ROUND((IFNULL(photo_score,60)+94.05+57.6+59.06+71.94)/5,2) WHERE listing_id=270;
UPDATE LISTING_ANALYTICS SET view_count=167, follower_count=9252, details_score=73.14, condition_score=73.48, shipping_score=98.83, pricing_score=81.4, view_to_bid_score=20.02, completeness_score=ROUND((IFNULL(photo_score,60)+73.14+73.48+98.83+81.4)/5,2) WHERE listing_id=271;
UPDATE LISTING_ANALYTICS SET view_count=121, follower_count=10926, details_score=96.72, condition_score=95.46, shipping_score=36.79, pricing_score=42.36, view_to_bid_score=19.54, completeness_score=ROUND((IFNULL(photo_score,60)+96.72+95.46+36.79+42.36)/5,2) WHERE listing_id=272;
UPDATE LISTING_ANALYTICS SET view_count=489, follower_count=6265, details_score=68.61, condition_score=88.36, shipping_score=71.03, pricing_score=99.27, view_to_bid_score=8.93, completeness_score=ROUND((IFNULL(photo_score,60)+68.61+88.36+71.03+99.27)/5,2) WHERE listing_id=273;
UPDATE LISTING_ANALYTICS SET view_count=456, follower_count=9632, details_score=74.31, condition_score=72.37, shipping_score=31.39, pricing_score=69.51, view_to_bid_score=15.27, completeness_score=ROUND((IFNULL(photo_score,60)+74.31+72.37+31.39+69.51)/5,2) WHERE listing_id=274;
UPDATE LISTING_ANALYTICS SET view_count=357, follower_count=5616, details_score=99.27, condition_score=94.32, shipping_score=34.82, pricing_score=48.1, view_to_bid_score=7.65, completeness_score=ROUND((IFNULL(photo_score,60)+99.27+94.32+34.82+48.1)/5,2) WHERE listing_id=275;
UPDATE LISTING_ANALYTICS SET view_count=408, follower_count=2499, details_score=46.66, condition_score=96.75, shipping_score=97.23, pricing_score=51.83, view_to_bid_score=14.5, completeness_score=ROUND((IFNULL(photo_score,60)+46.66+96.75+97.23+51.83)/5,2) WHERE listing_id=276;
UPDATE LISTING_ANALYTICS SET view_count=304, follower_count=11705, details_score=87.57, condition_score=89.33, shipping_score=54.83, pricing_score=99.01, view_to_bid_score=11.64, completeness_score=ROUND((IFNULL(photo_score,60)+87.57+89.33+54.83+99.01)/5,2) WHERE listing_id=277;
UPDATE LISTING_ANALYTICS SET view_count=641, follower_count=9721, details_score=65.06, condition_score=58.45, shipping_score=89.59, pricing_score=51.52, view_to_bid_score=7.25, completeness_score=ROUND((IFNULL(photo_score,60)+65.06+58.45+89.59+51.52)/5,2) WHERE listing_id=278;
UPDATE LISTING_ANALYTICS SET view_count=537, follower_count=434, details_score=69.38, condition_score=95.29, shipping_score=33.64, pricing_score=54.33, view_to_bid_score=7.79, completeness_score=ROUND((IFNULL(photo_score,60)+69.38+95.29+33.64+54.33)/5,2) WHERE listing_id=279;
UPDATE LISTING_ANALYTICS SET view_count=464, follower_count=7143, details_score=60.25, condition_score=63.64, shipping_score=99.66, pricing_score=79.4, view_to_bid_score=15.02, completeness_score=ROUND((IFNULL(photo_score,60)+60.25+63.64+99.66+79.4)/5,2) WHERE listing_id=280;
UPDATE LISTING_ANALYTICS SET view_count=345, follower_count=9082, details_score=41.88, condition_score=93.6, shipping_score=94.86, pricing_score=40.64, view_to_bid_score=13.26, completeness_score=ROUND((IFNULL(photo_score,60)+41.88+93.6+94.86+40.64)/5,2) WHERE listing_id=281;
UPDATE LISTING_ANALYTICS SET view_count=314, follower_count=6286, details_score=51.98, condition_score=73.51, shipping_score=57.19, pricing_score=81.72, view_to_bid_score=7.04, completeness_score=ROUND((IFNULL(photo_score,60)+51.98+73.51+57.19+81.72)/5,2) WHERE listing_id=282;
UPDATE LISTING_ANALYTICS SET view_count=389, follower_count=5549, details_score=62.01, condition_score=75.63, shipping_score=99.56, pricing_score=65.47, view_to_bid_score=16.0, completeness_score=ROUND((IFNULL(photo_score,60)+62.01+75.63+99.56+65.47)/5,2) WHERE listing_id=283;
UPDATE LISTING_ANALYTICS SET view_count=140, follower_count=5722, details_score=83.15, condition_score=77.62, shipping_score=64.22, pricing_score=56.0, view_to_bid_score=20.22, completeness_score=ROUND((IFNULL(photo_score,60)+83.15+77.62+64.22+56.0)/5,2) WHERE listing_id=284;
UPDATE LISTING_ANALYTICS SET view_count=692, follower_count=1439, details_score=88.33, condition_score=95.67, shipping_score=90.3, pricing_score=93.75, view_to_bid_score=1.97, completeness_score=ROUND((IFNULL(photo_score,60)+88.33+95.67+90.3+93.75)/5,2) WHERE listing_id=285;
UPDATE LISTING_ANALYTICS SET view_count=136, follower_count=1803, details_score=54.58, condition_score=58.86, shipping_score=34.55, pricing_score=74.31, view_to_bid_score=6.36, completeness_score=ROUND((IFNULL(photo_score,60)+54.58+58.86+34.55+74.31)/5,2) WHERE listing_id=286;
UPDATE LISTING_ANALYTICS SET view_count=94, follower_count=1285, details_score=40.58, condition_score=50.67, shipping_score=86.49, pricing_score=92.21, view_to_bid_score=14.16, completeness_score=ROUND((IFNULL(photo_score,60)+40.58+50.67+86.49+92.21)/5,2) WHERE listing_id=287;
UPDATE LISTING_ANALYTICS SET view_count=164, follower_count=9597, details_score=77.57, condition_score=93.57, shipping_score=62.25, pricing_score=92.4, view_to_bid_score=17.62, completeness_score=ROUND((IFNULL(photo_score,60)+77.57+93.57+62.25+92.4)/5,2) WHERE listing_id=288;
UPDATE LISTING_ANALYTICS SET view_count=113, follower_count=10086, details_score=47.32, condition_score=85.21, shipping_score=43.97, pricing_score=84.76, view_to_bid_score=3.16, completeness_score=ROUND((IFNULL(photo_score,60)+47.32+85.21+43.97+84.76)/5,2) WHERE listing_id=289;
UPDATE LISTING_ANALYTICS SET view_count=98, follower_count=11817, details_score=97.08, condition_score=50.19, shipping_score=85.41, pricing_score=53.98, view_to_bid_score=2.52, completeness_score=ROUND((IFNULL(photo_score,60)+97.08+50.19+85.41+53.98)/5,2) WHERE listing_id=290;
UPDATE LISTING_ANALYTICS SET view_count=86, follower_count=6388, details_score=59.22, condition_score=76.47, shipping_score=63.32, pricing_score=51.84, view_to_bid_score=21.75, completeness_score=ROUND((IFNULL(photo_score,60)+59.22+76.47+63.32+51.84)/5,2) WHERE listing_id=291;
UPDATE LISTING_ANALYTICS SET view_count=624, follower_count=11621, details_score=51.16, condition_score=64.4, shipping_score=77.33, pricing_score=91.9, view_to_bid_score=2.76, completeness_score=ROUND((IFNULL(photo_score,60)+51.16+64.4+77.33+91.9)/5,2) WHERE listing_id=292;
UPDATE LISTING_ANALYTICS SET view_count=194, follower_count=8366, details_score=40.38, condition_score=58.79, shipping_score=43.84, pricing_score=48.63, view_to_bid_score=12.61, completeness_score=ROUND((IFNULL(photo_score,60)+40.38+58.79+43.84+48.63)/5,2) WHERE listing_id=293;
UPDATE LISTING_ANALYTICS SET view_count=198, follower_count=11518, details_score=47.44, condition_score=88.08, shipping_score=43.17, pricing_score=90.92, view_to_bid_score=17.0, completeness_score=ROUND((IFNULL(photo_score,60)+47.44+88.08+43.17+90.92)/5,2) WHERE listing_id=294;
UPDATE LISTING_ANALYTICS SET view_count=238, follower_count=2711, details_score=63.68, condition_score=91.8, shipping_score=50.77, pricing_score=64.74, view_to_bid_score=14.63, completeness_score=ROUND((IFNULL(photo_score,60)+63.68+91.8+50.77+64.74)/5,2) WHERE listing_id=295;
UPDATE LISTING_ANALYTICS SET view_count=228, follower_count=7038, details_score=55.06, condition_score=67.24, shipping_score=46.85, pricing_score=40.42, view_to_bid_score=19.76, completeness_score=ROUND((IFNULL(photo_score,60)+55.06+67.24+46.85+40.42)/5,2) WHERE listing_id=296;
UPDATE LISTING_ANALYTICS SET view_count=704, follower_count=4173, details_score=56.89, condition_score=58.06, shipping_score=34.31, pricing_score=69.64, view_to_bid_score=20.01, completeness_score=ROUND((IFNULL(photo_score,60)+56.89+58.06+34.31+69.64)/5,2) WHERE listing_id=297;
UPDATE LISTING_ANALYTICS SET view_count=66, follower_count=10205, details_score=85.34, condition_score=71.5, shipping_score=77.18, pricing_score=93.92, view_to_bid_score=10.64, completeness_score=ROUND((IFNULL(photo_score,60)+85.34+71.5+77.18+93.92)/5,2) WHERE listing_id=298;
UPDATE LISTING_ANALYTICS SET view_count=767, follower_count=11101, details_score=45.29, condition_score=79.41, shipping_score=94.14, pricing_score=61.69, view_to_bid_score=15.46, completeness_score=ROUND((IFNULL(photo_score,60)+45.29+79.41+94.14+61.69)/5,2) WHERE listing_id=299;
UPDATE LISTING_ANALYTICS SET view_count=699, follower_count=1129, details_score=74.15, condition_score=86.36, shipping_score=52.33, pricing_score=61.49, view_to_bid_score=18.12, completeness_score=ROUND((IFNULL(photo_score,60)+74.15+86.36+52.33+61.49)/5,2) WHERE listing_id=300;
UPDATE LISTING_ANALYTICS SET view_count=384, follower_count=8237, details_score=58.01, condition_score=74.45, shipping_score=68.21, pricing_score=84.7, view_to_bid_score=6.18, completeness_score=ROUND((IFNULL(photo_score,60)+58.01+74.45+68.21+84.7)/5,2) WHERE listing_id=301;
UPDATE LISTING_ANALYTICS SET view_count=179, follower_count=749, details_score=81.45, condition_score=70.49, shipping_score=91.6, pricing_score=59.46, view_to_bid_score=17.82, completeness_score=ROUND((IFNULL(photo_score,60)+81.45+70.49+91.6+59.46)/5,2) WHERE listing_id=302;
UPDATE LISTING_ANALYTICS SET view_count=417, follower_count=7646, details_score=92.12, condition_score=73.22, shipping_score=40.69, pricing_score=84.27, view_to_bid_score=9.4, completeness_score=ROUND((IFNULL(photo_score,60)+92.12+73.22+40.69+84.27)/5,2) WHERE listing_id=303;
UPDATE LISTING_ANALYTICS SET view_count=30, follower_count=2334, details_score=87.3, condition_score=69.07, shipping_score=90.92, pricing_score=48.96, view_to_bid_score=9.0, completeness_score=ROUND((IFNULL(photo_score,60)+87.3+69.07+90.92+48.96)/5,2) WHERE listing_id=304;
UPDATE LISTING_ANALYTICS SET view_count=449, follower_count=10892, details_score=94.32, condition_score=57.55, shipping_score=96.22, pricing_score=53.02, view_to_bid_score=1.84, completeness_score=ROUND((IFNULL(photo_score,60)+94.32+57.55+96.22+53.02)/5,2) WHERE listing_id=305;
UPDATE LISTING_ANALYTICS SET view_count=488, follower_count=2505, details_score=56.25, condition_score=59.89, shipping_score=64.81, pricing_score=49.5, view_to_bid_score=18.51, completeness_score=ROUND((IFNULL(photo_score,60)+56.25+59.89+64.81+49.5)/5,2) WHERE listing_id=306;
UPDATE LISTING_ANALYTICS SET view_count=567, follower_count=4599, details_score=53.66, condition_score=74.33, shipping_score=80.66, pricing_score=65.97, view_to_bid_score=20.92, completeness_score=ROUND((IFNULL(photo_score,60)+53.66+74.33+80.66+65.97)/5,2) WHERE listing_id=307;
UPDATE LISTING_ANALYTICS SET view_count=168, follower_count=8034, details_score=98.15, condition_score=52.99, shipping_score=97.3, pricing_score=44.01, view_to_bid_score=8.13, completeness_score=ROUND((IFNULL(photo_score,60)+98.15+52.99+97.3+44.01)/5,2) WHERE listing_id=308;
UPDATE LISTING_ANALYTICS SET view_count=493, follower_count=10008, details_score=57.36, condition_score=61.76, shipping_score=96.03, pricing_score=88.22, view_to_bid_score=10.04, completeness_score=ROUND((IFNULL(photo_score,60)+57.36+61.76+96.03+88.22)/5,2) WHERE listing_id=309;

SET FOREIGN_KEY_CHECKS = 1;