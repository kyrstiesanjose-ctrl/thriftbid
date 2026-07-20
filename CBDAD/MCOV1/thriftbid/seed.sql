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
('admin_verify1', 'Sophia', 'Lim', 'verify1@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a'),
('admin_verify2', 'Marco', 'Reyes', 'verify2@thriftbid.com', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a');

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
('ana_delacruz', 'Ana', 'De la Cruz', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'ana@email.com', '09201234561', 1, 'Active'),
('kai_rowan', 'Kai', 'Rowan', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'kai@email.com', '09201234562', 1, 'Active'),
('james_parker', 'James', 'Parker', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'james@email.com', '09201234563', 1, 'Active'),
('riley_avery', 'Riley', 'Avery', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'riley@email.com', '09201234564', 0, 'Active'),
('liza_magsaysay', 'Liza', 'Magsaysay', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'liza@email.com', '09201234565', 1, 'Active'),
('saige_fuentes', 'Saige', 'Fuentes', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'saige@email.com', '09201234566', 1, 'Active'),
('john_cruz', 'John', 'Cruz', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'johncruz@email.com', '09201234567', 1, 'Active'),
('mira_santos', 'Mira', 'Santos', '$2b$10$kioP7lIPAWMOJeunSS97HeUKnKUtRAzmlW8XlyHWyRqvPnBwlAx7a', 'mira@email.com', '09201234568', 1, 'Active');

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
INSERT INTO LISTINGS (title, description, price, original_price, condition_grade, is_active, created_at, category_id, seller_id, product_line_id, size_id) VALUES
('Classic Blouse', 'A lightly used blouse from Unbranded. Well-maintained and true to size, see photos for details.', 517.33, 1031.21, 'Lightly Used', 1, '2026-03-09 01:01:00', 1, 1, 31, 1),
('Oversized Shein Blouse', 'A lightly used blouse from Shein. Well-maintained and true to size, see photos for details.', 266.66, 707.05, 'Lightly Used', 1, '2025-12-15 08:09:00', 1, 2, 28, 5),
('Everyday Bershka Blouse', 'A well used blouse from Bershka. Well-maintained and true to size, see photos for details.', 414.89, 1287.84, 'Well Used', 1, '2025-05-08 12:05:00', 1, 1, 42, 3),
('Cropped Blouse', NULL, 216.36, NULL, 'Heavily Used', 1, '2026-01-09 05:23:00', 1, 2, 31, 3),
('Cropped H&M Blouse', 'A lightly used blouse from H&M. Well-maintained and true to size, see photos for details.', 1688.05, 4310.46, 'Lightly Used', 1, '2026-01-24 08:59:00', 1, 6, 24, 3),
('Y2K Uniqlo Blouse', NULL, 812.55, NULL, 'Brand New', 1, '2026-05-27 12:56:00', 1, 4, 36, 3),
('Y2K H&M Blouse', 'A like new blouse from H&M. Well-maintained and true to size, see photos for details.', 3442.66, 6019.77, 'Like New', 1, '2025-05-22 16:31:00', 1, 3, 24, 2),
('Vintage Blouse', 'A lightly used blouse from Unbranded. Well-maintained and true to size, see photos for details.', 420.94, 817.22, 'Lightly Used', 1, '2025-04-28 21:56:00', 1, 2, 31, 4),
('Preloved H&M Blouse', NULL, 124.2, NULL, 'Heavily Used', 1, '2026-06-04 03:55:00', 1, 4, 38, 1),
('Classic Blouse', 'A like new blouse from Unbranded. Well-maintained and true to size, see photos for details.', 540.01, 918.47, 'Like New', 1, '2026-01-07 09:15:00', 1, 5, 31, 5),
('Everyday Blouse', 'A heavily used blouse from Unbranded. Well-maintained and true to size, see photos for details.', 198.95, 1422.93, 'Heavily Used', 1, '2026-03-10 06:59:00', 1, 4, 31, 1),
('Timeless Shein Blouse', 'A like new blouse from Shein. Well-maintained and true to size, see photos for details.', 286.11, 570.75, 'Like New', 1, '2025-03-02 07:04:00', 1, 4, 28, 1),
('Cropped Uniqlo Blouse', 'A like new blouse from Uniqlo. Well-maintained and true to size, see photos for details.', 861.43, 1429.07, 'Like New', 1, '2025-09-06 15:51:00', 1, 6, 36, 4),
('Classic Uniqlo Sleeveless', NULL, 442.31, NULL, 'Lightly Used', 1, '2025-03-04 12:46:00', 2, 4, 36, 9),
('Classic ZARA Sleeveless', 'A like new sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 714.25, 1086.47, 'Like New', 1, '2026-03-30 17:06:00', 2, 2, 30, 7),
('Vintage H&M Sleeveless', NULL, 388.13, NULL, 'Lightly Used', 1, '2026-02-04 08:59:00', 2, 4, 38, 9),
('Timeless Uniqlo Sleeveless', 'A like new sleeveless from Uniqlo. Well-maintained and true to size, see photos for details.', 468.75, 784.39, 'Like New', 1, '2025-11-18 01:03:00', 2, 4, 36, 9),
('Classic ZARA Sleeveless', 'A lightly used sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 843.04, 2363.08, 'Lightly Used', 1, '2026-03-06 21:37:00', 2, 5, 21, 6),
('Signature Uniqlo Sleeveless', 'A lightly used sleeveless from Uniqlo. Well-maintained and true to size, see photos for details.', 186.91, 410.25, 'Lightly Used', 1, '2025-04-13 02:34:00', 2, 4, 26, 7),
('Limited Edition ZARA Sleeveless', 'A like new sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 908.02, 1339.85, 'Like New', 1, '2026-06-26 00:42:00', 2, 2, 30, 8),
('Retro ZARA Sleeveless', 'A like new sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 396.82, 646.12, 'Like New', 1, '2026-06-02 15:16:00', 2, 6, 30, 7),
('Vintage ZARA Sleeveless', 'A well used sleeveless from ZARA. Well-maintained and true to size, see photos for details.', 346.45, 1237.86, 'Well Used', 1, '2025-04-25 02:56:00', 2, 1, 30, 8),
('Minimalist H&M Sleeveless', NULL, 547.32, NULL, 'Like New', 1, '2025-08-04 21:15:00', 2, 1, 38, 8),
('Preloved Uniqlo Sleeveless', NULL, 154.99, NULL, 'Heavily Used', 1, '2025-07-01 13:01:00', 2, 5, 36, 9),
('Timeless Sleeveless', NULL, 315.41, NULL, 'Well Used', 1, '2025-04-21 12:55:00', 2, 3, 31, 9),
('Y2K Bershka Sleeveless', 'A well used sleeveless from Bershka. Well-maintained and true to size, see photos for details.', 191.81, 578.89, 'Well Used', 1, '2025-08-17 00:42:00', 2, 2, 42, 7),
('Classic Uniqlo Long sleeve', 'A lightly used long sleeve from Uniqlo. Well-maintained and true to size, see photos for details.', 570.97, 1120.27, 'Lightly Used', 1, '2025-09-25 05:37:00', 3, 3, 36, 12),
('Everyday ZARA Long sleeve', 'A like new long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 201.9, 302.88, 'Like New', 1, '2025-07-21 11:27:00', 3, 4, 30, 10),
('Limited Edition ZARA Long sleeve', 'A lightly used long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 475.4, 1242.5, 'Lightly Used', 1, '2026-01-24 21:47:00', 3, 5, 30, 12),
('Y2K ZARA Long sleeve', 'A lightly used long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 463.64, 1090.48, 'Lightly Used', 1, '2026-06-08 15:50:00', 3, 3, 30, 11),
('Classic H&M Long sleeve', 'A like new long sleeve from H&M. Well-maintained and true to size, see photos for details.', 3919.13, 6424.5, 'Like New', 1, '2026-04-12 13:56:00', 3, 6, 24, 12),
('Y2K H&M Long sleeve', NULL, 512.16, NULL, 'Well Used', 1, '2025-06-30 22:33:00', 3, 6, 38, 10),
('Signature Uniqlo Long sleeve', 'A well used long sleeve from Uniqlo. Well-maintained and true to size, see photos for details.', 514.03, 1434.61, 'Well Used', 1, '2025-11-21 14:39:00', 3, 5, 25, 11),
('Y2K ZARA Long sleeve', 'A well used long sleeve from ZARA. Well-maintained and true to size, see photos for details.', 335.18, 1047.78, 'Well Used', 1, '2025-10-06 10:20:00', 3, 2, 30, 12),
('Oversized H&M Long sleeve', 'A brand new long sleeve from H&M. Well-maintained and true to size, see photos for details.', 1708.81, 2092.65, 'Brand New', 1, '2025-01-21 18:24:00', 3, 6, 24, 11),
('Limited Edition Bershka Long sleeve', 'A lightly used long sleeve from Bershka. Well-maintained and true to size, see photos for details.', 439.84, 1057.05, 'Lightly Used', 1, '2026-02-19 23:10:00', 3, 5, 42, 11),
('Minimalist Uniqlo Long sleeve', 'A like new long sleeve from Uniqlo. Well-maintained and true to size, see photos for details.', 557.58, 958.29, 'Like New', 1, '2026-01-24 08:48:00', 3, 6, 25, 13),
('Y2K Long sleeve', 'A like new long sleeve from Unbranded. Well-maintained and true to size, see photos for details.', 54.79, 108.37, 'Like New', 1, '2025-07-24 00:39:00', 3, 1, 31, 12),
('Retro Uniqlo Long sleeve', 'A lightly used long sleeve from Uniqlo. Well-maintained and true to size, see photos for details.', 600.35, 1588.91, 'Lightly Used', 1, '2025-04-21 18:01:00', 3, 5, 25, 11),
('Classic Shirt', NULL, 780.12, NULL, 'Like New', 1, '2025-02-12 11:34:00', 4, 6, 31, 15),
('Limited Edition H&M Shirt', 'A lightly used shirt from H&M. Well-maintained and true to size, see photos for details.', 1178.63, 2296.03, 'Lightly Used', 1, '2026-04-16 22:09:00', 4, 1, 24, 18),
('Cropped Bershka Shirt', NULL, 810.26, NULL, 'Like New', 1, '2025-09-07 14:36:00', 4, 6, 42, 18),
('Timeless H&M Shirt', 'A well used shirt from H&M. Well-maintained and true to size, see photos for details.', 1166.89, 3399.59, 'Well Used', 1, '2025-10-10 17:00:00', 4, 1, 24, 17),
('Timeless Shirt', 'A lightly used shirt from Unbranded. Well-maintained and true to size, see photos for details.', 71.69, 184.93, 'Lightly Used', 1, '2025-09-07 09:42:00', 4, 2, 31, 17),
('Timeless H&M Shirt', 'A like new shirt from H&M. Well-maintained and true to size, see photos for details.', 2080.55, 3283.08, 'Like New', 1, '2025-07-09 06:13:00', 4, 6, 24, 17),
('Retro H&M Shirt', 'A like new shirt from H&M. Well-maintained and true to size, see photos for details.', 1026.73, 2013.92, 'Like New', 1, '2025-05-10 20:55:00', 4, 2, 24, 16),
('Classic Bershka Shirt', 'A like new shirt from Bershka. Well-maintained and true to size, see photos for details.', 1008.16, 1720.44, 'Like New', 1, '2026-02-15 15:04:00', 4, 4, 42, 16),
('Cropped ZARA Shirt', 'A well used shirt from ZARA. Well-maintained and true to size, see photos for details.', 200.42, 683.67, 'Well Used', 1, '2026-03-30 09:55:00', 4, 1, 30, 18),
('Cropped ZARA Shirt', 'A like new shirt from ZARA. Well-maintained and true to size, see photos for details.', 1187.64, 1903.0, 'Like New', 1, '2025-10-26 01:14:00', 4, 3, 21, 14),
('Limited Edition H&M Shirt', NULL, 453.17, NULL, 'Lightly Used', 1, '2025-06-02 08:52:00', 4, 6, 38, 18),
('Cropped Uniqlo Shirt', 'A well used shirt from Uniqlo. Well-maintained and true to size, see photos for details.', 476.72, 1693.61, 'Well Used', 1, '2025-11-08 22:25:00', 4, 1, 36, 15),
('Signature Bershka Shirt', 'A lightly used shirt from Bershka. Well-maintained and true to size, see photos for details.', 352.68, 759.05, 'Lightly Used', 1, '2025-01-22 21:52:00', 4, 6, 42, 16),
('Oversized H&M Shorts', NULL, 588.56, NULL, 'Lightly Used', 1, '2025-12-08 10:42:00', 5, 2, 38, 23),
('Cropped ZARA Shorts', 'A lightly used shorts from ZARA. Well-maintained and true to size, see photos for details.', 746.46, 1683.06, 'Lightly Used', 1, '2025-04-01 10:16:00', 5, 3, 30, 22),
('Vintage Bershka Shorts', 'A lightly used shorts from Bershka. Well-maintained and true to size, see photos for details.', 381.99, 898.49, 'Lightly Used', 1, '2025-07-28 08:35:00', 5, 1, 42, 20),
('Oversized Levi\'s Shorts', NULL, 157.73, NULL, 'Well Used', 1, '2025-04-06 07:53:00', 5, 1, 39, 23),
('Cropped Bershka Shorts', NULL, 360.35, NULL, 'Lightly Used', 1, '2026-04-29 07:29:00', 5, 1, 42, 20),
('Oversized Bershka Shorts', NULL, 501.77, NULL, 'Lightly Used', 1, '2025-12-15 16:17:00', 5, 2, 42, 23),
('Cropped H&M Shorts', 'A well used shorts from H&M. Well-maintained and true to size, see photos for details.', 361.58, 1059.94, 'Well Used', 1, '2026-07-06 15:22:00', 5, 6, 38, 21),
('Cropped Shorts', NULL, 359.79, NULL, 'Like New', 1, '2026-01-26 12:42:00', 5, 2, 31, 23),
('Cropped Bershka Shorts', 'A lightly used shorts from Bershka. Well-maintained and true to size, see photos for details.', 633.09, 1269.7, 'Lightly Used', 1, '2025-04-13 16:58:00', 5, 1, 42, 20),
('Limited Edition Levi\'s Shorts', 'A like new shorts from Levi\'s. Well-maintained and true to size, see photos for details.', 685.88, 1049.84, 'Like New', 1, '2026-07-01 12:20:00', 5, 4, 39, 21),
('Vintage ZARA Shorts', 'A lightly used shorts from ZARA. Well-maintained and true to size, see photos for details.', 493.37, 1054.25, 'Lightly Used', 1, '2025-02-17 10:50:00', 5, 6, 30, 19),
('Classic Bershka Shorts', 'A lightly used shorts from Bershka. Well-maintained and true to size, see photos for details.', 451.84, 1192.52, 'Lightly Used', 1, '2026-01-27 19:43:00', 5, 2, 42, 20),
('Retro Bershka Shorts', 'A lightly used shorts from Bershka. Well-maintained and true to size, see photos for details.', 557.35, 1298.91, 'Lightly Used', 1, '2026-07-14 05:04:00', 5, 6, 42, 21),
('Minimalist Shein Skirts', NULL, 30.72, NULL, 'Heavily Used', 1, '2025-10-30 22:18:00', 6, 3, 28, 24),
('Cropped Shein Skirts', 'A lightly used skirts from Shein. Well-maintained and true to size, see photos for details.', 63.09, 139.24, 'Lightly Used', 1, '2025-10-21 07:38:00', 6, 3, 28, 24),
('Preloved ZARA Skirts', NULL, 257.9, NULL, 'Brand New', 1, '2025-04-03 09:20:00', 6, 6, 30, 26),
('Retro H&M Skirts', NULL, 211.67, NULL, 'Well Used', 1, '2025-06-18 08:58:00', 6, 2, 38, 24),
('Y2K Bershka Skirts', 'A well used skirts from Bershka. Well-maintained and true to size, see photos for details.', 152.3, 467.77, 'Well Used', 1, '2026-02-11 17:23:00', 6, 6, 42, 25),
('Limited Edition Skirts', NULL, 244.57, NULL, 'Like New', 1, '2026-01-16 03:43:00', 6, 1, 31, 25),
('Cropped Shein Skirts', 'A well used skirts from Shein. Well-maintained and true to size, see photos for details.', 63.41, 277.09, 'Well Used', 1, '2025-11-06 20:26:00', 6, 1, 28, 26),
('Limited Edition Bershka Skirts', NULL, 386.73, NULL, 'Brand New', 1, '2026-07-08 13:37:00', 6, 4, 42, 24),
('Y2K Shein Skirts', 'A well used skirts from Shein. Well-maintained and true to size, see photos for details.', 102.52, 323.79, 'Well Used', 1, '2026-03-31 14:15:00', 6, 6, 28, 24),
('Y2K Shein Skirts', NULL, 99.48, NULL, 'Heavily Used', 1, '2025-01-22 01:50:00', 6, 3, 28, 24),
('Y2K H&M Skirts', NULL, 544.26, NULL, 'Like New', 1, '2025-12-03 04:50:00', 6, 2, 38, 26),
('Preloved Bershka Skirts', NULL, 248.12, NULL, 'Lightly Used', 1, '2025-01-16 11:50:00', 6, 2, 42, 24),
('Cropped Skirts', 'A like new skirts from Unbranded. Well-maintained and true to size, see photos for details.', 515.51, 812.82, 'Like New', 1, '2026-04-05 11:32:00', 6, 3, 31, 24),
('Cropped Bershka Pants', 'A brand new pants from Bershka. Well-maintained and true to size, see photos for details.', 978.19, 1242.59, 'Brand New', 1, '2026-03-31 02:57:00', 7, 6, 42, 27),
('Classic ZARA Pants', 'A lightly used pants from ZARA. Well-maintained and true to size, see photos for details.', 485.22, 1071.32, 'Lightly Used', 1, '2025-04-28 20:41:00', 7, 3, 30, 31),
('Minimalist Uniqlo Pants', 'A lightly used pants from Uniqlo. Well-maintained and true to size, see photos for details.', 594.03, 1282.82, 'Lightly Used', 1, '2025-06-06 21:59:00', 7, 4, 36, 30),
('Everyday Bershka Pants', NULL, 670.14, NULL, 'Lightly Used', 1, '2025-12-04 21:07:00', 7, 1, 42, 32),
('Retro Uniqlo Pants', NULL, 272.17, NULL, 'Lightly Used', 1, '2025-12-27 03:36:00', 7, 6, 36, 33),
('Signature ZARA Pants', 'A like new pants from ZARA. Well-maintained and true to size, see photos for details.', 589.38, 924.85, 'Like New', 1, '2025-08-20 13:54:00', 7, 6, 30, 30),
('Preloved Uniqlo Pants', NULL, 1099.7, NULL, 'Brand New', 1, '2025-02-01 02:47:00', 7, 3, 36, 29),
('Signature Bershka Pants', 'A like new pants from Bershka. Well-maintained and true to size, see photos for details.', 1122.61, 1754.55, 'Like New', 1, '2025-03-28 01:09:00', 7, 4, 42, 30),
('Classic Bershka Pants', 'A lightly used pants from Bershka. Well-maintained and true to size, see photos for details.', 496.07, 1037.07, 'Lightly Used', 1, '2025-12-20 13:07:00', 7, 6, 42, 30),
('Retro Bershka Pants', 'A brand new pants from Bershka. Well-maintained and true to size, see photos for details.', 635.42, 937.97, 'Brand New', 1, '2025-10-24 10:07:00', 7, 5, 42, 27),
('Timeless ZARA Pants', 'A lightly used pants from ZARA. Well-maintained and true to size, see photos for details.', 605.16, 1670.54, 'Lightly Used', 1, '2025-02-13 13:01:00', 7, 4, 30, 31),
('Cropped Bershka Pants', NULL, 447.21, NULL, 'Lightly Used', 1, '2026-01-06 02:27:00', 7, 3, 42, 27),
('Preloved ZARA Pants', 'A lightly used pants from ZARA. Well-maintained and true to size, see photos for details.', 607.81, 1567.87, 'Lightly Used', 1, '2025-03-20 16:40:00', 7, 4, 30, 31),
('Cropped H&M Dress', 'A like new dress from H&M. Well-maintained and true to size, see photos for details.', 1682.52, 2632.59, 'Like New', 1, '2026-04-21 18:48:00', 8, 2, 24, 34),
('Classic ZARA Dress', NULL, 535.0, NULL, 'Lightly Used', 1, '2025-11-14 14:28:00', 8, 4, 30, 37),
('Everyday ZARA Dress', NULL, 1355.84, NULL, 'Brand New', 1, '2026-01-29 14:37:00', 8, 3, 30, 36),
('Minimalist Shein Dress', 'A like new dress from Shein. Well-maintained and true to size, see photos for details.', 297.42, 460.42, 'Like New', 1, '2025-03-28 16:41:00', 8, 5, 28, 35),
('Limited Edition Shein Dress', NULL, 262.11, NULL, 'Like New', 1, '2025-02-23 20:41:00', 8, 5, 28, 35),
('Preloved ZARA Dress', 'A lightly used dress from ZARA. Well-maintained and true to size, see photos for details.', 877.54, 1939.5, 'Lightly Used', 1, '2025-12-08 02:37:00', 8, 3, 30, 34),
('Timeless Dress', 'A like new dress from Unbranded. Well-maintained and true to size, see photos for details.', 762.82, 1229.12, 'Like New', 1, '2026-06-24 02:41:00', 8, 6, 31, 34),
('Classic H&M Dress', 'A heavily used dress from H&M. Well-maintained and true to size, see photos for details.', 393.13, 2528.24, 'Heavily Used', 1, '2026-06-04 17:53:00', 8, 2, 24, 36),
('Timeless H&M Dress', 'A lightly used dress from H&M. Well-maintained and true to size, see photos for details.', 2884.85, 6357.07, 'Lightly Used', 1, '2026-04-05 07:34:00', 8, 2, 24, 35),
('Signature Bershka Dress', 'A lightly used dress from Bershka. Well-maintained and true to size, see photos for details.', 1427.04, 2919.04, 'Lightly Used', 1, '2025-05-22 08:03:00', 8, 6, 27, 37),
('Cropped ZARA Dress', 'A lightly used dress from ZARA. Well-maintained and true to size, see photos for details.', 230.14, 455.91, 'Lightly Used', 1, '2025-12-24 00:26:00', 8, 2, 30, 36),
('Retro Shein Dress', 'A like new dress from Shein. Well-maintained and true to size, see photos for details.', 384.71, 733.1, 'Like New', 1, '2026-04-29 22:53:00', 8, 1, 28, 36),
('Retro ZARA Dress', 'A like new dress from ZARA. Well-maintained and true to size, see photos for details.', 769.27, 1335.1, 'Like New', 1, '2025-09-01 09:07:00', 8, 1, 30, 36),
('Vintage ZARA Co-ords', 'A lightly used co-ords from ZARA. Well-maintained and true to size, see photos for details.', 2434.14, 6092.72, 'Lightly Used', 1, '2025-12-28 07:36:00', 9, 1, 20, 39),
('Minimalist Co-ords', 'A well used co-ords from Unbranded. Well-maintained and true to size, see photos for details.', 31.01, 113.12, 'Well Used', 1, '2025-09-17 23:01:00', 9, 5, 31, 40),
('Timeless Co-ords', 'A like new co-ords from Unbranded. Well-maintained and true to size, see photos for details.', 781.58, 1254.06, 'Like New', 1, '2026-05-06 20:11:00', 9, 6, 31, 39),
('Oversized Bershka Co-ords', NULL, 358.96, NULL, 'Well Used', 1, '2026-07-11 15:16:00', 9, 2, 42, 38),
('Oversized H&M Co-ords', 'A well used co-ords from H&M. Well-maintained and true to size, see photos for details.', 422.77, 1273.75, 'Well Used', 1, '2026-02-14 23:28:00', 9, 3, 38, 39),
('Preloved Bershka Co-ords', NULL, 263.49, NULL, 'Well Used', 1, '2026-07-13 09:20:00', 9, 5, 42, 39),
('Cropped ZARA Co-ords', 'A like new co-ords from ZARA. Well-maintained and true to size, see photos for details.', 338.26, 583.3, 'Like New', 1, '2025-02-13 23:55:00', 9, 3, 30, 40),
('Cropped Shein Co-ords', 'A well used co-ords from Shein. Well-maintained and true to size, see photos for details.', 65.35, 214.22, 'Well Used', 1, '2025-02-05 04:04:00', 9, 3, 28, 40),
('Everyday Co-ords', 'A like new co-ords from Unbranded. Well-maintained and true to size, see photos for details.', 697.71, 1156.47, 'Like New', 1, '2026-01-11 12:20:00', 9, 1, 31, 40),
('Signature Shein Co-ords', 'A well used co-ords from Shein. Well-maintained and true to size, see photos for details.', 165.83, 663.23, 'Well Used', 1, '2025-10-20 22:58:00', 9, 5, 28, 39),
('Minimalist Shein Co-ords', 'A lightly used co-ords from Shein. Well-maintained and true to size, see photos for details.', 313.93, 776.42, 'Lightly Used', 1, '2025-03-08 17:34:00', 9, 2, 28, 40),
('Minimalist Co-ords', NULL, 70.51, NULL, 'Heavily Used', 1, '2026-01-13 14:51:00', 9, 2, 31, 38),
('Oversized Co-ords', NULL, 649.54, NULL, 'Like New', 1, '2025-03-17 04:20:00', 9, 1, 31, 38),
('Preloved Athleisure', NULL, 514.56, NULL, 'Like New', 1, '2026-03-20 16:58:00', 10, 4, 31, 43),
('Everyday Nike Athleisure', 'A like new athleisure from Nike. Well-maintained and true to size, see photos for details.', 756.64, 1128.39, 'Like New', 1, '2025-10-18 02:16:00', 10, 5, 32, 42),
('Vintage Nike Athleisure', 'A lightly used athleisure from Nike. Well-maintained and true to size, see photos for details.', 1558.61, 3496.1, 'Lightly Used', 1, '2025-03-25 01:41:00', 10, 5, 29, 42),
('Classic Uniqlo Athleisure', NULL, 801.72, NULL, 'Lightly Used', 1, '2025-03-03 05:28:00', 10, 6, 36, 43),
('Minimalist Athleisure', 'A like new athleisure from Unbranded. Well-maintained and true to size, see photos for details.', 347.74, 513.01, 'Like New', 1, '2026-02-13 04:48:00', 10, 4, 31, 42),
('Preloved Nike Athleisure', 'A like new athleisure from Nike. Well-maintained and true to size, see photos for details.', 2051.0, 3565.32, 'Like New', 1, '2025-12-02 18:46:00', 10, 3, 29, 44),
('Y2K Athleisure', NULL, 660.24, NULL, 'Brand New', 1, '2025-12-28 01:03:00', 10, 3, 31, 44),
('Oversized Athleisure', 'A like new athleisure from Unbranded. Well-maintained and true to size, see photos for details.', 838.89, 1329.56, 'Like New', 1, '2026-01-10 01:25:00', 10, 5, 31, 44),
('Classic Nike Athleisure', 'A well used athleisure from Nike. Well-maintained and true to size, see photos for details.', 471.55, 1992.76, 'Well Used', 1, '2026-02-08 11:50:00', 10, 4, 32, 44),
('Preloved Nike Athleisure', 'A like new athleisure from Nike. Well-maintained and true to size, see photos for details.', 843.54, 1276.61, 'Like New', 1, '2025-12-02 19:20:00', 10, 1, 29, 41),
('Timeless Athleisure', 'A lightly used athleisure from Unbranded. Well-maintained and true to size, see photos for details.', 660.75, 1470.85, 'Lightly Used', 1, '2025-01-28 19:30:00', 10, 6, 31, 43),
('Minimalist Athleisure', NULL, 136.87, NULL, 'Brand New', 1, '2026-03-05 04:26:00', 10, 2, 31, 42),
('Y2K Athleisure', NULL, 33.58, NULL, 'Well Used', 1, '2025-11-29 21:30:00', 10, 5, 31, 44),
('Y2K Shein Heels', 'A well used heels from Shein. Well-maintained and true to size, see photos for details.', 145.2, 588.06, 'Well Used', 1, '2025-10-13 17:19:00', 11, 2, 28, 48),
('Classic Heels', NULL, 660.9, NULL, 'Like New', 1, '2026-07-11 12:57:00', 11, 3, 31, 48),
('Limited Edition Shein Heels', NULL, 136.26, NULL, 'Brand New', 1, '2025-09-20 23:30:00', 11, 2, 28, 47),
('Signature Coach Heels', 'A heavily used heels from Coach. Well-maintained and true to size, see photos for details.', 218.98, 1129.46, 'Heavily Used', 1, '2025-09-03 07:03:00', 11, 5, 41, 47),
('Preloved Shein Heels', NULL, 62.39, NULL, 'Like New', 1, '2026-02-21 20:59:00', 11, 6, 28, 48),
('Signature Heels', 'A well used heels from Unbranded. Well-maintained and true to size, see photos for details.', 317.75, 1366.51, 'Well Used', 1, '2025-08-26 17:47:00', 11, 6, 31, 46),
('Vintage Heels', NULL, 313.66, NULL, 'Heavily Used', 1, '2025-11-02 18:38:00', 11, 4, 31, 46),
('Y2K Shein Heels', 'A heavily used heels from Shein. Well-maintained and true to size, see photos for details.', 137.56, 780.85, 'Heavily Used', 1, '2025-04-26 10:10:00', 11, 3, 28, 48),
('Everyday Shein Heels', NULL, 530.53, NULL, 'Like New', 1, '2025-12-02 02:25:00', 11, 5, 28, 46),
('Retro Coach Heels', 'A like new heels from Coach. Well-maintained and true to size, see photos for details.', 773.39, 1425.88, 'Like New', 1, '2025-12-04 09:37:00', 11, 2, 41, 48),
('Timeless ZARA Heels', 'A like new heels from ZARA. Well-maintained and true to size, see photos for details.', 1155.34, 1809.26, 'Like New', 1, '2025-05-01 20:58:00', 11, 4, 30, 47),
('Y2K Heels', 'A lightly used heels from Unbranded. Well-maintained and true to size, see photos for details.', 558.4, 1148.16, 'Lightly Used', 1, '2025-09-11 21:48:00', 11, 2, 31, 48),
('Signature ZARA Heels', 'A like new heels from ZARA. Well-maintained and true to size, see photos for details.', 267.2, 497.61, 'Like New', 1, '2026-05-16 02:57:00', 11, 5, 30, 49),
('Timeless Louis Vuitton Sneakers', 'A lightly used sneakers from Louis Vuitton. Well-maintained and true to size, see photos for details.', 49239.79, 100736.67, 'Lightly Used', 0, '2025-08-12 18:04:00', 12, 5, 7, 50),
('Cropped Nike Sneakers', 'A like new sneakers from Nike. Well-maintained and true to size, see photos for details.', 1319.74, 1998.27, 'Like New', 1, '2026-01-22 12:05:00', 12, 4, 29, 50),
('Vintage Nike Sneakers', NULL, 678.35, NULL, 'Lightly Used', 1, '2025-11-02 14:43:00', 12, 2, 32, 56),
('Classic Gucci Sneakers', 'A well used sneakers from Gucci. Well-maintained and true to size, see photos for details.', 15960.77, 46596.82, 'Well Used', 0, '2025-02-02 21:26:00', 12, 4, 10, 56),
('Cropped Nike Sneakers', 'A lightly used sneakers from Nike. Well-maintained and true to size, see photos for details.', 717.76, 2007.62, 'Lightly Used', 1, '2025-08-28 17:13:00', 12, 5, 32, 50),
('Preloved Adidas Sneakers', NULL, 1522.32, NULL, 'Lightly Used', 1, '2026-06-18 07:26:00', 12, 6, 33, 55),
('Everyday Converse Sneakers', 'A lightly used sneakers from Converse. Well-maintained and true to size, see photos for details.', 1578.36, 3400.7, 'Lightly Used', 1, '2025-11-23 22:26:00', 12, 1, 23, 52),
('Vintage Sneakers', 'A like new sneakers from Unbranded. Well-maintained and true to size, see photos for details.', 151.27, 259.31, 'Like New', 1, '2026-02-27 13:35:00', 12, 5, 31, 57),
('Y2K Converse Sneakers', NULL, 483.81, NULL, 'Well Used', 1, '2025-02-22 08:24:00', 12, 6, 35, 51),
('Cropped Gucci Sneakers', 'A well used sneakers from Gucci. Well-maintained and true to size, see photos for details.', 1070.74, 3590.21, 'Well Used', 1, '2025-08-02 10:19:00', 12, 5, 34, 50),
('Minimalist Nike Sneakers', 'A well used sneakers from Nike. Well-maintained and true to size, see photos for details.', 636.02, 2508.89, 'Well Used', 1, '2025-10-17 12:29:00', 12, 6, 32, 57),
('Y2K Gucci Sneakers', NULL, 2248.8, NULL, 'Brand New', 1, '2026-01-15 10:26:00', 12, 4, 34, 57),
('Y2K Gucci Sneakers', 'A brand new sneakers from Gucci. Well-maintained and true to size, see photos for details.', 34690.56, 50331.73, 'Brand New', 0, '2026-01-24 18:53:00', 12, 2, 10, 52),
('Cropped Running shoes', 'A lightly used running shoes from Unbranded. Well-maintained and true to size, see photos for details.', 139.58, 295.44, 'Lightly Used', 1, '2025-07-08 17:41:00', 13, 6, 31, 63),
('Minimalist Nike Running shoes', 'A well used running shoes from Nike. Well-maintained and true to size, see photos for details.', 446.84, 1536.57, 'Well Used', 1, '2025-03-03 19:40:00', 13, 4, 32, 59),
('Classic Nike Running shoes', 'A lightly used running shoes from Nike. Well-maintained and true to size, see photos for details.', 6640.63, 13158.59, 'Lightly Used', 1, '2025-04-09 16:09:00', 13, 1, 14, 62),
('Y2K Adidas Running shoes', 'A like new running shoes from Adidas. Well-maintained and true to size, see photos for details.', 2550.2, 3760.01, 'Like New', 1, '2025-11-04 21:52:00', 13, 4, 33, 58),
('Oversized Adidas Running shoes', 'A lightly used running shoes from Adidas. Well-maintained and true to size, see photos for details.', 1569.59, 4311.38, 'Lightly Used', 1, '2025-12-06 18:54:00', 13, 4, 33, 62),
('Everyday Running shoes', NULL, 573.82, NULL, 'Like New', 1, '2025-02-03 05:59:00', 13, 5, 31, 61),
('Retro Nike Running shoes', NULL, 3191.61, NULL, 'Like New', 1, '2025-06-16 18:15:00', 13, 2, 32, 62),
('Classic Running shoes', NULL, 746.53, NULL, 'Like New', 1, '2026-05-28 23:22:00', 13, 5, 31, 60),
('Minimalist Nike Running shoes', 'A well used running shoes from Nike. Well-maintained and true to size, see photos for details.', 1465.71, 5319.43, 'Well Used', 1, '2025-01-31 20:17:00', 13, 4, 32, 59),
('Y2K Adidas Running shoes', 'A lightly used running shoes from Adidas. Well-maintained and true to size, see photos for details.', 1836.45, 4588.67, 'Lightly Used', 1, '2025-03-17 02:17:00', 13, 2, 33, 63),
('Classic Adidas Running shoes', NULL, 2630.59, NULL, 'Brand New', 1, '2025-05-16 02:11:00', 13, 3, 33, 58),
('Signature Adidas Running shoes', 'A lightly used running shoes from Adidas. Well-maintained and true to size, see photos for details.', 825.57, 1858.48, 'Lightly Used', 1, '2025-11-29 12:00:00', 13, 5, 33, 62),
('Oversized Running shoes', 'A lightly used running shoes from Unbranded. Well-maintained and true to size, see photos for details.', 275.99, 765.03, 'Lightly Used', 1, '2025-10-10 13:19:00', 13, 5, 31, 59),
('Minimalist Boots', 'A like new boots from Unbranded. Well-maintained and true to size, see photos for details.', 325.21, 531.71, 'Like New', 1, '2026-03-27 10:27:00', 14, 5, 31, 68),
('Y2K Boots', 'A heavily used boots from Unbranded. Well-maintained and true to size, see photos for details.', 144.09, 761.96, 'Heavily Used', 1, '2025-11-30 12:17:00', 14, 2, 31, 67),
('Oversized Dr. Martens Boots', 'A heavily used boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 678.88, 5291.38, 'Heavily Used', 1, '2026-05-27 04:40:00', 14, 6, 40, 67),
('Minimalist Boots', 'A heavily used boots from Unbranded. Well-maintained and true to size, see photos for details.', 180.14, 838.29, 'Heavily Used', 1, '2026-07-04 19:40:00', 14, 1, 31, 67),
('Minimalist Dr. Martens Boots', NULL, 3390.77, NULL, 'Brand New', 1, '2026-03-17 03:00:00', 14, 6, 40, 68),
('Cropped Boots', 'A lightly used boots from Unbranded. Well-maintained and true to size, see photos for details.', 153.24, 370.5, 'Lightly Used', 1, '2026-05-28 04:22:00', 14, 2, 31, 68),
('Y2K Boots', NULL, 148.78, NULL, 'Well Used', 1, '2026-06-18 15:22:00', 14, 1, 31, 64),
('Limited Edition Dr. Martens Boots', 'A like new boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 1490.7, 2283.36, 'Like New', 1, '2025-04-22 21:51:00', 14, 4, 40, 67),
('Oversized Boots', 'A heavily used boots from Unbranded. Well-maintained and true to size, see photos for details.', 63.69, 320.26, 'Heavily Used', 1, '2025-01-30 23:39:00', 14, 5, 31, 67),
('Classic Dr. Martens Boots', NULL, 2656.86, NULL, 'Like New', 1, '2026-07-04 05:23:00', 14, 6, 40, 65),
('Signature Dr. Martens Boots', NULL, 2470.24, NULL, 'Like New', 1, '2026-02-02 19:25:00', 14, 4, 40, 64),
('Signature Boots', NULL, 430.08, NULL, 'Lightly Used', 1, '2025-03-28 21:08:00', 14, 3, 31, 67),
('Oversized Dr. Martens Boots', 'A like new boots from Dr. Martens. Well-maintained and true to size, see photos for details.', 3459.17, 6591.2, 'Like New', 1, '2026-03-10 05:31:00', 14, 2, 17, 66),
('Y2K ZARA Flats', NULL, 829.37, NULL, 'Lightly Used', 1, '2026-01-29 17:32:00', 15, 3, 30, 72),
('Vintage Shein Flats', NULL, 178.74, NULL, 'Lightly Used', 1, '2025-08-14 09:02:00', 15, 6, 28, 72),
('Classic ZARA Flats', 'A like new flats from ZARA. Well-maintained and true to size, see photos for details.', 959.55, 1602.06, 'Like New', 1, '2025-04-27 08:49:00', 15, 5, 30, 71),
('Classic ZARA Flats', NULL, 599.06, NULL, 'Like New', 1, '2026-03-26 03:49:00', 15, 6, 30, 70),
('Vintage ZARA Flats', 'A well used flats from ZARA. Well-maintained and true to size, see photos for details.', 545.66, 1634.24, 'Well Used', 1, '2025-12-26 17:17:00', 15, 6, 30, 71),
('Retro Flats', NULL, 330.31, NULL, 'Like New', 1, '2025-05-10 22:55:00', 15, 6, 31, 69),
('Signature ZARA Flats', NULL, 418.24, NULL, 'Well Used', 1, '2025-10-03 20:26:00', 15, 2, 30, 71),
('Cropped Shein Flats', NULL, 327.32, NULL, 'Lightly Used', 1, '2026-05-15 10:37:00', 15, 1, 28, 69),
('Oversized Flats', 'A lightly used flats from Unbranded. Well-maintained and true to size, see photos for details.', 502.69, 1203.73, 'Lightly Used', 1, '2025-08-05 15:17:00', 15, 1, 31, 72),
('Preloved Shein Flats', 'A brand new flats from Shein. Well-maintained and true to size, see photos for details.', 94.48, 113.03, 'Brand New', 1, '2026-03-28 14:00:00', 15, 6, 28, 69),
('Retro Shein Flats', 'A like new flats from Shein. Well-maintained and true to size, see photos for details.', 132.79, 232.42, 'Like New', 1, '2025-08-28 13:41:00', 15, 1, 28, 71),
('Oversized Shein Flats', 'A lightly used flats from Shein. Well-maintained and true to size, see photos for details.', 320.96, 656.48, 'Lightly Used', 1, '2025-05-16 15:04:00', 15, 1, 28, 70),
('Limited Edition ZARA Flats', 'A well used flats from ZARA. Well-maintained and true to size, see photos for details.', 377.14, 1580.37, 'Well Used', 1, '2025-05-27 02:33:00', 15, 3, 30, 71),
('Classic Sandals', 'A well used sandals from Unbranded. Well-maintained and true to size, see photos for details.', 41.13, 175.7, 'Well Used', 1, '2026-01-29 11:27:00', 16, 6, 31, 74),
('Everyday ZARA Sandals', 'A well used sandals from ZARA. Well-maintained and true to size, see photos for details.', 372.18, 1419.29, 'Well Used', 1, '2026-06-06 06:47:00', 16, 5, 30, 75),
('Preloved Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 452.55, 889.51, 'Lightly Used', 1, '2026-02-01 18:26:00', 16, 1, 28, 74),
('Everyday Sandals', 'A like new sandals from Unbranded. Well-maintained and true to size, see photos for details.', 481.07, 784.59, 'Like New', 1, '2026-03-02 13:44:00', 16, 1, 31, 73),
('Y2K Shein Sandals', 'A heavily used sandals from Shein. Well-maintained and true to size, see photos for details.', 60.05, 348.14, 'Heavily Used', 1, '2025-03-01 07:05:00', 16, 1, 28, 74),
('Minimalist Sandals', NULL, 565.06, NULL, 'Like New', 1, '2026-06-20 16:50:00', 16, 6, 31, 74),
('Vintage ZARA Sandals', NULL, 572.12, NULL, 'Lightly Used', 1, '2025-12-10 13:17:00', 16, 3, 30, 74),
('Classic Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 155.05, 394.15, 'Lightly Used', 1, '2025-04-29 07:47:00', 16, 6, 28, 73),
('Timeless Shein Sandals', 'A well used sandals from Shein. Well-maintained and true to size, see photos for details.', 42.65, 128.29, 'Well Used', 1, '2026-03-06 07:20:00', 16, 3, 28, 76),
('Oversized ZARA Sandals', 'A like new sandals from ZARA. Well-maintained and true to size, see photos for details.', 1128.23, 1667.37, 'Like New', 1, '2025-03-12 14:55:00', 16, 5, 30, 75),
('Minimalist ZARA Sandals', NULL, 846.64, NULL, 'Like New', 1, '2026-05-21 06:46:00', 16, 3, 30, 74),
('Limited Edition ZARA Sandals', 'A brand new sandals from ZARA. Well-maintained and true to size, see photos for details.', 1246.4, 1916.68, 'Brand New', 1, '2026-01-21 23:46:00', 16, 1, 30, 76),
('Timeless Shein Sandals', 'A lightly used sandals from Shein. Well-maintained and true to size, see photos for details.', 358.5, 817.83, 'Lightly Used', 1, '2026-01-17 14:47:00', 16, 1, 28, 74),
('Minimalist Gucci Bags & Purses', NULL, 660.99, NULL, 'Lightly Used', 1, '2026-02-07 22:53:00', 17, 5, 34, 77),
('Classic Dior Bags & Purses', NULL, 832.52, NULL, 'Like New', 1, '2025-06-09 03:10:00', 17, 4, 43, 79),
('Classic Coach Bags & Purses', 'A like new bags & purses from Coach. Well-maintained and true to size, see photos for details.', 1442.22, 2472.09, 'Like New', 1, '2025-04-03 05:51:00', 17, 3, 41, 80),
('Vintage Gucci Bags & Purses', 'A heavily used bags & purses from Gucci. Well-maintained and true to size, see photos for details.', 15673.0, 65610.01, 'Heavily Used', 0, '2026-02-19 14:35:00', 17, 6, 6, 78),
('Oversized Louis Vuitton Bags & Purses', NULL, 1118.9, NULL, 'Brand New', 1, '2026-01-17 21:40:00', 17, 1, 37, 77),
('Preloved ZARA Bags & Purses', 'A well used bags & purses from ZARA. Well-maintained and true to size, see photos for details.', 197.49, 636.18, 'Well Used', 1, '2025-04-05 10:07:00', 17, 5, 30, 79),
('Retro ZARA Bags & Purses', 'A lightly used bags & purses from ZARA. Well-maintained and true to size, see photos for details.', 253.92, 665.02, 'Lightly Used', 1, '2026-04-02 04:02:00', 17, 4, 30, 80),
('Vintage Gucci Bags & Purses', 'A like new bags & purses from Gucci. Well-maintained and true to size, see photos for details.', 72369.27, 112306.58, 'Like New', 0, '2026-01-27 22:22:00', 17, 1, 5, 79),
('Everyday Coach Bags & Purses', 'A brand new bags & purses from Coach. Well-maintained and true to size, see photos for details.', 9228.61, 10878.87, 'Brand New', 1, '2026-01-02 18:14:00', 17, 3, 13, 78),
('Oversized Dior Bags & Purses', NULL, 1047.71, NULL, 'Well Used', 1, '2025-12-30 05:11:00', 17, 5, 43, 77),
('Signature ZARA Bags & Purses', 'A well used bags & purses from ZARA. Well-maintained and true to size, see photos for details.', 571.16, 1910.85, 'Well Used', 1, '2025-07-12 15:34:00', 17, 3, 30, 79),
('Preloved Gucci Bags & Purses', 'A brand new bags & purses from Gucci. Well-maintained and true to size, see photos for details.', 90116.14, 125483.41, 'Brand New', 0, '2025-11-28 01:01:00', 17, 2, 5, 78),
('Limited Edition Dior Bags & Purses', 'A lightly used bags & purses from Dior. Well-maintained and true to size, see photos for details.', 122376.17, 288440.97, 'Lightly Used', 0, '2026-05-14 20:20:00', 17, 6, 1, 80),
('Oversized Accessories', 'A like new accessories from Unbranded. Well-maintained and true to size, see photos for details.', 956.34, 1425.74, 'Like New', 1, '2025-02-03 05:38:00', 18, 2, 31, 81),
('Classic H&M Accessories', NULL, 353.26, NULL, 'Like New', 1, '2025-12-10 14:00:00', 18, 6, 38, 81),
('Cropped ZARA Accessories', NULL, 775.56, NULL, 'Like New', 1, '2026-03-06 05:56:00', 18, 2, 30, 81),
('Limited Edition H&M Accessories', 'A lightly used accessories from H&M. Well-maintained and true to size, see photos for details.', 575.88, 1158.98, 'Lightly Used', 1, '2025-08-19 05:28:00', 18, 4, 38, 81),
('Everyday H&M Accessories', 'A brand new accessories from H&M. Well-maintained and true to size, see photos for details.', 757.31, 950.92, 'Brand New', 1, '2025-04-06 10:38:00', 18, 3, 38, 81),
('Timeless ZARA Accessories', NULL, 597.21, NULL, 'Like New', 1, '2026-07-08 08:42:00', 18, 1, 30, 81),
('Minimalist H&M Accessories', 'A brand new accessories from H&M. Well-maintained and true to size, see photos for details.', 1279.55, 1879.71, 'Brand New', 1, '2025-01-04 13:05:00', 18, 2, 38, 81),
('Retro ZARA Accessories', 'A heavily used accessories from ZARA. Well-maintained and true to size, see photos for details.', 250.26, 1100.61, 'Heavily Used', 1, '2025-04-04 20:34:00', 18, 2, 30, 81),
('Timeless ZARA Accessories', 'A like new accessories from ZARA. Well-maintained and true to size, see photos for details.', 663.87, 1259.22, 'Like New', 1, '2025-04-10 02:42:00', 18, 4, 30, 81),
('Everyday Accessories', 'A lightly used accessories from Unbranded. Well-maintained and true to size, see photos for details.', 640.69, 1359.03, 'Lightly Used', 1, '2026-06-14 18:43:00', 18, 4, 31, 81),
('Preloved ZARA Accessories', 'A brand new accessories from ZARA. Well-maintained and true to size, see photos for details.', 523.94, 643.26, 'Brand New', 1, '2025-09-22 10:58:00', 18, 2, 30, 81),
('Oversized H&M Accessories', 'A well used accessories from H&M. Well-maintained and true to size, see photos for details.', 483.86, 1600.82, 'Well Used', 1, '2025-04-26 13:09:00', 18, 5, 38, 81),
('Cropped H&M Accessories', 'A well used accessories from H&M. Well-maintained and true to size, see photos for details.', 453.0, 1509.58, 'Well Used', 1, '2025-02-08 05:17:00', 18, 5, 38, 81),
('Retro ZARA Earrings', 'A brand new earrings from ZARA. Well-maintained and true to size, see photos for details.', 272.03, 334.4, 'Brand New', 1, '2025-11-15 08:53:00', 19, 6, 30, 82),
('Timeless ZARA Earrings', 'A lightly used earrings from ZARA. Well-maintained and true to size, see photos for details.', 323.14, 659.36, 'Lightly Used', 1, '2026-05-12 16:55:00', 19, 3, 30, 82),
('Vintage ZARA Earrings', NULL, 327.27, NULL, 'Like New', 1, '2026-04-13 01:58:00', 19, 2, 30, 82),
('Cropped Earrings', 'A well used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 263.44, 1037.7, 'Well Used', 1, '2026-04-02 05:55:00', 19, 3, 31, 82),
('Limited Edition Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 797.05, 1292.81, 'Like New', 1, '2025-07-31 08:41:00', 19, 3, 31, 82),
('Retro Earrings', 'A like new earrings from Unbranded. Well-maintained and true to size, see photos for details.', 680.08, 1083.47, 'Like New', 1, '2026-03-10 12:54:00', 19, 5, 31, 82),
('Everyday ZARA Earrings', 'A lightly used earrings from ZARA. Well-maintained and true to size, see photos for details.', 957.32, 1943.03, 'Lightly Used', 1, '2025-10-17 09:43:00', 19, 6, 30, 82),
('Preloved ZARA Earrings', 'A well used earrings from ZARA. Well-maintained and true to size, see photos for details.', 475.76, 1817.04, 'Well Used', 1, '2026-06-14 07:57:00', 19, 6, 30, 82),
('Signature Earrings', 'A heavily used earrings from Unbranded. Well-maintained and true to size, see photos for details.', 212.43, 1118.26, 'Heavily Used', 1, '2025-07-14 10:46:00', 19, 6, 31, 82),
('Preloved Earrings', NULL, 490.22, NULL, 'Lightly Used', 1, '2025-12-10 20:05:00', 19, 3, 31, 82),
('Cropped ZARA Earrings', NULL, 418.91, NULL, 'Lightly Used', 1, '2025-05-01 15:03:00', 19, 2, 30, 82),
('Y2K ZARA Earrings', 'A well used earrings from ZARA. Well-maintained and true to size, see photos for details.', 429.28, 1780.44, 'Well Used', 1, '2025-12-17 13:36:00', 19, 2, 30, 82),
('Preloved ZARA Earrings', 'A like new earrings from ZARA. Well-maintained and true to size, see photos for details.', 845.39, 1594.03, 'Like New', 1, '2026-05-17 02:08:00', 19, 3, 30, 82),
('Everyday ZARA Rings', NULL, 960.7, NULL, 'Lightly Used', 1, '2025-07-15 00:43:00', 20, 1, 30, 83),
('Retro Rings', 'A like new rings from Unbranded. Well-maintained and true to size, see photos for details.', 189.42, 292.18, 'Like New', 1, '2025-10-25 14:46:00', 20, 2, 31, 85),
('Timeless ZARA Rings', NULL, 145.31, NULL, 'Heavily Used', 1, '2025-05-15 06:46:00', 20, 2, 30, 84),
('Everyday Rings', NULL, 272.57, NULL, 'Lightly Used', 1, '2025-02-19 19:03:00', 20, 1, 31, 85),
('Limited Edition Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 411.0, 1067.71, 'Lightly Used', 1, '2025-01-10 09:26:00', 20, 1, 31, 83),
('Minimalist Rings', 'A well used rings from Unbranded. Well-maintained and true to size, see photos for details.', 447.32, 1255.67, 'Well Used', 1, '2026-02-24 09:10:00', 20, 3, 31, 83),
('Everyday ZARA Rings', 'A brand new rings from ZARA. Well-maintained and true to size, see photos for details.', 369.78, 553.55, 'Brand New', 1, '2025-03-18 23:46:00', 20, 2, 30, 83),
('Minimalist ZARA Rings', NULL, 1465.36, NULL, 'Brand New', 1, '2025-11-17 13:47:00', 20, 3, 30, 86),
('Retro Rings', 'A well used rings from Unbranded. Well-maintained and true to size, see photos for details.', 476.48, 1347.07, 'Well Used', 1, '2025-04-06 11:52:00', 20, 1, 31, 83),
('Vintage ZARA Rings', 'A lightly used rings from ZARA. Well-maintained and true to size, see photos for details.', 230.52, 492.2, 'Lightly Used', 1, '2025-06-13 03:26:00', 20, 3, 30, 86),
('Limited Edition Rings', 'A lightly used rings from Unbranded. Well-maintained and true to size, see photos for details.', 248.57, 689.0, 'Lightly Used', 1, '2025-11-18 00:45:00', 20, 6, 31, 84),
('Vintage ZARA Rings', NULL, 1108.66, NULL, 'Like New', 1, '2025-06-10 16:54:00', 20, 3, 30, 86),
('Limited Edition ZARA Rings', 'A well used rings from ZARA. Well-maintained and true to size, see photos for details.', 96.85, 385.6, 'Well Used', 1, '2026-01-23 12:52:00', 20, 2, 30, 83),
('Everyday ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 199.33, 474.49, 'Lightly Used', 1, '2026-07-17 00:52:00', 21, 1, 30, 88),
('Signature ZARA Necklace', NULL, 283.02, NULL, 'Well Used', 1, '2026-04-30 22:42:00', 21, 3, 30, 88),
('Classic ZARA Necklace', 'A well used necklace from ZARA. Well-maintained and true to size, see photos for details.', 335.28, 1231.07, 'Well Used', 1, '2025-02-16 05:31:00', 21, 1, 30, 88),
('Oversized Necklace', 'A heavily used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 144.81, 1089.34, 'Heavily Used', 1, '2025-02-17 20:53:00', 21, 2, 31, 88),
('Preloved Necklace', 'A lightly used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 399.69, 1053.14, 'Lightly Used', 1, '2025-04-17 12:42:00', 21, 5, 31, 88),
('Minimalist ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 768.04, 1733.23, 'Lightly Used', 1, '2025-08-11 06:13:00', 21, 3, 30, 88),
('Everyday Necklace', NULL, 501.64, NULL, 'Lightly Used', 1, '2025-10-20 13:51:00', 21, 3, 31, 88),
('Preloved Necklace', 'A like new necklace from Unbranded. Well-maintained and true to size, see photos for details.', 919.64, 1476.12, 'Like New', 1, '2025-03-05 22:50:00', 21, 1, 31, 88),
('Oversized Necklace', 'A lightly used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 377.59, 1054.76, 'Lightly Used', 1, '2026-02-01 13:50:00', 21, 5, 31, 88),
('Limited Edition ZARA Necklace', 'A well used necklace from ZARA. Well-maintained and true to size, see photos for details.', 195.9, 800.1, 'Well Used', 1, '2025-03-18 05:11:00', 21, 2, 30, 88),
('Signature ZARA Necklace', 'A lightly used necklace from ZARA. Well-maintained and true to size, see photos for details.', 186.84, 367.9, 'Lightly Used', 1, '2025-02-22 20:39:00', 21, 2, 30, 88),
('Y2K Necklace', 'A well used necklace from Unbranded. Well-maintained and true to size, see photos for details.', 46.01, 183.32, 'Well Used', 1, '2025-12-06 10:23:00', 21, 2, 31, 88),
('Classic ZARA Necklace', 'A well used necklace from ZARA. Well-maintained and true to size, see photos for details.', 386.89, 1460.34, 'Well Used', 1, '2026-01-31 08:34:00', 21, 4, 30, 88),
('Limited Edition Bracelet', 'A like new bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 515.91, 959.05, 'Like New', 1, '2025-08-07 21:27:00', 22, 3, 31, 89),
('Signature Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 534.57, 1201.61, 'Lightly Used', 1, '2025-08-22 08:26:00', 22, 1, 31, 89),
('Everyday Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 386.36, 1066.28, 'Lightly Used', 1, '2025-04-19 09:50:00', 22, 4, 31, 89),
('Retro ZARA Bracelet', 'A lightly used bracelet from ZARA. Well-maintained and true to size, see photos for details.', 818.01, 1654.51, 'Lightly Used', 1, '2025-05-28 09:43:00', 22, 6, 30, 89),
('Timeless Bracelet', NULL, 234.69, NULL, 'Lightly Used', 1, '2025-12-19 06:26:00', 22, 5, 31, 89),
('Everyday Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 653.18, 1284.51, 'Lightly Used', 1, '2026-04-18 20:35:00', 22, 2, 31, 89),
('Classic Bracelet', 'A heavily used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 60.16, 390.07, 'Heavily Used', 1, '2025-07-18 10:31:00', 22, 2, 31, 89),
('Limited Edition ZARA Bracelet', 'A brand new bracelet from ZARA. Well-maintained and true to size, see photos for details.', 556.12, 770.36, 'Brand New', 1, '2025-12-06 15:29:00', 22, 4, 30, 89),
('Retro Bracelet', NULL, 74.74, NULL, 'Well Used', 1, '2025-03-20 23:04:00', 22, 6, 31, 89),
('Cropped Bracelet', 'A well used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 301.54, 838.03, 'Well Used', 1, '2025-06-02 11:25:00', 22, 5, 31, 89),
('Preloved Bracelet', 'A lightly used bracelet from Unbranded. Well-maintained and true to size, see photos for details.', 554.11, 1219.48, 'Lightly Used', 1, '2026-06-11 04:28:00', 22, 4, 31, 89),
('Minimalist ZARA Bracelet', 'A well used bracelet from ZARA. Well-maintained and true to size, see photos for details.', 92.8, 372.77, 'Well Used', 1, '2026-02-02 15:58:00', 22, 1, 30, 89),
('Classic ZARA Bracelet', 'A lightly used bracelet from ZARA. Well-maintained and true to size, see photos for details.', 424.64, 921.0, 'Lightly Used', 1, '2026-06-14 08:24:00', 22, 6, 30, 89),
('Preloved Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 316.63, 796.08, 'Lightly Used', 1, '2025-07-11 05:23:00', 23, 4, 31, 90),
('Signature Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 29.5, 82.55, 'Lightly Used', 1, '2025-06-14 04:40:00', 23, 6, 31, 90),
('Signature Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 550.65, 1423.52, 'Lightly Used', 1, '2026-04-28 15:10:00', 23, 5, 31, 90),
('Y2K Aesthetic Bundles', 'A well used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 143.22, 608.92, 'Well Used', 1, '2026-06-20 16:43:00', 23, 2, 31, 90),
('Limited Edition Aesthetic Bundles', 'A brand new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 540.97, 831.96, 'Brand New', 1, '2026-03-18 16:26:00', 23, 5, 31, 90),
('Signature Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 498.88, 1369.62, 'Lightly Used', 1, '2026-07-11 13:16:00', 23, 3, 31, 90),
('Retro Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 300.18, 667.8, 'Lightly Used', 1, '2026-07-03 13:36:00', 23, 4, 31, 90),
('Oversized Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 427.47, 887.59, 'Lightly Used', 1, '2025-05-22 21:07:00', 23, 2, 31, 90),
('Preloved Aesthetic Bundles', NULL, 29.78, NULL, 'Like New', 1, '2026-04-28 19:27:00', 23, 3, 31, 90),
('Limited Edition Aesthetic Bundles', 'A like new aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 800.67, 1399.49, 'Like New', 1, '2026-06-18 09:45:00', 23, 3, 31, 90),
('Signature Aesthetic Bundles', NULL, 494.5, NULL, 'Like New', 1, '2025-06-23 21:02:00', 23, 6, 31, 90),
('Signature Aesthetic Bundles', 'A heavily used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 94.1, 562.04, 'Heavily Used', 1, '2025-07-25 16:00:00', 23, 6, 31, 90),
('Classic Aesthetic Bundles', 'A lightly used aesthetic bundles from Unbranded. Well-maintained and true to size, see photos for details.', 235.71, 640.35, 'Lightly Used', 1, '2026-05-31 09:21:00', 23, 2, 31, 90),
('Nike Air Jordan 1 Retro High "Chicago"', 'Grail tier Air Jordan 1 in the original black, white, and red colorway that started it all in 1985. Authenticated preloved pair with minimal creasing, full original box included.', 28500.0, 32000.0, 'Like New', 0, '2026-01-22 18:30:00', 12, 1, 14, 50),
('Nike Air Jordan 1 Retro High "Bred Toe"', 'Highly sought after Bred Toe colorway. Lightly worn with visible love on the toe box, priced accordingly below mint condition resale comps.', 21000.0, 26000.0, 'Lightly Used', 0, '2025-09-07 10:49:00', 12, 2, 14, 51),
('Nike Air Jordan 13 Retro "Black Cat"', 'Cult favorite Jordan 13 in the stealthy Black Cat colorway. Rare full family size run from a private collection, sold as is with authenticity guarantee.', 18500.0, 21000.0, 'Like New', 0, '2026-04-15 21:29:00', 12, 3, 14, 52),
('Nike Air Force 1 \'07 "Triple White"', 'The everyday icon. Clean triple white Air Force 1, freshly deep cleaned, minor sole yellowing consistent with age.', 5800.0, 6500.0, 'Lightly Used', 0, '2025-01-29 15:07:00', 12, 4, 16, 53),
('Nike Air Force 1 Low "Premium Collab Edition"', 'Limited premium AF1 build with upgraded leather and collab style detailing. Deadstock condition, worn twice for photos only.', 8200.0, 9800.0, 'Brand New', 0, '2025-09-22 02:24:00', 12, 5, 16, 54),
('Louis Vuitton Trainer Sneaker, Monogram', 'Structured LV Trainer with monogram detailing and a chunky sole. Comes with dust bag and authenticity card, a true grail crossover between streetwear and luxury.', 98000.0, 125000.0, 'Like New', 0, '2025-08-14 21:44:00', 12, 6, 7, 55),
('Louis Vuitton LV Runner Sneaker', 'Sporty LV Runner with signature branding along the midsole. Well loved but structurally sound, priced fairly for the wear shown.', 67000.0, 89000.0, 'Well Used', 0, '2025-08-24 10:26:00', 12, 1, 8, 56),
('Gucci Ace Sneaker, Web Stripe', 'Clean low top Ace sneaker with the signature green and red web stripe. Minimalist leather build, barely worn.', 42000.0, 52000.0, 'Like New', 0, '2025-12-28 16:34:00', 12, 2, 9, 57),
('Gucci Rhyton Sneaker, Chunky Sole', 'Statement chunky sole Rhyton sneaker. The distressed look upper is factory finish, not wear, authenticated and boxed.', 48500.0, 58000.0, 'Brand New', 0, '2025-01-10 22:53:00', 12, 3, 10, 50),
('Dior B23 High-Top Sneaker, Oblique Canvas', 'Signature Dior Oblique canvas high top with leather trim. One of the most recognized silhouettes in modern luxury streetwear.', 72000.0, 95000.0, 'Like New', 0, '2025-09-27 07:18:00', 12, 4, 11, 51);

INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(1, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(2, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(2, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(2, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(3, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(3, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(3, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(3, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(3, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(4, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(5, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(5, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(5, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(5, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(5, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(6, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(7, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(7, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(7, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(8, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(8, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(8, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(8, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(8, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(9, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(10, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(10, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(10, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(11, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(11, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(11, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(11, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(11, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(12, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 1),
(12, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(12, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(13, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 1),
(13, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(13, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=600', 0),
(13, 'https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=600', 0),
(14, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(15, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(15, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(15, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(16, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(17, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(17, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(18, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(18, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(18, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(18, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(18, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(19, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(19, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(19, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(20, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(20, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(20, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(20, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(20, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(21, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(21, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(21, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(22, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(22, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(22, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(22, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 0),
(22, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(23, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(24, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(25, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600', 1),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(26, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(27, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(27, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(27, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(27, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(28, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(28, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(28, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(29, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(29, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(30, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(30, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(30, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(31, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(31, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(31, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(32, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(33, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(33, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(33, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(33, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(33, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(34, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(34, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(34, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(34, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(34, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(35, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(35, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(35, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(35, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(36, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(36, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(36, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(36, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(37, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(37, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(37, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(38, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 1),
(38, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(38, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(39, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 1),
(39, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600', 0),
(39, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(39, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 0),
(40, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(41, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(42, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(43, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(44, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(45, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(46, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(46, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(46, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(46, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(47, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(48, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(49, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(49, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(49, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(49, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(50, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(51, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 1),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(52, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 0),
(53, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(54, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(54, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(54, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(54, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(55, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(55, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(55, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(56, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(57, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(58, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(59, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(59, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(60, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(61, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 1),
(61, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(61, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(61, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(62, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(62, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(62, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(62, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(62, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(63, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(63, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(63, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(64, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(64, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(64, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600', 0),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 1),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(65, 'https://images.unsplash.com/photo-1580906853203-fbc1ae42d1f5?w=600', 0),
(66, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(67, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(67, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(67, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(67, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(68, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(69, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(70, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(70, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(71, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(72, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(73, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(74, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(74, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(74, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(74, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(75, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 1),
(76, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(77, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(78, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 1),
(78, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(78, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(78, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?w=600', 0),
(78, 'https://images.unsplash.com/photo-1583744946564-b52d01c92716?w=600', 0),
(79, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(79, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(79, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(80, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(80, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(80, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(80, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(80, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(81, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(81, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(81, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(81, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(82, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(83, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(84, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(84, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(84, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(84, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(84, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(85, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(86, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(86, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(86, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(87, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(87, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(87, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(87, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(88, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 1),
(88, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(88, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 0),
(89, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(89, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(89, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(89, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(90, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(91, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600', 1),
(91, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(91, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', 0),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(92, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(92, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(93, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(94, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(95, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(95, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(95, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(96, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(97, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(97, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(97, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(97, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(97, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(98, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(98, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(99, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(99, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(99, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(99, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(99, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(100, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(100, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(100, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(101, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(101, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(101, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(102, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(102, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(102, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(103, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 1),
(103, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(103, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 0),
(104, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600', 1),
(104, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(104, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600', 0),
(105, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(105, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(105, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(105, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(106, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(106, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(106, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(106, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(107, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(107, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(107, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(108, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(109, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(109, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(110, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(111, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(111, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(111, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(111, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(112, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(112, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(112, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(113, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(113, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(114, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(114, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(114, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(114, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(115, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 1),
(115, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(115, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 0),
(115, 'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600', 0),
(116, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(117, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600', 1),
(118, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(119, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(119, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(119, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(120, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(120, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(120, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(121, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(122, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(122, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(122, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(122, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(123, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(123, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(123, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(123, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(124, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(125, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(125, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(125, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(126, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(126, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(126, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(126, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(127, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(127, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(127, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(128, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(128, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(128, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 0),
(128, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 0),
(129, 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=600', 1),
(130, 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=600', 1),
(131, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(131, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(131, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(132, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(133, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(134, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(134, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(134, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(134, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(134, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(135, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(136, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(136, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(136, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(136, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(136, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(137, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(138, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(138, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(138, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(139, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(140, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(140, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(140, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(140, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(140, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(141, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(141, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(141, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(141, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(142, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 1),
(142, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(142, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(142, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(142, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(143, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 1),
(143, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(143, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(143, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600', 0),
(143, 'https://images.unsplash.com/photo-1596703263926-eb0762ee17e4?w=600', 0),
(144, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(144, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(144, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(144, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(145, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(145, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(145, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(145, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(145, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(146, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(147, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(147, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(147, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(148, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(148, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(148, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(149, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 1),
(150, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(150, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(150, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(150, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(151, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(151, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(151, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(151, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(151, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(152, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(153, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(153, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(153, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(154, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(154, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(155, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(156, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(156, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(156, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(156, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(156, 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=600', 0),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(157, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(158, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(158, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(158, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(158, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(158, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(159, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(159, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(159, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(160, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(160, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(160, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(161, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(161, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(161, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(162, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(163, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(164, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(165, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(165, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(165, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(165, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(166, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(166, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(166, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(167, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(168, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 1),
(168, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(168, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(168, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(169, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 1),
(169, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(169, 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600', 0),
(169, 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600', 0),
(170, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(170, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(170, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(170, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(170, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(171, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(171, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(171, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(171, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(172, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(172, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(172, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(172, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(173, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(173, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(173, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(174, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(175, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(175, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(175, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(176, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(177, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(177, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(177, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(178, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(178, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(178, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(179, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(180, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(181, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 1),
(182, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 1),
(182, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(182, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(182, 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600', 0),
(182, 'https://images.unsplash.com/photo-1616244916660-d135a013d1f8?w=600', 0),
(183, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(184, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(185, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(185, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(185, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(185, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(185, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(186, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(187, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(187, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(188, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(189, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(190, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(191, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(191, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(191, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(191, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(192, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(192, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(192, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(192, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(193, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(193, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(193, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(194, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 1),
(194, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(194, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(195, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 1),
(195, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(195, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(195, 'https://images.unsplash.com/photo-1518049362265-d5b2a6467637?w=600', 0),
(195, 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600', 0),
(196, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(196, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(196, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(196, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(197, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(197, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(198, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(198, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(198, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(198, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(199, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(199, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(199, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(199, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(200, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(200, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(200, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(201, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(202, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(203, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(204, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(205, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 1),
(205, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(205, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(205, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(206, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(207, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(207, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(207, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(207, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(208, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 1),
(208, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600', 0),
(208, 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=600', 0),
(209, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(210, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(211, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(211, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(211, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(211, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(211, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(212, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 1),
(212, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(212, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 0),
(213, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(214, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 1),
(214, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(214, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(215, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(215, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(215, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(215, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(215, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(216, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 1),
(216, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(216, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(216, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(217, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(217, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(217, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(218, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(219, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 1),
(219, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600', 0),
(219, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(219, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600', 0),
(220, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 1),
(220, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 0),
(220, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(220, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(220, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 0),
(221, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 1),
(221, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(221, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 0),
(221, 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600', 0),
(221, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=600', 0),
(222, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(222, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(222, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(222, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(223, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(224, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(225, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(225, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(225, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(226, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(226, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(226, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(226, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(226, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(227, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(228, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(228, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(228, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(228, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(229, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(229, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(230, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 1),
(230, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(230, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(230, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(231, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(231, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(232, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(232, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(232, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(232, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(232, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(233, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(233, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(233, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(234, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 1),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(234, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', 0),
(234, 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600', 0),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(235, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(235, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(236, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(236, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(236, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(236, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(237, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(238, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(238, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(238, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(238, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(239, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(239, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(239, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(239, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(240, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(240, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(240, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(240, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(241, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(241, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(241, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(242, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(242, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(242, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(243, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(243, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(243, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(243, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(243, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(244, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(245, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(246, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 1),
(246, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(246, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(246, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 1),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(247, 'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4a09?w=600', 0),
(248, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(249, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(249, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(249, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(249, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(249, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(250, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(251, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(252, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(252, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(252, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(253, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(253, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(253, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(254, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(254, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(254, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(255, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(256, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(256, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(256, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(257, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(257, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(257, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(257, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(257, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(258, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(258, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(258, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 0),
(259, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 1),
(260, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', 1),
(260, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(260, 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600', 0),
(261, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(261, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(261, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(262, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(263, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(263, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(263, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(264, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(264, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(264, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(265, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(265, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(265, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(265, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(265, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(266, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(266, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(266, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(267, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(268, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(268, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(268, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(268, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(269, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(269, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(269, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(269, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(270, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(270, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(270, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(270, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(270, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(271, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(271, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(271, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(271, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(271, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(272, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 1),
(272, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(272, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(272, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(273, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600', 0),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(273, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(274, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(274, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(274, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(275, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(275, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(275, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(275, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(276, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(276, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(277, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(277, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(278, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(279, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(279, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(279, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(280, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(280, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(280, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(280, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(281, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(281, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(281, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(281, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(282, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(283, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(283, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(283, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(284, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(284, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(284, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(285, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 1),
(285, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(285, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(285, 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', 0),
(286, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 1),
(286, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(286, 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=600', 0),
(287, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(287, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(287, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(287, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(287, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(288, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(289, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(289, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(289, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(290, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(290, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(290, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(290, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(291, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(291, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(291, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(291, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(292, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(292, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(292, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(293, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(293, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(293, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(293, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(294, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(294, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(294, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(294, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(294, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(295, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(296, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(296, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(296, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(296, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(296, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(297, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(298, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 1),
(298, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600', 0),
(298, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(298, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(298, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(299, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 1),
(299, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
(299, 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600', 0),
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
(144, 'Pending', 'Certificate of authenticity submitted by seller.'),
(147, 'Pending', 'Certificate of authenticity submitted by seller.'),
(156, 'Pending', 'No certificate provided, item verified against original box.'),
(212, 'Pending', 'Certificate of authenticity submitted by seller.'),
(216, 'Pending', 'Certificate of authenticity submitted by seller.'),
(220, 'Pending', 'No certificate provided, item verified against original box.'),
(221, 'Pending', 'Certificate of authenticity submitted by seller.'),
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
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=1, date_verified='2026-05-24 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=147;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=2, date_verified='2026-02-22 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=156;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=3, date_verified='2026-05-11 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=216;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=3, date_verified='2026-06-02 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=220;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=2, date_verified='2026-01-08 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=300;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=1, date_verified='2026-01-25 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=301;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=3, date_verified='2026-05-31 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=303;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=1, date_verified='2026-03-13 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=304;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=2, date_verified='2026-01-11 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=306;
UPDATE AUTHENTICATION SET authentication_status='Rejected', verified_by_admin_id=2, date_verified='2026-05-28 15:00:00', remarks='Box serial number does not match item.' WHERE listing_id=307;
UPDATE AUTHENTICATION SET authentication_status='Verified', verified_by_admin_id=2, date_verified='2026-05-19 15:00:00', remarks='Certificate matches brand records.' WHERE listing_id=309;

-- (Luxury listings seeded: 17 total; roughly 1/3 left Pending for the admin queue)

-- ------------------------------------------------------------
-- AUCTIONS + BIDDINGS
-- ------------------------------------------------------------
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (396.14, 20, 396.14, '2025-12-28 01:03:00', '2027-07-19 15:00:00', 'Active', 124);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(441.72, '2025-12-28 23:03:00', 1, 8),
(498.08, '2025-12-29 16:03:00', 1, 6),
(539.67, '2025-12-30 19:03:00', 1, 7),
(563.25, '2025-12-31 06:03:00', 1, 5),
(597.88, '2025-12-31 16:03:00', 1, 4),
(624.11, '2025-12-31 18:03:00', 1, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-31 19:03:00' WHERE auction_id=1;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (190.65, 20, 190.65, '2026-07-16 15:00:00', '2026-07-22 02:00:00', 'Active', 136);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(216.64, '2026-07-18 08:00:00', 2, 1),
(252.6, '2026-07-18 13:00:00', 2, 6),
(277.22, '2026-07-18 14:00:00', 2, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (18.61, 20, 18.61, '2025-09-17 23:01:00', '2027-07-19 15:00:00', 'Active', 106);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(48.61, '2025-09-19 06:01:00', 3, 7),
(98.09, '2025-09-19 20:01:00', 3, 5),
(151.23, '2025-09-20 05:01:00', 3, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-20 08:01:00' WHERE auction_id=3;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (308.74, 20, 308.74, '2026-03-20 16:58:00', '2027-07-19 15:00:00', 'Active', 118);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(350.02, '2026-03-21 14:58:00', 4, 5),
(386.54, '2026-03-22 19:58:00', 4, 3),
(409.28, '2026-03-23 01:58:00', 4, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-23 04:58:00' WHERE auction_id=4;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (461.56, 23.08, 461.56, '2025-09-01 09:07:00', '2027-07-19 15:00:00', 'Active', 104);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(485.54, '2025-09-01 18:07:00', 5, 8),
(553.38, '2025-09-01 20:07:00', 5, 3),
(585.04, '2025-09-02 01:07:00', 5, 6),
(621.14, '2025-09-02 07:07:00', 5, 5),
(677.23, '2025-09-03 08:07:00', 5, 4),
(700.69, '2025-09-03 12:07:00', 5, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-03 14:07:00' WHERE auction_id=5;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (396.45, 20, 396.45, '2025-01-28 19:30:00', '2027-07-19 15:00:00', 'Active', 128);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(444.33, '2025-01-29 06:30:00', 6, 7),
(477.54, '2025-01-30 10:30:00', 6, 3),
(527.56, '2025-01-30 16:30:00', 6, 4),
(549.8, '2025-01-31 18:30:00', 6, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-31 22:30:00' WHERE auction_id=6;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (359.44, 20, 359.44, '2026-03-26 03:49:00', '2027-07-19 15:00:00', 'Active', 186);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(412.57, '2026-03-26 15:49:00', 7, 4),
(471.55, '2026-03-27 15:49:00', 7, 7),
(501.51, '2026-03-28 17:49:00', 7, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-28 21:49:00' WHERE auction_id=7;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (291.13, 20, 291.13, '2026-07-15 15:00:00', '2026-07-20 21:00:00', 'Active', 80);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (229.19, 20, 229.19, '2025-07-28 08:35:00', '2027-07-19 15:00:00', 'Active', 55);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(286.64, '2025-07-28 20:35:00', 9, 8),
(331.81, '2025-07-28 23:35:00', 9, 4),
(381.6, '2025-07-29 18:35:00', 9, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-29 23:35:00' WHERE auction_id=9;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (411.53, 20.58, 411.53, '2026-07-01 12:20:00', '2027-07-19 15:00:00', 'Active', 62);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(449.98, '2026-07-02 01:20:00', 10, 5),
(477.45, '2026-07-02 11:20:00', 10, 2),
(522.1, '2026-07-03 01:20:00', 10, 3),
(575.16, '2026-07-03 03:20:00', 10, 1),
(635.62, '2026-07-03 23:20:00', 10, 7),
(688.45, '2026-07-04 16:20:00', 10, 8),
(737.36, '2026-07-04 22:20:00', 10, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-05 01:20:00' WHERE auction_id=10;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (707.18, 35.36, 707.18, '2026-04-16 22:09:00', '2027-07-19 15:00:00', 'Active', 41);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(767.68, '2026-04-17 05:09:00', 11, 2),
(852.64, '2026-04-18 08:09:00', 11, 6),
(895.59, '2026-04-19 01:09:00', 11, 5),
(947.4, '2026-04-19 20:09:00', 11, 3),
(1038.53, '2026-04-20 22:09:00', 11, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-21 01:09:00' WHERE auction_id=11;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (58.11, 20, 58.11, '2026-07-15 15:00:00', '2026-07-21 13:00:00', 'Active', 260);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(87.82, '2026-07-19 12:00:00', 12, 3),
(119.0, '2026-07-19 17:00:00', 12, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (129.82, 20, 129.82, '2026-01-09 05:23:00', '2027-07-19 15:00:00', 'Active', 4);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(179.12, '2026-01-09 21:23:00', 13, 3),
(233.83, '2026-01-10 18:23:00', 13, 5),
(290.41, '2026-01-11 13:23:00', 13, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-11 15:23:00' WHERE auction_id=13;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (55.68, 20, 55.68, '2026-02-02 15:58:00', '2027-07-19 15:00:00', 'Active', 285);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(75.71, '2026-02-03 21:58:00', 14, 5),
(115.95, '2026-02-04 22:58:00', 14, 7),
(143.37, '2026-02-05 00:58:00', 14, 3),
(188.16, '2026-02-05 13:58:00', 14, 8),
(239.2, '2026-02-05 22:58:00', 14, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-06 01:58:00' WHERE auction_id=14;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (207.87, 20, 207.87, '2025-04-25 02:56:00', '2027-07-19 15:00:00', 'Active', 22);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(240.77, '2025-04-26 05:56:00', 15, 7),
(273.65, '2025-04-26 10:56:00', 15, 2),
(314.58, '2025-04-26 14:56:00', 15, 5),
(336.33, '2025-04-26 20:56:00', 15, 4),
(363.48, '2025-04-26 23:56:00', 15, 8),
(391.56, '2025-04-27 16:56:00', 15, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-27 18:56:00' WHERE auction_id=15;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (221.87, 20, 221.87, '2025-03-18 23:46:00', '2027-07-19 15:00:00', 'Active', 254);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(266.11, '2025-03-19 07:46:00', 16, 7),
(286.63, '2025-03-19 15:46:00', 16, 6),
(332.86, '2025-03-20 21:46:00', 16, 4),
(386.14, '2025-03-21 13:46:00', 16, 5),
(438.18, '2025-03-21 16:46:00', 16, 3),
(472.62, '2025-03-22 17:46:00', 16, 1),
(530.15, '2025-03-23 08:46:00', 16, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-23 11:46:00' WHERE auction_id=16;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (192.58, 20, 192.58, '2026-07-18 15:00:00', '2026-07-23 07:00:00', 'Active', 194);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (879.43, 43.97, 879.43, '2025-01-31 20:17:00', '2027-07-19 15:00:00', 'Active', 165);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(970.15, '2025-02-01 08:17:00', 18, 2),
(1031.1, '2025-02-02 07:17:00', 18, 1),
(1096.95, '2025-02-03 05:17:00', 18, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-03 07:17:00' WHERE auction_id=18;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (17.7, 20, 17.7, '2026-07-18 15:00:00', '2026-07-24 14:00:00', 'Active', 288);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(41.04, '2026-07-19 06:00:00', 19, 6),
(72.04, '2026-07-19 11:00:00', 19, 8),
(98.79, '2026-07-19 13:00:00', 19, 4),
(129.47, '2026-07-19 18:00:00', 19, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (693.2, 34.66, 693.2, '2025-05-01 20:58:00', '2027-07-19 15:00:00', 'Active', 141);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(780.83, '2025-05-02 18:58:00', 20, 6),
(872.76, '2025-05-03 06:58:00', 20, 5),
(949.6, '2025-05-04 02:58:00', 20, 3),
(1022.08, '2025-05-04 16:58:00', 20, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-04 21:58:00' WHERE auction_id=20;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (665.2, 33.26, 665.2, '2025-06-10 16:54:00', '2027-07-19 15:00:00', 'Active', 259);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(699.54, '2025-06-11 08:54:00', 21, 8),
(798.88, '2025-06-11 19:54:00', 21, 4),
(832.58, '2025-06-12 04:54:00', 21, 1),
(880.13, '2025-06-12 16:54:00', 21, 6),
(914.83, '2025-06-13 20:54:00', 21, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-14 02:54:00' WHERE auction_id=21;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (813.5, 40.68, 813.5, '2026-07-17 15:00:00', '2026-07-25 08:00:00', 'Active', 94);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (226.55, 20, 226.55, '2026-02-01 13:50:00', '2027-07-19 15:00:00', 'Active', 269);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(256.54, '2026-02-02 09:50:00', 23, 3),
(308.98, '2026-02-02 13:50:00', 23, 8),
(351.8, '2026-02-03 09:50:00', 23, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-03 11:50:00' WHERE auction_id=23;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (791.84, 39.59, 791.84, '2026-07-15 15:00:00', '2026-07-23 20:00:00', 'Active', 145);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(860.36, '2026-07-19 13:00:00', 24, 2),
(915.06, '2026-07-19 14:00:00', 24, 5),
(991.15, '2026-07-19 17:00:00', 24, 6),
(1044.51, '2026-07-19 21:00:00', 24, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (747.84, 37.39, 747.84, '2026-01-21 23:46:00', '2027-07-19 15:00:00', 'Active', 207);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(848.75, '2026-01-22 12:46:00', 25, 4),
(933.54, '2026-01-23 10:46:00', 25, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-23 14:46:00' WHERE auction_id=25;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (99.5, 20, 99.5, '2025-10-20 22:58:00', '2027-07-19 15:00:00', 'Active', 114);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(125.48, '2025-10-22 02:58:00', 26, 6),
(173.39, '2025-10-22 08:58:00', 26, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-22 09:58:00' WHERE auction_id=26;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (18.43, 20, 18.43, '2026-07-18 15:00:00', '2026-07-25 09:00:00', 'Active', 66);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(54.16, '2026-07-18 18:00:00', 27, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (121.14, 20, 121.14, '2025-07-21 11:27:00', '2027-07-19 15:00:00', 'Active', 28);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(143.11, '2025-07-22 13:27:00', 28, 8),
(173.61, '2025-07-23 03:27:00', 28, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-23 08:27:00' WHERE auction_id=28;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (465.34, 23.27, 465.34, '2026-07-15 15:00:00', '2026-07-21 19:00:00', 'Active', 224);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(501.67, '2026-07-19 04:00:00', 29, 4),
(537.14, '2026-07-19 06:00:00', 29, 8),
(562.08, '2026-07-19 10:00:00', 29, 7),
(592.88, '2026-07-19 15:00:00', 29, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (246.6, 20, 246.6, '2025-01-10 09:26:00', '2027-07-19 15:00:00', 'Active', 252);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(292.82, '2025-01-11 21:26:00', 30, 7),
(325.01, '2025-01-12 10:26:00', 30, 4),
(369.66, '2025-01-13 13:26:00', 30, 3),
(407.35, '2025-01-13 19:26:00', 30, 6),
(444.97, '2025-01-14 23:26:00', 30, 2),
(474.31, '2025-01-15 22:26:00', 30, 8),
(509.26, '2025-01-17 00:26:00', 30, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-17 06:26:00' WHERE auction_id=30;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (281.25, 20, 281.25, '2025-11-18 01:03:00', '2027-07-19 15:00:00', 'Active', 17);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(336.0, '2025-11-19 08:03:00', 31, 4),
(367.51, '2025-11-19 20:03:00', 31, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-20 02:03:00' WHERE auction_id=31;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (239.81, 20, 239.81, '2025-04-17 12:42:00', '2027-07-19 15:00:00', 'Active', 265);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(281.67, '2025-04-18 18:42:00', 32, 1),
(312.02, '2025-04-19 11:42:00', 32, 3),
(356.94, '2025-04-19 17:42:00', 32, 2),
(404.74, '2025-04-20 16:42:00', 32, 5),
(425.48, '2025-04-21 12:42:00', 32, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-21 18:42:00' WHERE auction_id=32;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (258.05, 20, 258.05, '2025-03-28 21:08:00', '2027-07-19 15:00:00', 'Active', 181);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(302.77, '2025-03-29 12:08:00', 33, 1),
(341.37, '2025-03-29 14:08:00', 33, 3),
(364.03, '2025-03-30 13:08:00', 33, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-30 16:08:00' WHERE auction_id=33;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (676.94, 33.85, 676.94, '2026-07-15 15:00:00', '2026-07-21 00:00:00', 'Active', 205);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(743.85, '2026-07-18 03:00:00', 34, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (268.33, 20, 268.33, '2026-07-18 15:00:00', '2026-07-24 10:00:00', 'Active', 90);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(307.67, '2026-07-18 07:00:00', 35, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (285.46, 20, 285.46, '2026-07-17 15:00:00', '2026-07-20 16:00:00', 'Active', 242);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(305.83, '2026-07-19 06:00:00', 36, 5),
(332.87, '2026-07-19 12:00:00', 36, 3),
(358.92, '2026-07-19 17:00:00', 36, 4),
(384.44, '2026-07-19 18:00:00', 36, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (85.93, 20, 85.93, '2026-06-20 16:43:00', '2027-07-19 15:00:00', 'Active', 290);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(141.82, '2026-06-21 21:43:00', 37, 1),
(167.31, '2026-06-22 22:43:00', 37, 5),
(202.6, '2026-06-23 21:43:00', 37, 3),
(247.1, '2026-06-24 19:43:00', 37, 2),
(294.56, '2026-06-25 10:43:00', 37, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-25 12:43:00' WHERE auction_id=37;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2075.5, 103.78, 2075.5, '2026-03-10 05:31:00', '2027-07-19 15:00:00', 'Active', 182);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2314.71, '2026-03-11 05:31:00', 38, 6),
(2530.85, '2026-03-12 08:31:00', 38, 4),
(2676.62, '2026-03-12 14:31:00', 38, 5),
(2844.54, '2026-03-13 14:31:00', 38, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-13 19:31:00' WHERE auction_id=38;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (81.76, 20, 81.76, '2025-09-20 23:30:00', '2027-07-19 15:00:00', 'Active', 133);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(123.08, '2025-09-22 09:30:00', 39, 3),
(147.82, '2025-09-22 21:30:00', 39, 8),
(201.4, '2025-09-23 03:30:00', 39, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-23 09:30:00' WHERE auction_id=39;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (480.4, 24.02, 480.4, '2026-07-16 15:00:00', '2026-07-24 04:00:00', 'Active', 296);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(507.58, '2026-07-19 05:00:00', 40, 5),
(549.91, '2026-07-19 10:00:00', 40, 2),
(588.75, '2026-07-19 15:00:00', 40, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (356.42, 20, 356.42, '2025-06-06 21:59:00', '2027-07-19 15:00:00', 'Active', 81);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(390.79, '2025-06-07 22:59:00', 41, 4),
(441.98, '2025-06-08 04:59:00', 41, 2),
(482.07, '2025-06-09 01:59:00', 41, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-09 05:59:00' WHERE auction_id=41;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1482.14, 74.11, 1482.14, '2026-02-02 19:25:00', '2027-07-19 15:00:00', 'Active', 180);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1561.03, '2026-02-04 01:25:00', 42, 8),
(1778.74, '2026-02-04 11:25:00', 42, 4),
(1993.69, '2026-02-04 20:25:00', 42, 2),
(2177.83, '2026-02-05 04:25:00', 42, 6),
(2364.26, '2026-02-05 08:25:00', 42, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-05 10:25:00' WHERE auction_id=42;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (248.93, 20, 248.93, '2026-07-16 15:00:00', '2026-07-24 13:00:00', 'Active', 3);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(281.09, '2026-07-19 12:00:00', 43, 4),
(315.49, '2026-07-19 16:00:00', 43, 8),
(347.72, '2026-07-19 22:00:00', 43, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (189.98, 20, 189.98, '2025-07-11 05:23:00', '2027-07-19 15:00:00', 'Active', 287);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(230.73, '2025-07-11 23:23:00', 44, 1),
(290.08, '2025-07-12 02:23:00', 44, 5),
(332.39, '2025-07-12 20:23:00', 44, 8),
(383.0, '2025-07-12 23:23:00', 44, 4),
(410.59, '2025-07-13 15:23:00', 44, 7),
(446.51, '2025-07-14 02:23:00', 44, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-14 05:23:00' WHERE auction_id=44;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (89.27, 20, 89.27, '2026-06-18 15:22:00', '2027-07-19 15:00:00', 'Active', 176);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(142.47, '2026-06-19 15:22:00', 45, 1),
(166.09, '2026-06-20 09:22:00', 45, 6),
(190.62, '2026-06-21 11:22:00', 45, 5),
(234.04, '2026-06-22 17:22:00', 45, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-22 23:22:00' WHERE auction_id=45;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (447.88, 22.39, 447.88, '2025-04-01 10:16:00', '2027-07-19 15:00:00', 'Active', 54);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(510.42, '2025-04-03 02:16:00', 46, 6),
(541.85, '2025-04-03 18:16:00', 46, 4),
(568.28, '2025-04-04 06:16:00', 46, 1),
(621.65, '2025-04-05 06:16:00', 46, 2),
(679.71, '2025-04-06 06:16:00', 46, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-06 12:16:00' WHERE auction_id=46;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (457.69, 22.88, 457.69, '2026-06-24 02:41:00', '2027-07-19 15:00:00', 'Active', 98);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(505.75, '2026-06-24 12:41:00', 47, 8),
(563.79, '2026-06-25 00:41:00', 47, 6),
(612.55, '2026-06-25 23:41:00', 47, 3),
(674.91, '2026-06-26 06:41:00', 47, 1),
(737.55, '2026-06-26 13:41:00', 47, 4),
(795.63, '2026-06-26 16:41:00', 47, 7),
(837.71, '2026-06-27 03:41:00', 47, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-27 09:41:00' WHERE auction_id=47;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (90.76, 20, 90.76, '2026-02-27 13:35:00', '2027-07-19 15:00:00', 'Active', 151);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(135.66, '2026-02-28 00:35:00', 48, 2),
(156.15, '2026-02-28 17:35:00', 48, 8),
(210.37, '2026-03-01 12:35:00', 48, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-01 13:35:00' WHERE auction_id=48;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (115.09, 20, 115.09, '2026-07-15 15:00:00', '2026-07-21 21:00:00', 'Active', 26);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(147.09, '2026-07-17 22:00:00', 49, 7),
(184.73, '2026-07-18 01:00:00', 49, 4),
(217.13, '2026-07-18 06:00:00', 49, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (353.63, 20, 353.63, '2026-07-17 15:00:00', '2026-07-21 16:00:00', 'Active', 84);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(380.61, '2026-07-17 19:00:00', 50, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (321.0, 20, 321.0, '2026-07-16 15:00:00', '2026-07-25 10:00:00', 'Active', 93);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(349.34, '2026-07-19 06:00:00', 51, 2),
(372.57, '2026-07-19 09:00:00', 51, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1530.12, 76.51, 1530.12, '2025-11-04 21:52:00', '2027-07-19 15:00:00', 'Active', 160);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1656.03, '2025-11-06 08:52:00', 52, 3),
(1790.53, '2025-11-06 12:52:00', 52, 4),
(1983.1, '2025-11-07 16:52:00', 52, 6),
(2143.84, '2025-11-08 03:52:00', 52, 5),
(2292.39, '2025-11-08 08:52:00', 52, 8),
(2475.19, '2025-11-08 18:52:00', 52, 1),
(2602.08, '2025-11-09 09:52:00', 52, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-09 14:52:00' WHERE auction_id=52;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (767.73, 38.39, 767.73, '2025-01-04 13:05:00', '2027-07-19 15:00:00', 'Active', 228);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(858.99, '2025-01-06 04:05:00', 53, 1),
(973.11, '2025-01-06 15:05:00', 53, 8),
(1044.29, '2025-01-07 20:05:00', 53, 5),
(1106.98, '2025-01-08 14:05:00', 53, 6),
(1189.53, '2025-01-09 11:05:00', 53, 7),
(1255.09, '2025-01-09 17:05:00', 53, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-09 22:05:00' WHERE auction_id=53;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (37.85, 20, 37.85, '2025-10-21 07:38:00', '2027-07-19 15:00:00', 'Active', 67);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(57.91, '2025-10-21 13:38:00', 54, 8),
(96.51, '2025-10-22 16:38:00', 54, 4),
(121.23, '2025-10-23 21:38:00', 54, 2),
(149.52, '2025-10-24 18:38:00', 54, 5),
(209.48, '2025-10-25 09:38:00', 54, 6),
(231.3, '2025-10-25 22:38:00', 54, 3),
(273.72, '2025-10-26 20:38:00', 54, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-26 22:38:00' WHERE auction_id=54;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (120.25, 20, 120.25, '2026-03-30 09:55:00', '2027-07-19 15:00:00', 'Active', 48);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(144.8, '2026-03-30 22:55:00', 55, 5),
(178.45, '2026-03-31 23:55:00', 55, 3),
(221.21, '2026-04-01 01:55:00', 55, 1),
(274.49, '2026-04-01 09:55:00', 55, 7),
(307.71, '2026-04-01 21:55:00', 55, 8),
(364.6, '2026-04-02 14:55:00', 55, 4),
(421.25, '2026-04-03 17:55:00', 55, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-03 18:55:00' WHERE auction_id=55;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (36.1, 20, 36.1, '2025-07-18 10:31:00', '2027-07-19 15:00:00', 'Active', 280);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(68.07, '2025-07-19 20:31:00', 56, 8),
(115.2, '2025-07-20 15:31:00', 56, 7),
(156.64, '2025-07-20 23:31:00', 56, 5),
(199.74, '2025-07-21 11:31:00', 56, 3),
(251.72, '2025-07-22 17:31:00', 56, 4),
(303.55, '2025-07-22 21:31:00', 56, 2),
(362.33, '2025-07-23 07:31:00', 56, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-23 08:31:00' WHERE auction_id=56;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (154.74, 20, 154.74, '2026-07-15 15:00:00', '2026-07-24 20:00:00', 'Active', 68);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(188.85, '2026-07-18 18:00:00', 57, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (379.85, 20, 379.85, '2026-07-18 15:00:00', '2026-07-23 04:00:00', 'Active', 61);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(404.17, '2026-07-18 18:00:00', 58, 4),
(427.67, '2026-07-18 21:00:00', 58, 3),
(463.37, '2026-07-18 23:00:00', 58, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (127.0, 20, 127.0, '2026-07-18 15:00:00', '2026-07-24 07:00:00', 'Active', 69);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(161.65, '2026-07-18 09:00:00', 59, 3),
(187.86, '2026-07-18 12:00:00', 59, 2),
(210.73, '2026-07-18 13:00:00', 59, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (481.03, 24.05, 481.03, '2026-07-17 15:00:00', '2026-07-25 12:00:00', 'Active', 121);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(514.4, '2026-07-18 10:00:00', 60, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (576.42, 28.82, 576.42, '2025-07-15 00:43:00', '2027-07-19 15:00:00', 'Active', 248);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(632.15, '2025-07-15 09:43:00', 61, 1),
(666.91, '2025-07-16 11:43:00', 61, 6),
(733.71, '2025-07-16 22:43:00', 61, 5),
(763.83, '2025-07-18 00:43:00', 61, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-18 03:43:00' WHERE auction_id=61;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (381.25, 20, 381.25, '2025-10-24 10:07:00', '2027-07-19 15:00:00', 'Active', 88);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(432.16, '2025-10-25 15:07:00', 62, 5),
(456.87, '2025-10-25 21:07:00', 62, 3),
(483.17, '2025-10-26 02:07:00', 62, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-26 03:07:00' WHERE auction_id=62;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (140.81, 20, 140.81, '2025-12-19 06:26:00', '2027-07-19 15:00:00', 'Active', 278);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(182.78, '2025-12-19 22:26:00', 63, 4),
(208.44, '2025-12-20 22:26:00', 63, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-21 01:26:00' WHERE auction_id=63;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (251.35, 20, 251.35, '2025-05-01 15:03:00', '2027-07-19 15:00:00', 'Active', 245);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(292.97, '2025-05-02 00:03:00', 64, 5),
(318.17, '2025-05-02 17:03:00', 64, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-02 23:03:00' WHERE auction_id=64;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (256.48, 20, 256.48, '2025-05-22 21:07:00', '2027-07-19 15:00:00', 'Active', 294);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(283.64, '2025-05-24 01:07:00', 65, 2),
(339.29, '2025-05-24 23:07:00', 65, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-25 05:07:00' WHERE auction_id=65;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (253.66, 20, 253.66, '2026-02-14 23:28:00', '2027-07-19 15:00:00', 'Active', 109);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(312.61, '2026-02-16 03:28:00', 66, 6),
(363.19, '2026-02-16 23:28:00', 66, 7),
(388.46, '2026-02-18 03:28:00', 66, 2),
(440.55, '2026-02-19 03:28:00', 66, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-19 07:28:00' WHERE auction_id=66;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (332.47, 20, 332.47, '2026-06-11 04:28:00', '2027-07-19 15:00:00', 'Active', 284);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(368.15, '2026-06-12 10:28:00', 67, 8),
(424.84, '2026-06-12 22:28:00', 67, 4),
(476.39, '2026-06-14 04:28:00', 67, 2),
(509.38, '2026-06-14 21:28:00', 67, 6),
(530.59, '2026-06-15 14:28:00', 67, 5),
(555.11, '2026-06-16 07:28:00', 67, 3),
(593.56, '2026-06-16 14:28:00', 67, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-16 17:28:00' WHERE auction_id=67;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (215.38, 20, 215.38, '2026-07-11 15:16:00', '2027-07-19 15:00:00', 'Active', 108);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(248.41, '2026-07-12 15:16:00', 68, 2),
(271.25, '2026-07-13 02:16:00', 68, 4),
(312.56, '2026-07-13 16:16:00', 68, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-13 21:16:00' WHERE auction_id=68;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (497.62, 24.88, 497.62, '2026-01-29 17:32:00', '2027-07-19 15:00:00', 'Active', 183);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(539.45, '2026-01-30 23:32:00', 69, 3),
(598.87, '2026-01-31 14:32:00', 69, 4),
(662.78, '2026-02-01 05:32:00', 69, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-01 10:32:00' WHERE auction_id=69;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (24.68, 20, 24.68, '2026-01-29 11:27:00', '2027-07-19 15:00:00', 'Active', 196);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(74.25, '2026-01-30 13:27:00', 70, 3),
(117.22, '2026-01-31 06:27:00', 70, 6),
(141.79, '2026-02-01 03:27:00', 70, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-01 07:27:00' WHERE auction_id=70;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (157.27, 20, 157.27, '2025-02-23 20:41:00', '2027-07-19 15:00:00', 'Active', 96);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(209.83, '2025-02-25 09:41:00', 71, 3),
(262.62, '2025-02-25 21:41:00', 71, 8),
(302.39, '2025-02-26 20:41:00', 71, 4),
(324.85, '2025-02-27 04:41:00', 71, 1),
(377.53, '2025-02-28 10:41:00', 71, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-28 15:41:00' WHERE auction_id=71;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (196.36, 20, 196.36, '2026-07-16 15:00:00', '2026-07-22 05:00:00', 'Active', 237);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(233.91, '2026-07-17 18:00:00', 72, 8),
(265.32, '2026-07-18 00:00:00', 72, 2),
(291.41, '2026-07-18 04:00:00', 72, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (454.39, 22.72, 454.39, '2026-07-18 15:00:00', '2026-07-22 17:00:00', 'Active', 226);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(485.5, '2026-07-19 12:00:00', 73, 7),
(530.21, '2026-07-19 13:00:00', 73, 8),
(568.91, '2026-07-19 16:00:00', 73, 2),
(594.12, '2026-07-19 19:00:00', 73, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (230.83, 20, 230.83, '2026-07-15 15:00:00', '2026-07-22 04:00:00', 'Active', 103);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(259.53, '2026-07-18 12:00:00', 74, 7),
(292.78, '2026-07-18 16:00:00', 74, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (38.05, 20, 38.05, '2025-11-06 20:26:00', '2027-07-19 15:00:00', 'Active', 72);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(63.07, '2025-11-07 09:26:00', 75, 7),
(85.94, '2025-11-07 11:26:00', 75, 8),
(111.7, '2025-11-08 17:26:00', 75, 3),
(151.17, '2025-11-09 08:26:00', 75, 4),
(210.17, '2025-11-09 14:26:00', 75, 2),
(233.56, '2025-11-10 12:26:00', 75, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-10 16:26:00' WHERE auction_id=75;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (42.31, 20, 42.31, '2026-07-17 15:00:00', '2026-07-25 04:00:00', 'Active', 116);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(69.42, '2026-07-18 12:00:00', 76, 7),
(97.92, '2026-07-18 13:00:00', 76, 5),
(129.48, '2026-07-18 19:00:00', 76, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (604.9, 30.24, 604.9, '2026-02-15 15:04:00', '2027-07-19 15:00:00', 'Active', 47);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(669.5, '2026-02-16 16:04:00', 77, 5),
(722.03, '2026-02-17 12:04:00', 77, 4),
(781.39, '2026-02-18 12:04:00', 77, 8),
(816.47, '2026-02-19 13:04:00', 77, 6),
(890.94, '2026-02-20 18:04:00', 77, 3),
(980.67, '2026-02-21 20:04:00', 77, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-21 23:04:00' WHERE auction_id=77;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (913.39, 45.67, 913.39, '2026-06-18 07:26:00', '2027-07-19 15:00:00', 'Active', 149);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1041.59, '2026-06-19 03:26:00', 78, 2),
(1158.37, '2026-06-19 20:26:00', 78, 8),
(1245.51, '2026-06-21 02:26:00', 78, 4),
(1334.04, '2026-06-22 03:26:00', 78, 1),
(1409.99, '2026-06-22 16:26:00', 78, 3),
(1543.4, '2026-06-23 19:26:00', 78, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-23 22:26:00' WHERE auction_id=78;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (201.11, 20, 201.11, '2025-10-06 10:20:00', '2027-07-19 15:00:00', 'Active', 34);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(227.87, '2025-10-06 23:20:00', 79, 5),
(274.12, '2025-10-07 10:20:00', 79, 6),
(326.48, '2025-10-08 07:20:00', 79, 8),
(347.57, '2025-10-09 00:20:00', 79, 3),
(370.87, '2025-10-09 18:20:00', 79, 1),
(393.94, '2025-10-10 21:20:00', 79, 7),
(425.05, '2025-10-11 03:20:00', 79, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-11 08:20:00' WHERE auction_id=79;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (947.02, 47.35, 947.02, '2025-11-23 22:26:00', '2027-07-19 15:00:00', 'Active', 150);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1080.56, '2025-11-25 02:26:00', 80, 1),
(1142.22, '2025-11-25 18:26:00', 80, 6),
(1224.59, '2025-11-26 01:26:00', 80, 8),
(1296.68, '2025-11-27 01:26:00', 80, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-27 03:26:00' WHERE auction_id=80;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1594.12, 79.71, 1594.12, '2026-07-04 05:23:00', '2027-07-19 15:00:00', 'Active', 179);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1796.64, '2026-07-04 21:23:00', 81, 1),
(1981.67, '2026-07-05 22:23:00', 81, 3),
(2163.02, '2026-07-06 06:23:00', 81, 8),
(2334.84, '2026-07-07 10:23:00', 81, 2),
(2469.56, '2026-07-08 08:23:00', 81, 5),
(2591.42, '2026-07-09 12:23:00', 81, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-09 13:23:00' WHERE auction_id=81;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (216.95, 20, 216.95, '2026-07-06 15:22:00', '2027-07-19 15:00:00', 'Active', 59);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(264.29, '2026-07-07 12:22:00', 82, 8),
(303.27, '2026-07-07 18:22:00', 82, 3),
(344.49, '2026-07-08 09:22:00', 82, 4),
(364.96, '2026-07-09 12:22:00', 82, 5),
(402.91, '2026-07-10 11:22:00', 82, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-10 14:22:00' WHERE auction_id=82;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (671.34, 33.57, 671.34, '2026-01-17 21:40:00', '2027-07-19 15:00:00', 'Active', 213);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(728.67, '2026-01-19 13:40:00', 83, 2),
(791.23, '2026-01-20 11:40:00', 83, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-20 14:40:00' WHERE auction_id=83;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (163.54, 20, 163.54, '2025-02-19 19:03:00', '2027-07-19 15:00:00', 'Active', 251);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(199.19, '2025-02-21 07:03:00', 84, 5),
(246.2, '2025-02-21 16:03:00', 84, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-21 22:03:00' WHERE auction_id=84;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (198.19, 20, 198.19, '2026-07-17 15:00:00', '2026-07-25 01:00:00', 'Active', 188);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(234.82, '2026-07-19 11:00:00', 85, 1),
(263.04, '2026-07-19 16:00:00', 85, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (91.38, 20, 91.38, '2026-02-11 17:23:00', '2027-07-19 15:00:00', 'Active', 70);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(112.74, '2026-02-12 18:23:00', 86, 6),
(136.42, '2026-02-13 15:23:00', 86, 2),
(182.68, '2026-02-14 19:23:00', 86, 8),
(211.35, '2026-02-15 16:23:00', 86, 3),
(256.87, '2026-02-16 16:23:00', 86, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-16 17:23:00' WHERE auction_id=86;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (396.59, 20, 396.59, '2026-07-17 15:00:00', '2026-07-22 03:00:00', 'Active', 209);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (86.89, 20, 86.89, '2025-02-17 20:53:00', '2027-07-19 15:00:00', 'Active', 264);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(143.03, '2025-02-19 10:53:00', 88, 2),
(193.83, '2025-02-19 20:53:00', 88, 6),
(220.31, '2025-02-20 00:53:00', 88, 4),
(251.4, '2025-02-20 03:53:00', 88, 3),
(286.71, '2025-02-20 15:53:00', 88, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-20 16:53:00' WHERE auction_id=88;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (160.32, 20, 160.32, '2026-07-15 15:00:00', '2026-07-22 20:00:00', 'Active', 143);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (202.96, 20, 202.96, '2026-07-15 15:00:00', '2026-07-22 10:00:00', 'Active', 111);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(225.84, '2026-07-19 08:00:00', 90, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (268.39, 20, 268.39, '2026-02-24 09:10:00', '2027-07-19 15:00:00', 'Active', 253);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(311.24, '2026-02-24 21:10:00', 91, 2),
(362.33, '2026-02-24 23:10:00', 91, 4),
(418.19, '2026-02-25 05:10:00', 91, 6),
(464.3, '2026-02-25 07:10:00', 91, 3),
(521.62, '2026-02-26 06:10:00', 91, 1),
(557.24, '2026-02-26 12:10:00', 91, 7),
(605.24, '2026-02-27 18:10:00', 91, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-27 22:10:00' WHERE auction_id=91;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (286.03, 20, 286.03, '2025-11-08 22:25:00', '2027-07-19 15:00:00', 'Active', 51);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(321.41, '2025-11-09 23:25:00', 92, 8),
(374.13, '2025-11-10 16:25:00', 92, 4),
(398.98, '2025-11-11 11:25:00', 92, 7),
(456.38, '2025-11-12 00:25:00', 92, 6),
(489.72, '2025-11-12 11:25:00', 92, 1),
(525.74, '2025-11-13 09:25:00', 92, 3),
(585.62, '2025-11-14 07:25:00', 92, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-14 08:25:00' WHERE auction_id=92;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (32.87, 20, 32.87, '2025-07-24 00:39:00', '2027-07-19 15:00:00', 'Active', 38);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(60.99, '2025-07-25 06:39:00', 93, 2),
(82.56, '2025-07-25 20:39:00', 93, 7),
(128.99, '2025-07-26 07:39:00', 93, 4),
(176.83, '2025-07-27 13:39:00', 93, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-27 14:39:00' WHERE auction_id=93;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (79.67, 20, 79.67, '2025-08-28 13:41:00', '2027-07-19 15:00:00', 'Active', 193);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(139.53, '2025-08-29 10:41:00', 94, 8),
(179.1, '2025-08-29 14:41:00', 94, 6),
(230.81, '2025-08-30 12:41:00', 94, 2),
(263.12, '2025-08-31 07:41:00', 94, 7),
(321.72, '2025-09-01 10:41:00', 94, 1),
(359.69, '2025-09-01 12:41:00', 94, 4),
(381.17, '2025-09-01 15:41:00', 94, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-01 18:41:00' WHERE auction_id=94;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (360.21, 20, 360.21, '2025-04-21 18:01:00', '2027-07-19 15:00:00', 'Active', 39);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(409.85, '2025-04-22 06:01:00', 95, 8),
(466.84, '2025-04-22 09:01:00', 95, 6),
(516.26, '2025-04-23 02:01:00', 95, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-23 08:01:00' WHERE auction_id=95;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (208.64, 20, 208.64, '2026-02-13 04:48:00', '2027-07-19 15:00:00', 'Active', 122);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(230.64, '2026-02-14 02:48:00', 96, 1),
(283.47, '2026-02-14 07:48:00', 96, 2),
(321.72, '2026-02-14 14:48:00', 96, 6),
(375.13, '2026-02-14 18:48:00', 96, 7),
(427.84, '2026-02-14 23:48:00', 96, 8),
(452.41, '2026-02-15 20:48:00', 96, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-16 01:48:00' WHERE auction_id=96;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (138.31, 20, 138.31, '2025-06-13 03:26:00', '2027-07-19 15:00:00', 'Active', 257);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(174.39, '2025-06-13 19:26:00', 97, 7),
(233.42, '2025-06-14 15:26:00', 97, 3),
(275.26, '2025-06-15 03:26:00', 97, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-15 05:26:00' WHERE auction_id=97;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (616.04, 30.8, 616.04, '2025-05-10 20:55:00', '2027-07-19 15:00:00', 'Active', 46);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(657.19, '2025-05-11 16:55:00', 98, 2),
(722.08, '2025-05-12 08:55:00', 98, 1),
(767.89, '2025-05-13 04:55:00', 98, 3),
(801.2, '2025-05-13 09:55:00', 98, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-13 15:55:00' WHERE auction_id=98;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (314.36, 20, 314.36, '2025-09-22 10:58:00', '2027-07-19 15:00:00', 'Active', 232);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(334.65, '2025-09-22 15:58:00', 99, 1),
(382.92, '2025-09-23 11:58:00', 99, 4),
(438.4, '2025-09-24 02:58:00', 99, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-24 08:58:00' WHERE auction_id=99;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (163.22, 20, 163.22, '2025-11-15 08:53:00', '2027-07-19 15:00:00', 'Active', 235);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(201.24, '2025-11-16 02:53:00', 100, 3),
(258.76, '2025-11-16 23:53:00', 100, 6),
(306.43, '2025-11-17 20:53:00', 100, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-17 22:53:00' WHERE auction_id=100;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1025.29, 51.26, 1025.29, '2025-01-21 18:24:00', '2027-07-19 15:00:00', 'Active', 35);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1077.02, '2025-01-22 10:24:00', 101, 5),
(1147.95, '2025-01-23 04:24:00', 101, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-23 05:24:00' WHERE auction_id=101;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (44.84, 20, 44.84, '2025-03-20 23:04:00', '2027-07-19 15:00:00', 'Active', 282);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(69.35, '2025-03-21 09:04:00', 102, 4),
(116.76, '2025-03-22 02:04:00', 102, 8),
(156.66, '2025-03-22 09:04:00', 102, 6),
(203.47, '2025-03-22 12:04:00', 102, 2),
(225.63, '2025-03-23 01:04:00', 102, 3),
(257.03, '2025-03-23 16:04:00', 102, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-23 19:04:00' WHERE auction_id=102;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (119.6, 20, 119.6, '2026-07-17 00:52:00', '2027-07-19 15:00:00', 'Active', 261);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(171.02, '2026-07-17 20:52:00', 103, 1),
(211.62, '2026-07-18 00:52:00', 103, 8),
(267.42, '2026-07-19 01:52:00', 103, 6),
(305.21, '2026-07-19 21:52:00', 103, 7),
(338.25, '2026-07-20 05:52:00', 103, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-20 11:52:00' WHERE auction_id=103;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (188.2, 20, 188.2, '2025-11-02 18:38:00', '2027-07-19 15:00:00', 'Active', 137);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(217.68, '2025-11-03 11:38:00', 104, 6),
(272.48, '2025-11-04 01:38:00', 104, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-04 03:38:00' WHERE auction_id=104;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (865.33, 43.27, 865.33, '2025-04-03 05:51:00', '2027-07-19 15:00:00', 'Active', 211);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(942.12, '2025-04-03 14:51:00', 105, 1),
(1025.0, '2025-04-03 22:51:00', 105, 4),
(1122.97, '2025-04-04 08:51:00', 105, 2),
(1183.74, '2025-04-04 14:51:00', 105, 6),
(1229.79, '2025-04-05 10:51:00', 105, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-05 11:51:00' WHERE auction_id=105;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (391.91, 20, 391.91, '2026-04-18 20:35:00', '2027-07-19 15:00:00', 'Active', 279);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(436.06, '2026-04-20 04:35:00', 106, 8),
(487.84, '2026-04-21 01:35:00', 106, 4),
(544.06, '2026-04-21 21:35:00', 106, 2),
(602.87, '2026-04-23 02:35:00', 106, 3),
(632.06, '2026-04-23 17:35:00', 106, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-23 22:35:00' WHERE auction_id=106;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (503.33, 25.17, 503.33, '2026-07-15 15:00:00', '2026-07-22 09:00:00', 'Active', 125);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(547.03, '2026-07-18 09:00:00', 107, 5),
(578.44, '2026-07-18 13:00:00', 107, 1),
(618.2, '2026-07-18 18:00:00', 107, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (148.87, 20, 148.87, '2026-07-15 15:00:00', '2026-07-24 15:00:00', 'Active', 77);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (334.41, 20, 334.41, '2026-07-15 15:00:00', '2026-07-24 16:00:00', 'Active', 65);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(364.32, '2026-07-18 07:00:00', 109, 7),
(395.49, '2026-07-18 08:00:00', 109, 4),
(429.35, '2026-07-18 12:00:00', 109, 6),
(468.35, '2026-07-18 14:00:00', 109, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (231.82, 20, 231.82, '2025-04-19 09:50:00', '2027-07-19 15:00:00', 'Active', 276);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(264.01, '2025-04-20 20:50:00', 110, 2),
(302.38, '2025-04-21 16:50:00', 110, 1),
(352.27, '2025-04-21 18:50:00', 110, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-21 22:50:00' WHERE auction_id=110;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (430.66, 21.53, 430.66, '2026-07-16 15:00:00', '2026-07-23 20:00:00', 'Active', 148);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(460.48, '2026-07-19 12:00:00', 111, 1),
(489.18, '2026-07-19 13:00:00', 111, 7),
(517.1, '2026-07-19 16:00:00', 111, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (516.86, 25.84, 516.86, '2025-09-06 15:51:00', '2027-07-19 15:00:00', 'Active', 13);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(569.3, '2025-09-07 15:51:00', 112, 4),
(613.95, '2025-09-07 18:51:00', 112, 7),
(645.52, '2025-09-08 07:51:00', 112, 6),
(695.41, '2025-09-08 10:51:00', 112, 1),
(740.14, '2025-09-08 17:51:00', 112, 3),
(799.48, '2025-09-09 17:51:00', 112, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-09 18:51:00' WHERE auction_id=112;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (138.08, 20, 138.08, '2026-07-16 15:00:00', '2026-07-21 19:00:00', 'Active', 102);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(167.65, '2026-07-17 22:00:00', 113, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (118.49, 20, 118.49, '2026-07-17 15:00:00', '2026-07-22 14:00:00', 'Active', 214);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(152.09, '2026-07-18 05:00:00', 114, 6),
(173.18, '2026-07-18 08:00:00', 114, 3);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (149.14, 20, 149.14, '2025-11-18 00:45:00', '2027-07-19 15:00:00', 'Active', 258);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(193.98, '2025-11-19 11:45:00', 115, 2),
(240.91, '2025-11-20 11:45:00', 115, 4),
(293.26, '2025-11-21 17:45:00', 115, 6),
(315.89, '2025-11-22 23:45:00', 115, 5),
(371.25, '2025-11-23 03:45:00', 115, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-23 04:45:00' WHERE auction_id=115;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (486.16, 24.31, 486.16, '2026-07-18 15:00:00', '2026-07-22 17:00:00', 'Active', 42);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(527.42, '2026-07-19 07:00:00', 116, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (232.88, 20, 232.88, '2026-02-04 08:59:00', '2027-07-19 15:00:00', 'Active', 16);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(274.54, '2026-02-05 01:59:00', 117, 1),
(313.5, '2026-02-05 16:59:00', 117, 3),
(351.25, '2026-02-06 14:59:00', 117, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-06 15:59:00' WHERE auction_id=117;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (94.64, 20, 94.64, '2025-04-06 07:53:00', '2027-07-19 15:00:00', 'Active', 56);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(140.43, '2025-04-07 07:53:00', 118, 4),
(183.58, '2025-04-08 05:53:00', 118, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-08 11:53:00' WHERE auction_id=118;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (232.13, 20, 232.13, '2026-01-31 08:34:00', '2027-07-19 15:00:00', 'Active', 273);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(261.2, '2026-02-01 02:34:00', 119, 8),
(320.03, '2026-02-02 04:34:00', 119, 4),
(373.85, '2026-02-02 10:34:00', 119, 3),
(407.97, '2026-02-03 02:34:00', 119, 5),
(466.22, '2026-02-03 23:34:00', 119, 2),
(523.19, '2026-02-04 23:34:00', 119, 7),
(564.6, '2026-02-05 06:34:00', 119, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-02-05 08:34:00' WHERE auction_id=119;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (36.03, 20, 36.03, '2025-03-01 07:05:00', '2027-07-19 15:00:00', 'Active', 200);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(61.09, '2025-03-02 03:05:00', 120, 1),
(95.88, '2025-03-02 11:05:00', 120, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-02 16:05:00' WHERE auction_id=120;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (180.92, 20, 180.92, '2025-06-02 11:25:00', '2027-07-19 15:00:00', 'Active', 283);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(222.27, '2025-06-02 19:25:00', 121, 3),
(279.09, '2025-06-03 09:25:00', 121, 8),
(336.33, '2025-06-04 11:25:00', 121, 4),
(362.15, '2025-06-05 03:25:00', 121, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-05 06:25:00' WHERE auction_id=121;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (189.25, 20, 189.25, '2025-04-21 12:55:00', '2027-07-19 15:00:00', 'Active', 25);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(238.39, '2025-04-22 14:55:00', 122, 6),
(271.94, '2025-04-22 19:55:00', 122, 8),
(321.21, '2025-04-24 01:55:00', 122, 7),
(342.81, '2025-04-25 00:55:00', 122, 3),
(384.85, '2025-04-25 11:55:00', 122, 4),
(405.84, '2025-04-26 08:55:00', 122, 2),
(459.48, '2025-04-27 00:55:00', 122, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-27 03:55:00' WHERE auction_id=122;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (112.1, 20, 112.1, '2025-02-22 20:39:00', '2027-07-19 15:00:00', 'Active', 271);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(135.44, '2025-02-24 02:39:00', 123, 4),
(173.26, '2025-02-25 01:39:00', 123, 5),
(231.56, '2025-02-25 19:39:00', 123, 7),
(267.34, '2025-02-26 12:39:00', 123, 2),
(300.05, '2025-02-27 09:39:00', 123, 3),
(340.51, '2025-02-27 12:39:00', 123, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-27 18:39:00' WHERE auction_id=123;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (673.57, 33.68, 673.57, '2025-03-28 01:09:00', '2027-07-19 15:00:00', 'Active', 86);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(728.0, '2025-03-28 23:09:00', 124, 7),
(820.57, '2025-03-29 03:09:00', 124, 3),
(868.78, '2025-03-30 09:09:00', 124, 4),
(932.38, '2025-03-31 00:09:00', 124, 8),
(1020.2, '2025-03-31 11:09:00', 124, 1),
(1064.91, '2025-04-01 12:09:00', 124, 2),
(1163.95, '2025-04-02 03:09:00', 124, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-02 09:09:00' WHERE auction_id=124;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (257.57, 20, 257.57, '2025-12-17 13:36:00', '2027-07-19 15:00:00', 'Active', 246);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(280.21, '2025-12-18 15:36:00', 125, 2),
(330.45, '2025-12-18 19:36:00', 125, 8),
(350.71, '2025-12-19 17:36:00', 125, 7),
(407.29, '2025-12-20 08:36:00', 125, 3),
(434.29, '2025-12-21 00:36:00', 125, 4),
(482.7, '2025-12-22 02:36:00', 125, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-22 04:36:00' WHERE auction_id=125;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (113.65, 20, 113.65, '2025-10-25 14:46:00', '2027-07-19 15:00:00', 'Active', 249);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(145.81, '2025-10-26 19:46:00', 126, 5),
(195.4, '2025-10-27 04:46:00', 126, 8),
(216.47, '2025-10-27 06:46:00', 126, 4),
(242.63, '2025-10-27 17:46:00', 126, 1),
(300.87, '2025-10-28 21:46:00', 126, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-29 03:46:00' WHERE auction_id=126;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (195.13, 20, 195.13, '2026-03-27 10:27:00', '2027-07-19 15:00:00', 'Active', 170);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(234.85, '2026-03-27 19:27:00', 127, 5),
(278.81, '2026-03-28 08:27:00', 127, 4),
(322.05, '2026-03-29 04:27:00', 127, 2),
(359.49, '2026-03-29 14:27:00', 127, 7),
(404.61, '2026-03-30 07:27:00', 127, 6),
(463.58, '2026-03-31 11:27:00', 127, 1),
(488.36, '2026-04-01 05:27:00', 127, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-01 11:27:00' WHERE auction_id=127;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (180.11, 20, 180.11, '2026-07-03 13:36:00', '2027-07-19 15:00:00', 'Active', 293);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(218.55, '2026-07-04 19:36:00', 128, 3),
(243.97, '2026-07-05 02:36:00', 128, 5),
(266.09, '2026-07-05 15:36:00', 128, 1),
(302.87, '2026-07-06 04:36:00', 128, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-06 05:36:00' WHERE auction_id=128;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (320.74, 20, 320.74, '2025-08-22 08:26:00', '2027-07-19 15:00:00', 'Active', 275);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(353.64, '2025-08-23 05:26:00', 129, 2),
(406.71, '2025-08-24 04:26:00', 129, 5),
(458.71, '2025-08-24 14:26:00', 129, 8),
(506.13, '2025-08-25 14:26:00', 129, 6),
(540.63, '2025-08-26 09:26:00', 129, 1),
(583.83, '2025-08-27 13:26:00', 129, 3),
(609.58, '2025-08-27 19:26:00', 129, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-28 00:26:00' WHERE auction_id=129;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (894.42, 44.72, 894.42, '2025-04-22 21:51:00', '2027-07-19 15:00:00', 'Active', 177);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(984.16, '2025-04-24 04:51:00', 130, 7),
(1045.73, '2025-04-25 10:51:00', 130, 3),
(1140.42, '2025-04-26 10:51:00', 130, 2),
(1259.5, '2025-04-27 04:51:00', 130, 1),
(1379.89, '2025-04-28 04:51:00', 130, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-28 09:51:00' WHERE auction_id=130;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (363.1, 20, 363.1, '2025-02-13 13:01:00', '2027-07-19 15:00:00', 'Active', 89);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(420.04, '2025-02-14 09:01:00', 131, 2),
(453.97, '2025-02-15 09:01:00', 131, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-15 12:01:00' WHERE auction_id=131;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (487.53, 24.38, 487.53, '2026-07-16 15:00:00', '2026-07-25 07:00:00', 'Active', 6);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(530.06, '2026-07-19 10:00:00', 132, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (296.7, 20, 296.7, '2025-06-23 21:02:00', '2027-07-19 15:00:00', 'Active', 297);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(333.69, '2025-06-25 01:02:00', 133, 3),
(385.05, '2025-06-25 05:02:00', 133, 6),
(405.8, '2025-06-25 22:02:00', 133, 2),
(456.09, '2025-06-26 01:02:00', 133, 8),
(483.94, '2025-06-26 04:02:00', 133, 7),
(535.66, '2025-06-26 22:02:00', 133, 1),
(579.39, '2025-06-27 15:02:00', 133, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-27 16:02:00' WHERE auction_id=133;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (307.3, 20, 307.3, '2025-06-30 22:33:00', '2027-07-19 15:00:00', 'Active', 32);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(335.52, '2025-07-02 14:33:00', 134, 1),
(363.52, '2025-07-03 13:33:00', 134, 7),
(397.58, '2025-07-03 17:33:00', 134, 8),
(423.4, '2025-07-04 18:33:00', 134, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-04 21:33:00' WHERE auction_id=134;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (551.78, 27.59, 551.78, '2025-03-05 22:50:00', '2027-07-19 15:00:00', 'Active', 268);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(584.84, '2025-03-06 20:50:00', 135, 4),
(654.55, '2025-03-07 14:50:00', 135, 5),
(694.11, '2025-03-07 22:50:00', 135, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-08 01:50:00' WHERE auction_id=135;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (3984.38, 199.22, 3984.38, '2026-07-18 15:00:00', '2026-07-24 15:00:00', 'Active', 159);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(4322.68, '2026-07-18 13:00:00', 136, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (25.59, 20, 25.59, '2026-03-06 07:20:00', '2027-07-19 15:00:00', 'Active', 204);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(84.84, '2026-03-07 04:20:00', 137, 3),
(113.41, '2026-03-07 13:20:00', 137, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-07 17:20:00' WHERE auction_id=137;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (628.63, 31.43, 628.63, '2026-07-15 15:00:00', '2026-07-22 18:00:00', 'Active', 218);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (268.1, 20, 268.1, '2025-03-03 19:40:00', '2027-07-19 15:00:00', 'Active', 158);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(301.22, '2025-03-04 02:40:00', 139, 5),
(336.61, '2025-03-04 18:40:00', 139, 8),
(380.63, '2025-03-05 05:40:00', 139, 6),
(428.11, '2025-03-06 09:40:00', 139, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-06 13:40:00' WHERE auction_id=139;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (82.54, 20, 82.54, '2025-04-26 10:10:00', '2027-07-19 15:00:00', 'Active', 138);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(117.24, '2025-04-26 23:10:00', 140, 7),
(177.19, '2025-04-27 16:10:00', 140, 2),
(224.07, '2025-04-28 06:10:00', 140, 1),
(261.59, '2025-04-29 05:10:00', 140, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-29 11:10:00' WHERE auction_id=140;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1248.33, 62.42, 1248.33, '2025-07-09 06:13:00', '2027-07-19 15:00:00', 'Active', 45);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1356.16, '2025-07-09 16:13:00', 141, 7),
(1460.85, '2025-07-10 13:13:00', 141, 6),
(1628.64, '2025-07-11 03:13:00', 141, 5),
(1706.39, '2025-07-12 07:13:00', 141, 1),
(1821.83, '2025-07-13 00:13:00', 141, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-13 03:13:00' WHERE auction_id=141;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (232.04, 20, 232.04, '2026-07-08 13:37:00', '2027-07-19 15:00:00', 'Active', 73);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(282.76, '2026-07-08 21:37:00', 142, 7),
(307.65, '2026-07-09 14:37:00', 142, 3),
(347.54, '2026-07-10 12:37:00', 142, 4),
(405.24, '2026-07-10 14:37:00', 142, 5),
(429.22, '2026-07-10 17:37:00', 142, 6),
(482.43, '2026-07-11 10:37:00', 142, 2),
(529.55, '2026-07-11 17:37:00', 142, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2026-07-11 21:37:00' WHERE auction_id=142;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (364.69, 20, 364.69, '2025-03-20 16:40:00', '2027-07-19 15:00:00', 'Active', 91);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(415.1, '2025-03-21 17:40:00', 143, 5),
(465.16, '2025-03-22 19:40:00', 143, 8),
(504.85, '2025-03-23 11:40:00', 143, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-23 13:40:00' WHERE auction_id=143;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (87.19, 20, 87.19, '2025-05-15 06:46:00', '2027-07-19 15:00:00', 'Active', 250);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(146.82, '2025-05-16 13:46:00', 144, 5),
(203.42, '2025-05-17 03:46:00', 144, 8),
(241.42, '2025-05-18 08:46:00', 144, 3),
(276.47, '2025-05-19 00:46:00', 144, 7),
(297.91, '2025-05-19 07:46:00', 144, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-19 12:46:00' WHERE auction_id=144;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (87.12, 20, 87.12, '2026-07-15 15:00:00', '2026-07-22 06:00:00', 'Active', 131);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(116.87, '2026-07-18 11:00:00', 145, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (250.94, 20, 250.94, '2025-10-03 20:26:00', '2027-07-19 15:00:00', 'Active', 189);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(281.48, '2025-10-04 23:26:00', 146, 8),
(340.31, '2025-10-05 20:26:00', 146, 4),
(387.37, '2025-10-06 22:26:00', 146, 5),
(446.48, '2025-10-07 10:26:00', 146, 2),
(468.94, '2025-10-08 06:26:00', 146, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-08 07:26:00' WHERE auction_id=146;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (188.36, 20, 188.36, '2026-07-18 15:00:00', '2026-07-23 14:00:00', 'Active', 115);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(215.26, '2026-07-18 10:00:00', 147, 7),
(243.5, '2026-07-18 11:00:00', 147, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (238.09, 20, 238.09, '2026-06-02 15:16:00', '2027-07-19 15:00:00', 'Active', 21);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(261.49, '2026-06-04 01:16:00', 148, 4),
(284.11, '2026-06-04 12:16:00', 148, 6),
(308.69, '2026-06-04 19:16:00', 148, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-04 20:16:00' WHERE auction_id=148;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (460.82, 23.04, 460.82, '2025-08-11 06:13:00', '2027-07-19 15:00:00', 'Active', 266);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(515.93, '2025-08-12 03:13:00', 149, 7),
(539.99, '2025-08-12 15:13:00', 149, 5),
(580.44, '2025-08-13 05:13:00', 149, 8),
(618.34, '2025-08-13 10:13:00', 149, 4),
(678.63, '2025-08-13 15:13:00', 149, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-13 21:13:00' WHERE auction_id=149;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (61.51, 20, 61.51, '2026-03-31 14:15:00', '2027-07-19 15:00:00', 'Active', 74);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(101.39, '2026-04-01 23:15:00', 150, 6),
(160.35, '2026-04-02 03:15:00', 150, 2),
(213.97, '2026-04-02 22:15:00', 150, 5),
(242.53, '2026-04-03 08:15:00', 150, 3),
(264.43, '2026-04-04 04:15:00', 150, 8),
(300.51, '2026-04-04 13:15:00', 150, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-04 18:15:00' WHERE auction_id=150;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (453.98, 22.7, 453.98, '2026-07-16 15:00:00', '2026-07-24 18:00:00', 'Active', 119);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(487.47, '2026-07-18 03:00:00', 151, 2),
(518.05, '2026-07-18 04:00:00', 151, 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (93.03, 20, 93.03, '2025-04-29 07:47:00', '2027-07-19 15:00:00', 'Active', 203);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(121.03, '2025-04-30 03:47:00', 152, 5),
(151.08, '2025-04-30 21:47:00', 152, 4),
(189.21, '2025-05-01 23:47:00', 152, 6),
(231.11, '2025-05-03 05:47:00', 152, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-03 06:47:00' WHERE auction_id=152;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (700.13, 35.01, 700.13, '2026-07-17 15:00:00', '2026-07-25 06:00:00', 'Active', 43);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(765.0, '2026-07-17 23:00:00', 153, 5),
(832.73, '2026-07-18 05:00:00', 153, 6),
(889.68, '2026-07-18 10:00:00', 153, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (297.64, 20, 297.64, '2025-12-20 13:07:00', '2027-07-19 15:00:00', 'Active', 87);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(330.39, '2025-12-22 00:07:00', 154, 3),
(386.84, '2025-12-22 22:07:00', 154, 2),
(414.98, '2025-12-23 13:07:00', 154, 7),
(445.66, '2025-12-24 00:07:00', 154, 8),
(491.5, '2025-12-24 10:07:00', 154, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-24 16:07:00' WHERE auction_id=154;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (223.31, 20, 223.31, '2026-06-06 06:47:00', '2027-07-19 15:00:00', 'Active', 197);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(253.13, '2026-06-07 11:47:00', 155, 2),
(285.55, '2026-06-08 04:47:00', 155, 8),
(327.94, '2026-06-08 19:47:00', 155, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-08 23:47:00' WHERE auction_id=155;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (17.87, 20, 17.87, '2026-04-28 19:27:00', '2027-07-19 15:00:00', 'Active', 295);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(59.9, '2026-04-30 04:27:00', 156, 3),
(114.0, '2026-05-01 05:27:00', 156, 1),
(153.43, '2026-05-01 07:27:00', 156, 8),
(175.64, '2026-05-02 13:27:00', 156, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-02 14:27:00' WHERE auction_id=156;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (112.15, 20, 112.15, '2025-04-13 02:34:00', '2027-07-19 15:00:00', 'Active', 19);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(158.45, '2025-04-13 17:34:00', 157, 7),
(194.33, '2025-04-14 21:34:00', 157, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-15 03:34:00' WHERE auction_id=157;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (407.01, 20.35, 407.01, '2025-11-02 14:43:00', '2027-07-19 15:00:00', 'Active', 146);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(437.05, '2025-11-02 21:43:00', 158, 2),
(488.87, '2025-11-03 09:43:00', 158, 5),
(522.62, '2025-11-04 05:43:00', 158, 6),
(572.98, '2025-11-05 08:43:00', 158, 7),
(623.79, '2025-11-05 17:43:00', 158, 3),
(682.21, '2025-11-06 01:43:00', 158, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-06 03:43:00' WHERE auction_id=158;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (300.98, 20, 300.98, '2025-10-20 13:51:00', '2027-07-19 15:00:00', 'Active', 267);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(340.59, '2025-10-21 03:51:00', 159, 8),
(388.57, '2025-10-21 08:51:00', 159, 4),
(421.23, '2025-10-21 23:51:00', 159, 3),
(460.22, '2025-10-22 08:51:00', 159, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-22 11:51:00' WHERE auction_id=159;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (158.06, 20, 158.06, '2026-04-02 05:55:00', '2027-07-19 15:00:00', 'Active', 238);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(214.76, '2026-04-03 16:55:00', 160, 6),
(244.35, '2026-04-04 11:55:00', 160, 7),
(279.74, '2026-04-05 09:55:00', 160, 3),
(338.08, '2026-04-05 22:55:00', 160, 1),
(394.21, '2026-04-06 21:55:00', 160, 5),
(419.09, '2026-04-08 02:55:00', 160, 8),
(448.55, '2026-04-08 18:55:00', 160, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-08 22:55:00' WHERE auction_id=160;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (152.35, 20, 152.35, '2026-07-16 15:00:00', '2026-07-23 23:00:00', 'Active', 215);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (196.39, 20, 196.39, '2026-05-15 10:37:00', '2027-07-19 15:00:00', 'Active', 190);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(232.64, '2026-05-16 00:37:00', 162, 8),
(263.6, '2026-05-16 04:37:00', 162, 6),
(316.53, '2026-05-16 21:37:00', 162, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-17 01:37:00' WHERE auction_id=162;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (402.08, 20.1, 402.08, '2026-07-15 15:00:00', '2026-07-23 13:00:00', 'Active', 82);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (59.69, 20, 59.69, '2025-01-22 01:50:00', '2027-07-19 15:00:00', 'Active', 75);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(80.78, '2025-01-22 16:50:00', 164, 2),
(126.43, '2025-01-22 23:50:00', 164, 3),
(171.64, '2025-01-24 02:50:00', 164, 4),
(217.28, '2025-01-24 04:50:00', 164, 5),
(253.31, '2025-01-25 02:50:00', 164, 7),
(285.53, '2025-01-25 22:50:00', 164, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-01-25 23:50:00' WHERE auction_id=164;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (574.39, 28.72, 574.39, '2025-10-17 09:43:00', '2027-07-19 15:00:00', 'Active', 241);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(653.28, '2025-10-17 23:43:00', 165, 3),
(696.97, '2025-10-18 22:43:00', 165, 7),
(759.75, '2025-10-19 10:43:00', 165, 5),
(834.39, '2025-10-19 18:43:00', 165, 4),
(867.96, '2025-10-20 07:43:00', 165, 8),
(907.13, '2025-10-21 13:43:00', 165, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-21 17:43:00' WHERE auction_id=165;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (309.31, 20, 309.31, '2026-04-05 11:32:00', '2027-07-19 15:00:00', 'Active', 78);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(337.24, '2026-04-06 19:32:00', 166, 4),
(391.31, '2026-04-06 22:32:00', 166, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-07 02:32:00' WHERE auction_id=166;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (163.3, 20, 163.3, '2025-12-27 03:36:00', '2027-07-19 15:00:00', 'Active', 83);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(187.99, '2025-12-28 13:36:00', 167, 3),
(229.02, '2025-12-29 15:36:00', 167, 1),
(285.82, '2025-12-30 07:36:00', 167, 8),
(338.91, '2025-12-31 00:36:00', 167, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-31 01:36:00' WHERE auction_id=167;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (478.23, 23.91, 478.23, '2026-07-16 15:00:00', '2026-07-21 23:00:00', 'Active', 239);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(516.49, '2026-07-19 00:00:00', 168, 7),
(557.78, '2026-07-19 02:00:00', 168, 2),
(591.69, '2026-07-19 06:00:00', 168, 4);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (226.28, 20, 226.28, '2026-07-16 15:00:00', '2026-07-21 00:00:00', 'Active', 195);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(253.67, '2026-07-19 01:00:00', 169, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (309.55, 20, 309.55, '2025-08-07 21:27:00', '2027-07-19 15:00:00', 'Active', 274);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(364.41, '2025-08-09 00:27:00', 170, 1),
(400.31, '2025-08-09 08:27:00', 170, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-09 14:27:00' WHERE auction_id=170;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (216.21, 20, 216.21, '2026-07-18 15:00:00', '2026-07-24 23:00:00', 'Active', 57);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1730.91, 86.55, 1730.91, '2026-04-05 07:34:00', '2027-07-19 15:00:00', 'Active', 100);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1984.88, '2026-04-06 15:34:00', 172, 4),
(2194.26, '2026-04-07 18:34:00', 172, 8),
(2288.69, '2026-04-08 04:34:00', 172, 3),
(2462.58, '2026-04-08 18:34:00', 172, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-08 21:34:00' WHERE auction_id=172;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (507.98, 25.4, 507.98, '2026-05-21 06:46:00', '2027-07-19 15:00:00', 'Active', 206);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(542.01, '2026-05-22 04:46:00', 173, 1),
(614.67, '2026-05-23 10:46:00', 173, 5),
(663.85, '2026-05-23 14:46:00', 173, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-23 17:46:00' WHERE auction_id=173;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (211.96, 20, 211.96, '2025-12-10 14:00:00', '2027-07-19 15:00:00', 'Active', 223);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(266.83, '2025-12-12 02:00:00', 174, 2),
(298.07, '2025-12-12 15:00:00', 174, 3),
(355.12, '2025-12-13 02:00:00', 174, 1),
(411.23, '2025-12-13 12:00:00', 174, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-13 17:00:00' WHERE auction_id=174;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (150.16, 20, 150.16, '2025-04-04 20:34:00', '2027-07-19 15:00:00', 'Active', 229);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(204.28, '2025-04-06 04:34:00', 175, 3),
(249.75, '2025-04-06 20:34:00', 175, 8),
(271.88, '2025-04-07 02:34:00', 175, 6),
(294.06, '2025-04-07 09:34:00', 175, 4),
(315.49, '2025-04-07 19:34:00', 175, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-07 21:34:00' WHERE auction_id=175;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (326.56, 20, 326.56, '2025-12-03 04:50:00', '2027-07-19 15:00:00', 'Active', 76);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(366.28, '2025-12-04 17:50:00', 176, 1),
(415.07, '2025-12-04 23:50:00', 176, 4),
(440.02, '2025-12-05 03:50:00', 176, 3),
(468.17, '2025-12-05 14:50:00', 176, 5),
(495.4, '2025-12-05 21:50:00', 176, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-06 03:50:00' WHERE auction_id=176;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (86.45, 20, 86.45, '2026-07-17 15:00:00', '2026-07-25 12:00:00', 'Active', 171);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(124.86, '2026-07-18 10:00:00', 177, 1),
(160.23, '2026-07-18 16:00:00', 177, 5),
(182.12, '2026-07-18 19:00:00', 177, 7),
(202.64, '2026-07-19 01:00:00', 177, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (301.06, 20, 301.06, '2026-07-16 15:00:00', '2026-07-21 03:00:00', 'Active', 58);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(322.68, '2026-07-19 15:00:00', 178, 2),
(355.87, '2026-07-19 19:00:00', 178, 7),
(388.44, '2026-07-19 22:00:00', 178, 3),
(420.32, '2026-07-19 23:00:00', 178, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (353.14, 20, 353.14, '2025-12-08 10:42:00', '2027-07-19 15:00:00', 'Active', 53);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(413.13, '2025-12-10 01:42:00', 179, 8),
(455.9, '2025-12-10 09:42:00', 179, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-10 10:42:00' WHERE auction_id=179;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (254.78, 20, 254.78, '2026-06-14 08:24:00', '2027-07-19 15:00:00', 'Active', 286);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(290.04, '2026-06-15 08:24:00', 180, 2),
(320.25, '2026-06-15 17:24:00', 180, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-15 21:24:00' WHERE auction_id=180;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (92.99, 20, 92.99, '2025-07-01 13:01:00', '2027-07-19 15:00:00', 'Active', 24);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(138.88, '2025-07-02 16:01:00', 181, 3),
(165.05, '2025-07-03 03:01:00', 181, 4),
(204.68, '2025-07-03 18:01:00', 181, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-04 00:01:00' WHERE auction_id=181;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (158.09, 20, 158.09, '2026-07-16 15:00:00', '2026-07-24 19:00:00', 'Active', 110);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (288.64, 20, 288.64, '2026-03-02 13:44:00', '2027-07-19 15:00:00', 'Active', 199);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(338.9, '2026-03-03 18:44:00', 183, 8),
(373.63, '2026-03-04 01:44:00', 183, 4),
(410.99, '2026-03-04 16:44:00', 183, 7),
(434.71, '2026-03-05 10:44:00', 183, 3),
(468.38, '2026-03-06 02:44:00', 183, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-06 08:44:00' WHERE auction_id=183;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (490.81, 24.54, 490.81, '2025-05-28 09:43:00', '2027-07-19 15:00:00', 'Active', 277);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(519.24, '2025-05-29 19:43:00', 184, 3),
(567.22, '2025-05-30 01:43:00', 184, 4),
(640.06, '2025-05-31 00:43:00', 184, 5),
(708.91, '2025-06-01 04:43:00', 184, 6),
(745.65, '2025-06-01 19:43:00', 184, 1),
(784.69, '2025-06-01 22:43:00', 184, 2),
(836.27, '2025-06-02 01:43:00', 184, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-02 06:43:00' WHERE auction_id=184;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (507.23, 25.36, 507.23, '2026-05-17 02:08:00', '2027-07-19 15:00:00', 'Active', 247);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(545.52, '2026-05-17 12:08:00', 185, 2),
(609.87, '2026-05-17 14:08:00', 185, 4),
(641.01, '2026-05-18 13:08:00', 185, 6),
(689.85, '2026-05-19 16:08:00', 185, 5),
(724.45, '2026-05-20 06:08:00', 185, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-05-20 07:08:00' WHERE auction_id=185;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2351.48, 117.57, 2351.48, '2026-04-12 13:56:00', '2027-07-19 15:00:00', 'Active', 31);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2696.36, '2026-04-14 00:56:00', 186, 5),
(3004.39, '2026-04-14 08:56:00', 186, 3),
(3165.48, '2026-04-15 09:56:00', 186, 8),
(3514.0, '2026-04-15 19:56:00', 186, 4),
(3836.52, '2026-04-16 00:56:00', 186, 6),
(4056.09, '2026-04-16 02:56:00', 186, 7),
(4175.03, '2026-04-16 07:56:00', 186, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-16 08:56:00' WHERE auction_id=186;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (659.82, 32.99, 659.82, '2025-02-01 02:47:00', '2027-07-19 15:00:00', 'Active', 85);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(733.62, '2025-02-02 04:47:00', 187, 7),
(790.41, '2025-02-03 03:47:00', 187, 8),
(886.95, '2025-02-04 02:47:00', 187, 6),
(946.0, '2025-02-04 13:47:00', 187, 5),
(984.77, '2025-02-04 19:47:00', 187, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-04 20:47:00' WHERE auction_id=187;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (308.42, 20, 308.42, '2025-11-21 14:39:00', '2027-07-19 15:00:00', 'Active', 33);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(336.79, '2025-11-22 13:39:00', 188, 4),
(362.6, '2025-11-22 22:39:00', 188, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-11-23 02:39:00' WHERE auction_id=188;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (333.67, 20, 333.67, '2025-12-06 15:29:00', '2027-07-19 15:00:00', 'Active', 281);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(358.33, '2025-12-07 22:29:00', 189, 8),
(384.43, '2025-12-08 22:29:00', 189, 2),
(422.24, '2025-12-09 15:29:00', 189, 4),
(461.1, '2025-12-10 20:29:00', 189, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-11 00:29:00' WHERE auction_id=189;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (941.75, 47.09, 941.75, '2025-12-06 18:54:00', '2027-07-19 15:00:00', 'Active', 161);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1048.21, '2025-12-07 20:54:00', 190, 7),
(1135.97, '2025-12-08 11:54:00', 190, 1),
(1262.98, '2025-12-09 12:54:00', 190, 3),
(1364.57, '2025-12-10 13:54:00', 190, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-10 18:54:00' WHERE auction_id=190;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (56.69, 20, 56.69, '2026-03-28 14:00:00', '2027-07-19 15:00:00', 'Active', 192);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(105.26, '2026-03-29 12:00:00', 191, 8),
(126.02, '2026-03-30 08:00:00', 191, 5),
(158.65, '2026-03-30 12:00:00', 191, 7),
(189.36, '2026-03-31 10:00:00', 191, 6),
(226.05, '2026-04-01 03:00:00', 191, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-04-01 04:00:00' WHERE auction_id=191;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (119.37, 20, 119.37, '2026-03-10 06:59:00', '2027-07-19 15:00:00', 'Active', 11);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(147.06, '2026-03-11 07:59:00', 192, 6),
(184.58, '2026-03-12 01:59:00', 192, 4),
(213.37, '2026-03-13 00:59:00', 192, 8),
(246.94, '2026-03-13 21:59:00', 192, 7),
(301.08, '2026-03-14 21:59:00', 192, 1),
(347.36, '2026-03-15 03:59:00', 192, 5),
(402.69, '2026-03-16 04:59:00', 192, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-16 10:59:00' WHERE auction_id=192;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (342.58, 20, 342.58, '2026-07-17 15:00:00', '2026-07-23 06:00:00', 'Active', 27);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(372.24, '2026-07-17 18:00:00', 193, 4),
(396.23, '2026-07-17 23:00:00', 193, 3),
(426.07, '2026-07-18 03:00:00', 193, 6),
(464.93, '2026-07-18 07:00:00', 193, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (418.63, 20.93, 418.63, '2026-01-11 12:20:00', '2027-07-19 15:00:00', 'Active', 113);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(454.51, '2026-01-12 00:20:00', 194, 1),
(482.75, '2026-01-13 05:20:00', 194, 8),
(541.12, '2026-01-13 08:20:00', 194, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-13 09:20:00' WHERE auction_id=194;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (573.8, 28.69, 573.8, '2025-02-03 05:38:00', '2027-07-19 15:00:00', 'Active', 222);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(647.53, '2025-02-04 13:38:00', 195, 4),
(678.9, '2025-02-05 19:38:00', 195, 1),
(739.55, '2025-02-07 01:38:00', 195, 5),
(776.91, '2025-02-08 01:38:00', 195, 2),
(855.73, '2025-02-08 22:38:00', 195, 8),
(922.84, '2025-02-09 22:38:00', 195, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-09 23:38:00' WHERE auction_id=195;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (265.39, 20, 265.39, '2026-07-18 15:00:00', '2026-07-20 18:00:00', 'Active', 14);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(287.75, '2026-07-17 20:00:00', 196, 1),
(325.97, '2026-07-17 22:00:00', 196, 5),
(360.54, '2026-07-18 04:00:00', 196, 8),
(389.37, '2026-07-18 09:00:00', 196, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (107.24, 20, 107.24, '2025-08-14 09:02:00', '2027-07-19 15:00:00', 'Active', 184);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(140.62, '2025-08-14 21:02:00', 197, 3),
(165.54, '2025-08-15 05:02:00', 197, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-15 09:02:00' WHERE auction_id=197;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (74.52, 20, 74.52, '2026-07-15 15:00:00', '2026-07-20 22:00:00', 'Active', 9);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(96.22, '2026-07-19 03:00:00', 198, 5),
(130.52, '2026-07-19 07:00:00', 198, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (215.1, 20, 215.1, '2026-01-17 14:47:00', '2027-07-19 15:00:00', 'Active', 208);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(271.82, '2026-01-19 03:47:00', 199, 4),
(310.17, '2026-01-20 08:47:00', 199, 2),
(350.82, '2026-01-21 07:47:00', 199, 5),
(385.29, '2026-01-21 09:47:00', 199, 8),
(422.99, '2026-01-22 11:47:00', 199, 7),
(443.39, '2026-01-23 14:47:00', 199, 1),
(484.08, '2026-01-23 18:47:00', 199, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-23 19:47:00' WHERE auction_id=199;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (146.74, 20, 146.74, '2026-01-16 03:43:00', '2027-07-19 15:00:00', 'Active', 71);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(193.15, '2026-01-17 02:43:00', 200, 7),
(219.19, '2026-01-17 22:43:00', 200, 1),
(241.5, '2026-01-18 20:43:00', 200, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-19 02:43:00' WHERE auction_id=200;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (2065.6, 103.28, 2065.6, '2026-07-16 15:00:00', '2026-07-24 03:00:00', 'Active', 7);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(2261.85, '2026-07-18 22:00:00', 201, 6),
(2460.19, '2026-07-19 04:00:00', 201, 1);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (285.89, 20, 285.89, '2025-04-06 11:52:00', '2027-07-19 15:00:00', 'Active', 256);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(322.07, '2025-04-07 06:52:00', 202, 4),
(377.31, '2025-04-07 10:52:00', 202, 5),
(398.79, '2025-04-07 22:52:00', 202, 7),
(434.39, '2025-04-08 23:52:00', 202, 6),
(483.99, '2025-04-09 05:52:00', 202, 8),
(524.81, '2025-04-10 00:52:00', 202, 3),
(556.17, '2025-04-10 04:52:00', 202, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-04-10 09:52:00' WHERE auction_id=202;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (495.34, 24.77, 495.34, '2025-11-29 12:00:00', '2027-07-19 15:00:00', 'Active', 168);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(532.93, '2025-12-01 02:00:00', 203, 3),
(596.05, '2025-12-02 03:00:00', 203, 1),
(641.76, '2025-12-02 21:00:00', 203, 7),
(672.0, '2025-12-03 00:00:00', 203, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-03 03:00:00' WHERE auction_id=203;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (127.46, 20, 127.46, '2025-07-14 10:46:00', '2027-07-19 15:00:00', 'Active', 243);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(159.38, '2025-07-15 19:46:00', 204, 2),
(179.59, '2025-07-16 07:46:00', 204, 1),
(238.91, '2025-07-17 10:46:00', 204, 6),
(288.74, '2025-07-18 06:46:00', 204, 7);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-18 11:46:00' WHERE auction_id=204;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (856.22, 42.81, 856.22, '2026-07-16 15:00:00', '2026-07-22 02:00:00', 'Active', 101);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(921.28, '2026-07-18 12:00:00', 205, 3),
(968.59, '2026-07-18 17:00:00', 205, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (526.52, 26.33, 526.52, '2025-12-08 02:37:00', '2027-07-19 15:00:00', 'Active', 97);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(557.17, '2025-12-08 12:37:00', 206, 8),
(605.87, '2025-12-08 18:37:00', 206, 1),
(657.28, '2025-12-09 10:37:00', 206, 2),
(687.72, '2025-12-10 09:37:00', 206, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-12-10 14:37:00' WHERE auction_id=206;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (342.7, 20, 342.7, '2025-07-12 15:34:00', '2027-07-19 15:00:00', 'Active', 219);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(402.56, '2025-07-13 22:34:00', 207, 7),
(459.8, '2025-07-14 15:34:00', 207, 8),
(509.07, '2025-07-15 06:34:00', 207, 3),
(562.02, '2025-07-15 12:34:00', 207, 5),
(602.25, '2025-07-16 05:34:00', 207, 4),
(650.7, '2025-07-16 11:34:00', 207, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-07-16 17:34:00' WHERE auction_id=207;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (299.33, 20, 299.33, '2026-07-17 15:00:00', '2026-07-21 13:00:00', 'Active', 292);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(338.21, '2026-07-19 03:00:00', 208, 8),
(376.64, '2026-07-19 04:00:00', 208, 1),
(408.67, '2026-07-19 08:00:00', 208, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (544.81, 27.24, 544.81, '2026-06-26 00:42:00', '2027-07-19 15:00:00', 'Active', 20);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(592.29, '2026-06-26 15:42:00', 209, 5),
(636.05, '2026-06-27 08:42:00', 209, 1),
(664.81, '2026-06-27 14:42:00', 209, 8),
(699.79, '2026-06-28 10:42:00', 209, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-28 14:42:00' WHERE auction_id=209;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (343.27, 20, 343.27, '2026-07-17 15:00:00', '2026-07-23 00:00:00', 'Active', 202);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(365.72, '2026-07-19 13:00:00', 210, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (271.9, 20, 271.9, '2025-06-02 08:52:00', '2027-07-19 15:00:00', 'Active', 50);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(304.29, '2025-06-03 10:52:00', 211, 7),
(360.3, '2025-06-04 13:52:00', 211, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-06-04 17:52:00' WHERE auction_id=211;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (468.07, 23.4, 468.07, '2026-07-17 15:00:00', '2026-07-24 19:00:00', 'Active', 40);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(511.74, '2026-07-19 04:00:00', 212, 8),
(537.23, '2026-07-19 09:00:00', 212, 7),
(576.18, '2026-07-19 13:00:00', 212, 4),
(608.64, '2026-07-19 17:00:00', 212, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (278.18, 20, 278.18, '2026-06-08 15:50:00', '2027-07-19 15:00:00', 'Active', 30);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(324.02, '2026-06-10 01:50:00', 213, 8),
(350.64, '2026-06-10 03:50:00', 213, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-10 08:50:00' WHERE auction_id=213;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (344.29, 20, 344.29, '2025-02-03 05:59:00', '2027-07-19 15:00:00', 'Active', 162);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(385.96, '2025-02-04 17:59:00', 214, 2),
(408.07, '2025-02-05 13:59:00', 214, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-05 18:59:00' WHERE auction_id=214;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (334.55, 20, 334.55, '2026-07-18 15:00:00', '2026-07-24 15:00:00', 'Active', 37);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(371.14, '2026-07-19 00:00:00', 215, 3),
(400.02, '2026-07-19 05:00:00', 215, 1),
(432.16, '2026-07-19 09:00:00', 215, 8),
(463.94, '2026-07-19 13:00:00', 215, 2);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (879.22, 43.96, 879.22, '2026-07-15 15:00:00', '2026-07-21 01:00:00', 'Active', 255);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(960.97, '2026-07-19 12:00:00', 216, 7);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (271.8, 20, 271.8, '2025-02-08 05:17:00', '2027-07-19 15:00:00', 'Active', 234);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(298.53, '2025-02-08 20:17:00', 217, 2),
(325.84, '2025-02-09 22:17:00', 217, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-09 23:17:00' WHERE auction_id=217;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (389.72, 20, 389.72, '2025-03-17 04:20:00', '2027-07-19 15:00:00', 'Active', 117);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(438.25, '2025-03-17 16:20:00', 218, 3),
(473.85, '2025-03-18 04:20:00', 218, 1),
(499.55, '2025-03-19 10:20:00', 218, 5),
(532.52, '2025-03-20 00:20:00', 218, 8),
(590.18, '2025-03-21 06:20:00', 218, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-21 07:20:00' WHERE auction_id=218;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (91.94, 20, 91.94, '2026-05-28 04:22:00', '2027-07-19 15:00:00', 'Active', 175);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(114.37, '2026-05-29 01:22:00', 219, 4),
(156.49, '2026-05-29 05:22:00', 219, 8),
(195.86, '2026-05-29 20:22:00', 219, 5),
(241.2, '2026-05-31 02:22:00', 219, 6),
(261.94, '2026-05-31 21:22:00', 219, 7),
(320.48, '2026-06-01 20:22:00', 219, 1);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-01 21:22:00' WHERE auction_id=219;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (235.88, 20, 235.88, '2026-07-15 15:00:00', '2026-07-22 00:00:00', 'Active', 99);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(259.95, '2026-07-18 04:00:00', 220, 2),
(287.42, '2026-07-18 06:00:00', 220, 7),
(323.06, '2026-07-18 11:00:00', 220, 6);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (290.29, 20, 290.29, '2026-07-18 15:00:00', '2026-07-25 05:00:00', 'Active', 152);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1012.83, 50.64, 1012.83, '2026-07-17 15:00:00', '2026-07-25 00:00:00', 'Active', 5);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (271.53, 20, 271.53, '2026-07-16 15:00:00', '2026-07-23 23:00:00', 'Active', 198);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(303.23, '2026-07-19 02:00:00', 223, 6),
(328.86, '2026-07-19 04:00:00', 223, 7),
(363.64, '2026-07-19 09:00:00', 223, 8);
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (131.39, 20, 131.39, '2025-09-03 07:03:00', '2027-07-19 15:00:00', 'Active', 134);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(184.61, '2025-09-04 10:03:00', 224, 7),
(226.87, '2025-09-04 20:03:00', 224, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2025-09-05 00:03:00' WHERE auction_id=224;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1349.28, 67.46, 1349.28, '2026-01-15 10:26:00', '2027-07-19 15:00:00', 'Active', 155);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1449.92, '2026-01-16 03:26:00', 225, 6),
(1563.47, '2026-01-16 19:26:00', 225, 8),
(1760.32, '2026-01-17 07:26:00', 225, 3),
(1829.92, '2026-01-18 07:26:00', 225, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-18 09:26:00' WHERE auction_id=225;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (215.87, 20, 215.87, '2026-01-26 12:42:00', '2027-07-19 15:00:00', 'Active', 60);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(252.4, '2026-01-27 21:42:00', 226, 1),
(300.26, '2026-01-28 14:42:00', 226, 6);
UPDATE AUCTIONS SET status='Closed', end_time='2026-01-28 18:42:00' WHERE auction_id=226;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (141.43, 20, 141.43, '2026-05-31 09:21:00', '2027-07-19 15:00:00', 'Active', 299);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(175.75, '2026-06-01 02:21:00', 227, 2),
(229.32, '2026-06-02 05:21:00', 227, 5),
(277.2, '2026-06-02 07:21:00', 227, 1),
(302.19, '2026-06-02 20:21:00', 227, 4),
(359.64, '2026-06-03 12:21:00', 227, 6),
(380.01, '2026-06-04 13:21:00', 227, 8),
(400.8, '2026-06-04 23:21:00', 227, 3);
UPDATE AUCTIONS SET status='Closed', end_time='2026-06-05 05:21:00' WHERE auction_id=227;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (301.61, 20, 301.61, '2025-08-05 15:17:00', '2027-07-19 15:00:00', 'Active', 191);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(323.08, '2025-08-06 14:17:00', 228, 5),
(379.26, '2025-08-07 14:17:00', 228, 7),
(423.5, '2025-08-07 16:17:00', 228, 6),
(451.34, '2025-08-08 20:17:00', 228, 2),
(496.88, '2025-08-09 01:17:00', 228, 8),
(551.68, '2025-08-09 21:17:00', 228, 4);
UPDATE AUCTIONS SET status='Closed', end_time='2025-08-10 02:17:00' WHERE auction_id=228;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (505.82, 25.29, 505.82, '2026-03-06 21:37:00', '2027-07-19 15:00:00', 'Active', 18);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(568.84, '2026-03-07 06:37:00', 229, 3),
(607.26, '2026-03-08 02:37:00', 229, 1),
(675.82, '2026-03-09 08:37:00', 229, 5);
UPDATE AUCTIONS SET status='Closed', end_time='2026-03-09 13:37:00' WHERE auction_id=229;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (296.02, 20, 296.02, '2025-02-17 10:50:00', '2027-07-19 15:00:00', 'Active', 63);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(353.54, '2025-02-18 09:50:00', 230, 1),
(400.46, '2025-02-19 07:50:00', 230, 6),
(422.53, '2025-02-19 19:50:00', 230, 7),
(459.83, '2025-02-20 10:50:00', 230, 5),
(490.79, '2025-02-21 09:50:00', 230, 3),
(531.52, '2025-02-22 02:50:00', 230, 4),
(565.98, '2025-02-23 04:50:00', 230, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-02-23 05:50:00' WHERE auction_id=230;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1578.35, 78.92, 1578.35, '2025-05-16 02:11:00', '2027-07-19 15:00:00', 'Active', 167);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1670.18, '2025-05-17 04:11:00', 231, 8),
(1876.58, '2025-05-18 05:11:00', 231, 3),
(1991.11, '2025-05-19 05:11:00', 231, 1),
(2136.93, '2025-05-19 09:11:00', 231, 4),
(2360.59, '2025-05-19 17:11:00', 231, 2);
UPDATE AUCTIONS SET status='Closed', end_time='2025-05-19 19:11:00' WHERE auction_id=231;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (381.61, 20, 381.61, '2025-10-17 12:29:00', '2027-07-19 15:00:00', 'Active', 154);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(411.5, '2025-10-18 10:29:00', 232, 2),
(441.03, '2025-10-18 22:29:00', 232, 1),
(494.33, '2025-10-20 02:29:00', 232, 4),
(527.67, '2025-10-21 05:29:00', 232, 6),
(557.14, '2025-10-21 09:29:00', 232, 7),
(608.17, '2025-10-22 06:29:00', 232, 3),
(645.71, '2025-10-22 11:29:00', 232, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-10-22 17:29:00' WHERE auction_id=232;
INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (1101.87, 55.09, 1101.87, '2025-03-17 02:17:00', '2027-07-19 15:00:00', 'Active', 166);
INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES
(1191.48, '2025-03-18 14:17:00', 233, 1),
(1322.96, '2025-03-19 17:17:00', 233, 8);
UPDATE AUCTIONS SET status='Closed', end_time='2025-03-19 19:17:00' WHERE auction_id=233;
-- (Auctions seeded: 233; ~70% historical/closed with a declared winner, ~30% currently Active)

-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
INSERT INTO ORDERS (order_date, status, listing_id, buyer_id, seller_id) VALUES
('2025-11-14 11:00:00', 'Preparing', 298, 4, 6),
('2026-02-08 08:05:00', 'Delivered', 244, 1, 3),
('2026-03-28 04:37:00', 'Shipped', 140, 7, 2),
('2026-04-02 06:15:00', 'Preparing', 10, 6, 5),
('2025-05-31 11:41:00', 'Shipped', 120, 8, 5),
('2025-05-11 08:49:00', 'Shipped', 185, 2, 5),
('2026-03-12 23:17:00', 'Preparing', 187, 2, 6),
('2026-02-22 18:25:00', 'Delivered', 139, 3, 5),
('2025-05-04 06:04:00', 'Shipped', 12, 7, 4),
('2025-09-06 01:15:00', 'Preparing', 23, 3, 1),
('2026-01-20 03:14:00', 'Shipped', 217, 1, 3),
('2026-01-16 04:23:00', 'Preparing', 272, 6, 2),
('2026-06-15 19:40:00', 'Delivered', 172, 3, 6),
('2026-07-19 13:00:00', 'Delivered', 231, 6, 4),
('2025-02-13 11:04:00', 'Delivered', 112, 3, 3),
('2026-01-24 08:30:00', 'Delivered', 130, 1, 5),
('2026-07-19 06:00:00', 'Delivered', 132, 4, 3),
('2026-07-17 03:00:00', 'Shipped', 236, 8, 3),
('2025-06-06 23:31:00', 'Shipped', 263, 6, 1),
('2026-05-12 05:59:00', 'Delivered', 135, 6, 6),
('2026-01-01 12:03:00', 'Delivered', 124, 3, 3),
('2025-09-20 11:01:00', 'Delivered', 106, 4, 5),
('2026-03-23 08:58:00', 'Preparing', 118, 6, 4),
('2025-09-03 15:07:00', 'Delivered', 104, 1, 1),
('2025-02-01 01:30:00', 'Delivered', 128, 8, 6),
('2026-03-29 05:49:00', 'Delivered', 186, 3, 6),
('2025-07-30 03:35:00', 'Delivered', 55, 6, 1),
('2026-07-05 04:20:00', 'Delivered', 62, 6, 4),
('2026-04-21 16:09:00', 'Shipped', 41, 1, 1),
('2026-01-11 18:23:00', 'Delivered', 4, 8, 2),
('2026-02-06 04:58:00', 'Out for Delivery', 285, 6, 1),
('2025-04-27 22:56:00', 'Cancelled', 22, 3, 1),
('2025-03-23 13:46:00', 'Delivered', 254, 2, 2),
('2025-02-04 01:17:00', 'Out for Delivery', 165, 6, 4),
('2025-05-05 06:58:00', 'Delivered', 141, 8, 4),
('2025-06-14 11:54:00', 'Delivered', 259, 3, 3),
('2026-02-03 14:50:00', 'Cancelled', 269, 7, 5),
('2026-01-23 16:46:00', 'Delivered', 207, 6, 1),
('2025-10-22 22:58:00', 'Delivered', 114, 5, 5),
('2025-07-23 22:27:00', 'Delivered', 28, 5, 4),
('2025-01-17 09:26:00', 'Delivered', 252, 5, 1),
('2025-11-20 06:03:00', 'Delivered', 17, 5, 4),
('2025-04-22 11:42:00', 'Delivered', 265, 6, 5),
('2025-03-31 04:08:00', 'Shipped', 181, 2, 3),
('2026-06-26 07:43:00', 'Out for Delivery', 290, 7, 2),
('2026-03-14 00:31:00', 'Delivered', 182, 2, 2),
('2025-09-23 10:30:00', 'Delivered', 133, 1, 2),
('2025-06-09 17:59:00', 'Delivered', 81, 6, 4),
('2026-02-06 01:25:00', 'Delivered', 180, 5, 4),
('2025-07-14 20:23:00', 'Preparing', 287, 6, 4),
('2026-06-23 17:22:00', 'Out for Delivery', 176, 2, 1),
('2025-04-06 16:16:00', 'Delivered', 54, 7, 3),
('2026-06-28 00:41:00', 'Shipped', 98, 5, 6),
('2026-03-02 09:35:00', 'Delivered', 151, 7, 5),
('2025-11-09 21:52:00', 'Delivered', 160, 7, 4),
('2025-01-10 17:05:00', 'Preparing', 228, 2, 2),
('2025-10-26 23:38:00', 'Preparing', 67, 7, 3),
('2026-04-03 23:55:00', 'Delivered', 48, 2, 1),
('2025-07-23 19:31:00', 'Shipped', 280, 1, 2),
('2025-07-18 10:43:00', 'Delivered', 248, 8, 1),
('2025-10-26 23:07:00', 'Preparing', 88, 8, 5),
('2025-12-21 20:26:00', 'Delivered', 278, 5, 5),
('2025-05-03 01:03:00', 'Preparing', 245, 8, 2),
('2025-05-25 20:07:00', 'Delivered', 294, 4, 2),
('2026-02-19 11:28:00', 'Delivered', 109, 5, 3),
('2026-06-17 05:28:00', 'Preparing', 284, 7, 4),
('2026-07-14 11:16:00', 'Shipped', 108, 6, 2),
('2026-02-01 21:32:00', 'Preparing', 183, 7, 3),
('2026-02-01 18:27:00', 'Cancelled', 196, 7, 6),
('2025-02-28 16:41:00', 'Cancelled', 96, 5, 5),
('2025-11-11 07:26:00', 'Preparing', 72, 5, 1),
('2026-02-22 14:04:00', 'Preparing', 47, 1, 4),
('2026-06-24 08:26:00', 'Delivered', 149, 6, 6),
('2025-10-11 17:20:00', 'Delivered', 34, 2, 2),
('2025-11-27 19:26:00', 'Preparing', 150, 5, 1),
('2026-07-09 15:23:00', 'Preparing', 179, 4, 6),
('2026-07-11 07:22:00', 'Delivered', 59, 2, 6),
('2026-01-21 01:40:00', 'Delivered', 213, 5, 1),
('2025-02-22 17:03:00', 'Delivered', 251, 6, 1),
('2026-02-16 20:23:00', 'Shipped', 70, 5, 6),
('2025-02-21 01:53:00', 'Cancelled', 264, 7, 2),
('2026-02-28 17:10:00', 'Delivered', 253, 5, 3),
('2025-11-14 20:25:00', 'Delivered', 51, 5, 1),
('2025-07-28 02:39:00', 'Shipped', 38, 3, 1),
('2025-09-01 20:41:00', 'Delivered', 193, 3, 1),
('2025-04-23 09:01:00', 'Delivered', 39, 5, 5),
('2026-02-16 09:48:00', 'Preparing', 122, 4, 4),
('2025-06-15 07:26:00', 'Delivered', 257, 6, 3),
('2025-05-14 11:55:00', 'Delivered', 46, 8, 2),
('2025-09-25 00:58:00', 'Preparing', 232, 8, 2),
('2025-11-18 14:53:00', 'Preparing', 235, 8, 6),
('2025-01-24 01:24:00', 'Preparing', 35, 3, 6),
('2025-03-24 06:04:00', 'Cancelled', 282, 1, 6),
('2026-07-18 07:00:00', 'Delivered', 261, 2, 1),
('2025-11-04 06:38:00', 'Delivered', 137, 2, 4),
('2025-04-05 20:51:00', 'Delivered', 211, 7, 3),
('2026-04-24 14:35:00', 'Shipped', 279, 6, 2),
('2025-04-22 13:50:00', 'Delivered', 276, 4, 4),
('2025-09-10 12:51:00', 'Delivered', 13, 8, 6),
('2025-11-23 17:45:00', 'Out for Delivery', 258, 3, 6),
('2026-02-07 01:59:00', 'Shipped', 16, 4, 4),
('2025-04-08 22:53:00', 'Delivered', 56, 7, 1),
('2026-02-05 13:34:00', 'Delivered', 273, 1, 4),
('2025-03-02 18:05:00', 'Delivered', 200, 3, 1),
('2025-06-05 11:25:00', 'Delivered', 283, 5, 5),
('2025-04-27 06:55:00', 'Delivered', 25, 1, 3),
('2025-02-28 06:39:00', 'Out for Delivery', 271, 1, 2),
('2025-04-02 23:09:00', 'Out for Delivery', 86, 5, 4),
('2025-12-22 11:36:00', 'Delivered', 246, 5, 2),
('2025-10-29 19:46:00', 'Delivered', 249, 3, 2),
('2026-04-02 06:27:00', 'Delivered', 170, 3, 5),
('2026-07-06 15:36:00', 'Preparing', 293, 2, 4),
('2025-08-28 10:26:00', 'Shipped', 275, 4, 1),
('2025-04-28 13:51:00', 'Delivered', 177, 6, 4),
('2025-02-15 17:01:00', 'Delivered', 89, 7, 4),
('2025-06-28 01:02:00', 'Delivered', 297, 5, 6),
('2025-07-05 16:33:00', 'Preparing', 32, 6, 6),
('2025-03-08 07:50:00', 'Delivered', 268, 7, 1),
('2026-03-07 21:20:00', 'Delivered', 204, 7, 3),
('2025-03-06 21:40:00', 'Preparing', 158, 1, 4),
('2025-04-29 14:10:00', 'Shipped', 138, 4, 3),
('2025-07-13 22:13:00', 'Preparing', 45, 2, 6),
('2026-07-12 17:37:00', 'Delivered', 73, 8, 4),
('2025-03-23 23:40:00', 'Shipped', 91, 7, 4),
('2025-05-19 22:46:00', 'Delivered', 250, 1, 2),
('2025-10-08 12:26:00', 'Delivered', 189, 1, 2),
('2026-06-05 14:16:00', 'Delivered', 21, 3, 6),
('2025-08-14 04:13:00', 'Delivered', 266, 3, 3),
('2026-04-04 21:15:00', 'Shipped', 74, 7, 6),
('2025-05-03 23:47:00', 'Delivered', 203, 8, 6),
('2025-12-25 12:07:00', 'Shipped', 87, 4, 6),
('2026-06-09 01:47:00', 'Delivered', 197, 7, 5),
('2026-05-03 01:27:00', 'Delivered', 295, 6, 3),
('2025-04-15 08:34:00', 'Delivered', 19, 3, 4),
('2025-11-06 07:43:00', 'Preparing', 146, 8, 2),
('2025-10-22 16:51:00', 'Delivered', 267, 5, 3),
('2026-04-08 23:55:00', 'Delivered', 238, 4, 3),
('2026-05-17 15:37:00', 'Delivered', 190, 3, 1),
('2025-01-26 03:50:00', 'Delivered', 75, 8, 3),
('2025-10-22 12:43:00', 'Shipped', 241, 2, 6),
('2026-04-07 22:32:00', 'Delivered', 78, 1, 3),
('2025-12-31 09:36:00', 'Delivered', 83, 2, 6),
('2025-08-10 03:27:00', 'Preparing', 274, 4, 3),
('2026-04-09 10:34:00', 'Delivered', 100, 5, 2),
('2026-05-24 10:46:00', 'Shipped', 206, 2, 3),
('2025-12-14 02:00:00', 'Preparing', 223, 8, 6),
('2025-04-08 12:34:00', 'Preparing', 229, 2, 2),
('2025-12-06 20:50:00', 'Delivered', 76, 7, 2),
('2025-12-10 20:42:00', 'Delivered', 53, 3, 2),
('2026-06-16 00:24:00', 'Delivered', 286, 5, 6),
('2025-07-04 10:01:00', 'Delivered', 24, 7, 5),
('2026-03-06 16:44:00', 'Delivered', 199, 6, 1),
('2025-06-02 10:43:00', 'Delivered', 277, 8, 6),
('2026-05-20 10:08:00', 'Delivered', 247, 3, 3),
('2026-04-16 14:56:00', 'Preparing', 31, 2, 6),
('2025-02-05 03:47:00', 'Out for Delivery', 85, 4, 3),
('2025-11-23 20:39:00', 'Delivered', 33, 7, 5),
('2025-12-11 19:29:00', 'Out for Delivery', 281, 6, 4),
('2025-12-11 04:54:00', 'Cancelled', 161, 8, 4),
('2026-04-01 20:00:00', 'Cancelled', 192, 4, 6),
('2026-03-16 23:59:00', 'Out for Delivery', 11, 2, 4),
('2026-01-13 20:20:00', 'Out for Delivery', 113, 3, 1),
('2025-02-10 14:38:00', 'Preparing', 222, 6, 2),
('2025-08-15 23:02:00', 'Delivered', 184, 6, 6),
('2026-01-24 06:47:00', 'Delivered', 208, 6, 1),
('2026-01-19 19:43:00', 'Preparing', 71, 4, 1),
('2025-04-11 03:52:00', 'Preparing', 256, 2, 1),
('2025-12-03 12:00:00', 'Delivered', 168, 5, 5),
('2025-07-19 05:46:00', 'Delivered', 243, 7, 6),
('2025-12-11 03:37:00', 'Shipped', 97, 4, 3),
('2025-07-17 10:34:00', 'Shipped', 219, 6, 3),
('2026-06-28 16:42:00', 'Delivered', 20, 2, 2),
('2025-06-05 09:52:00', 'Delivered', 50, 4, 6),
('2026-06-10 18:50:00', 'Out for Delivery', 30, 6, 3),
('2025-02-06 01:59:00', 'Delivered', 162, 8, 5),
('2025-02-10 04:17:00', 'Delivered', 234, 1, 5),
('2025-03-21 09:20:00', 'Delivered', 117, 2, 1),
('2026-06-02 05:22:00', 'Out for Delivery', 175, 1, 2),
('2025-09-05 07:03:00', 'Delivered', 134, 6, 5),
('2026-01-18 10:26:00', 'Delivered', 155, 4, 4),
('2026-01-29 12:42:00', 'Preparing', 60, 6, 2),
('2026-06-05 17:21:00', 'Out for Delivery', 299, 3, 2),
('2025-08-10 18:17:00', 'Out for Delivery', 191, 4, 1),
('2026-03-09 22:37:00', 'Delivered', 18, 5, 5),
('2025-02-23 13:50:00', 'Preparing', 63, 2, 6),
('2025-05-20 06:11:00', 'Delivered', 167, 2, 3),
('2025-10-23 08:29:00', 'Delivered', 154, 8, 6),
('2025-03-19 21:17:00', 'Out for Delivery', 166, 8, 2);

-- (Orders seeded: 188)

-- ------------------------------------------------------------
-- PAYMENTS (fires after_payment_insert_create_transaction automatically)
-- ------------------------------------------------------------
INSERT INTO PAYMENTS (payment_method, amount_paid, payment_status, gateway_reference_token, payment_date, order_id) VALUES
('Bank', 94.1, 'Completed', 'SIM-12F3C9A67F', '2025-11-14 13:00:00', 1),
('Bank', 490.22, 'Completed', 'SIM-4062FA68C9', '2026-02-08 12:05:00', 2),
('Bank', 773.39, 'Completed', 'SIM-9D02DB318B', '2026-03-28 07:37:00', 3),
('GCash', 1558.61, 'Completed', 'SIM-A51CB9ED4B', '2025-05-31 16:41:00', 5),
('Bank', 959.55, 'Completed', 'SIM-2C70CB21B9', '2025-05-11 09:49:00', 6),
('GCash', 545.66, 'Completed', 'SIM-E74C3ED51D', '2026-03-13 01:17:00', 7),
('Bank', 530.53, 'Completed', 'SIM-B06288135E', '2026-02-22 20:25:00', 8),
('Bank', 286.11, 'Completed', 'SIM-55E36CD851', '2025-05-04 10:04:00', 9),
('GCash', 547.32, 'Completed', 'SIM-09D7E4E855', '2025-09-06 03:15:00', 10),
('Bank', 9228.61, 'Completed', 'SIM-06BF6260CD', '2026-01-20 05:14:00', 11),
('GCash', 678.88, 'Completed', 'SIM-441F0DAE5C', '2026-06-15 20:40:00', 13),
('Bank', 640.69, 'Completed', 'SIM-1B2D9C77CA', '2026-07-19 19:00:00', 14),
('GCash', 65.35, 'Completed', 'SIM-E20B64CFDA', '2025-02-13 12:04:00', 15),
('GCash', 33.58, 'Completed', 'SIM-1A4244B513', '2026-01-24 14:30:00', 16),
('Bank', 660.9, 'Completed', 'SIM-68FDB09FD4', '2026-07-19 07:00:00', 17),
('GCash', 323.14, 'Completed', 'SIM-67CC0BF2DD', '2026-07-17 05:00:00', 18),
('Bank', 335.28, 'Completed', 'SIM-9BDFC0F01B', '2025-06-07 04:31:00', 19),
('Bank', 62.39, 'Completed', 'SIM-A806195683', '2026-05-12 08:59:00', 20),
('GCash', 660.24, 'Completed', 'SIM-395495F48F', '2026-01-01 15:03:00', 21),
('Bank', 31.01, 'Completed', 'SIM-BA812525AA', '2025-09-20 17:01:00', 22),
('Bank', 514.56, 'Completed', 'SIM-D0DBC1D04D', '2026-03-23 09:58:00', 23),
('Bank', 769.27, 'Completed', 'SIM-5FE46294EA', '2025-09-03 21:07:00', 24),
('Bank', 660.75, 'Completed', 'SIM-FDA8965D72', '2025-02-01 07:30:00', 25),
('Bank', 599.06, 'Completed', 'SIM-4B19A99CC2', '2026-03-29 07:49:00', 26),
('GCash', 381.99, 'Completed', 'SIM-201CD03E39', '2025-07-30 05:35:00', 27),
('Bank', 685.88, 'Completed', 'SIM-719F01030C', '2026-07-05 06:20:00', 28),
('GCash', 1178.63, 'Completed', 'SIM-60B8E22C0E', '2026-04-21 20:09:00', 29),
('Bank', 216.36, 'Completed', 'SIM-21F5D8A75F', '2026-01-11 21:23:00', 30),
('Bank', 92.8, 'Completed', 'SIM-99F1430A80', '2026-02-06 08:58:00', 31),
('GCash', 369.78, 'Completed', 'SIM-D0E8521554', '2025-03-23 18:46:00', 33),
('GCash', 1465.71, 'Completed', 'SIM-DA74454E14', '2025-02-04 05:17:00', 34),
('GCash', 1155.34, 'Completed', 'SIM-397A648038', '2025-05-05 09:58:00', 35),
('GCash', 1108.66, 'Completed', 'SIM-8C05228356', '2025-06-14 16:54:00', 36),
('GCash', 1246.4, 'Completed', 'SIM-B367ED55AC', '2026-01-23 22:46:00', 38),
('GCash', 165.83, 'Completed', 'SIM-B600E0CCC1', '2025-10-23 02:58:00', 39),
('GCash', 201.9, 'Completed', 'SIM-17CAC6E804', '2025-07-24 03:27:00', 40),
('GCash', 411.0, 'Completed', 'SIM-7CE0EF314B', '2025-01-17 14:26:00', 41),
('Bank', 468.75, 'Completed', 'SIM-6A39B2A396', '2025-11-20 07:03:00', 42),
('Bank', 399.69, 'Completed', 'SIM-63F4FFDF03', '2025-04-22 15:42:00', 43),
('Bank', 430.08, 'Completed', 'SIM-6A7078AB29', '2025-03-31 07:08:00', 44),
('Bank', 143.22, 'Completed', 'SIM-14724A49F4', '2026-06-26 09:43:00', 45),
('Bank', 3459.17, 'Completed', 'SIM-4D156F9914', '2026-03-14 01:31:00', 46),
('GCash', 136.26, 'Completed', 'SIM-5EDC2372C6', '2025-09-23 16:30:00', 47),
('Bank', 594.03, 'Completed', 'SIM-C1B4DD64B0', '2025-06-09 20:59:00', 48),
('GCash', 2470.24, 'Completed', 'SIM-C886DE18BC', '2026-02-06 07:25:00', 49),
('Bank', 316.63, 'Completed', 'SIM-B578634055', '2025-07-15 02:23:00', 50),
('Bank', 148.78, 'Completed', 'SIM-6DBBB585BF', '2026-06-23 21:22:00', 51),
('Bank', 746.46, 'Completed', 'SIM-3AA279FF46', '2025-04-06 19:16:00', 52),
('GCash', 762.82, 'Completed', 'SIM-BA7F7ED4CE', '2026-06-28 05:41:00', 53),
('GCash', 151.27, 'Completed', 'SIM-3E9B951715', '2026-03-02 15:35:00', 54),
('GCash', 2550.2, 'Completed', 'SIM-9F7D565A7C', '2025-11-10 01:52:00', 55),
('GCash', 200.42, 'Completed', 'SIM-92F49602E5', '2026-04-04 05:55:00', 58),
('Bank', 60.16, 'Completed', 'SIM-BF67A8E431', '2025-07-23 21:31:00', 59),
('Bank', 960.7, 'Completed', 'SIM-8D6D4F7B67', '2025-07-18 14:43:00', 60),
('GCash', 234.69, 'Completed', 'SIM-8B9CA94394', '2025-12-22 00:26:00', 62),
('GCash', 427.47, 'Completed', 'SIM-D159405646', '2025-05-25 21:07:00', 64),
('Bank', 422.77, 'Completed', 'SIM-E4FBB142A3', '2026-02-19 17:28:00', 65),
('GCash', 554.11, 'Completed', 'SIM-6C1403BB86', '2026-06-17 08:28:00', 66),
('Bank', 358.96, 'Completed', 'SIM-7A22612356', '2026-07-14 13:16:00', 67),
('GCash', 63.41, 'Completed', 'SIM-C3C26BCDC2', '2025-11-11 13:26:00', 71),
('GCash', 1008.16, 'Completed', 'SIM-92F209AE92', '2026-02-22 15:04:00', 72),
('Bank', 1522.32, 'Completed', 'SIM-C1F893254A', '2026-06-24 11:26:00', 73),
('GCash', 335.18, 'Completed', 'SIM-C7DC23E502', '2025-10-11 18:20:00', 74),
('Bank', 2656.86, 'Completed', 'SIM-1949CD4E44', '2026-07-09 17:23:00', 76),
('Bank', 361.58, 'Completed', 'SIM-342C7F609D', '2026-07-11 13:22:00', 77),
('GCash', 1118.9, 'Completed', 'SIM-240FB86C6E', '2026-01-21 04:40:00', 78),
('Bank', 272.57, 'Completed', 'SIM-9D96B2836B', '2025-02-22 18:03:00', 79),
('Bank', 152.3, 'Completed', 'SIM-238C90F592', '2026-02-16 23:23:00', 80),
('Bank', 447.32, 'Completed', 'SIM-1CA2CC05A5', '2026-02-28 22:10:00', 82),
('GCash', 476.72, 'Completed', 'SIM-4011F1E925', '2025-11-14 23:25:00', 83),
('Bank', 54.79, 'Completed', 'SIM-4BE674BDB3', '2025-07-28 04:39:00', 84),
('Bank', 132.79, 'Completed', 'SIM-2179025129', '2025-09-01 21:41:00', 85),
('GCash', 600.35, 'Completed', 'SIM-0385555D59', '2025-04-23 14:01:00', 86),
('GCash', 347.74, 'Completed', 'SIM-39482DB729', '2026-02-16 14:48:00', 87),
('Bank', 230.52, 'Completed', 'SIM-0FB8D26BEE', '2025-06-15 11:26:00', 88),
('GCash', 1026.73, 'Completed', 'SIM-53DE847A13', '2025-05-14 13:55:00', 89),
('Bank', 1708.81, 'Completed', 'SIM-FA8CFB1B2C', '2025-01-24 04:24:00', 92),
('Bank', 199.33, 'Completed', 'SIM-A6E1FF82E9', '2026-07-18 08:00:00', 94),
('Bank', 313.66, 'Completed', 'SIM-CF0F7DDA05', '2025-11-04 12:38:00', 95),
('GCash', 1442.22, 'Completed', 'SIM-4999B114C6', '2025-04-05 21:51:00', 96),
('Bank', 653.18, 'Completed', 'SIM-C96CFA4A70', '2026-04-24 18:35:00', 97),
('GCash', 386.36, 'Completed', 'SIM-0E16DC2D67', '2025-04-22 18:50:00', 98),
('GCash', 861.43, 'Completed', 'SIM-4016B53D74', '2025-09-10 18:51:00', 99),
('GCash', 248.57, 'Completed', 'SIM-B0EDCAD702', '2025-11-23 19:45:00', 100),
('GCash', 388.13, 'Completed', 'SIM-D0A0ABF95D', '2026-02-07 07:59:00', 101),
('GCash', 157.73, 'Completed', 'SIM-AA5D18BC9F', '2025-04-08 23:53:00', 102),
('GCash', 386.89, 'Completed', 'SIM-BA27F5F62F', '2026-02-05 16:34:00', 103),
('Bank', 60.05, 'Completed', 'SIM-D08C5B384D', '2025-03-03 00:05:00', 104),
('Bank', 301.54, 'Completed', 'SIM-8B2F59D5AD', '2025-06-05 17:25:00', 105),
('Bank', 315.41, 'Completed', 'SIM-8672FF4B01', '2025-04-27 11:55:00', 106),
('GCash', 186.84, 'Completed', 'SIM-CE9E9A9D71', '2025-02-28 11:39:00', 107),
('GCash', 1122.61, 'Completed', 'SIM-C6060ECCD5', '2025-04-03 04:09:00', 108),
('Bank', 429.28, 'Completed', 'SIM-25E7EEBD2E', '2025-12-22 16:36:00', 109),
('GCash', 189.42, 'Completed', 'SIM-9EC7A99DB4', '2025-10-30 01:46:00', 110),
('Bank', 325.21, 'Completed', 'SIM-F98EC8E94A', '2026-04-02 12:27:00', 111),
('Bank', 534.57, 'Completed', 'SIM-C92966B504', '2025-08-28 16:26:00', 113),
('GCash', 1490.7, 'Completed', 'SIM-7DE366CD5F', '2025-04-28 19:51:00', 114),
('GCash', 605.16, 'Completed', 'SIM-117C39CEE8', '2025-02-15 21:01:00', 115),
('GCash', 494.5, 'Completed', 'SIM-BBD89B2563', '2025-06-28 05:02:00', 116),
('GCash', 919.64, 'Completed', 'SIM-764ADBC4A9', '2025-03-08 08:50:00', 118),
('Bank', 42.65, 'Completed', 'SIM-7BC687E1D2', '2026-03-07 22:20:00', 119),
('GCash', 137.56, 'Completed', 'SIM-AA2B80ADD0', '2025-04-29 19:10:00', 121),
('GCash', 386.73, 'Completed', 'SIM-8445819D9E', '2026-07-12 20:37:00', 123),
('Bank', 607.81, 'Completed', 'SIM-B8883C234C', '2025-03-24 00:40:00', 124),
('Bank', 145.31, 'Completed', 'SIM-3E8E1FE866', '2025-05-20 04:46:00', 125),
('GCash', 418.24, 'Completed', 'SIM-F0561B39EB', '2025-10-08 14:26:00', 126),
('GCash', 396.82, 'Completed', 'SIM-6F11934C98', '2026-06-05 16:16:00', 127),
('Bank', 768.04, 'Completed', 'SIM-2212DB5266', '2025-08-14 08:13:00', 128),
('GCash', 102.52, 'Completed', 'SIM-DA9A298AF7', '2026-04-04 23:15:00', 129),
('Bank', 155.05, 'Completed', 'SIM-17280DD5B5', '2025-05-04 01:47:00', 130),
('Bank', 496.07, 'Completed', 'SIM-550AB313CC', '2025-12-25 14:07:00', 131),
('GCash', 372.18, 'Completed', 'SIM-DA7061C291', '2026-06-09 03:47:00', 132),
('Bank', 29.78, 'Completed', 'SIM-14ABA43CC0', '2026-05-03 07:27:00', 133),
('Bank', 186.91, 'Completed', 'SIM-278250C929', '2025-04-15 12:34:00', 134),
('Bank', 501.64, 'Completed', 'SIM-3DC52771F4', '2025-10-22 18:51:00', 136),
('GCash', 263.44, 'Completed', 'SIM-AF0EBF6FDC', '2026-04-09 03:55:00', 137),
('GCash', 327.32, 'Completed', 'SIM-DA8DD8DB3A', '2026-05-17 16:37:00', 138),
('GCash', 99.48, 'Completed', 'SIM-ABE9692F0F', '2025-01-26 07:50:00', 139),
('GCash', 957.32, 'Completed', 'SIM-F8226A617A', '2025-10-22 14:43:00', 140),
('GCash', 515.51, 'Completed', 'SIM-4B49DD4C59', '2026-04-08 00:32:00', 141),
('Bank', 272.17, 'Completed', 'SIM-1CE39A54D9', '2025-12-31 14:36:00', 142),
('Bank', 515.91, 'Completed', 'SIM-BA6E76811C', '2025-08-10 05:27:00', 143),
('GCash', 2884.85, 'Completed', 'SIM-B3FB519961', '2026-04-09 13:34:00', 144),
('GCash', 846.64, 'Completed', 'SIM-91FE034123', '2026-05-24 12:46:00', 145),
('Bank', 544.26, 'Completed', 'SIM-E84345D7A7', '2025-12-07 00:50:00', 148),
('Bank', 588.56, 'Completed', 'SIM-C0B01B1481', '2025-12-10 23:42:00', 149),
('GCash', 424.64, 'Completed', 'SIM-5886DFF915', '2026-06-16 01:24:00', 150),
('GCash', 154.99, 'Completed', 'SIM-EAC14FA308', '2025-07-04 14:01:00', 151),
('Bank', 481.07, 'Completed', 'SIM-9DDA60ECCE', '2026-03-06 19:44:00', 152),
('Bank', 818.01, 'Completed', 'SIM-710D8CA809', '2025-06-02 11:43:00', 153),
('GCash', 845.39, 'Completed', 'SIM-D912690837', '2026-05-20 13:08:00', 154),
('GCash', 3919.13, 'Completed', 'SIM-B43F9955FC', '2026-04-16 19:56:00', 155),
('GCash', 1099.7, 'Completed', 'SIM-1F64E59974', '2025-02-05 07:47:00', 156),
('GCash', 514.03, 'Completed', 'SIM-A5D563DDD4', '2025-11-24 02:39:00', 157),
('Bank', 556.12, 'Completed', 'SIM-7A8275410F', '2025-12-11 20:29:00', 158),
('Bank', 198.95, 'Completed', 'SIM-26BC0C3207', '2026-03-17 04:59:00', 161),
('Bank', 697.71, 'Completed', 'SIM-4598BB7BA8', '2026-01-14 02:20:00', 162),
('GCash', 178.74, 'Completed', 'SIM-42647D62B7', '2025-08-16 05:02:00', 164),
('Bank', 358.5, 'Completed', 'SIM-980755AFDE', '2026-01-24 07:47:00', 165),
('Bank', 244.57, 'Completed', 'SIM-760D80ACF7', '2026-01-19 22:43:00', 166),
('Bank', 476.48, 'Completed', 'SIM-F99D9D4763', '2025-04-11 08:52:00', 167),
('Bank', 825.57, 'Completed', 'SIM-9C820B6246', '2025-12-03 14:00:00', 168),
('Bank', 212.43, 'Completed', 'SIM-7CFBAA6C32', '2025-07-19 11:46:00', 169),
('Bank', 877.54, 'Completed', 'SIM-A5946C4DD7', '2025-12-11 04:37:00', 170),
('Bank', 571.16, 'Completed', 'SIM-64E8443B13', '2025-07-17 16:34:00', 171),
('GCash', 908.02, 'Completed', 'SIM-E8B1F701AB', '2026-06-28 17:42:00', 172),
('GCash', 453.17, 'Completed', 'SIM-D0841CE844', '2025-06-05 15:52:00', 173),
('GCash', 463.64, 'Completed', 'SIM-99132C58DA', '2026-06-10 19:50:00', 174),
('GCash', 573.82, 'Completed', 'SIM-DF8ACB5CED', '2025-02-06 02:59:00', 175),
('Bank', 453.0, 'Completed', 'SIM-5416098ED7', '2025-02-10 05:17:00', 176),
('Bank', 649.54, 'Completed', 'SIM-9B63CD5013', '2025-03-21 15:20:00', 177),
('Bank', 153.24, 'Completed', 'SIM-3303F4BCA2', '2026-06-02 08:22:00', 178),
('Bank', 218.98, 'Completed', 'SIM-E749FACF6F', '2025-09-05 12:03:00', 179),
('GCash', 2248.8, 'Completed', 'SIM-4F6BFAF168', '2026-01-18 11:26:00', 180),
('Bank', 359.79, 'Completed', 'SIM-32BE387B80', '2026-01-29 16:42:00', 181),
('Bank', 235.71, 'Completed', 'SIM-7DA1AEB133', '2026-06-05 21:21:00', 182),
('GCash', 502.69, 'Completed', 'SIM-E4798E7088', '2025-08-10 20:17:00', 183),
('Bank', 843.04, 'Completed', 'SIM-4BB65E602F', '2026-03-09 23:37:00', 184),
('Bank', 493.37, 'Completed', 'SIM-5179BF3AAA', '2025-02-23 17:50:00', 185),
('Bank', 2630.59, 'Completed', 'SIM-75DB5672A5', '2025-05-20 07:11:00', 186),
('Bank', 636.02, 'Completed', 'SIM-8AAEE56058', '2025-10-23 09:29:00', 187),
('Bank', 1836.45, 'Completed', 'SIM-BFC378442D', '2025-03-20 02:17:00', 188);

-- (Payments seeded: 162)

-- ------------------------------------------------------------
-- SHIPMENTS (insert-then-update so after_shipment_status_change fires)
-- ------------------------------------------------------------
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (2, 4, 'TRK1001', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-10 11:05:00' WHERE order_id=2;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=2;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=2;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (3, 4, 'TRK1002', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-29 08:37:00' WHERE order_id=3;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (5, 3, 'TRK1003', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-02 15:41:00' WHERE order_id=5;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (6, 1, 'TRK1004', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-13 11:49:00' WHERE order_id=6;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (8, 2, 'TRK1005', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-24 17:25:00' WHERE order_id=8;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=8;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=8;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (9, 4, 'TRK1006', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-05 03:04:00' WHERE order_id=9;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (11, 1, 'TRK1007', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-21 18:14:00' WHERE order_id=11;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (13, 4, 'TRK1008', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-17 10:40:00' WHERE order_id=13;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=13;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=13;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (14, 2, 'TRK1009', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-22 02:00:00' WHERE order_id=14;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=14;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=14;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (15, 3, 'TRK1010', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-16 00:04:00' WHERE order_id=15;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=15;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=15;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (16, 1, 'TRK1011', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-25 11:30:00' WHERE order_id=16;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=16;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=16;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (17, 4, 'TRK1012', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-21 08:00:00' WHERE order_id=17;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=17;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=17;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (18, 2, 'TRK1013', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-18 03:00:00' WHERE order_id=18;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (19, 4, 'TRK1014', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-08 18:31:00' WHERE order_id=19;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (20, 3, 'TRK1015', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-13 03:59:00' WHERE order_id=20;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=20;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=20;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (21, 1, 'TRK1016', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-02 15:03:00' WHERE order_id=21;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=21;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=21;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (22, 3, 'TRK1017', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-21 15:01:00' WHERE order_id=22;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=22;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=22;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (24, 4, 'TRK1018', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-05 09:07:00' WHERE order_id=24;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=24;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=24;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (25, 1, 'TRK1019', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-03 00:30:00' WHERE order_id=25;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=25;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=25;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (26, 4, 'TRK1020', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-31 14:49:00' WHERE order_id=26;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=26;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=26;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (27, 1, 'TRK1021', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-01 03:35:00' WHERE order_id=27;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=27;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=27;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (28, 1, 'TRK1022', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-07 15:20:00' WHERE order_id=28;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=28;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=28;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (29, 3, 'TRK1023', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-23 04:09:00' WHERE order_id=29;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (30, 2, 'TRK1024', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-13 15:23:00' WHERE order_id=30;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=30;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=30;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (31, 4, 'TRK1025', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-07 19:58:00' WHERE order_id=31;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=31;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (33, 2, 'TRK1026', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-24 15:46:00' WHERE order_id=33;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=33;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=33;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (34, 1, 'TRK1027', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-05 13:17:00' WHERE order_id=34;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=34;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (35, 1, 'TRK1028', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-06 18:58:00' WHERE order_id=35;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=35;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=35;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (36, 4, 'TRK1029', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-16 12:54:00' WHERE order_id=36;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=36;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=36;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (38, 3, 'TRK1030', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-25 17:46:00' WHERE order_id=38;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=38;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=38;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (39, 3, 'TRK1031', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-25 02:58:00' WHERE order_id=39;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=39;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=39;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (40, 1, 'TRK1032', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-24 21:27:00' WHERE order_id=40;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=40;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=40;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (41, 4, 'TRK1033', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-19 14:26:00' WHERE order_id=41;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=41;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=41;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (42, 3, 'TRK1034', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-21 03:03:00' WHERE order_id=42;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=42;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=42;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (43, 4, 'TRK1035', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-23 08:42:00' WHERE order_id=43;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=43;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=43;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (44, 4, 'TRK1036', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-01 13:08:00' WHERE order_id=44;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (45, 2, 'TRK1037', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-27 13:43:00' WHERE order_id=45;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=45;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (46, 1, 'TRK1038', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-16 01:31:00' WHERE order_id=46;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=46;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=46;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (47, 4, 'TRK1039', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-25 04:30:00' WHERE order_id=47;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=47;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=47;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (48, 1, 'TRK1040', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-11 06:59:00' WHERE order_id=48;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=48;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=48;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (49, 2, 'TRK1041', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-07 22:25:00' WHERE order_id=49;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=49;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=49;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (51, 3, 'TRK1042', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-25 16:22:00' WHERE order_id=51;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=51;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (52, 3, 'TRK1043', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-08 22:16:00' WHERE order_id=52;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=52;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=52;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (53, 3, 'TRK1044', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-30 01:41:00' WHERE order_id=53;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (54, 1, 'TRK1045', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-04 04:35:00' WHERE order_id=54;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=54;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=54;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (55, 4, 'TRK1046', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-11 00:52:00' WHERE order_id=55;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=55;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=55;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (58, 1, 'TRK1047', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-05 09:55:00' WHERE order_id=58;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=58;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=58;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (59, 2, 'TRK1048', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-25 20:31:00' WHERE order_id=59;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (60, 1, 'TRK1049', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-20 07:43:00' WHERE order_id=60;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=60;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=60;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (62, 4, 'TRK1050', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-23 13:26:00' WHERE order_id=62;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=62;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=62;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (64, 2, 'TRK1051', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-28 04:07:00' WHERE order_id=64;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=64;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=64;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (65, 4, 'TRK1052', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-21 13:28:00' WHERE order_id=65;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=65;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=65;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (67, 3, 'TRK1053', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-16 08:16:00' WHERE order_id=67;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (73, 4, 'TRK1054', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-25 22:26:00' WHERE order_id=73;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=73;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=73;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (74, 3, 'TRK1055', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-13 01:20:00' WHERE order_id=74;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=74;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=74;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (77, 3, 'TRK1056', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-12 16:22:00' WHERE order_id=77;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=77;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=77;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (78, 2, 'TRK1057', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-23 15:40:00' WHERE order_id=78;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=78;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=78;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (79, 3, 'TRK1058', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-24 00:03:00' WHERE order_id=79;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=79;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=79;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (80, 1, 'TRK1059', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-18 02:23:00' WHERE order_id=80;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (82, 4, 'TRK1060', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-01 13:10:00' WHERE order_id=82;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=82;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=82;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (83, 1, 'TRK1061', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-16 02:25:00' WHERE order_id=83;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=83;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=83;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (84, 4, 'TRK1062', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-30 09:39:00' WHERE order_id=84;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (85, 1, 'TRK1063', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-02 19:41:00' WHERE order_id=85;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=85;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=85;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (86, 3, 'TRK1064', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-26 02:01:00' WHERE order_id=86;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=86;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=86;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (88, 2, 'TRK1065', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-16 22:26:00' WHERE order_id=88;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=88;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=88;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (89, 2, 'TRK1066', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-16 20:55:00' WHERE order_id=89;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=89;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=89;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (94, 2, 'TRK1067', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-19 12:00:00' WHERE order_id=94;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=94;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=94;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (95, 4, 'TRK1068', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-06 09:38:00' WHERE order_id=95;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=95;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=95;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (96, 3, 'TRK1069', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-07 08:51:00' WHERE order_id=96;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=96;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=96;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (97, 3, 'TRK1070', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-26 07:35:00' WHERE order_id=97;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (98, 2, 'TRK1071', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-23 21:50:00' WHERE order_id=98;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=98;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=98;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (99, 2, 'TRK1072', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-12 04:51:00' WHERE order_id=99;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=99;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=99;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (100, 4, 'TRK1073', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-25 20:45:00' WHERE order_id=100;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=100;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (101, 4, 'TRK1074', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-07 23:59:00' WHERE order_id=101;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (102, 4, 'TRK1075', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-10 22:53:00' WHERE order_id=102;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=102;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=102;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (103, 3, 'TRK1076', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-02-07 17:34:00' WHERE order_id=103;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=103;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=103;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (104, 4, 'TRK1077', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-04 22:05:00' WHERE order_id=104;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=104;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=104;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (105, 1, 'TRK1078', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-07 03:25:00' WHERE order_id=105;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=105;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=105;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (106, 3, 'TRK1079', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-29 03:55:00' WHERE order_id=106;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=106;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=106;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (107, 2, 'TRK1080', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-02 22:39:00' WHERE order_id=107;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=107;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (108, 1, 'TRK1081', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-04 16:09:00' WHERE order_id=108;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=108;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (109, 1, 'TRK1082', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-25 04:36:00' WHERE order_id=109;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=109;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=109;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (110, 1, 'TRK1083', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-30 13:46:00' WHERE order_id=110;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=110;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=110;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (111, 1, 'TRK1084', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-04 10:27:00' WHERE order_id=111;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=111;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=111;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (113, 4, 'TRK1085', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-29 20:26:00' WHERE order_id=113;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (114, 1, 'TRK1086', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-01 08:51:00' WHERE order_id=114;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=114;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=114;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (115, 2, 'TRK1087', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-17 18:01:00' WHERE order_id=115;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=115;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=115;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (116, 4, 'TRK1088', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-29 04:02:00' WHERE order_id=116;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=116;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=116;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (118, 2, 'TRK1089', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-10 10:50:00' WHERE order_id=118;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=118;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=118;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (119, 1, 'TRK1090', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-10 11:20:00' WHERE order_id=119;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=119;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=119;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (121, 1, 'TRK1091', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-30 06:10:00' WHERE order_id=121;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (123, 2, 'TRK1092', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-07-14 04:37:00' WHERE order_id=123;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=123;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=123;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (124, 2, 'TRK1093', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-25 08:40:00' WHERE order_id=124;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (125, 1, 'TRK1094', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-22 08:46:00' WHERE order_id=125;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=125;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=125;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (126, 1, 'TRK1095', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-10 07:26:00' WHERE order_id=126;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=126;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=126;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (127, 2, 'TRK1096', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-07 20:16:00' WHERE order_id=127;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=127;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=127;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (128, 4, 'TRK1097', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-15 12:13:00' WHERE order_id=128;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=128;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=128;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (129, 1, 'TRK1098', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-06 00:15:00' WHERE order_id=129;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (130, 2, 'TRK1099', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-05 13:47:00' WHERE order_id=130;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=130;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=130;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (131, 2, 'TRK1100', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-27 21:07:00' WHERE order_id=131;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (132, 3, 'TRK1101', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-11 04:47:00' WHERE order_id=132;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=132;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=132;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (133, 4, 'TRK1102', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-05 09:27:00' WHERE order_id=133;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=133;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=133;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (134, 4, 'TRK1103', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-04-16 16:34:00' WHERE order_id=134;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=134;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=134;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (136, 2, 'TRK1104', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-23 14:51:00' WHERE order_id=136;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=136;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=136;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (137, 4, 'TRK1105', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-10 05:55:00' WHERE order_id=137;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=137;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=137;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (138, 4, 'TRK1106', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-18 16:37:00' WHERE order_id=138;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=138;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=138;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (139, 4, 'TRK1107', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-01-27 08:50:00' WHERE order_id=139;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=139;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=139;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (140, 2, 'TRK1108', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-24 20:43:00' WHERE order_id=140;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (141, 4, 'TRK1109', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-09 20:32:00' WHERE order_id=141;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=141;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=141;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (142, 2, 'TRK1110', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-02 15:36:00' WHERE order_id=142;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=142;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=142;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (144, 3, 'TRK1111', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-04-12 01:34:00' WHERE order_id=144;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=144;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=144;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (145, 3, 'TRK1112', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-26 01:46:00' WHERE order_id=145;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (148, 4, 'TRK1113', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-08 23:50:00' WHERE order_id=148;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=148;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=148;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (149, 2, 'TRK1114', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-13 16:42:00' WHERE order_id=149;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=149;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=149;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (150, 3, 'TRK1115', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-17 18:24:00' WHERE order_id=150;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=150;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=150;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (151, 3, 'TRK1116', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-06 01:01:00' WHERE order_id=151;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=151;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=151;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (152, 2, 'TRK1117', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-07 21:44:00' WHERE order_id=152;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=152;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=152;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (153, 4, 'TRK1118', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-04 14:43:00' WHERE order_id=153;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=153;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=153;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (154, 2, 'TRK1119', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-05-21 09:08:00' WHERE order_id=154;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=154;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=154;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (156, 4, 'TRK1120', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-05 20:47:00' WHERE order_id=156;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=156;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (157, 3, 'TRK1121', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-11-24 16:39:00' WHERE order_id=157;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=157;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=157;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (158, 4, 'TRK1122', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-14 01:29:00' WHERE order_id=158;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=158;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (161, 1, 'TRK1123', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-18 08:59:00' WHERE order_id=161;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=161;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (162, 4, 'TRK1124', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-15 12:20:00' WHERE order_id=162;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=162;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (164, 2, 'TRK1125', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-17 07:02:00' WHERE order_id=164;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=164;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=164;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (165, 3, 'TRK1126', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-25 14:47:00' WHERE order_id=165;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=165;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=165;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (168, 4, 'TRK1127', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-05 15:00:00' WHERE order_id=168;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=168;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=168;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (169, 1, 'TRK1128', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-20 05:46:00' WHERE order_id=169;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=169;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=169;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (170, 1, 'TRK1129', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-12-13 14:37:00' WHERE order_id=170;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (171, 4, 'TRK1130', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-07-19 10:34:00' WHERE order_id=171;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (172, 3, 'TRK1131', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-30 12:42:00' WHERE order_id=172;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=172;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=172;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (173, 4, 'TRK1132', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-06-06 15:52:00' WHERE order_id=173;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=173;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=173;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (174, 3, 'TRK1133', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-12 23:50:00' WHERE order_id=174;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=174;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (175, 2, 'TRK1134', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-07 07:59:00' WHERE order_id=175;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=175;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=175;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (176, 4, 'TRK1135', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-02-11 14:17:00' WHERE order_id=176;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=176;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=176;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (177, 3, 'TRK1136', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-22 06:20:00' WHERE order_id=177;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=177;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=177;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (178, 1, 'TRK1137', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-04 13:22:00' WHERE order_id=178;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=178;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (179, 2, 'TRK1138', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-09-06 21:03:00' WHERE order_id=179;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=179;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=179;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (180, 3, 'TRK1139', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-01-19 07:26:00' WHERE order_id=180;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=180;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=180;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (182, 2, 'TRK1140', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-06-08 09:21:00' WHERE order_id=182;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=182;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (183, 3, 'TRK1141', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-08-13 02:17:00' WHERE order_id=183;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=183;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (184, 1, 'TRK1142', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2026-03-12 00:37:00' WHERE order_id=184;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=184;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=184;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (186, 1, 'TRK1143', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-05-22 04:11:00' WHERE order_id=186;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=186;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=186;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (187, 3, 'TRK1144', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-10-24 03:29:00' WHERE order_id=187;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=187;
UPDATE SHIPMENTS SET status='Delivered' WHERE order_id=187;
INSERT INTO SHIPMENTS (order_id, courier_id, tracking_number, status) VALUES (188, 3, 'TRK1145', 'Preparing');
UPDATE SHIPMENTS SET status='Shipped', shipped_date='2025-03-20 19:17:00' WHERE order_id=188;
UPDATE SHIPMENTS SET status='Out for Delivery' WHERE order_id=188;
-- (Shipments progressed for 145 orders)

-- ------------------------------------------------------------
-- REVIEWS
-- ------------------------------------------------------------
INSERT INTO REVIEWS (buyer_id, seller_id, order_id, rating, review_text, review_date) VALUES
(1, 3, 2, 2, 'Decent but sizing ran a bit small.', '2026-02-12 08:05:00'),
(3, 5, 8, 5, 'Exceeded expectations, looks brand new.', '2026-02-27 18:25:00'),
(6, 4, 14, 5, 'Item was exactly as described, fast shipping too!', '2026-07-19 13:00:00'),
(3, 3, 15, 5, 'Seller was very responsive and packed it well.', '2025-03-01 11:04:00'),
(1, 5, 16, 3, 'Item was okay but took a while to arrive.', '2026-01-27 08:30:00'),
(6, 6, 20, 3, 'Item was okay but took a while to arrive.', '2026-06-01 05:59:00'),
(4, 5, 22, 4, 'Item was exactly as described, fast shipping too!', '2025-10-10 11:01:00'),
(1, 1, 24, 5, 'Exceeded expectations, looks brand new.', '2025-09-10 15:07:00'),
(8, 6, 25, 5, 'Great quality for the price, would buy again.', '2025-02-07 01:30:00'),
(3, 6, 26, 2, 'Slight wear not mentioned in the listing, otherwise fine.', '2026-04-12 05:49:00'),
(6, 1, 27, 5, 'Item was exactly as described, fast shipping too!', '2025-08-09 03:35:00'),
(6, 4, 28, 4, 'Great quality for the price, would buy again.', '2026-07-18 21:00:00'),
(8, 4, 35, 4, 'Item was exactly as described, fast shipping too!', '2025-05-10 06:58:00'),
(3, 3, 36, 5, 'Seller was very responsive and packed it well.', '2025-06-18 11:54:00'),
(6, 1, 38, 4, 'Great quality for the price, would buy again.', '2026-02-04 16:46:00'),
(5, 5, 39, 5, 'Item was exactly as described, fast shipping too!', '2025-10-27 22:58:00'),
(5, 4, 40, 2, 'Item was okay but took a while to arrive.', '2025-08-10 22:27:00'),
(1, 2, 47, 5, 'Seller was very responsive and packed it well.', '2025-10-13 10:30:00'),
(6, 4, 48, 4, 'Smooth transaction, item as pictured.', '2025-06-20 17:59:00'),
(5, 4, 49, 4, 'Item was exactly as described, fast shipping too!', '2026-02-10 01:25:00'),
(7, 3, 52, 5, 'Smooth transaction, item as pictured.', '2025-04-24 16:16:00'),
(7, 5, 54, 5, 'Great quality for the price, would buy again.', '2026-03-21 09:35:00'),
(7, 4, 55, 4, 'Great quality for the price, would buy again.', '2025-11-15 21:52:00'),
(2, 1, 58, 3, 'Item was okay but took a while to arrive.', '2026-04-07 23:55:00'),
(5, 3, 65, 5, 'Exceeded expectations, looks brand new.', '2026-02-23 11:28:00'),
(6, 6, 73, 4, 'Seller was very responsive and packed it well.', '2026-06-29 08:26:00'),
(2, 2, 74, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-10-29 17:20:00'),
(2, 6, 77, 5, 'Exceeded expectations, looks brand new.', '2026-07-15 07:22:00'),
(5, 1, 78, 5, 'Exceeded expectations, looks brand new.', '2026-02-10 01:40:00'),
(6, 1, 79, 5, 'Smooth transaction, item as pictured.', '2025-03-08 17:03:00'),
(5, 5, 86, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-05-02 09:01:00'),
(8, 2, 89, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-05-30 11:55:00'),
(3, 1, 104, 1, 'Decent but sizing ran a bit small.', '2025-03-19 18:05:00'),
(5, 5, 105, 4, 'Smooth transaction, item as pictured.', '2025-06-16 11:25:00'),
(1, 3, 106, 5, 'Great quality for the price, would buy again.', '2025-05-04 06:55:00'),
(3, 2, 110, 4, 'Seller was very responsive and packed it well.', '2025-11-03 19:46:00'),
(7, 4, 115, 4, 'Item was exactly as described, fast shipping too!', '2025-02-26 17:01:00'),
(5, 6, 116, 4, 'Smooth transaction, item as pictured.', '2025-07-01 01:02:00'),
(7, 1, 118, 4, 'Seller was very responsive and packed it well.', '2025-03-19 07:50:00'),
(8, 4, 123, 5, 'Item was exactly as described, fast shipping too!', '2026-07-19 13:00:00'),
(1, 2, 126, 3, 'Item was okay but took a while to arrive.', '2025-10-24 12:26:00'),
(3, 6, 127, 2, 'Slight wear not mentioned in the listing, otherwise fine.', '2026-06-25 14:16:00'),
(3, 3, 128, 5, 'Great quality for the price, would buy again.', '2025-08-25 04:13:00'),
(7, 5, 132, 3, 'Item was okay but took a while to arrive.', '2026-06-19 01:47:00'),
(3, 4, 134, 4, 'Item was exactly as described, fast shipping too!', '2025-04-25 08:34:00'),
(5, 3, 136, 5, 'Smooth transaction, item as pictured.', '2025-11-08 16:51:00'),
(3, 1, 138, 4, 'Item was exactly as described, fast shipping too!', '2026-05-28 15:37:00'),
(1, 3, 141, 3, 'Slight wear not mentioned in the listing, otherwise fine.', '2026-04-27 22:32:00'),
(7, 2, 148, 5, 'Exceeded expectations, looks brand new.', '2025-12-12 20:50:00'),
(3, 2, 149, 5, 'Seller was very responsive and packed it well.', '2025-12-24 20:42:00'),
(6, 1, 152, 5, 'Seller was very responsive and packed it well.', '2026-03-13 16:44:00'),
(8, 6, 153, 4, 'Seller was very responsive and packed it well.', '2025-06-15 10:43:00'),
(6, 6, 164, 2, 'Slight wear not mentioned in the listing, otherwise fine.', '2025-08-18 23:02:00'),
(6, 1, 165, 5, 'Great quality for the price, would buy again.', '2026-01-27 06:47:00'),
(5, 5, 168, 5, 'Seller was very responsive and packed it well.', '2025-12-22 12:00:00'),
(2, 1, 177, 4, 'Great quality for the price, would buy again.', '2025-04-05 09:20:00');

-- (Reviews seeded: 56)

-- ------------------------------------------------------------
-- DISPUTES
-- ------------------------------------------------------------
INSERT INTO DISPUTES (order_id, buyer_id, seller_id, reason, opened_at) VALUES
(13, 3, 6, 'Item misrepresented in listing #1, condition did not match photos.', '2025-09-28 15:00:00'),
(20, 6, 6, 'Item misrepresented in listing #2, condition did not match photos.', '2025-10-30 15:00:00'),
(25, 8, 6, 'Item misrepresented in listing #3, condition did not match photos.', '2025-09-23 15:00:00'),
(176, 1, 5, 'Item arrived with a small tear not disclosed in the listing.', '2026-06-23 15:00:00'),
(139, 8, 3, 'Wrong item color received.', '2026-03-29 15:00:00'),
(31, 6, 1, 'Package arrived significantly later than expected.', '2025-12-06 15:00:00'),
(181, 6, 2, 'Item does not match the size listed.', '2025-10-22 15:00:00'),
(158, 6, 4, 'Missing accessory that was shown in listing photos.', '2026-02-22 15:00:00'),
(172, 2, 2, 'Item smells strongly of smoke, not mentioned in description.', '2025-09-23 15:00:00'),
(55, 7, 4, 'Buyer claims item was never received despite tracking showing delivered.', '2026-02-04 15:00:00'),
(56, 2, 2, 'Seller sent a different item than what was ordered.', '2026-05-25 15:00:00'),
(48, 6, 4, 'Authenticity of branded item is in question.', '2026-01-18 15:00:00'),
(145, 2, 3, 'Buyer requesting refund due to change of mind (outside policy).', '2026-02-19 15:00:00'),
(24, 1, 1, 'Item arrived with visible stains not shown in photos.', '2026-04-21 15:00:00');

-- Resolve/reject the seeded disputes via UPDATE so status-change triggers fire correctly
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2025-09-30 15:00:00' WHERE dispute_id=1;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2025-11-04 15:00:00' WHERE dispute_id=2;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2025-10-01 15:00:00' WHERE dispute_id=3;
UPDATE DISPUTES SET status='Under Review', assigned_admin_id=2 WHERE dispute_id=5;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2025-12-16 15:00:00' WHERE dispute_id=6;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2025-10-27 15:00:00' WHERE dispute_id=7;
UPDATE DISPUTES SET status='Rejected', assigned_admin_id=1, resolved_at='2026-02-26 15:00:00' WHERE dispute_id=8;
UPDATE DISPUTES SET status='Under Review', assigned_admin_id=1 WHERE dispute_id=10;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=1, resolved_at='2026-06-03 15:00:00' WHERE dispute_id=11;
UPDATE DISPUTES SET status='Rejected', assigned_admin_id=1, resolved_at='2026-01-26 15:00:00' WHERE dispute_id=12;
UPDATE DISPUTES SET status='Resolved', resolution_type='Full Refund', assigned_admin_id=2, resolved_at='2026-02-25 15:00:00' WHERE dispute_id=13;
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
(219, 5, 3, 'Photos look reused from another online marketplace listing.', 'Pending'),
(228, 2, 2, 'Price is suspiciously below market value for this brand.', 'Pending'),
(267, 3, 3, 'Buyer reports item never matched the description.', 'Pending'),
(65, 5, 6, 'Multiple reports of delayed responses from this seller.', 'Reviewed'),
(233, 2, 5, 'Listing may be duplicated across two accounts.', 'Reviewed'),
(152, 6, 6, 'Suspected counterfeit branded item, no verifiable serial number.', 'Resolved'),
(57, 2, 1, 'Same product photos found on an unrelated resale site.', 'Resolved'),
(62, 4, 4, 'Buyer flagged seller for requesting off-platform payment.', 'Pending'),
(222, 2, 2, 'Listing description copied from another seller\'s item.', 'Reviewed'),
(253, 6, 3, 'Unusual bidding pattern detected (possible shill bidding).', 'Pending');

-- ------------------------------------------------------------
-- CURRENCY_RATES (seed cache)
-- ------------------------------------------------------------
INSERT INTO CURRENCY_RATES (base_currency, target_currency, exchange_rate, recorded_date) VALUES
('PHP','USD',0.0175, CURDATE()),
('PHP','KRW',23.50,  CURDATE());

-- ------------------------------------------------------------
-- LISTING_ANALYTICS, fill in realistic variation on top of the trigger-seeded baseline
-- ------------------------------------------------------------
UPDATE LISTING_ANALYTICS SET view_count=165, follower_count=8357, details_score=60.12, condition_score=72.67, shipping_score=81.49, pricing_score=80.32, view_to_bid_score=3.02, completeness_score=ROUND((IFNULL(photo_score,60)+60.12+72.67+81.49+80.32)/5,2) WHERE listing_id=1;
UPDATE LISTING_ANALYTICS SET view_count=709, follower_count=5207, details_score=93.54, condition_score=51.92, shipping_score=37.03, pricing_score=82.31, view_to_bid_score=12.19, completeness_score=ROUND((IFNULL(photo_score,60)+93.54+51.92+37.03+82.31)/5,2) WHERE listing_id=2;
UPDATE LISTING_ANALYTICS SET view_count=199, follower_count=9195, details_score=79.67, condition_score=93.88, shipping_score=32.49, pricing_score=78.07, view_to_bid_score=1.66, completeness_score=ROUND((IFNULL(photo_score,60)+79.67+93.88+32.49+78.07)/5,2) WHERE listing_id=3;
UPDATE LISTING_ANALYTICS SET view_count=145, follower_count=9656, details_score=62.57, condition_score=97.16, shipping_score=77.13, pricing_score=55.92, view_to_bid_score=4.6, completeness_score=ROUND((IFNULL(photo_score,60)+62.57+97.16+77.13+55.92)/5,2) WHERE listing_id=4;
UPDATE LISTING_ANALYTICS SET view_count=196, follower_count=8188, details_score=56.96, condition_score=59.93, shipping_score=91.31, pricing_score=97.05, view_to_bid_score=19.07, completeness_score=ROUND((IFNULL(photo_score,60)+56.96+59.93+91.31+97.05)/5,2) WHERE listing_id=5;
UPDATE LISTING_ANALYTICS SET view_count=772, follower_count=3559, details_score=40.19, condition_score=53.36, shipping_score=69.04, pricing_score=52.51, view_to_bid_score=5.15, completeness_score=ROUND((IFNULL(photo_score,60)+40.19+53.36+69.04+52.51)/5,2) WHERE listing_id=6;
UPDATE LISTING_ANALYTICS SET view_count=433, follower_count=11321, details_score=55.78, condition_score=69.01, shipping_score=70.87, pricing_score=78.26, view_to_bid_score=11.43, completeness_score=ROUND((IFNULL(photo_score,60)+55.78+69.01+70.87+78.26)/5,2) WHERE listing_id=7;
UPDATE LISTING_ANALYTICS SET view_count=677, follower_count=3000, details_score=92.67, condition_score=92.03, shipping_score=91.25, pricing_score=80.08, view_to_bid_score=11.55, completeness_score=ROUND((IFNULL(photo_score,60)+92.67+92.03+91.25+80.08)/5,2) WHERE listing_id=8;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=6475, details_score=75.87, condition_score=77.17, shipping_score=50.68, pricing_score=53.14, view_to_bid_score=21.24, completeness_score=ROUND((IFNULL(photo_score,60)+75.87+77.17+50.68+53.14)/5,2) WHERE listing_id=9;
UPDATE LISTING_ANALYTICS SET view_count=778, follower_count=4756, details_score=65.18, condition_score=72.36, shipping_score=47.32, pricing_score=65.49, view_to_bid_score=5.11, completeness_score=ROUND((IFNULL(photo_score,60)+65.18+72.36+47.32+65.49)/5,2) WHERE listing_id=10;
UPDATE LISTING_ANALYTICS SET view_count=331, follower_count=10873, details_score=46.81, condition_score=84.85, shipping_score=79.34, pricing_score=86.42, view_to_bid_score=11.42, completeness_score=ROUND((IFNULL(photo_score,60)+46.81+84.85+79.34+86.42)/5,2) WHERE listing_id=11;
UPDATE LISTING_ANALYTICS SET view_count=505, follower_count=9897, details_score=64.72, condition_score=61.74, shipping_score=50.37, pricing_score=70.45, view_to_bid_score=19.74, completeness_score=ROUND((IFNULL(photo_score,60)+64.72+61.74+50.37+70.45)/5,2) WHERE listing_id=12;
UPDATE LISTING_ANALYTICS SET view_count=423, follower_count=1046, details_score=73.74, condition_score=66.16, shipping_score=77.25, pricing_score=64.67, view_to_bid_score=18.09, completeness_score=ROUND((IFNULL(photo_score,60)+73.74+66.16+77.25+64.67)/5,2) WHERE listing_id=13;
UPDATE LISTING_ANALYTICS SET view_count=440, follower_count=6581, details_score=55.64, condition_score=52.73, shipping_score=63.99, pricing_score=53.14, view_to_bid_score=14.54, completeness_score=ROUND((IFNULL(photo_score,60)+55.64+52.73+63.99+53.14)/5,2) WHERE listing_id=14;
UPDATE LISTING_ANALYTICS SET view_count=51, follower_count=5104, details_score=66.86, condition_score=61.07, shipping_score=91.29, pricing_score=72.16, view_to_bid_score=17.48, completeness_score=ROUND((IFNULL(photo_score,60)+66.86+61.07+91.29+72.16)/5,2) WHERE listing_id=15;
UPDATE LISTING_ANALYTICS SET view_count=117, follower_count=10098, details_score=76.65, condition_score=56.46, shipping_score=67.78, pricing_score=97.02, view_to_bid_score=1.93, completeness_score=ROUND((IFNULL(photo_score,60)+76.65+56.46+67.78+97.02)/5,2) WHERE listing_id=16;
UPDATE LISTING_ANALYTICS SET view_count=393, follower_count=1528, details_score=86.83, condition_score=66.66, shipping_score=54.69, pricing_score=85.96, view_to_bid_score=2.8, completeness_score=ROUND((IFNULL(photo_score,60)+86.83+66.66+54.69+85.96)/5,2) WHERE listing_id=17;
UPDATE LISTING_ANALYTICS SET view_count=55, follower_count=8547, details_score=52.63, condition_score=76.77, shipping_score=98.97, pricing_score=90.29, view_to_bid_score=9.61, completeness_score=ROUND((IFNULL(photo_score,60)+52.63+76.77+98.97+90.29)/5,2) WHERE listing_id=18;
UPDATE LISTING_ANALYTICS SET view_count=740, follower_count=3807, details_score=57.41, condition_score=58.07, shipping_score=56.17, pricing_score=64.8, view_to_bid_score=12.84, completeness_score=ROUND((IFNULL(photo_score,60)+57.41+58.07+56.17+64.8)/5,2) WHERE listing_id=19;
UPDATE LISTING_ANALYTICS SET view_count=259, follower_count=273, details_score=42.16, condition_score=51.0, shipping_score=95.82, pricing_score=46.15, view_to_bid_score=9.66, completeness_score=ROUND((IFNULL(photo_score,60)+42.16+51.0+95.82+46.15)/5,2) WHERE listing_id=20;
UPDATE LISTING_ANALYTICS SET view_count=501, follower_count=742, details_score=49.42, condition_score=65.07, shipping_score=46.1, pricing_score=86.34, view_to_bid_score=6.57, completeness_score=ROUND((IFNULL(photo_score,60)+49.42+65.07+46.1+86.34)/5,2) WHERE listing_id=21;
UPDATE LISTING_ANALYTICS SET view_count=283, follower_count=2075, details_score=88.78, condition_score=68.89, shipping_score=58.05, pricing_score=89.1, view_to_bid_score=19.47, completeness_score=ROUND((IFNULL(photo_score,60)+88.78+68.89+58.05+89.1)/5,2) WHERE listing_id=22;
UPDATE LISTING_ANALYTICS SET view_count=91, follower_count=1303, details_score=44.43, condition_score=86.11, shipping_score=83.37, pricing_score=64.92, view_to_bid_score=1.8, completeness_score=ROUND((IFNULL(photo_score,60)+44.43+86.11+83.37+64.92)/5,2) WHERE listing_id=23;
UPDATE LISTING_ANALYTICS SET view_count=559, follower_count=9960, details_score=95.14, condition_score=54.78, shipping_score=71.17, pricing_score=63.47, view_to_bid_score=18.55, completeness_score=ROUND((IFNULL(photo_score,60)+95.14+54.78+71.17+63.47)/5,2) WHERE listing_id=24;
UPDATE LISTING_ANALYTICS SET view_count=324, follower_count=5353, details_score=65.51, condition_score=87.17, shipping_score=51.15, pricing_score=67.53, view_to_bid_score=3.54, completeness_score=ROUND((IFNULL(photo_score,60)+65.51+87.17+51.15+67.53)/5,2) WHERE listing_id=25;
UPDATE LISTING_ANALYTICS SET view_count=676, follower_count=9490, details_score=68.28, condition_score=64.56, shipping_score=36.51, pricing_score=98.01, view_to_bid_score=13.0, completeness_score=ROUND((IFNULL(photo_score,60)+68.28+64.56+36.51+98.01)/5,2) WHERE listing_id=26;
UPDATE LISTING_ANALYTICS SET view_count=499, follower_count=4709, details_score=94.46, condition_score=76.66, shipping_score=47.12, pricing_score=41.03, view_to_bid_score=11.69, completeness_score=ROUND((IFNULL(photo_score,60)+94.46+76.66+47.12+41.03)/5,2) WHERE listing_id=27;
UPDATE LISTING_ANALYTICS SET view_count=408, follower_count=6156, details_score=85.76, condition_score=85.73, shipping_score=61.66, pricing_score=74.67, view_to_bid_score=2.01, completeness_score=ROUND((IFNULL(photo_score,60)+85.76+85.73+61.66+74.67)/5,2) WHERE listing_id=28;
UPDATE LISTING_ANALYTICS SET view_count=794, follower_count=3852, details_score=66.83, condition_score=73.84, shipping_score=37.63, pricing_score=58.64, view_to_bid_score=4.45, completeness_score=ROUND((IFNULL(photo_score,60)+66.83+73.84+37.63+58.64)/5,2) WHERE listing_id=29;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=1420, details_score=45.72, condition_score=58.46, shipping_score=90.54, pricing_score=69.39, view_to_bid_score=6.62, completeness_score=ROUND((IFNULL(photo_score,60)+45.72+58.46+90.54+69.39)/5,2) WHERE listing_id=30;
UPDATE LISTING_ANALYTICS SET view_count=149, follower_count=6655, details_score=76.99, condition_score=73.68, shipping_score=80.61, pricing_score=74.0, view_to_bid_score=6.26, completeness_score=ROUND((IFNULL(photo_score,60)+76.99+73.68+80.61+74.0)/5,2) WHERE listing_id=31;
UPDATE LISTING_ANALYTICS SET view_count=790, follower_count=8134, details_score=55.12, condition_score=65.57, shipping_score=53.65, pricing_score=49.04, view_to_bid_score=8.09, completeness_score=ROUND((IFNULL(photo_score,60)+55.12+65.57+53.65+49.04)/5,2) WHERE listing_id=32;
UPDATE LISTING_ANALYTICS SET view_count=583, follower_count=9859, details_score=64.39, condition_score=50.28, shipping_score=78.33, pricing_score=85.3, view_to_bid_score=17.79, completeness_score=ROUND((IFNULL(photo_score,60)+64.39+50.28+78.33+85.3)/5,2) WHERE listing_id=33;
UPDATE LISTING_ANALYTICS SET view_count=563, follower_count=8238, details_score=58.78, condition_score=82.6, shipping_score=52.53, pricing_score=82.53, view_to_bid_score=12.05, completeness_score=ROUND((IFNULL(photo_score,60)+58.78+82.6+52.53+82.53)/5,2) WHERE listing_id=34;
UPDATE LISTING_ANALYTICS SET view_count=762, follower_count=1384, details_score=95.27, condition_score=71.29, shipping_score=35.43, pricing_score=47.64, view_to_bid_score=1.78, completeness_score=ROUND((IFNULL(photo_score,60)+95.27+71.29+35.43+47.64)/5,2) WHERE listing_id=35;
UPDATE LISTING_ANALYTICS SET view_count=537, follower_count=2040, details_score=49.97, condition_score=71.88, shipping_score=98.03, pricing_score=42.34, view_to_bid_score=10.2, completeness_score=ROUND((IFNULL(photo_score,60)+49.97+71.88+98.03+42.34)/5,2) WHERE listing_id=36;
UPDATE LISTING_ANALYTICS SET view_count=179, follower_count=10309, details_score=88.19, condition_score=74.36, shipping_score=82.43, pricing_score=72.83, view_to_bid_score=9.69, completeness_score=ROUND((IFNULL(photo_score,60)+88.19+74.36+82.43+72.83)/5,2) WHERE listing_id=37;
UPDATE LISTING_ANALYTICS SET view_count=308, follower_count=1976, details_score=66.13, condition_score=64.71, shipping_score=94.54, pricing_score=80.6, view_to_bid_score=12.21, completeness_score=ROUND((IFNULL(photo_score,60)+66.13+64.71+94.54+80.6)/5,2) WHERE listing_id=38;
UPDATE LISTING_ANALYTICS SET view_count=634, follower_count=6138, details_score=73.83, condition_score=58.3, shipping_score=50.31, pricing_score=81.1, view_to_bid_score=17.96, completeness_score=ROUND((IFNULL(photo_score,60)+73.83+58.3+50.31+81.1)/5,2) WHERE listing_id=39;
UPDATE LISTING_ANALYTICS SET view_count=736, follower_count=6132, details_score=71.16, condition_score=62.56, shipping_score=62.4, pricing_score=96.17, view_to_bid_score=20.51, completeness_score=ROUND((IFNULL(photo_score,60)+71.16+62.56+62.4+96.17)/5,2) WHERE listing_id=40;
UPDATE LISTING_ANALYTICS SET view_count=742, follower_count=2267, details_score=49.85, condition_score=85.75, shipping_score=63.17, pricing_score=59.06, view_to_bid_score=5.17, completeness_score=ROUND((IFNULL(photo_score,60)+49.85+85.75+63.17+59.06)/5,2) WHERE listing_id=41;
UPDATE LISTING_ANALYTICS SET view_count=486, follower_count=1148, details_score=99.6, condition_score=50.28, shipping_score=79.1, pricing_score=51.96, view_to_bid_score=3.42, completeness_score=ROUND((IFNULL(photo_score,60)+99.6+50.28+79.1+51.96)/5,2) WHERE listing_id=42;
UPDATE LISTING_ANALYTICS SET view_count=474, follower_count=5473, details_score=45.68, condition_score=81.25, shipping_score=71.61, pricing_score=44.01, view_to_bid_score=14.55, completeness_score=ROUND((IFNULL(photo_score,60)+45.68+81.25+71.61+44.01)/5,2) WHERE listing_id=43;
UPDATE LISTING_ANALYTICS SET view_count=236, follower_count=5701, details_score=77.73, condition_score=96.39, shipping_score=49.22, pricing_score=89.25, view_to_bid_score=19.3, completeness_score=ROUND((IFNULL(photo_score,60)+77.73+96.39+49.22+89.25)/5,2) WHERE listing_id=44;
UPDATE LISTING_ANALYTICS SET view_count=603, follower_count=11999, details_score=58.35, condition_score=81.23, shipping_score=58.23, pricing_score=55.28, view_to_bid_score=12.59, completeness_score=ROUND((IFNULL(photo_score,60)+58.35+81.23+58.23+55.28)/5,2) WHERE listing_id=45;
UPDATE LISTING_ANALYTICS SET view_count=680, follower_count=3369, details_score=44.65, condition_score=57.62, shipping_score=81.15, pricing_score=56.8, view_to_bid_score=6.89, completeness_score=ROUND((IFNULL(photo_score,60)+44.65+57.62+81.15+56.8)/5,2) WHERE listing_id=46;
UPDATE LISTING_ANALYTICS SET view_count=109, follower_count=2125, details_score=87.81, condition_score=79.37, shipping_score=83.62, pricing_score=59.81, view_to_bid_score=17.33, completeness_score=ROUND((IFNULL(photo_score,60)+87.81+79.37+83.62+59.81)/5,2) WHERE listing_id=47;
UPDATE LISTING_ANALYTICS SET view_count=611, follower_count=9958, details_score=56.63, condition_score=90.36, shipping_score=90.99, pricing_score=80.11, view_to_bid_score=11.2, completeness_score=ROUND((IFNULL(photo_score,60)+56.63+90.36+90.99+80.11)/5,2) WHERE listing_id=48;
UPDATE LISTING_ANALYTICS SET view_count=177, follower_count=93, details_score=87.0, condition_score=99.45, shipping_score=36.39, pricing_score=88.2, view_to_bid_score=4.5, completeness_score=ROUND((IFNULL(photo_score,60)+87.0+99.45+36.39+88.2)/5,2) WHERE listing_id=49;
UPDATE LISTING_ANALYTICS SET view_count=173, follower_count=7840, details_score=92.48, condition_score=66.17, shipping_score=92.72, pricing_score=43.13, view_to_bid_score=11.99, completeness_score=ROUND((IFNULL(photo_score,60)+92.48+66.17+92.72+43.13)/5,2) WHERE listing_id=50;
UPDATE LISTING_ANALYTICS SET view_count=455, follower_count=7019, details_score=79.89, condition_score=66.35, shipping_score=65.03, pricing_score=47.04, view_to_bid_score=12.98, completeness_score=ROUND((IFNULL(photo_score,60)+79.89+66.35+65.03+47.04)/5,2) WHERE listing_id=51;
UPDATE LISTING_ANALYTICS SET view_count=391, follower_count=6366, details_score=82.37, condition_score=67.75, shipping_score=88.71, pricing_score=59.02, view_to_bid_score=3.1, completeness_score=ROUND((IFNULL(photo_score,60)+82.37+67.75+88.71+59.02)/5,2) WHERE listing_id=52;
UPDATE LISTING_ANALYTICS SET view_count=624, follower_count=3554, details_score=97.32, condition_score=97.27, shipping_score=88.35, pricing_score=82.68, view_to_bid_score=18.72, completeness_score=ROUND((IFNULL(photo_score,60)+97.32+97.27+88.35+82.68)/5,2) WHERE listing_id=53;
UPDATE LISTING_ANALYTICS SET view_count=578, follower_count=7285, details_score=69.41, condition_score=89.45, shipping_score=77.98, pricing_score=73.47, view_to_bid_score=10.43, completeness_score=ROUND((IFNULL(photo_score,60)+69.41+89.45+77.98+73.47)/5,2) WHERE listing_id=54;
UPDATE LISTING_ANALYTICS SET view_count=361, follower_count=2966, details_score=41.52, condition_score=68.28, shipping_score=62.63, pricing_score=80.2, view_to_bid_score=16.43, completeness_score=ROUND((IFNULL(photo_score,60)+41.52+68.28+62.63+80.2)/5,2) WHERE listing_id=55;
UPDATE LISTING_ANALYTICS SET view_count=223, follower_count=10158, details_score=73.59, condition_score=99.9, shipping_score=95.76, pricing_score=62.95, view_to_bid_score=5.17, completeness_score=ROUND((IFNULL(photo_score,60)+73.59+99.9+95.76+62.95)/5,2) WHERE listing_id=56;
UPDATE LISTING_ANALYTICS SET view_count=770, follower_count=224, details_score=51.75, condition_score=68.05, shipping_score=43.64, pricing_score=75.17, view_to_bid_score=8.23, completeness_score=ROUND((IFNULL(photo_score,60)+51.75+68.05+43.64+75.17)/5,2) WHERE listing_id=57;
UPDATE LISTING_ANALYTICS SET view_count=382, follower_count=4207, details_score=70.17, condition_score=50.65, shipping_score=49.11, pricing_score=78.83, view_to_bid_score=14.65, completeness_score=ROUND((IFNULL(photo_score,60)+70.17+50.65+49.11+78.83)/5,2) WHERE listing_id=58;
UPDATE LISTING_ANALYTICS SET view_count=412, follower_count=769, details_score=99.74, condition_score=85.21, shipping_score=49.19, pricing_score=43.43, view_to_bid_score=13.23, completeness_score=ROUND((IFNULL(photo_score,60)+99.74+85.21+49.19+43.43)/5,2) WHERE listing_id=59;
UPDATE LISTING_ANALYTICS SET view_count=36, follower_count=11814, details_score=95.65, condition_score=99.86, shipping_score=74.26, pricing_score=69.42, view_to_bid_score=11.21, completeness_score=ROUND((IFNULL(photo_score,60)+95.65+99.86+74.26+69.42)/5,2) WHERE listing_id=60;
UPDATE LISTING_ANALYTICS SET view_count=668, follower_count=8988, details_score=88.45, condition_score=51.91, shipping_score=32.02, pricing_score=93.66, view_to_bid_score=4.64, completeness_score=ROUND((IFNULL(photo_score,60)+88.45+51.91+32.02+93.66)/5,2) WHERE listing_id=61;
UPDATE LISTING_ANALYTICS SET view_count=758, follower_count=2948, details_score=92.25, condition_score=56.58, shipping_score=59.37, pricing_score=90.75, view_to_bid_score=2.65, completeness_score=ROUND((IFNULL(photo_score,60)+92.25+56.58+59.37+90.75)/5,2) WHERE listing_id=62;
UPDATE LISTING_ANALYTICS SET view_count=657, follower_count=11692, details_score=43.74, condition_score=54.87, shipping_score=68.09, pricing_score=99.0, view_to_bid_score=5.48, completeness_score=ROUND((IFNULL(photo_score,60)+43.74+54.87+68.09+99.0)/5,2) WHERE listing_id=63;
UPDATE LISTING_ANALYTICS SET view_count=633, follower_count=323, details_score=59.96, condition_score=83.6, shipping_score=92.98, pricing_score=93.86, view_to_bid_score=4.97, completeness_score=ROUND((IFNULL(photo_score,60)+59.96+83.6+92.98+93.86)/5,2) WHERE listing_id=64;
UPDATE LISTING_ANALYTICS SET view_count=605, follower_count=11881, details_score=96.66, condition_score=75.82, shipping_score=95.84, pricing_score=64.19, view_to_bid_score=18.67, completeness_score=ROUND((IFNULL(photo_score,60)+96.66+75.82+95.84+64.19)/5,2) WHERE listing_id=65;
UPDATE LISTING_ANALYTICS SET view_count=690, follower_count=1057, details_score=43.9, condition_score=91.25, shipping_score=65.11, pricing_score=83.74, view_to_bid_score=3.22, completeness_score=ROUND((IFNULL(photo_score,60)+43.9+91.25+65.11+83.74)/5,2) WHERE listing_id=66;
UPDATE LISTING_ANALYTICS SET view_count=459, follower_count=779, details_score=56.53, condition_score=59.93, shipping_score=65.38, pricing_score=50.38, view_to_bid_score=16.81, completeness_score=ROUND((IFNULL(photo_score,60)+56.53+59.93+65.38+50.38)/5,2) WHERE listing_id=67;
UPDATE LISTING_ANALYTICS SET view_count=8, follower_count=5148, details_score=56.43, condition_score=67.53, shipping_score=53.9, pricing_score=74.09, view_to_bid_score=15.77, completeness_score=ROUND((IFNULL(photo_score,60)+56.43+67.53+53.9+74.09)/5,2) WHERE listing_id=68;
UPDATE LISTING_ANALYTICS SET view_count=584, follower_count=7635, details_score=45.29, condition_score=95.9, shipping_score=42.78, pricing_score=45.19, view_to_bid_score=8.01, completeness_score=ROUND((IFNULL(photo_score,60)+45.29+95.9+42.78+45.19)/5,2) WHERE listing_id=69;
UPDATE LISTING_ANALYTICS SET view_count=646, follower_count=379, details_score=86.0, condition_score=89.44, shipping_score=45.23, pricing_score=62.47, view_to_bid_score=3.17, completeness_score=ROUND((IFNULL(photo_score,60)+86.0+89.44+45.23+62.47)/5,2) WHERE listing_id=70;
UPDATE LISTING_ANALYTICS SET view_count=746, follower_count=4092, details_score=58.47, condition_score=84.04, shipping_score=95.99, pricing_score=91.88, view_to_bid_score=16.82, completeness_score=ROUND((IFNULL(photo_score,60)+58.47+84.04+95.99+91.88)/5,2) WHERE listing_id=71;
UPDATE LISTING_ANALYTICS SET view_count=760, follower_count=2224, details_score=58.63, condition_score=68.97, shipping_score=50.1, pricing_score=56.74, view_to_bid_score=13.08, completeness_score=ROUND((IFNULL(photo_score,60)+58.63+68.97+50.1+56.74)/5,2) WHERE listing_id=72;
UPDATE LISTING_ANALYTICS SET view_count=428, follower_count=3752, details_score=90.12, condition_score=63.64, shipping_score=43.95, pricing_score=98.76, view_to_bid_score=6.82, completeness_score=ROUND((IFNULL(photo_score,60)+90.12+63.64+43.95+98.76)/5,2) WHERE listing_id=73;
UPDATE LISTING_ANALYTICS SET view_count=455, follower_count=4384, details_score=45.54, condition_score=67.76, shipping_score=55.45, pricing_score=86.34, view_to_bid_score=12.22, completeness_score=ROUND((IFNULL(photo_score,60)+45.54+67.76+55.45+86.34)/5,2) WHERE listing_id=74;
UPDATE LISTING_ANALYTICS SET view_count=651, follower_count=11306, details_score=89.9, condition_score=51.84, shipping_score=88.43, pricing_score=63.14, view_to_bid_score=12.53, completeness_score=ROUND((IFNULL(photo_score,60)+89.9+51.84+88.43+63.14)/5,2) WHERE listing_id=75;
UPDATE LISTING_ANALYTICS SET view_count=220, follower_count=11554, details_score=66.03, condition_score=82.3, shipping_score=77.74, pricing_score=57.32, view_to_bid_score=8.51, completeness_score=ROUND((IFNULL(photo_score,60)+66.03+82.3+77.74+57.32)/5,2) WHERE listing_id=76;
UPDATE LISTING_ANALYTICS SET view_count=520, follower_count=9087, details_score=89.79, condition_score=89.71, shipping_score=36.35, pricing_score=86.4, view_to_bid_score=6.79, completeness_score=ROUND((IFNULL(photo_score,60)+89.79+89.71+36.35+86.4)/5,2) WHERE listing_id=77;
UPDATE LISTING_ANALYTICS SET view_count=483, follower_count=4323, details_score=41.89, condition_score=55.76, shipping_score=76.08, pricing_score=51.19, view_to_bid_score=4.37, completeness_score=ROUND((IFNULL(photo_score,60)+41.89+55.76+76.08+51.19)/5,2) WHERE listing_id=78;
UPDATE LISTING_ANALYTICS SET view_count=605, follower_count=5341, details_score=62.34, condition_score=68.9, shipping_score=71.19, pricing_score=42.03, view_to_bid_score=15.88, completeness_score=ROUND((IFNULL(photo_score,60)+62.34+68.9+71.19+42.03)/5,2) WHERE listing_id=79;
UPDATE LISTING_ANALYTICS SET view_count=649, follower_count=5929, details_score=92.16, condition_score=50.39, shipping_score=59.5, pricing_score=60.08, view_to_bid_score=14.78, completeness_score=ROUND((IFNULL(photo_score,60)+92.16+50.39+59.5+60.08)/5,2) WHERE listing_id=80;
UPDATE LISTING_ANALYTICS SET view_count=107, follower_count=3115, details_score=94.79, condition_score=65.31, shipping_score=62.68, pricing_score=51.17, view_to_bid_score=1.95, completeness_score=ROUND((IFNULL(photo_score,60)+94.79+65.31+62.68+51.17)/5,2) WHERE listing_id=81;
UPDATE LISTING_ANALYTICS SET view_count=636, follower_count=7528, details_score=75.61, condition_score=84.72, shipping_score=81.17, pricing_score=68.41, view_to_bid_score=6.49, completeness_score=ROUND((IFNULL(photo_score,60)+75.61+84.72+81.17+68.41)/5,2) WHERE listing_id=82;
UPDATE LISTING_ANALYTICS SET view_count=745, follower_count=6164, details_score=76.06, condition_score=74.13, shipping_score=58.08, pricing_score=42.41, view_to_bid_score=20.54, completeness_score=ROUND((IFNULL(photo_score,60)+76.06+74.13+58.08+42.41)/5,2) WHERE listing_id=83;
UPDATE LISTING_ANALYTICS SET view_count=244, follower_count=8356, details_score=46.47, condition_score=71.29, shipping_score=48.86, pricing_score=74.65, view_to_bid_score=13.66, completeness_score=ROUND((IFNULL(photo_score,60)+46.47+71.29+48.86+74.65)/5,2) WHERE listing_id=84;
UPDATE LISTING_ANALYTICS SET view_count=172, follower_count=8441, details_score=49.98, condition_score=65.03, shipping_score=71.78, pricing_score=81.86, view_to_bid_score=12.24, completeness_score=ROUND((IFNULL(photo_score,60)+49.98+65.03+71.78+81.86)/5,2) WHERE listing_id=85;
UPDATE LISTING_ANALYTICS SET view_count=586, follower_count=2336, details_score=47.79, condition_score=66.66, shipping_score=97.19, pricing_score=98.22, view_to_bid_score=7.84, completeness_score=ROUND((IFNULL(photo_score,60)+47.79+66.66+97.19+98.22)/5,2) WHERE listing_id=86;
UPDATE LISTING_ANALYTICS SET view_count=789, follower_count=2367, details_score=88.09, condition_score=72.94, shipping_score=41.57, pricing_score=40.05, view_to_bid_score=4.52, completeness_score=ROUND((IFNULL(photo_score,60)+88.09+72.94+41.57+40.05)/5,2) WHERE listing_id=87;
UPDATE LISTING_ANALYTICS SET view_count=181, follower_count=4986, details_score=58.45, condition_score=59.23, shipping_score=90.04, pricing_score=66.19, view_to_bid_score=16.34, completeness_score=ROUND((IFNULL(photo_score,60)+58.45+59.23+90.04+66.19)/5,2) WHERE listing_id=88;
UPDATE LISTING_ANALYTICS SET view_count=162, follower_count=11268, details_score=73.32, condition_score=88.78, shipping_score=30.35, pricing_score=49.56, view_to_bid_score=3.55, completeness_score=ROUND((IFNULL(photo_score,60)+73.32+88.78+30.35+49.56)/5,2) WHERE listing_id=89;
UPDATE LISTING_ANALYTICS SET view_count=568, follower_count=11302, details_score=63.64, condition_score=60.62, shipping_score=63.06, pricing_score=62.58, view_to_bid_score=11.0, completeness_score=ROUND((IFNULL(photo_score,60)+63.64+60.62+63.06+62.58)/5,2) WHERE listing_id=90;
UPDATE LISTING_ANALYTICS SET view_count=253, follower_count=1619, details_score=63.25, condition_score=65.92, shipping_score=95.47, pricing_score=63.99, view_to_bid_score=8.21, completeness_score=ROUND((IFNULL(photo_score,60)+63.25+65.92+95.47+63.99)/5,2) WHERE listing_id=91;
UPDATE LISTING_ANALYTICS SET view_count=294, follower_count=11105, details_score=83.82, condition_score=71.23, shipping_score=57.57, pricing_score=44.3, view_to_bid_score=11.51, completeness_score=ROUND((IFNULL(photo_score,60)+83.82+71.23+57.57+44.3)/5,2) WHERE listing_id=92;
UPDATE LISTING_ANALYTICS SET view_count=763, follower_count=9658, details_score=41.61, condition_score=94.28, shipping_score=42.47, pricing_score=54.11, view_to_bid_score=8.93, completeness_score=ROUND((IFNULL(photo_score,60)+41.61+94.28+42.47+54.11)/5,2) WHERE listing_id=93;
UPDATE LISTING_ANALYTICS SET view_count=518, follower_count=76, details_score=76.63, condition_score=87.58, shipping_score=94.02, pricing_score=78.73, view_to_bid_score=4.33, completeness_score=ROUND((IFNULL(photo_score,60)+76.63+87.58+94.02+78.73)/5,2) WHERE listing_id=94;
UPDATE LISTING_ANALYTICS SET view_count=197, follower_count=774, details_score=52.67, condition_score=71.77, shipping_score=53.77, pricing_score=79.24, view_to_bid_score=10.23, completeness_score=ROUND((IFNULL(photo_score,60)+52.67+71.77+53.77+79.24)/5,2) WHERE listing_id=95;
UPDATE LISTING_ANALYTICS SET view_count=296, follower_count=5146, details_score=63.21, condition_score=91.06, shipping_score=32.44, pricing_score=97.51, view_to_bid_score=10.15, completeness_score=ROUND((IFNULL(photo_score,60)+63.21+91.06+32.44+97.51)/5,2) WHERE listing_id=96;
UPDATE LISTING_ANALYTICS SET view_count=172, follower_count=6574, details_score=80.94, condition_score=91.71, shipping_score=62.54, pricing_score=44.96, view_to_bid_score=15.56, completeness_score=ROUND((IFNULL(photo_score,60)+80.94+91.71+62.54+44.96)/5,2) WHERE listing_id=97;
UPDATE LISTING_ANALYTICS SET view_count=108, follower_count=10795, details_score=91.75, condition_score=90.18, shipping_score=30.86, pricing_score=59.14, view_to_bid_score=13.28, completeness_score=ROUND((IFNULL(photo_score,60)+91.75+90.18+30.86+59.14)/5,2) WHERE listing_id=98;
UPDATE LISTING_ANALYTICS SET view_count=398, follower_count=11294, details_score=67.28, condition_score=74.31, shipping_score=97.19, pricing_score=64.1, view_to_bid_score=17.31, completeness_score=ROUND((IFNULL(photo_score,60)+67.28+74.31+97.19+64.1)/5,2) WHERE listing_id=99;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=7012, details_score=55.52, condition_score=81.71, shipping_score=72.25, pricing_score=88.15, view_to_bid_score=10.73, completeness_score=ROUND((IFNULL(photo_score,60)+55.52+81.71+72.25+88.15)/5,2) WHERE listing_id=100;
UPDATE LISTING_ANALYTICS SET view_count=386, follower_count=7808, details_score=82.72, condition_score=92.21, shipping_score=98.02, pricing_score=46.7, view_to_bid_score=5.17, completeness_score=ROUND((IFNULL(photo_score,60)+82.72+92.21+98.02+46.7)/5,2) WHERE listing_id=101;
UPDATE LISTING_ANALYTICS SET view_count=439, follower_count=8761, details_score=85.58, condition_score=93.52, shipping_score=35.6, pricing_score=40.42, view_to_bid_score=20.94, completeness_score=ROUND((IFNULL(photo_score,60)+85.58+93.52+35.6+40.42)/5,2) WHERE listing_id=102;
UPDATE LISTING_ANALYTICS SET view_count=729, follower_count=9719, details_score=55.47, condition_score=75.74, shipping_score=73.02, pricing_score=92.33, view_to_bid_score=10.42, completeness_score=ROUND((IFNULL(photo_score,60)+55.47+75.74+73.02+92.33)/5,2) WHERE listing_id=103;
UPDATE LISTING_ANALYTICS SET view_count=480, follower_count=4665, details_score=42.39, condition_score=93.39, shipping_score=62.22, pricing_score=43.0, view_to_bid_score=13.79, completeness_score=ROUND((IFNULL(photo_score,60)+42.39+93.39+62.22+43.0)/5,2) WHERE listing_id=104;
UPDATE LISTING_ANALYTICS SET view_count=383, follower_count=4184, details_score=65.54, condition_score=83.75, shipping_score=83.68, pricing_score=41.41, view_to_bid_score=6.98, completeness_score=ROUND((IFNULL(photo_score,60)+65.54+83.75+83.68+41.41)/5,2) WHERE listing_id=105;
UPDATE LISTING_ANALYTICS SET view_count=305, follower_count=5897, details_score=65.02, condition_score=72.34, shipping_score=50.84, pricing_score=42.14, view_to_bid_score=3.79, completeness_score=ROUND((IFNULL(photo_score,60)+65.02+72.34+50.84+42.14)/5,2) WHERE listing_id=106;
UPDATE LISTING_ANALYTICS SET view_count=754, follower_count=649, details_score=71.88, condition_score=69.81, shipping_score=42.27, pricing_score=72.1, view_to_bid_score=4.08, completeness_score=ROUND((IFNULL(photo_score,60)+71.88+69.81+42.27+72.1)/5,2) WHERE listing_id=107;
UPDATE LISTING_ANALYTICS SET view_count=153, follower_count=10419, details_score=69.61, condition_score=94.64, shipping_score=54.18, pricing_score=67.48, view_to_bid_score=14.15, completeness_score=ROUND((IFNULL(photo_score,60)+69.61+94.64+54.18+67.48)/5,2) WHERE listing_id=108;
UPDATE LISTING_ANALYTICS SET view_count=755, follower_count=8627, details_score=74.14, condition_score=52.03, shipping_score=52.86, pricing_score=42.3, view_to_bid_score=13.99, completeness_score=ROUND((IFNULL(photo_score,60)+74.14+52.03+52.86+42.3)/5,2) WHERE listing_id=109;
UPDATE LISTING_ANALYTICS SET view_count=746, follower_count=10499, details_score=88.75, condition_score=55.06, shipping_score=65.88, pricing_score=83.52, view_to_bid_score=8.42, completeness_score=ROUND((IFNULL(photo_score,60)+88.75+55.06+65.88+83.52)/5,2) WHERE listing_id=110;
UPDATE LISTING_ANALYTICS SET view_count=657, follower_count=4997, details_score=65.35, condition_score=51.12, shipping_score=96.53, pricing_score=55.41, view_to_bid_score=14.88, completeness_score=ROUND((IFNULL(photo_score,60)+65.35+51.12+96.53+55.41)/5,2) WHERE listing_id=111;
UPDATE LISTING_ANALYTICS SET view_count=86, follower_count=7151, details_score=97.91, condition_score=89.68, shipping_score=69.96, pricing_score=99.7, view_to_bid_score=14.12, completeness_score=ROUND((IFNULL(photo_score,60)+97.91+89.68+69.96+99.7)/5,2) WHERE listing_id=112;
UPDATE LISTING_ANALYTICS SET view_count=557, follower_count=4043, details_score=81.66, condition_score=52.44, shipping_score=70.13, pricing_score=52.91, view_to_bid_score=20.68, completeness_score=ROUND((IFNULL(photo_score,60)+81.66+52.44+70.13+52.91)/5,2) WHERE listing_id=113;
UPDATE LISTING_ANALYTICS SET view_count=286, follower_count=11336, details_score=86.7, condition_score=63.84, shipping_score=77.0, pricing_score=76.28, view_to_bid_score=20.15, completeness_score=ROUND((IFNULL(photo_score,60)+86.7+63.84+77.0+76.28)/5,2) WHERE listing_id=114;
UPDATE LISTING_ANALYTICS SET view_count=699, follower_count=4718, details_score=56.36, condition_score=70.36, shipping_score=31.31, pricing_score=64.86, view_to_bid_score=4.16, completeness_score=ROUND((IFNULL(photo_score,60)+56.36+70.36+31.31+64.86)/5,2) WHERE listing_id=115;
UPDATE LISTING_ANALYTICS SET view_count=278, follower_count=7626, details_score=75.94, condition_score=98.79, shipping_score=52.27, pricing_score=53.28, view_to_bid_score=1.87, completeness_score=ROUND((IFNULL(photo_score,60)+75.94+98.79+52.27+53.28)/5,2) WHERE listing_id=116;
UPDATE LISTING_ANALYTICS SET view_count=337, follower_count=3671, details_score=43.82, condition_score=64.39, shipping_score=79.84, pricing_score=89.62, view_to_bid_score=13.55, completeness_score=ROUND((IFNULL(photo_score,60)+43.82+64.39+79.84+89.62)/5,2) WHERE listing_id=117;
UPDATE LISTING_ANALYTICS SET view_count=655, follower_count=9802, details_score=59.73, condition_score=69.45, shipping_score=95.09, pricing_score=40.75, view_to_bid_score=8.48, completeness_score=ROUND((IFNULL(photo_score,60)+59.73+69.45+95.09+40.75)/5,2) WHERE listing_id=118;
UPDATE LISTING_ANALYTICS SET view_count=359, follower_count=7330, details_score=49.11, condition_score=92.72, shipping_score=64.93, pricing_score=71.93, view_to_bid_score=4.99, completeness_score=ROUND((IFNULL(photo_score,60)+49.11+92.72+64.93+71.93)/5,2) WHERE listing_id=119;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=4239, details_score=64.18, condition_score=83.03, shipping_score=69.99, pricing_score=44.72, view_to_bid_score=11.47, completeness_score=ROUND((IFNULL(photo_score,60)+64.18+83.03+69.99+44.72)/5,2) WHERE listing_id=120;
UPDATE LISTING_ANALYTICS SET view_count=358, follower_count=1411, details_score=52.45, condition_score=99.24, shipping_score=55.84, pricing_score=57.51, view_to_bid_score=7.96, completeness_score=ROUND((IFNULL(photo_score,60)+52.45+99.24+55.84+57.51)/5,2) WHERE listing_id=121;
UPDATE LISTING_ANALYTICS SET view_count=695, follower_count=7707, details_score=41.77, condition_score=81.24, shipping_score=41.67, pricing_score=61.1, view_to_bid_score=10.35, completeness_score=ROUND((IFNULL(photo_score,60)+41.77+81.24+41.67+61.1)/5,2) WHERE listing_id=122;
UPDATE LISTING_ANALYTICS SET view_count=788, follower_count=433, details_score=85.08, condition_score=64.19, shipping_score=82.08, pricing_score=99.38, view_to_bid_score=9.19, completeness_score=ROUND((IFNULL(photo_score,60)+85.08+64.19+82.08+99.38)/5,2) WHERE listing_id=123;
UPDATE LISTING_ANALYTICS SET view_count=555, follower_count=2207, details_score=62.71, condition_score=97.44, shipping_score=38.64, pricing_score=63.74, view_to_bid_score=5.83, completeness_score=ROUND((IFNULL(photo_score,60)+62.71+97.44+38.64+63.74)/5,2) WHERE listing_id=124;
UPDATE LISTING_ANALYTICS SET view_count=118, follower_count=9401, details_score=57.36, condition_score=93.24, shipping_score=83.68, pricing_score=99.06, view_to_bid_score=21.57, completeness_score=ROUND((IFNULL(photo_score,60)+57.36+93.24+83.68+99.06)/5,2) WHERE listing_id=125;
UPDATE LISTING_ANALYTICS SET view_count=568, follower_count=6743, details_score=61.12, condition_score=60.89, shipping_score=93.03, pricing_score=56.73, view_to_bid_score=17.3, completeness_score=ROUND((IFNULL(photo_score,60)+61.12+60.89+93.03+56.73)/5,2) WHERE listing_id=126;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=1780, details_score=79.85, condition_score=84.34, shipping_score=74.32, pricing_score=78.17, view_to_bid_score=11.8, completeness_score=ROUND((IFNULL(photo_score,60)+79.85+84.34+74.32+78.17)/5,2) WHERE listing_id=127;
UPDATE LISTING_ANALYTICS SET view_count=550, follower_count=6475, details_score=53.51, condition_score=70.2, shipping_score=82.98, pricing_score=57.18, view_to_bid_score=20.45, completeness_score=ROUND((IFNULL(photo_score,60)+53.51+70.2+82.98+57.18)/5,2) WHERE listing_id=128;
UPDATE LISTING_ANALYTICS SET view_count=165, follower_count=2960, details_score=64.0, condition_score=50.17, shipping_score=88.09, pricing_score=85.78, view_to_bid_score=14.95, completeness_score=ROUND((IFNULL(photo_score,60)+64.0+50.17+88.09+85.78)/5,2) WHERE listing_id=129;
UPDATE LISTING_ANALYTICS SET view_count=704, follower_count=1660, details_score=63.0, condition_score=82.66, shipping_score=98.2, pricing_score=64.62, view_to_bid_score=14.55, completeness_score=ROUND((IFNULL(photo_score,60)+63.0+82.66+98.2+64.62)/5,2) WHERE listing_id=130;
UPDATE LISTING_ANALYTICS SET view_count=638, follower_count=3723, details_score=48.31, condition_score=81.0, shipping_score=99.92, pricing_score=75.97, view_to_bid_score=16.51, completeness_score=ROUND((IFNULL(photo_score,60)+48.31+81.0+99.92+75.97)/5,2) WHERE listing_id=131;
UPDATE LISTING_ANALYTICS SET view_count=28, follower_count=5375, details_score=76.59, condition_score=58.32, shipping_score=73.78, pricing_score=81.06, view_to_bid_score=21.01, completeness_score=ROUND((IFNULL(photo_score,60)+76.59+58.32+73.78+81.06)/5,2) WHERE listing_id=132;
UPDATE LISTING_ANALYTICS SET view_count=28, follower_count=9902, details_score=93.01, condition_score=82.71, shipping_score=68.64, pricing_score=91.81, view_to_bid_score=18.93, completeness_score=ROUND((IFNULL(photo_score,60)+93.01+82.71+68.64+91.81)/5,2) WHERE listing_id=133;
UPDATE LISTING_ANALYTICS SET view_count=170, follower_count=7550, details_score=62.14, condition_score=93.73, shipping_score=42.26, pricing_score=96.23, view_to_bid_score=20.39, completeness_score=ROUND((IFNULL(photo_score,60)+62.14+93.73+42.26+96.23)/5,2) WHERE listing_id=134;
UPDATE LISTING_ANALYTICS SET view_count=335, follower_count=2223, details_score=57.58, condition_score=94.72, shipping_score=44.49, pricing_score=67.67, view_to_bid_score=6.52, completeness_score=ROUND((IFNULL(photo_score,60)+57.58+94.72+44.49+67.67)/5,2) WHERE listing_id=135;
UPDATE LISTING_ANALYTICS SET view_count=622, follower_count=7318, details_score=99.38, condition_score=89.84, shipping_score=98.1, pricing_score=70.01, view_to_bid_score=3.78, completeness_score=ROUND((IFNULL(photo_score,60)+99.38+89.84+98.1+70.01)/5,2) WHERE listing_id=136;
UPDATE LISTING_ANALYTICS SET view_count=623, follower_count=5477, details_score=92.33, condition_score=95.44, shipping_score=47.14, pricing_score=83.32, view_to_bid_score=2.93, completeness_score=ROUND((IFNULL(photo_score,60)+92.33+95.44+47.14+83.32)/5,2) WHERE listing_id=137;
UPDATE LISTING_ANALYTICS SET view_count=771, follower_count=579, details_score=80.92, condition_score=70.32, shipping_score=66.38, pricing_score=68.21, view_to_bid_score=9.4, completeness_score=ROUND((IFNULL(photo_score,60)+80.92+70.32+66.38+68.21)/5,2) WHERE listing_id=138;
UPDATE LISTING_ANALYTICS SET view_count=432, follower_count=4310, details_score=93.0, condition_score=76.87, shipping_score=80.11, pricing_score=76.42, view_to_bid_score=21.78, completeness_score=ROUND((IFNULL(photo_score,60)+93.0+76.87+80.11+76.42)/5,2) WHERE listing_id=139;
UPDATE LISTING_ANALYTICS SET view_count=736, follower_count=438, details_score=66.31, condition_score=91.39, shipping_score=34.19, pricing_score=88.7, view_to_bid_score=18.48, completeness_score=ROUND((IFNULL(photo_score,60)+66.31+91.39+34.19+88.7)/5,2) WHERE listing_id=140;
UPDATE LISTING_ANALYTICS SET view_count=747, follower_count=703, details_score=61.8, condition_score=85.83, shipping_score=65.81, pricing_score=78.98, view_to_bid_score=10.29, completeness_score=ROUND((IFNULL(photo_score,60)+61.8+85.83+65.81+78.98)/5,2) WHERE listing_id=141;
UPDATE LISTING_ANALYTICS SET view_count=132, follower_count=1747, details_score=48.76, condition_score=63.12, shipping_score=87.77, pricing_score=85.21, view_to_bid_score=3.79, completeness_score=ROUND((IFNULL(photo_score,60)+48.76+63.12+87.77+85.21)/5,2) WHERE listing_id=142;
UPDATE LISTING_ANALYTICS SET view_count=178, follower_count=6054, details_score=64.77, condition_score=66.99, shipping_score=93.91, pricing_score=87.73, view_to_bid_score=5.81, completeness_score=ROUND((IFNULL(photo_score,60)+64.77+66.99+93.91+87.73)/5,2) WHERE listing_id=143;
UPDATE LISTING_ANALYTICS SET view_count=104, follower_count=5457, details_score=78.52, condition_score=53.7, shipping_score=92.94, pricing_score=69.49, view_to_bid_score=6.52, completeness_score=ROUND((IFNULL(photo_score,60)+78.52+53.7+92.94+69.49)/5,2) WHERE listing_id=144;
UPDATE LISTING_ANALYTICS SET view_count=271, follower_count=5660, details_score=57.72, condition_score=72.23, shipping_score=85.12, pricing_score=81.97, view_to_bid_score=13.15, completeness_score=ROUND((IFNULL(photo_score,60)+57.72+72.23+85.12+81.97)/5,2) WHERE listing_id=145;
UPDATE LISTING_ANALYTICS SET view_count=613, follower_count=635, details_score=85.68, condition_score=57.4, shipping_score=50.19, pricing_score=53.26, view_to_bid_score=9.1, completeness_score=ROUND((IFNULL(photo_score,60)+85.68+57.4+50.19+53.26)/5,2) WHERE listing_id=146;
UPDATE LISTING_ANALYTICS SET view_count=376, follower_count=11744, details_score=57.47, condition_score=97.24, shipping_score=41.08, pricing_score=78.03, view_to_bid_score=11.24, completeness_score=ROUND((IFNULL(photo_score,60)+57.47+97.24+41.08+78.03)/5,2) WHERE listing_id=147;
UPDATE LISTING_ANALYTICS SET view_count=455, follower_count=11080, details_score=57.69, condition_score=87.19, shipping_score=78.66, pricing_score=48.79, view_to_bid_score=7.49, completeness_score=ROUND((IFNULL(photo_score,60)+57.69+87.19+78.66+48.79)/5,2) WHERE listing_id=148;
UPDATE LISTING_ANALYTICS SET view_count=398, follower_count=4265, details_score=78.21, condition_score=51.4, shipping_score=44.82, pricing_score=58.18, view_to_bid_score=13.48, completeness_score=ROUND((IFNULL(photo_score,60)+78.21+51.4+44.82+58.18)/5,2) WHERE listing_id=149;
UPDATE LISTING_ANALYTICS SET view_count=270, follower_count=6016, details_score=83.27, condition_score=87.27, shipping_score=99.73, pricing_score=64.35, view_to_bid_score=14.18, completeness_score=ROUND((IFNULL(photo_score,60)+83.27+87.27+99.73+64.35)/5,2) WHERE listing_id=150;
UPDATE LISTING_ANALYTICS SET view_count=179, follower_count=5689, details_score=78.63, condition_score=79.36, shipping_score=65.08, pricing_score=71.4, view_to_bid_score=9.25, completeness_score=ROUND((IFNULL(photo_score,60)+78.63+79.36+65.08+71.4)/5,2) WHERE listing_id=151;
UPDATE LISTING_ANALYTICS SET view_count=501, follower_count=10673, details_score=50.15, condition_score=76.26, shipping_score=42.28, pricing_score=93.83, view_to_bid_score=1.79, completeness_score=ROUND((IFNULL(photo_score,60)+50.15+76.26+42.28+93.83)/5,2) WHERE listing_id=152;
UPDATE LISTING_ANALYTICS SET view_count=71, follower_count=5659, details_score=53.49, condition_score=60.32, shipping_score=40.51, pricing_score=76.52, view_to_bid_score=16.44, completeness_score=ROUND((IFNULL(photo_score,60)+53.49+60.32+40.51+76.52)/5,2) WHERE listing_id=153;
UPDATE LISTING_ANALYTICS SET view_count=127, follower_count=10699, details_score=51.82, condition_score=74.94, shipping_score=69.86, pricing_score=78.32, view_to_bid_score=1.75, completeness_score=ROUND((IFNULL(photo_score,60)+51.82+74.94+69.86+78.32)/5,2) WHERE listing_id=154;
UPDATE LISTING_ANALYTICS SET view_count=769, follower_count=8637, details_score=93.89, condition_score=87.07, shipping_score=55.45, pricing_score=41.97, view_to_bid_score=14.34, completeness_score=ROUND((IFNULL(photo_score,60)+93.89+87.07+55.45+41.97)/5,2) WHERE listing_id=155;
UPDATE LISTING_ANALYTICS SET view_count=342, follower_count=8363, details_score=44.03, condition_score=77.66, shipping_score=67.43, pricing_score=84.48, view_to_bid_score=19.39, completeness_score=ROUND((IFNULL(photo_score,60)+44.03+77.66+67.43+84.48)/5,2) WHERE listing_id=156;
UPDATE LISTING_ANALYTICS SET view_count=62, follower_count=7367, details_score=74.0, condition_score=62.4, shipping_score=47.93, pricing_score=84.37, view_to_bid_score=15.64, completeness_score=ROUND((IFNULL(photo_score,60)+74.0+62.4+47.93+84.37)/5,2) WHERE listing_id=157;
UPDATE LISTING_ANALYTICS SET view_count=671, follower_count=4065, details_score=53.7, condition_score=85.87, shipping_score=42.42, pricing_score=98.76, view_to_bid_score=6.95, completeness_score=ROUND((IFNULL(photo_score,60)+53.7+85.87+42.42+98.76)/5,2) WHERE listing_id=158;
UPDATE LISTING_ANALYTICS SET view_count=289, follower_count=1546, details_score=84.59, condition_score=86.67, shipping_score=94.22, pricing_score=94.37, view_to_bid_score=4.22, completeness_score=ROUND((IFNULL(photo_score,60)+84.59+86.67+94.22+94.37)/5,2) WHERE listing_id=159;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=1047, details_score=52.46, condition_score=62.2, shipping_score=83.32, pricing_score=68.64, view_to_bid_score=3.51, completeness_score=ROUND((IFNULL(photo_score,60)+52.46+62.2+83.32+68.64)/5,2) WHERE listing_id=160;
UPDATE LISTING_ANALYTICS SET view_count=57, follower_count=5274, details_score=87.4, condition_score=53.65, shipping_score=63.48, pricing_score=66.51, view_to_bid_score=11.26, completeness_score=ROUND((IFNULL(photo_score,60)+87.4+53.65+63.48+66.51)/5,2) WHERE listing_id=161;
UPDATE LISTING_ANALYTICS SET view_count=107, follower_count=8936, details_score=75.36, condition_score=79.91, shipping_score=51.0, pricing_score=40.58, view_to_bid_score=10.31, completeness_score=ROUND((IFNULL(photo_score,60)+75.36+79.91+51.0+40.58)/5,2) WHERE listing_id=162;
UPDATE LISTING_ANALYTICS SET view_count=119, follower_count=11846, details_score=93.19, condition_score=88.87, shipping_score=43.64, pricing_score=88.35, view_to_bid_score=14.1, completeness_score=ROUND((IFNULL(photo_score,60)+93.19+88.87+43.64+88.35)/5,2) WHERE listing_id=163;
UPDATE LISTING_ANALYTICS SET view_count=472, follower_count=58, details_score=55.1, condition_score=70.36, shipping_score=48.95, pricing_score=77.87, view_to_bid_score=8.24, completeness_score=ROUND((IFNULL(photo_score,60)+55.1+70.36+48.95+77.87)/5,2) WHERE listing_id=164;
UPDATE LISTING_ANALYTICS SET view_count=499, follower_count=8474, details_score=57.03, condition_score=82.26, shipping_score=48.49, pricing_score=71.93, view_to_bid_score=8.49, completeness_score=ROUND((IFNULL(photo_score,60)+57.03+82.26+48.49+71.93)/5,2) WHERE listing_id=165;
UPDATE LISTING_ANALYTICS SET view_count=699, follower_count=9245, details_score=70.18, condition_score=81.3, shipping_score=37.8, pricing_score=85.4, view_to_bid_score=5.23, completeness_score=ROUND((IFNULL(photo_score,60)+70.18+81.3+37.8+85.4)/5,2) WHERE listing_id=166;
UPDATE LISTING_ANALYTICS SET view_count=11, follower_count=5279, details_score=93.6, condition_score=75.48, shipping_score=64.71, pricing_score=50.73, view_to_bid_score=17.09, completeness_score=ROUND((IFNULL(photo_score,60)+93.6+75.48+64.71+50.73)/5,2) WHERE listing_id=167;
UPDATE LISTING_ANALYTICS SET view_count=694, follower_count=5041, details_score=45.67, condition_score=93.1, shipping_score=53.97, pricing_score=81.22, view_to_bid_score=18.36, completeness_score=ROUND((IFNULL(photo_score,60)+45.67+93.1+53.97+81.22)/5,2) WHERE listing_id=168;
UPDATE LISTING_ANALYTICS SET view_count=203, follower_count=1831, details_score=85.77, condition_score=60.66, shipping_score=65.12, pricing_score=59.2, view_to_bid_score=12.37, completeness_score=ROUND((IFNULL(photo_score,60)+85.77+60.66+65.12+59.2)/5,2) WHERE listing_id=169;
UPDATE LISTING_ANALYTICS SET view_count=110, follower_count=11268, details_score=58.0, condition_score=80.48, shipping_score=69.97, pricing_score=49.28, view_to_bid_score=4.71, completeness_score=ROUND((IFNULL(photo_score,60)+58.0+80.48+69.97+49.28)/5,2) WHERE listing_id=170;
UPDATE LISTING_ANALYTICS SET view_count=789, follower_count=6541, details_score=87.15, condition_score=92.62, shipping_score=72.71, pricing_score=49.43, view_to_bid_score=21.11, completeness_score=ROUND((IFNULL(photo_score,60)+87.15+92.62+72.71+49.43)/5,2) WHERE listing_id=171;
UPDATE LISTING_ANALYTICS SET view_count=490, follower_count=10756, details_score=75.71, condition_score=70.85, shipping_score=80.85, pricing_score=53.72, view_to_bid_score=6.89, completeness_score=ROUND((IFNULL(photo_score,60)+75.71+70.85+80.85+53.72)/5,2) WHERE listing_id=172;
UPDATE LISTING_ANALYTICS SET view_count=315, follower_count=6125, details_score=48.7, condition_score=66.69, shipping_score=54.78, pricing_score=84.71, view_to_bid_score=10.72, completeness_score=ROUND((IFNULL(photo_score,60)+48.7+66.69+54.78+84.71)/5,2) WHERE listing_id=173;
UPDATE LISTING_ANALYTICS SET view_count=440, follower_count=9278, details_score=63.61, condition_score=70.86, shipping_score=83.36, pricing_score=64.24, view_to_bid_score=21.36, completeness_score=ROUND((IFNULL(photo_score,60)+63.61+70.86+83.36+64.24)/5,2) WHERE listing_id=174;
UPDATE LISTING_ANALYTICS SET view_count=367, follower_count=10630, details_score=88.32, condition_score=98.75, shipping_score=83.69, pricing_score=41.17, view_to_bid_score=15.94, completeness_score=ROUND((IFNULL(photo_score,60)+88.32+98.75+83.69+41.17)/5,2) WHERE listing_id=175;
UPDATE LISTING_ANALYTICS SET view_count=218, follower_count=10897, details_score=83.0, condition_score=64.74, shipping_score=56.14, pricing_score=59.31, view_to_bid_score=17.71, completeness_score=ROUND((IFNULL(photo_score,60)+83.0+64.74+56.14+59.31)/5,2) WHERE listing_id=176;
UPDATE LISTING_ANALYTICS SET view_count=338, follower_count=9193, details_score=73.6, condition_score=59.97, shipping_score=45.05, pricing_score=70.18, view_to_bid_score=19.06, completeness_score=ROUND((IFNULL(photo_score,60)+73.6+59.97+45.05+70.18)/5,2) WHERE listing_id=177;
UPDATE LISTING_ANALYTICS SET view_count=114, follower_count=1269, details_score=54.59, condition_score=66.27, shipping_score=63.58, pricing_score=83.28, view_to_bid_score=11.13, completeness_score=ROUND((IFNULL(photo_score,60)+54.59+66.27+63.58+83.28)/5,2) WHERE listing_id=178;
UPDATE LISTING_ANALYTICS SET view_count=52, follower_count=10853, details_score=63.4, condition_score=97.99, shipping_score=79.45, pricing_score=54.99, view_to_bid_score=21.73, completeness_score=ROUND((IFNULL(photo_score,60)+63.4+97.99+79.45+54.99)/5,2) WHERE listing_id=179;
UPDATE LISTING_ANALYTICS SET view_count=605, follower_count=6194, details_score=43.56, condition_score=52.81, shipping_score=53.99, pricing_score=72.27, view_to_bid_score=10.48, completeness_score=ROUND((IFNULL(photo_score,60)+43.56+52.81+53.99+72.27)/5,2) WHERE listing_id=180;
UPDATE LISTING_ANALYTICS SET view_count=296, follower_count=1869, details_score=68.31, condition_score=94.04, shipping_score=35.18, pricing_score=98.63, view_to_bid_score=16.52, completeness_score=ROUND((IFNULL(photo_score,60)+68.31+94.04+35.18+98.63)/5,2) WHERE listing_id=181;
UPDATE LISTING_ANALYTICS SET view_count=160, follower_count=2514, details_score=75.39, condition_score=78.7, shipping_score=69.33, pricing_score=66.3, view_to_bid_score=8.22, completeness_score=ROUND((IFNULL(photo_score,60)+75.39+78.7+69.33+66.3)/5,2) WHERE listing_id=182;
UPDATE LISTING_ANALYTICS SET view_count=564, follower_count=10874, details_score=55.64, condition_score=76.55, shipping_score=50.4, pricing_score=41.31, view_to_bid_score=17.33, completeness_score=ROUND((IFNULL(photo_score,60)+55.64+76.55+50.4+41.31)/5,2) WHERE listing_id=183;
UPDATE LISTING_ANALYTICS SET view_count=74, follower_count=11506, details_score=82.68, condition_score=65.7, shipping_score=89.74, pricing_score=94.31, view_to_bid_score=10.64, completeness_score=ROUND((IFNULL(photo_score,60)+82.68+65.7+89.74+94.31)/5,2) WHERE listing_id=184;
UPDATE LISTING_ANALYTICS SET view_count=224, follower_count=3066, details_score=59.28, condition_score=61.38, shipping_score=55.35, pricing_score=51.94, view_to_bid_score=21.41, completeness_score=ROUND((IFNULL(photo_score,60)+59.28+61.38+55.35+51.94)/5,2) WHERE listing_id=185;
UPDATE LISTING_ANALYTICS SET view_count=270, follower_count=4233, details_score=76.22, condition_score=96.63, shipping_score=39.82, pricing_score=78.53, view_to_bid_score=10.26, completeness_score=ROUND((IFNULL(photo_score,60)+76.22+96.63+39.82+78.53)/5,2) WHERE listing_id=186;
UPDATE LISTING_ANALYTICS SET view_count=503, follower_count=836, details_score=89.9, condition_score=53.01, shipping_score=99.28, pricing_score=62.41, view_to_bid_score=13.1, completeness_score=ROUND((IFNULL(photo_score,60)+89.9+53.01+99.28+62.41)/5,2) WHERE listing_id=187;
UPDATE LISTING_ANALYTICS SET view_count=37, follower_count=8311, details_score=92.38, condition_score=66.35, shipping_score=67.72, pricing_score=56.96, view_to_bid_score=8.34, completeness_score=ROUND((IFNULL(photo_score,60)+92.38+66.35+67.72+56.96)/5,2) WHERE listing_id=188;
UPDATE LISTING_ANALYTICS SET view_count=73, follower_count=1287, details_score=73.92, condition_score=98.71, shipping_score=84.64, pricing_score=71.91, view_to_bid_score=17.87, completeness_score=ROUND((IFNULL(photo_score,60)+73.92+98.71+84.64+71.91)/5,2) WHERE listing_id=189;
UPDATE LISTING_ANALYTICS SET view_count=94, follower_count=9453, details_score=95.35, condition_score=80.5, shipping_score=99.51, pricing_score=85.11, view_to_bid_score=17.23, completeness_score=ROUND((IFNULL(photo_score,60)+95.35+80.5+99.51+85.11)/5,2) WHERE listing_id=190;
UPDATE LISTING_ANALYTICS SET view_count=446, follower_count=4586, details_score=67.94, condition_score=94.47, shipping_score=99.6, pricing_score=49.13, view_to_bid_score=8.27, completeness_score=ROUND((IFNULL(photo_score,60)+67.94+94.47+99.6+49.13)/5,2) WHERE listing_id=191;
UPDATE LISTING_ANALYTICS SET view_count=191, follower_count=10664, details_score=74.51, condition_score=72.7, shipping_score=84.68, pricing_score=84.37, view_to_bid_score=20.94, completeness_score=ROUND((IFNULL(photo_score,60)+74.51+72.7+84.68+84.37)/5,2) WHERE listing_id=192;
UPDATE LISTING_ANALYTICS SET view_count=26, follower_count=6627, details_score=74.48, condition_score=50.32, shipping_score=87.98, pricing_score=41.13, view_to_bid_score=6.12, completeness_score=ROUND((IFNULL(photo_score,60)+74.48+50.32+87.98+41.13)/5,2) WHERE listing_id=193;
UPDATE LISTING_ANALYTICS SET view_count=442, follower_count=2515, details_score=55.53, condition_score=61.14, shipping_score=77.22, pricing_score=59.6, view_to_bid_score=10.88, completeness_score=ROUND((IFNULL(photo_score,60)+55.53+61.14+77.22+59.6)/5,2) WHERE listing_id=194;
UPDATE LISTING_ANALYTICS SET view_count=686, follower_count=3332, details_score=86.2, condition_score=78.72, shipping_score=54.83, pricing_score=92.82, view_to_bid_score=19.28, completeness_score=ROUND((IFNULL(photo_score,60)+86.2+78.72+54.83+92.82)/5,2) WHERE listing_id=195;
UPDATE LISTING_ANALYTICS SET view_count=161, follower_count=3144, details_score=86.38, condition_score=60.31, shipping_score=42.71, pricing_score=41.57, view_to_bid_score=13.84, completeness_score=ROUND((IFNULL(photo_score,60)+86.38+60.31+42.71+41.57)/5,2) WHERE listing_id=196;
UPDATE LISTING_ANALYTICS SET view_count=45, follower_count=2136, details_score=72.4, condition_score=97.73, shipping_score=52.92, pricing_score=58.92, view_to_bid_score=6.22, completeness_score=ROUND((IFNULL(photo_score,60)+72.4+97.73+52.92+58.92)/5,2) WHERE listing_id=197;
UPDATE LISTING_ANALYTICS SET view_count=218, follower_count=3354, details_score=58.18, condition_score=71.21, shipping_score=48.98, pricing_score=96.18, view_to_bid_score=5.95, completeness_score=ROUND((IFNULL(photo_score,60)+58.18+71.21+48.98+96.18)/5,2) WHERE listing_id=198;
UPDATE LISTING_ANALYTICS SET view_count=368, follower_count=497, details_score=48.24, condition_score=94.94, shipping_score=60.77, pricing_score=90.05, view_to_bid_score=9.19, completeness_score=ROUND((IFNULL(photo_score,60)+48.24+94.94+60.77+90.05)/5,2) WHERE listing_id=199;
UPDATE LISTING_ANALYTICS SET view_count=459, follower_count=3467, details_score=62.82, condition_score=72.34, shipping_score=57.94, pricing_score=52.34, view_to_bid_score=9.3, completeness_score=ROUND((IFNULL(photo_score,60)+62.82+72.34+57.94+52.34)/5,2) WHERE listing_id=200;
UPDATE LISTING_ANALYTICS SET view_count=132, follower_count=1571, details_score=98.15, condition_score=75.34, shipping_score=70.48, pricing_score=70.99, view_to_bid_score=4.84, completeness_score=ROUND((IFNULL(photo_score,60)+98.15+75.34+70.48+70.99)/5,2) WHERE listing_id=201;
UPDATE LISTING_ANALYTICS SET view_count=219, follower_count=2021, details_score=96.44, condition_score=87.03, shipping_score=55.09, pricing_score=99.72, view_to_bid_score=10.01, completeness_score=ROUND((IFNULL(photo_score,60)+96.44+87.03+55.09+99.72)/5,2) WHERE listing_id=202;
UPDATE LISTING_ANALYTICS SET view_count=220, follower_count=1537, details_score=87.99, condition_score=67.99, shipping_score=47.87, pricing_score=46.72, view_to_bid_score=10.87, completeness_score=ROUND((IFNULL(photo_score,60)+87.99+67.99+47.87+46.72)/5,2) WHERE listing_id=203;
UPDATE LISTING_ANALYTICS SET view_count=12, follower_count=6276, details_score=88.2, condition_score=70.02, shipping_score=90.02, pricing_score=61.28, view_to_bid_score=20.89, completeness_score=ROUND((IFNULL(photo_score,60)+88.2+70.02+90.02+61.28)/5,2) WHERE listing_id=204;
UPDATE LISTING_ANALYTICS SET view_count=71, follower_count=7163, details_score=96.76, condition_score=82.6, shipping_score=46.06, pricing_score=82.07, view_to_bid_score=14.83, completeness_score=ROUND((IFNULL(photo_score,60)+96.76+82.6+46.06+82.07)/5,2) WHERE listing_id=205;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=7772, details_score=40.95, condition_score=98.21, shipping_score=81.07, pricing_score=93.84, view_to_bid_score=2.43, completeness_score=ROUND((IFNULL(photo_score,60)+40.95+98.21+81.07+93.84)/5,2) WHERE listing_id=206;
UPDATE LISTING_ANALYTICS SET view_count=259, follower_count=2955, details_score=73.87, condition_score=56.4, shipping_score=40.9, pricing_score=81.7, view_to_bid_score=17.13, completeness_score=ROUND((IFNULL(photo_score,60)+73.87+56.4+40.9+81.7)/5,2) WHERE listing_id=207;
UPDATE LISTING_ANALYTICS SET view_count=67, follower_count=9818, details_score=88.14, condition_score=93.32, shipping_score=76.27, pricing_score=62.3, view_to_bid_score=10.0, completeness_score=ROUND((IFNULL(photo_score,60)+88.14+93.32+76.27+62.3)/5,2) WHERE listing_id=208;
UPDATE LISTING_ANALYTICS SET view_count=166, follower_count=6918, details_score=50.35, condition_score=96.81, shipping_score=97.57, pricing_score=84.52, view_to_bid_score=18.11, completeness_score=ROUND((IFNULL(photo_score,60)+50.35+96.81+97.57+84.52)/5,2) WHERE listing_id=209;
UPDATE LISTING_ANALYTICS SET view_count=190, follower_count=6031, details_score=92.74, condition_score=55.47, shipping_score=41.37, pricing_score=69.85, view_to_bid_score=7.77, completeness_score=ROUND((IFNULL(photo_score,60)+92.74+55.47+41.37+69.85)/5,2) WHERE listing_id=210;
UPDATE LISTING_ANALYTICS SET view_count=645, follower_count=6164, details_score=94.54, condition_score=63.26, shipping_score=52.48, pricing_score=87.0, view_to_bid_score=8.3, completeness_score=ROUND((IFNULL(photo_score,60)+94.54+63.26+52.48+87.0)/5,2) WHERE listing_id=211;
UPDATE LISTING_ANALYTICS SET view_count=486, follower_count=610, details_score=84.1, condition_score=57.22, shipping_score=58.54, pricing_score=72.37, view_to_bid_score=17.13, completeness_score=ROUND((IFNULL(photo_score,60)+84.1+57.22+58.54+72.37)/5,2) WHERE listing_id=212;
UPDATE LISTING_ANALYTICS SET view_count=744, follower_count=8654, details_score=50.18, condition_score=55.01, shipping_score=54.41, pricing_score=53.36, view_to_bid_score=10.11, completeness_score=ROUND((IFNULL(photo_score,60)+50.18+55.01+54.41+53.36)/5,2) WHERE listing_id=213;
UPDATE LISTING_ANALYTICS SET view_count=72, follower_count=1891, details_score=98.12, condition_score=73.22, shipping_score=59.06, pricing_score=93.89, view_to_bid_score=10.53, completeness_score=ROUND((IFNULL(photo_score,60)+98.12+73.22+59.06+93.89)/5,2) WHERE listing_id=214;
UPDATE LISTING_ANALYTICS SET view_count=622, follower_count=10484, details_score=40.04, condition_score=73.81, shipping_score=92.97, pricing_score=55.41, view_to_bid_score=8.12, completeness_score=ROUND((IFNULL(photo_score,60)+40.04+73.81+92.97+55.41)/5,2) WHERE listing_id=215;
UPDATE LISTING_ANALYTICS SET view_count=557, follower_count=6039, details_score=97.41, condition_score=83.42, shipping_score=36.75, pricing_score=69.57, view_to_bid_score=18.54, completeness_score=ROUND((IFNULL(photo_score,60)+97.41+83.42+36.75+69.57)/5,2) WHERE listing_id=216;
UPDATE LISTING_ANALYTICS SET view_count=589, follower_count=3265, details_score=47.55, condition_score=75.74, shipping_score=86.38, pricing_score=48.56, view_to_bid_score=15.01, completeness_score=ROUND((IFNULL(photo_score,60)+47.55+75.74+86.38+48.56)/5,2) WHERE listing_id=217;
UPDATE LISTING_ANALYTICS SET view_count=766, follower_count=1603, details_score=83.04, condition_score=64.11, shipping_score=73.05, pricing_score=54.99, view_to_bid_score=6.64, completeness_score=ROUND((IFNULL(photo_score,60)+83.04+64.11+73.05+54.99)/5,2) WHERE listing_id=218;
UPDATE LISTING_ANALYTICS SET view_count=752, follower_count=10853, details_score=58.07, condition_score=85.52, shipping_score=62.35, pricing_score=75.45, view_to_bid_score=12.1, completeness_score=ROUND((IFNULL(photo_score,60)+58.07+85.52+62.35+75.45)/5,2) WHERE listing_id=219;
UPDATE LISTING_ANALYTICS SET view_count=278, follower_count=2207, details_score=59.68, condition_score=68.74, shipping_score=40.17, pricing_score=84.18, view_to_bid_score=18.94, completeness_score=ROUND((IFNULL(photo_score,60)+59.68+68.74+40.17+84.18)/5,2) WHERE listing_id=220;
UPDATE LISTING_ANALYTICS SET view_count=770, follower_count=6358, details_score=77.91, condition_score=89.71, shipping_score=98.57, pricing_score=40.86, view_to_bid_score=14.51, completeness_score=ROUND((IFNULL(photo_score,60)+77.91+89.71+98.57+40.86)/5,2) WHERE listing_id=221;
UPDATE LISTING_ANALYTICS SET view_count=248, follower_count=2702, details_score=63.81, condition_score=50.59, shipping_score=63.65, pricing_score=91.46, view_to_bid_score=5.35, completeness_score=ROUND((IFNULL(photo_score,60)+63.81+50.59+63.65+91.46)/5,2) WHERE listing_id=222;
UPDATE LISTING_ANALYTICS SET view_count=596, follower_count=6696, details_score=67.13, condition_score=60.74, shipping_score=73.49, pricing_score=72.75, view_to_bid_score=3.92, completeness_score=ROUND((IFNULL(photo_score,60)+67.13+60.74+73.49+72.75)/5,2) WHERE listing_id=223;
UPDATE LISTING_ANALYTICS SET view_count=291, follower_count=10789, details_score=86.11, condition_score=96.19, shipping_score=53.61, pricing_score=93.55, view_to_bid_score=6.73, completeness_score=ROUND((IFNULL(photo_score,60)+86.11+96.19+53.61+93.55)/5,2) WHERE listing_id=224;
UPDATE LISTING_ANALYTICS SET view_count=504, follower_count=9043, details_score=67.38, condition_score=54.83, shipping_score=89.94, pricing_score=85.8, view_to_bid_score=6.89, completeness_score=ROUND((IFNULL(photo_score,60)+67.38+54.83+89.94+85.8)/5,2) WHERE listing_id=225;
UPDATE LISTING_ANALYTICS SET view_count=379, follower_count=7038, details_score=78.54, condition_score=98.24, shipping_score=38.84, pricing_score=53.63, view_to_bid_score=10.88, completeness_score=ROUND((IFNULL(photo_score,60)+78.54+98.24+38.84+53.63)/5,2) WHERE listing_id=226;
UPDATE LISTING_ANALYTICS SET view_count=118, follower_count=2020, details_score=73.03, condition_score=64.79, shipping_score=91.13, pricing_score=58.42, view_to_bid_score=10.44, completeness_score=ROUND((IFNULL(photo_score,60)+73.03+64.79+91.13+58.42)/5,2) WHERE listing_id=227;
UPDATE LISTING_ANALYTICS SET view_count=89, follower_count=8319, details_score=50.96, condition_score=91.0, shipping_score=91.99, pricing_score=70.65, view_to_bid_score=4.41, completeness_score=ROUND((IFNULL(photo_score,60)+50.96+91.0+91.99+70.65)/5,2) WHERE listing_id=228;
UPDATE LISTING_ANALYTICS SET view_count=701, follower_count=3684, details_score=86.55, condition_score=59.93, shipping_score=82.12, pricing_score=71.53, view_to_bid_score=17.49, completeness_score=ROUND((IFNULL(photo_score,60)+86.55+59.93+82.12+71.53)/5,2) WHERE listing_id=229;
UPDATE LISTING_ANALYTICS SET view_count=581, follower_count=8742, details_score=71.5, condition_score=90.01, shipping_score=55.39, pricing_score=53.83, view_to_bid_score=20.92, completeness_score=ROUND((IFNULL(photo_score,60)+71.5+90.01+55.39+53.83)/5,2) WHERE listing_id=230;
UPDATE LISTING_ANALYTICS SET view_count=548, follower_count=2782, details_score=62.47, condition_score=55.01, shipping_score=41.59, pricing_score=78.06, view_to_bid_score=14.17, completeness_score=ROUND((IFNULL(photo_score,60)+62.47+55.01+41.59+78.06)/5,2) WHERE listing_id=231;
UPDATE LISTING_ANALYTICS SET view_count=774, follower_count=11782, details_score=49.12, condition_score=97.11, shipping_score=72.68, pricing_score=91.5, view_to_bid_score=7.21, completeness_score=ROUND((IFNULL(photo_score,60)+49.12+97.11+72.68+91.5)/5,2) WHERE listing_id=232;
UPDATE LISTING_ANALYTICS SET view_count=415, follower_count=4907, details_score=63.39, condition_score=76.09, shipping_score=59.49, pricing_score=68.59, view_to_bid_score=8.1, completeness_score=ROUND((IFNULL(photo_score,60)+63.39+76.09+59.49+68.59)/5,2) WHERE listing_id=233;
UPDATE LISTING_ANALYTICS SET view_count=743, follower_count=4965, details_score=40.02, condition_score=62.57, shipping_score=68.9, pricing_score=58.7, view_to_bid_score=20.42, completeness_score=ROUND((IFNULL(photo_score,60)+40.02+62.57+68.9+58.7)/5,2) WHERE listing_id=234;
UPDATE LISTING_ANALYTICS SET view_count=632, follower_count=9781, details_score=97.56, condition_score=52.96, shipping_score=58.73, pricing_score=48.63, view_to_bid_score=18.36, completeness_score=ROUND((IFNULL(photo_score,60)+97.56+52.96+58.73+48.63)/5,2) WHERE listing_id=235;
UPDATE LISTING_ANALYTICS SET view_count=787, follower_count=4022, details_score=63.47, condition_score=57.97, shipping_score=59.33, pricing_score=75.48, view_to_bid_score=6.6, completeness_score=ROUND((IFNULL(photo_score,60)+63.47+57.97+59.33+75.48)/5,2) WHERE listing_id=236;
UPDATE LISTING_ANALYTICS SET view_count=363, follower_count=1205, details_score=53.58, condition_score=97.45, shipping_score=39.83, pricing_score=64.09, view_to_bid_score=16.38, completeness_score=ROUND((IFNULL(photo_score,60)+53.58+97.45+39.83+64.09)/5,2) WHERE listing_id=237;
UPDATE LISTING_ANALYTICS SET view_count=604, follower_count=11065, details_score=49.11, condition_score=72.17, shipping_score=77.06, pricing_score=85.64, view_to_bid_score=1.72, completeness_score=ROUND((IFNULL(photo_score,60)+49.11+72.17+77.06+85.64)/5,2) WHERE listing_id=238;
UPDATE LISTING_ANALYTICS SET view_count=125, follower_count=8579, details_score=58.67, condition_score=55.13, shipping_score=74.0, pricing_score=68.27, view_to_bid_score=15.04, completeness_score=ROUND((IFNULL(photo_score,60)+58.67+55.13+74.0+68.27)/5,2) WHERE listing_id=239;
UPDATE LISTING_ANALYTICS SET view_count=310, follower_count=2095, details_score=72.48, condition_score=80.5, shipping_score=40.76, pricing_score=92.81, view_to_bid_score=16.96, completeness_score=ROUND((IFNULL(photo_score,60)+72.48+80.5+40.76+92.81)/5,2) WHERE listing_id=240;
UPDATE LISTING_ANALYTICS SET view_count=742, follower_count=5643, details_score=92.51, condition_score=97.47, shipping_score=32.87, pricing_score=90.28, view_to_bid_score=6.74, completeness_score=ROUND((IFNULL(photo_score,60)+92.51+97.47+32.87+90.28)/5,2) WHERE listing_id=241;
UPDATE LISTING_ANALYTICS SET view_count=646, follower_count=7693, details_score=65.55, condition_score=58.42, shipping_score=79.68, pricing_score=91.93, view_to_bid_score=11.49, completeness_score=ROUND((IFNULL(photo_score,60)+65.55+58.42+79.68+91.93)/5,2) WHERE listing_id=242;
UPDATE LISTING_ANALYTICS SET view_count=303, follower_count=3730, details_score=71.37, condition_score=54.43, shipping_score=81.22, pricing_score=97.58, view_to_bid_score=19.23, completeness_score=ROUND((IFNULL(photo_score,60)+71.37+54.43+81.22+97.58)/5,2) WHERE listing_id=243;
UPDATE LISTING_ANALYTICS SET view_count=252, follower_count=10943, details_score=69.67, condition_score=85.08, shipping_score=60.27, pricing_score=43.4, view_to_bid_score=3.66, completeness_score=ROUND((IFNULL(photo_score,60)+69.67+85.08+60.27+43.4)/5,2) WHERE listing_id=244;
UPDATE LISTING_ANALYTICS SET view_count=793, follower_count=4640, details_score=90.54, condition_score=86.62, shipping_score=93.33, pricing_score=78.42, view_to_bid_score=8.24, completeness_score=ROUND((IFNULL(photo_score,60)+90.54+86.62+93.33+78.42)/5,2) WHERE listing_id=245;
UPDATE LISTING_ANALYTICS SET view_count=687, follower_count=4166, details_score=98.99, condition_score=54.15, shipping_score=37.08, pricing_score=88.36, view_to_bid_score=6.48, completeness_score=ROUND((IFNULL(photo_score,60)+98.99+54.15+37.08+88.36)/5,2) WHERE listing_id=246;
UPDATE LISTING_ANALYTICS SET view_count=511, follower_count=3677, details_score=75.47, condition_score=83.28, shipping_score=37.28, pricing_score=86.86, view_to_bid_score=16.02, completeness_score=ROUND((IFNULL(photo_score,60)+75.47+83.28+37.28+86.86)/5,2) WHERE listing_id=247;
UPDATE LISTING_ANALYTICS SET view_count=579, follower_count=9989, details_score=90.24, condition_score=68.79, shipping_score=66.33, pricing_score=95.51, view_to_bid_score=9.34, completeness_score=ROUND((IFNULL(photo_score,60)+90.24+68.79+66.33+95.51)/5,2) WHERE listing_id=248;
UPDATE LISTING_ANALYTICS SET view_count=621, follower_count=1816, details_score=75.42, condition_score=89.68, shipping_score=96.79, pricing_score=74.54, view_to_bid_score=3.91, completeness_score=ROUND((IFNULL(photo_score,60)+75.42+89.68+96.79+74.54)/5,2) WHERE listing_id=249;
UPDATE LISTING_ANALYTICS SET view_count=787, follower_count=3959, details_score=61.64, condition_score=83.63, shipping_score=93.27, pricing_score=65.31, view_to_bid_score=9.57, completeness_score=ROUND((IFNULL(photo_score,60)+61.64+83.63+93.27+65.31)/5,2) WHERE listing_id=250;
UPDATE LISTING_ANALYTICS SET view_count=767, follower_count=703, details_score=60.84, condition_score=89.41, shipping_score=89.66, pricing_score=74.4, view_to_bid_score=12.22, completeness_score=ROUND((IFNULL(photo_score,60)+60.84+89.41+89.66+74.4)/5,2) WHERE listing_id=251;
UPDATE LISTING_ANALYTICS SET view_count=413, follower_count=10341, details_score=84.66, condition_score=71.59, shipping_score=93.57, pricing_score=52.96, view_to_bid_score=5.21, completeness_score=ROUND((IFNULL(photo_score,60)+84.66+71.59+93.57+52.96)/5,2) WHERE listing_id=252;
UPDATE LISTING_ANALYTICS SET view_count=650, follower_count=5439, details_score=45.93, condition_score=96.03, shipping_score=86.13, pricing_score=83.74, view_to_bid_score=18.91, completeness_score=ROUND((IFNULL(photo_score,60)+45.93+96.03+86.13+83.74)/5,2) WHERE listing_id=253;
UPDATE LISTING_ANALYTICS SET view_count=264, follower_count=5925, details_score=89.1, condition_score=67.2, shipping_score=98.15, pricing_score=54.92, view_to_bid_score=10.64, completeness_score=ROUND((IFNULL(photo_score,60)+89.1+67.2+98.15+54.92)/5,2) WHERE listing_id=254;
UPDATE LISTING_ANALYTICS SET view_count=53, follower_count=5366, details_score=67.49, condition_score=99.55, shipping_score=48.42, pricing_score=87.62, view_to_bid_score=5.79, completeness_score=ROUND((IFNULL(photo_score,60)+67.49+99.55+48.42+87.62)/5,2) WHERE listing_id=255;
UPDATE LISTING_ANALYTICS SET view_count=794, follower_count=9016, details_score=78.9, condition_score=87.04, shipping_score=82.73, pricing_score=86.86, view_to_bid_score=5.03, completeness_score=ROUND((IFNULL(photo_score,60)+78.9+87.04+82.73+86.86)/5,2) WHERE listing_id=256;
UPDATE LISTING_ANALYTICS SET view_count=516, follower_count=1506, details_score=60.03, condition_score=80.82, shipping_score=81.79, pricing_score=90.17, view_to_bid_score=6.17, completeness_score=ROUND((IFNULL(photo_score,60)+60.03+80.82+81.79+90.17)/5,2) WHERE listing_id=257;
UPDATE LISTING_ANALYTICS SET view_count=318, follower_count=1709, details_score=94.85, condition_score=54.52, shipping_score=58.42, pricing_score=77.31, view_to_bid_score=14.61, completeness_score=ROUND((IFNULL(photo_score,60)+94.85+54.52+58.42+77.31)/5,2) WHERE listing_id=258;
UPDATE LISTING_ANALYTICS SET view_count=779, follower_count=6320, details_score=52.13, condition_score=92.8, shipping_score=63.98, pricing_score=60.22, view_to_bid_score=10.47, completeness_score=ROUND((IFNULL(photo_score,60)+52.13+92.8+63.98+60.22)/5,2) WHERE listing_id=259;
UPDATE LISTING_ANALYTICS SET view_count=375, follower_count=2658, details_score=97.56, condition_score=66.14, shipping_score=37.8, pricing_score=74.91, view_to_bid_score=20.13, completeness_score=ROUND((IFNULL(photo_score,60)+97.56+66.14+37.8+74.91)/5,2) WHERE listing_id=260;
UPDATE LISTING_ANALYTICS SET view_count=722, follower_count=10573, details_score=73.63, condition_score=87.84, shipping_score=67.68, pricing_score=63.88, view_to_bid_score=15.76, completeness_score=ROUND((IFNULL(photo_score,60)+73.63+87.84+67.68+63.88)/5,2) WHERE listing_id=261;
UPDATE LISTING_ANALYTICS SET view_count=208, follower_count=1579, details_score=45.43, condition_score=79.9, shipping_score=91.39, pricing_score=64.28, view_to_bid_score=6.9, completeness_score=ROUND((IFNULL(photo_score,60)+45.43+79.9+91.39+64.28)/5,2) WHERE listing_id=262;
UPDATE LISTING_ANALYTICS SET view_count=738, follower_count=5623, details_score=71.97, condition_score=69.84, shipping_score=94.49, pricing_score=46.22, view_to_bid_score=21.1, completeness_score=ROUND((IFNULL(photo_score,60)+71.97+69.84+94.49+46.22)/5,2) WHERE listing_id=263;
UPDATE LISTING_ANALYTICS SET view_count=305, follower_count=10100, details_score=74.21, condition_score=54.11, shipping_score=99.96, pricing_score=66.55, view_to_bid_score=2.34, completeness_score=ROUND((IFNULL(photo_score,60)+74.21+54.11+99.96+66.55)/5,2) WHERE listing_id=264;
UPDATE LISTING_ANALYTICS SET view_count=566, follower_count=2589, details_score=80.05, condition_score=63.69, shipping_score=64.61, pricing_score=89.99, view_to_bid_score=21.66, completeness_score=ROUND((IFNULL(photo_score,60)+80.05+63.69+64.61+89.99)/5,2) WHERE listing_id=265;
UPDATE LISTING_ANALYTICS SET view_count=256, follower_count=3750, details_score=66.42, condition_score=90.58, shipping_score=40.18, pricing_score=57.81, view_to_bid_score=21.27, completeness_score=ROUND((IFNULL(photo_score,60)+66.42+90.58+40.18+57.81)/5,2) WHERE listing_id=266;
UPDATE LISTING_ANALYTICS SET view_count=631, follower_count=7967, details_score=90.28, condition_score=70.73, shipping_score=68.59, pricing_score=74.09, view_to_bid_score=9.95, completeness_score=ROUND((IFNULL(photo_score,60)+90.28+70.73+68.59+74.09)/5,2) WHERE listing_id=267;
UPDATE LISTING_ANALYTICS SET view_count=536, follower_count=9567, details_score=63.98, condition_score=78.77, shipping_score=93.16, pricing_score=63.23, view_to_bid_score=6.86, completeness_score=ROUND((IFNULL(photo_score,60)+63.98+78.77+93.16+63.23)/5,2) WHERE listing_id=268;
UPDATE LISTING_ANALYTICS SET view_count=377, follower_count=4368, details_score=65.88, condition_score=68.23, shipping_score=94.79, pricing_score=54.08, view_to_bid_score=12.58, completeness_score=ROUND((IFNULL(photo_score,60)+65.88+68.23+94.79+54.08)/5,2) WHERE listing_id=269;
UPDATE LISTING_ANALYTICS SET view_count=83, follower_count=11407, details_score=48.07, condition_score=93.0, shipping_score=99.04, pricing_score=54.81, view_to_bid_score=12.53, completeness_score=ROUND((IFNULL(photo_score,60)+48.07+93.0+99.04+54.81)/5,2) WHERE listing_id=270;
UPDATE LISTING_ANALYTICS SET view_count=136, follower_count=1633, details_score=98.86, condition_score=89.21, shipping_score=65.52, pricing_score=68.54, view_to_bid_score=7.93, completeness_score=ROUND((IFNULL(photo_score,60)+98.86+89.21+65.52+68.54)/5,2) WHERE listing_id=271;
UPDATE LISTING_ANALYTICS SET view_count=623, follower_count=3782, details_score=83.21, condition_score=85.88, shipping_score=75.15, pricing_score=73.24, view_to_bid_score=21.69, completeness_score=ROUND((IFNULL(photo_score,60)+83.21+85.88+75.15+73.24)/5,2) WHERE listing_id=272;
UPDATE LISTING_ANALYTICS SET view_count=481, follower_count=4459, details_score=74.46, condition_score=52.66, shipping_score=73.32, pricing_score=69.83, view_to_bid_score=10.44, completeness_score=ROUND((IFNULL(photo_score,60)+74.46+52.66+73.32+69.83)/5,2) WHERE listing_id=273;
UPDATE LISTING_ANALYTICS SET view_count=180, follower_count=412, details_score=73.6, condition_score=77.95, shipping_score=34.03, pricing_score=60.86, view_to_bid_score=19.29, completeness_score=ROUND((IFNULL(photo_score,60)+73.6+77.95+34.03+60.86)/5,2) WHERE listing_id=274;
UPDATE LISTING_ANALYTICS SET view_count=156, follower_count=1094, details_score=80.92, condition_score=53.27, shipping_score=80.32, pricing_score=74.19, view_to_bid_score=20.92, completeness_score=ROUND((IFNULL(photo_score,60)+80.92+53.27+80.32+74.19)/5,2) WHERE listing_id=275;
UPDATE LISTING_ANALYTICS SET view_count=750, follower_count=501, details_score=82.82, condition_score=74.54, shipping_score=79.3, pricing_score=96.56, view_to_bid_score=21.72, completeness_score=ROUND((IFNULL(photo_score,60)+82.82+74.54+79.3+96.56)/5,2) WHERE listing_id=276;
UPDATE LISTING_ANALYTICS SET view_count=225, follower_count=10892, details_score=67.13, condition_score=76.92, shipping_score=77.23, pricing_score=59.83, view_to_bid_score=13.18, completeness_score=ROUND((IFNULL(photo_score,60)+67.13+76.92+77.23+59.83)/5,2) WHERE listing_id=277;
UPDATE LISTING_ANALYTICS SET view_count=525, follower_count=6720, details_score=48.65, condition_score=76.98, shipping_score=77.69, pricing_score=58.87, view_to_bid_score=1.64, completeness_score=ROUND((IFNULL(photo_score,60)+48.65+76.98+77.69+58.87)/5,2) WHERE listing_id=278;
UPDATE LISTING_ANALYTICS SET view_count=629, follower_count=917, details_score=82.73, condition_score=67.92, shipping_score=38.38, pricing_score=98.64, view_to_bid_score=14.08, completeness_score=ROUND((IFNULL(photo_score,60)+82.73+67.92+38.38+98.64)/5,2) WHERE listing_id=279;
UPDATE LISTING_ANALYTICS SET view_count=547, follower_count=6828, details_score=83.82, condition_score=86.63, shipping_score=47.42, pricing_score=76.09, view_to_bid_score=17.06, completeness_score=ROUND((IFNULL(photo_score,60)+83.82+86.63+47.42+76.09)/5,2) WHERE listing_id=280;
UPDATE LISTING_ANALYTICS SET view_count=188, follower_count=3019, details_score=41.77, condition_score=96.44, shipping_score=81.01, pricing_score=59.91, view_to_bid_score=3.43, completeness_score=ROUND((IFNULL(photo_score,60)+41.77+96.44+81.01+59.91)/5,2) WHERE listing_id=281;
UPDATE LISTING_ANALYTICS SET view_count=418, follower_count=9454, details_score=82.06, condition_score=84.27, shipping_score=86.34, pricing_score=62.88, view_to_bid_score=11.23, completeness_score=ROUND((IFNULL(photo_score,60)+82.06+84.27+86.34+62.88)/5,2) WHERE listing_id=282;
UPDATE LISTING_ANALYTICS SET view_count=356, follower_count=3048, details_score=45.75, condition_score=67.76, shipping_score=79.51, pricing_score=92.74, view_to_bid_score=11.74, completeness_score=ROUND((IFNULL(photo_score,60)+45.75+67.76+79.51+92.74)/5,2) WHERE listing_id=283;
UPDATE LISTING_ANALYTICS SET view_count=193, follower_count=4318, details_score=64.09, condition_score=61.33, shipping_score=98.99, pricing_score=77.98, view_to_bid_score=8.46, completeness_score=ROUND((IFNULL(photo_score,60)+64.09+61.33+98.99+77.98)/5,2) WHERE listing_id=284;
UPDATE LISTING_ANALYTICS SET view_count=774, follower_count=1590, details_score=71.43, condition_score=51.02, shipping_score=72.43, pricing_score=98.92, view_to_bid_score=2.71, completeness_score=ROUND((IFNULL(photo_score,60)+71.43+51.02+72.43+98.92)/5,2) WHERE listing_id=285;
UPDATE LISTING_ANALYTICS SET view_count=387, follower_count=1614, details_score=50.11, condition_score=98.18, shipping_score=67.04, pricing_score=40.28, view_to_bid_score=9.39, completeness_score=ROUND((IFNULL(photo_score,60)+50.11+98.18+67.04+40.28)/5,2) WHERE listing_id=286;
UPDATE LISTING_ANALYTICS SET view_count=33, follower_count=9357, details_score=73.8, condition_score=92.97, shipping_score=96.9, pricing_score=51.31, view_to_bid_score=14.23, completeness_score=ROUND((IFNULL(photo_score,60)+73.8+92.97+96.9+51.31)/5,2) WHERE listing_id=287;
UPDATE LISTING_ANALYTICS SET view_count=191, follower_count=8818, details_score=53.1, condition_score=67.26, shipping_score=91.05, pricing_score=94.76, view_to_bid_score=13.79, completeness_score=ROUND((IFNULL(photo_score,60)+53.1+67.26+91.05+94.76)/5,2) WHERE listing_id=288;
UPDATE LISTING_ANALYTICS SET view_count=592, follower_count=2948, details_score=93.49, condition_score=85.32, shipping_score=91.58, pricing_score=50.65, view_to_bid_score=4.55, completeness_score=ROUND((IFNULL(photo_score,60)+93.49+85.32+91.58+50.65)/5,2) WHERE listing_id=289;
UPDATE LISTING_ANALYTICS SET view_count=460, follower_count=547, details_score=77.32, condition_score=96.76, shipping_score=92.18, pricing_score=87.62, view_to_bid_score=3.97, completeness_score=ROUND((IFNULL(photo_score,60)+77.32+96.76+92.18+87.62)/5,2) WHERE listing_id=290;
UPDATE LISTING_ANALYTICS SET view_count=324, follower_count=4824, details_score=46.47, condition_score=84.15, shipping_score=71.31, pricing_score=50.04, view_to_bid_score=3.54, completeness_score=ROUND((IFNULL(photo_score,60)+46.47+84.15+71.31+50.04)/5,2) WHERE listing_id=291;
UPDATE LISTING_ANALYTICS SET view_count=202, follower_count=9937, details_score=49.32, condition_score=80.66, shipping_score=53.62, pricing_score=67.28, view_to_bid_score=15.0, completeness_score=ROUND((IFNULL(photo_score,60)+49.32+80.66+53.62+67.28)/5,2) WHERE listing_id=292;
UPDATE LISTING_ANALYTICS SET view_count=403, follower_count=7388, details_score=96.64, condition_score=83.44, shipping_score=34.58, pricing_score=54.77, view_to_bid_score=4.4, completeness_score=ROUND((IFNULL(photo_score,60)+96.64+83.44+34.58+54.77)/5,2) WHERE listing_id=293;
UPDATE LISTING_ANALYTICS SET view_count=507, follower_count=3135, details_score=87.64, condition_score=52.08, shipping_score=34.1, pricing_score=98.94, view_to_bid_score=11.35, completeness_score=ROUND((IFNULL(photo_score,60)+87.64+52.08+34.1+98.94)/5,2) WHERE listing_id=294;
UPDATE LISTING_ANALYTICS SET view_count=680, follower_count=11643, details_score=85.28, condition_score=79.56, shipping_score=89.34, pricing_score=45.46, view_to_bid_score=14.92, completeness_score=ROUND((IFNULL(photo_score,60)+85.28+79.56+89.34+45.46)/5,2) WHERE listing_id=295;
UPDATE LISTING_ANALYTICS SET view_count=544, follower_count=9274, details_score=74.51, condition_score=76.6, shipping_score=57.59, pricing_score=72.78, view_to_bid_score=5.62, completeness_score=ROUND((IFNULL(photo_score,60)+74.51+76.6+57.59+72.78)/5,2) WHERE listing_id=296;
UPDATE LISTING_ANALYTICS SET view_count=333, follower_count=2269, details_score=66.87, condition_score=59.9, shipping_score=96.1, pricing_score=65.58, view_to_bid_score=10.42, completeness_score=ROUND((IFNULL(photo_score,60)+66.87+59.9+96.1+65.58)/5,2) WHERE listing_id=297;
UPDATE LISTING_ANALYTICS SET view_count=89, follower_count=8085, details_score=41.43, condition_score=55.22, shipping_score=69.29, pricing_score=76.58, view_to_bid_score=7.77, completeness_score=ROUND((IFNULL(photo_score,60)+41.43+55.22+69.29+76.58)/5,2) WHERE listing_id=298;
UPDATE LISTING_ANALYTICS SET view_count=794, follower_count=4755, details_score=86.25, condition_score=84.95, shipping_score=66.93, pricing_score=42.5, view_to_bid_score=20.91, completeness_score=ROUND((IFNULL(photo_score,60)+86.25+84.95+66.93+42.5)/5,2) WHERE listing_id=299;
UPDATE LISTING_ANALYTICS SET view_count=319, follower_count=9675, details_score=84.87, condition_score=78.56, shipping_score=42.14, pricing_score=58.82, view_to_bid_score=2.48, completeness_score=ROUND((IFNULL(photo_score,60)+84.87+78.56+42.14+58.82)/5,2) WHERE listing_id=300;
UPDATE LISTING_ANALYTICS SET view_count=33, follower_count=823, details_score=98.01, condition_score=69.25, shipping_score=54.62, pricing_score=72.27, view_to_bid_score=18.39, completeness_score=ROUND((IFNULL(photo_score,60)+98.01+69.25+54.62+72.27)/5,2) WHERE listing_id=301;
UPDATE LISTING_ANALYTICS SET view_count=705, follower_count=7157, details_score=84.31, condition_score=76.2, shipping_score=42.48, pricing_score=62.25, view_to_bid_score=15.83, completeness_score=ROUND((IFNULL(photo_score,60)+84.31+76.2+42.48+62.25)/5,2) WHERE listing_id=302;
UPDATE LISTING_ANALYTICS SET view_count=224, follower_count=1666, details_score=67.43, condition_score=59.29, shipping_score=45.51, pricing_score=59.22, view_to_bid_score=16.14, completeness_score=ROUND((IFNULL(photo_score,60)+67.43+59.29+45.51+59.22)/5,2) WHERE listing_id=303;
UPDATE LISTING_ANALYTICS SET view_count=512, follower_count=3437, details_score=74.27, condition_score=80.65, shipping_score=33.17, pricing_score=62.89, view_to_bid_score=19.96, completeness_score=ROUND((IFNULL(photo_score,60)+74.27+80.65+33.17+62.89)/5,2) WHERE listing_id=304;
UPDATE LISTING_ANALYTICS SET view_count=124, follower_count=4808, details_score=40.28, condition_score=62.02, shipping_score=86.95, pricing_score=89.88, view_to_bid_score=21.68, completeness_score=ROUND((IFNULL(photo_score,60)+40.28+62.02+86.95+89.88)/5,2) WHERE listing_id=305;
UPDATE LISTING_ANALYTICS SET view_count=404, follower_count=3791, details_score=62.31, condition_score=91.89, shipping_score=33.13, pricing_score=48.5, view_to_bid_score=6.55, completeness_score=ROUND((IFNULL(photo_score,60)+62.31+91.89+33.13+48.5)/5,2) WHERE listing_id=306;
UPDATE LISTING_ANALYTICS SET view_count=689, follower_count=4280, details_score=92.92, condition_score=71.14, shipping_score=69.94, pricing_score=91.82, view_to_bid_score=14.34, completeness_score=ROUND((IFNULL(photo_score,60)+92.92+71.14+69.94+91.82)/5,2) WHERE listing_id=307;
UPDATE LISTING_ANALYTICS SET view_count=214, follower_count=10754, details_score=84.2, condition_score=63.63, shipping_score=78.32, pricing_score=64.95, view_to_bid_score=9.98, completeness_score=ROUND((IFNULL(photo_score,60)+84.2+63.63+78.32+64.95)/5,2) WHERE listing_id=308;
UPDATE LISTING_ANALYTICS SET view_count=289, follower_count=3154, details_score=89.0, condition_score=74.41, shipping_score=72.01, pricing_score=77.59, view_to_bid_score=9.61, completeness_score=ROUND((IFNULL(photo_score,60)+89.0+74.41+72.01+77.59)/5,2) WHERE listing_id=309;

SET FOREIGN_KEY_CHECKS = 1;