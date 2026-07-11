-- ============================================================
-- ThriftBid v2 — Realistic Seed Data (Updated)
-- 15 listings per category × 12 categories = 180 listings
-- 5 extra users added (total 11 users)
-- Varied sizes, conditions, prices for realistic reports
-- ALL passwords = Password123!
-- ============================================================

USE thriftbid_db2;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE TRACKING_LOGS; TRUNCATE TABLE SHIPMENTS;
TRUNCATE TABLE FRAUD_FLAGS;   TRUNCATE TABLE WATCHLIST;
TRUNCATE TABLE CART_ITEMS;    TRUNCATE TABLE AWARDS;
TRUNCATE TABLE PENALTIES;     TRUNCATE TABLE REPORTS;
TRUNCATE TABLE WALLET_TRANSACTIONS; TRUNCATE TABLE TRANSACTIONS;
TRUNCATE TABLE PAYMENTS;      TRUNCATE TABLE REVIEWS;
TRUNCATE TABLE DISPUTES;      TRUNCATE TABLE NOTIFICATIONS;
TRUNCATE TABLE BIDDINGS;      TRUNCATE TABLE AUCTIONS;
TRUNCATE TABLE LISTINGS;      TRUNCATE TABLE BUNDLES;
TRUNCATE TABLE BUYER;         TRUNCATE TABLE SELLER;
TRUNCATE TABLE USERS;         TRUNCATE TABLE CATEGORIES;
TRUNCATE TABLE COURIERS;
SET FOREIGN_KEY_CHECKS = 1;

-- ── CATEGORIES ───────────────────────────────────────────────
INSERT INTO CATEGORIES (name) VALUES
('Tops'),('Bottoms'),('Dresses & Co-ords'),('Outerwear'),
('Footwear'),('Bags & Purses'),('Accessories'),('Headwear'),
('Luxury Designer Items'),('Vintage Collectibles'),
('Home & Lifestyle Items'),('Aesthetic Bundles');

-- ── USERS ────────────────────────────────────────────────────
-- Password123! hash (bcrypt-verified)
INSERT INTO USERS (username,password_hash,email,phone_number,address,is_verified,role) VALUES
('admin_thrift',  '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','admin@thriftbid.com',      '09171234567','DLSU Manila',          TRUE, 'admin'),
('seller_leila',  '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','seller_leila@thriftbid.com','09193456789','Makati City',          TRUE, 'seller'),
('seller_dhens',  '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','seller_dhens@thriftbid.com','09204567890','Pasig City',           TRUE, 'seller'),
('seller_marco',  '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','seller_marco@thriftbid.com','09221122334','BGC Taguig',           TRUE, 'seller'),
('buyer_ana',     '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','ana@email.com',            '09215678901','123 Quezon Ave, QC',   TRUE, 'buyer'),
('buyer_carlos',  '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','carlos@email.com',         '09226789012','45 Shaw Blvd, Mandaluyong',TRUE,'buyer'),
('buyer_mia',     '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','mia@email.com',            '09237890123','78 10th Ave, Caloocan', FALSE,'buyer'),
-- 5 NEW USERS
('buyer_sofia',   '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','sofia@email.com',          '09281234567','Alabang, Muntinlupa',  TRUE, 'buyer'),
('buyer_jake',    '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','jake@email.com',           '09292345678','Eastwood, QC',         TRUE, 'buyer'),
('seller_nina',   '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','nina@thriftbid.com',       '09303456789','Marikina City',        TRUE, 'seller'),
('buyer_rico',    '$2b$10$GGpD/hbHjH3idiof/2BLIeCgqbTUwi1ocVe4jw6NO36ZLCqIAy16m','rico@email.com',           '09314567890','Paranaque City',       TRUE, 'buyer');

-- ── SELLER profiles ──────────────────────────────────────────
-- user_id: 2=leila (seller_id=1), 3=dhens (seller_id=2), 4=marco (seller_id=3), 10=nina (seller_id=4)
INSERT INTO SELLER (user_id,store_loc) VALUES
(2,'Makati Ukay Hub'),(3,'Pasig Thrift Corner'),(4,'BGC Vintage Co.'),(10,'Marikina Thrift House');

-- ── BUYER profiles ───────────────────────────────────────────
-- user_id: 5=ana (buyer_id=1), 6=carlos (buyer_id=2), 7=mia (buyer_id=3), 8=sofia (buyer_id=4), 9=jake (buyer_id=5), 11=rico (buyer_id=6)
INSERT INTO BUYER (user_id,shipping_address) VALUES
(5,'123 Quezon Ave, QC'),(6,'45 Shaw Blvd, Mandaluyong'),(7,'78 10th Ave, Caloocan'),
(8,'Block 5 Alabang, Muntinlupa'),(9,'P. Tuazon Blvd, QC'),(11,'Dr. A. Santos Ave, Paranaque');

-- ── COURIERS ─────────────────────────────────────────────────
INSERT INTO COURIERS (courier_name,contact_no) VALUES
('J&T Express','1800-1888-8888'),('LBC','(02) 8585-999'),
('Flash Express','1800-7352-7464'),('GrabExpress','(02) 8856-7424'),
('Ninja Van','1800-1888-0000');

-- ── LISTINGS (15 per category, seller_id 1-4 mapped carefully to item_conditions compatible with ENUMs) ────────────────
-- Cat 1: Tops
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Vintage Levi''s Band Tee XL',   'Classic 90s band tee, slightly faded, great character', 320.00,'Lightly Used','XL',  NULL,1,1,1),
('Cropped Ribbed Knit Top S',      'Off-white ribbed knit, barely worn',                    180.00,'Like New','S',   NULL,1,1,2),
('Oversized Flannel Shirt L',      'Green plaid, cozy and soft',                            240.00,'Lightly Used','L',   NULL,1,1,1),
('Y2K Baby Tee Pink XS',           'Spaghetti strap, butterfly print, Y2K aesthetic',       150.00,'Like New','XS', NULL,1,1,3),
('Linen Button Down Shirt M',      'Cream colored, perfect for summer',                     280.00,'Like New','M',   NULL,1,1,4),
('Vintage Polo Ralph Lauren M',    'Classic fit, navy blue, minor pilling',                 420.00,'Lightly Used','M',   NULL,1,1,1),
('Tie Dye Hoodie L',               'Handmade tie dye, pullover style',                      350.00,'Lightly Used','L',   NULL,1,1,2),
('Striped Long Sleeve Top S',      'Navy and white stripes, excellent condition',            190.00,'Like New','S',  NULL,1,1,3),
('Graphic Tee - Retro Logo M',     'Retro brand logo, 100% cotton',                         200.00,'Lightly Used','M',   NULL,1,1,4),
('Off-Shoulder Ruffle Blouse M',   'White cotton, romantic style',                          260.00,'Like New','M',   NULL,1,1,1),
('Vintage Harley Davidson Tee L',  'Original 1998 tee, excellent condition',                650.00,'Like New','L',  NULL,1,1,2),
('Workout Crop Top S',             'Sports bra style, minimal wear',                        120.00,'Lightly Used','S',   NULL,1,1,3),
('Bohemian Embroidered Blouse M',  'Hand embroidery detail, artisan made',                  380.00,'Like New','M',   NULL,1,1,4),
('Oversized Vintage Sweatshirt L', 'Champion brand, faded logo',                            310.00,'Lightly Used','L',   NULL,1,1,1),
('Silk Cami Top XS',               'Ivory silk, adjustable straps',                         290.00,'Like New','XS', NULL,1,1,2);

-- Cat 2: Bottoms
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Vintage Levi''s 501 Jeans 30x32', 'Classic blue denim, minimal wear',                    580.00,'Lightly Used','M',   NULL,1,2,1),
('Wide Leg Trousers Beige M',        'Linen blend, flowy wide leg',                         320.00,'Like New','M',   NULL,1,2,2),
('Plaid Mini Skirt S',               'Black and white plaid, Y2K vibe',                    190.00,'Like New','S',  NULL,1,2,3),
('Cargo Pants Olive L',              'Multi-pocket, utility style',                         450.00,'Lightly Used','L',   NULL,1,2,4),
('High Waist Denim Shorts S',        'Light wash, distressed hem',                          220.00,'Lightly Used','S',   NULL,1,2,1),
('Palazzo Pants Floral M',           'Breathable rayon, resort wear',                       280.00,'Like New','M',   NULL,1,2,2),
('Leather Look Leggings S',          'Faux leather, comfortable stretch',                   260.00,'Lightly Used','S',   NULL,1,2,3),
('Denim Midi Skirt M',               'Button front, a-line silhouette',                     340.00,'Like New','M',  NULL,1,2,4),
('Tweed Mini Skirt S',               'Chanel-inspired, structured fit',                     480.00,'Like New','S',   NULL,1,2,1),
('Jogger Pants Gray L',              'French terry, drawstring waist',                      200.00,'Lightly Used','L',   NULL,1,2,2),
('Flare Jeans Dark Wash 28x30',      '70s inspired flare leg',                              420.00,'Lightly Used','S',   NULL,1,2,3),
('Satin Slip Skirt M',               'Champagne satin, bias cut',                           350.00,'Like New','M',   NULL,1,2,4),
('Track Pants Black L',              'Vintage adidas style',                                 230.00,'Lightly Used','L',   NULL,1,2,1),
('High Rise Mom Jeans M',            'Acid wash, 90s silhouette',                           390.00,'Like New','M',  NULL,1,2,2),
('Linen Wide Leg Pants White S',     'Breathable and elegant',                              310.00,'Like New','S',   NULL,1,2,3);

-- Cat 3: Dresses & Co-ords
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Floral Midi Dress S',          'Vintage 90s florals, button front',            450.00,'Like New','S',NULL,1,3,1),
('Linen Co-ord Set Beige M',     'Wide leg pants + matching top',                520.00,'Like New','M',NULL,1,3,2),
('Slip Dress Silk Green S',      'Forest green, spaghetti straps',               380.00,'Lightly Used','S',NULL,1,3,3),
('Babydoll Dress White XS',      'Cotton eyelet, cottagecore style',             290.00,'Like New','XS',NULL,1,3,4),
('Knit Set Two Piece M',         'Matching bralette and mini skirt',             480.00,'Lightly Used','M',NULL,1,3,1),
('Maxi Boho Dress L',            'Tiered hem, ethnic embroidery',                560.00,'Like New','L',NULL,1,3,2),
('Tennis Dress White S',         'Pleated skirt, sporty chic',                   320.00,'Like New','S',NULL,1,3,3),
('Velvet Slip Dress XS',         'Deep burgundy, 90s minimalist',                420.00,'Lightly Used','XS',NULL,1,3,4),
('Blazer Dress Pinstripe S',     'Oversized blazer dress, shoulder pads',        550.00,'Like New','S',NULL,1,3,1),
('Cottagecore Prairie Dress M',  'Long sleeve, smocked bodice',                  490.00,'Like New','M',NULL,1,3,2),
('Seersucker Set Blue S',        'Top and bermuda shorts, summer ready',         360.00,'Lightly Used','S',NULL,1,3,3),
('Denim Overall Dress M',        'Relaxed fit, adjustable straps',               340.00,'Lightly Used','M',NULL,1,3,4),
('Crochet Mini Dress XS',        'Handmade crochet, bohemian style',             620.00,'Like New','XS',NULL,1,3,1),
('Wrap Dress Floral L',          'Deep V, midi length',                           400.00,'Like New','L',NULL,1,3,2),
('Checkered Coord Set S',        'Black and white, crop top + skirt',            440.00,'Like New','S',NULL,1,3,3);

-- Cat 4: Outerwear
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Trench Coat Camel M',          'Classic trench, belted waist',                 980.00,'Lightly Used','M',NULL,1,4,1),
('Denim Jacket 90s L',           'Light wash, minimal distress',                 480.00,'Lightly Used','L',NULL,1,4,2),
('Leather Biker Jacket S',       'Faux leather, moto style',                     720.00,'Like New','S',NULL,1,4,3),
('Corduroy Blazer Brown M',      'Relaxed fit, vintage academic',                 560.00,'Lightly Used','M',NULL,1,4,4),
('Puffer Vest Black L',          'Lightweight quilted vest',                      420.00,'Like New','L',NULL,1,4,1),
('Vintage Windbreaker XL',       'Color block, 90s sportswear',                  380.00,'Lightly Used','XL',NULL,1,4,2),
('Wool Peacoat Navy M',          'Classic double breasted',                       860.00,'Like New','M',NULL,1,4,3),
('Sherpa Fleece Jacket L',       'Cream sherpa, cozy winter layer',               440.00,'Lightly Used','L',NULL,1,4,4),
('Plaid Blazer Red S',           'Oversized fit, power shoulders',                620.00,'Like New','S',NULL,1,4,1),
('Vintage MA-1 Bomber M',        'Military olive, original MA-1',                 580.00,'Lightly Used','M',NULL,1,4,2),
('Kimono Robe Floral L',         'Silk-feel kimono, streetwear style',            320.00,'Like New','L',NULL,1,4,3),
('Varsity Jacket Red/White M',   'Chenille patches, college aesthetic',           680.00,'Lightly Used','M',NULL,1,4,4),
('Cropped Moto Jacket XS',       'Short length, zipper details',                  560.00,'Like New','XS',NULL,1,4,1),
('Quilted Coach Jacket Black L', 'Coach brand, vintage style',                   1200.00,'Lightly Used','L',NULL,1,4,2),
('Pastel Blazer Set Lavender S', 'Matching blazer and shorts',                    740.00,'Like New','S',NULL,1,4,3);

-- Cat 5: Footwear
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Dr. Martens 1460 Boots UK7',   'Black, 8-eye, barely used',                   1800.00,'Like New','Free Size',NULL,1,5,1),
('Nike Air Force 1 White US8',   'Clean white, light creasing',                  1200.00,'Lightly Used','Free Size',NULL,1,5,2),
('Converse High Top Black US7',  'Classic canvas, worn-in look',                  480.00,'Lightly Used','Free Size',NULL,1,5,3),
('New Balance 574 US9',          'Grey/burgundy colorway',                         980.00,'Like New','Free Size',NULL,1,5,4),
('Vans Old Skool US8',           'Black and white, great condition',               560.00,'Lightly Used','Free Size',NULL,1,5,1),
('Levi''s Platform Loafers EU37','Black leather platform',                         640.00,'Like New','Free Size',NULL,1,5,2),
('Strappy Block Heel Sandals EU38','Tan leather straps, block heel',               420.00,'Lightly Used','Free Size',NULL,1,5,3),
('Mary Jane Shoes Patent US7',   'Glossy black, chunky sole',                     580.00,'Like New','Free Size',NULL,1,5,4),
('Timberland Boots Brown US9',   'Waterproof, worn once',                         1400.00,'Like New','Free Size',NULL,1,5,1),
('Birkenstock Arizona US8',      'Cork footbed, natural suede',                    760.00,'Lightly Used','Free Size',NULL,1,5,2),
('Adidas Samba White US9',       'Retro football shoe, minimal wear',             1100.00,'Lightly Used','Free Size',NULL,1,5,3),
('Pointed Toe Kitten Heels EU37','Nude patent leather',                            380.00,'Like New','Free Size',NULL,1,5,4),
('Chunky Dad Sneakers US8',      '90s dad shoe aesthetic, multicolor',             660.00,'Lightly Used','Free Size',NULL,1,5,1),
('Suede Chelsea Boots UK6',      'Tan suede, elastic sides',                       820.00,'Lightly Used','Free Size',NULL,1,5,2),
('Platform Mule Sandals EU38',   'Patent white, elevated sole',                    480.00,'Like New','Free Size',NULL,1,5,3);

-- Cat 6: Bags & Purses
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Coach Signature Bag Preloved', 'Authentic, minor scratches',                   2500.00,'Well Used','Free Size',NULL,1,6,1),
('Rattan Woven Tote Bag',        'Handmade, natural finish',                       380.00,'Lightly Used','Free Size',NULL,1,6,2),
('Mini Shoulder Bag White',      'Structured, clean lines',                        460.00,'Like New','Free Size',NULL,1,6,3),
('Canvas Tote Bag Oversized',    'Heavy canvas, reusable',                          180.00,'Lightly Used','Free Size',NULL,1,6,4),
('Chain Link Crossbody Black',   'Vegan leather, gold hardware',                   540.00,'Lightly Used','Free Size',NULL,1,6,1),
('Vintage Jansport Backpack',    'Navy blue, 90s original',                         320.00,'Lightly Used','Free Size',NULL,1,6,2),
('Raffia Clutch Beach Bag',      'Summer essential, gold clasp',                   280.00,'Like New','Free Size',NULL,1,6,3),
('Patchwork Denim Bag',          'Upcycled denim, unique piece',                   340.00,'Lightly Used','Free Size',NULL,1,6,4),
('Bucket Bag Tan Leather',       'Soft genuine leather',                            820.00,'Lightly Used','Free Size',NULL,1,6,1),
('Clear PVC Mini Bag',           'Transparent with colorful lining',               220.00,'Like New','Free Size',NULL,1,6,2),
('Quilted Belt Bag',             'Black quilted, gold zipper',                      360.00,'Lightly Used','Free Size',NULL,1,6,3),
('Straw Market Basket',          'Handwoven, leather handles',                      310.00,'Lightly Used','Free Size',NULL,1,6,4),
('Top Handle Box Bag',           'Structured tortoise shell',                        580.00,'Like New','Free Size',NULL,1,6,1),
('Fanny Pack Neon Green',        '90s runner fanny pack',                           180.00,'Lightly Used','Free Size',NULL,1,6,2),
('Micro Mini Bag Purple',        'Tiny chain bag, statement piece',                 260.00,'Like New','Free Size',NULL,1,6,3);

-- Cat 7: Accessories
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Pearl Layered Necklace',       'Faux pearl, chunky layers',                      180.00,'Lightly Used','Free Size',NULL,1,7,1),
('Vintage Brooch Flower',        'Gold tone, statement piece',                     140.00,'Lightly Used','Free Size',NULL,1,7,2),
('Wide Brim Leather Belt',       'Genuine leather, western buckle',                240.00,'Lightly Used','Free Size',NULL,1,7,3),
('Silk Scarf Floral 90s',        '100% silk, vintage print',                       320.00,'Like New','Free Size',NULL,1,7,4),
('Chunky Chain Necklace Silver', 'Statement necklace, weightless',                 160.00,'Lightly Used','Free Size',NULL,1,7,1),
('Enamel Pin Set Retro',         '6 pieces, assorted designs',                     120.00,'Like New','Free Size',NULL,1,7,2),
('Beaded Waist Bead Set',        'Handmade, African-inspired',                     180.00,'Lightly Used','Free Size',NULL,1,7,3),
('Vintage Watch Gold Tone',      'Analog, minimal dial',                            580.00,'Lightly Used','Free Size',NULL,1,7,4),
('Layered Charm Bracelet',       'Gold fill charms, dainty',                       200.00,'Like New','Free Size',NULL,1,7,1),
('Hoop Earrings Extra Large',    '5 inch gold hoops',                               140.00,'Lightly Used','Free Size',NULL,1,7,2),
('Woven Friendship Bracelet Set','Boho style, set of 3',                            100.00,'Lightly Used','Free Size',NULL,1,7,3),
('Tortoise Shell Hair Clip',     'Oversized claw clip',                              80.00,'Like New','Free Size',NULL,1,7,4),
('Crystal Drop Earrings',        'Art deco inspired, clear crystals',               220.00,'Lightly Used','Free Size',NULL,1,7,1),
('Suede Tassel Earrings',        'Long fringe, boho style',                        120.00,'Lightly Used','Free Size',NULL,1,7,2),
('Anklet Set Silver',            'Delicate chain, set of 2',                        90.00,'Like New','Free Size',NULL,1,7,3);

-- Cat 8: Headwear
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Vintage Starter Snapback',     '90s original, black adjustable',                 280.00,'Lightly Used','Free Size',NULL,1,8,1),
('Fisherman Beanie Cream',       'Chunky knit, rolled brim',                       180.00,'Like New','Free Size',NULL,1,8,2),
('Bucket Hat Plaid',             'Reversible, grunge aesthetic',                    200.00,'Lightly Used','Free Size',NULL,1,8,3),
('Wide Brim Straw Hat',          'Beach and picnic ready',                          220.00,'Lightly Used','Free Size',NULL,1,8,4),
('Corduroy Dad Hat Brown',       'Unstructured, adjustable strap',                 160.00,'Like New','Free Size',NULL,1,8,1),
('Knit Beret Gray',              'French style, soft acrylic',                      140.00,'Lightly Used','Free Size',NULL,1,8,2),
('Trucker Cap Retro Logo',       'Mesh back, foam front',                           190.00,'Lightly Used','Free Size',NULL,1,8,3),
('Cowboy Hat Tan',               'Suede, crushable felt',                           380.00,'Lightly Used','Free Size',NULL,1,8,4),
('Crochet Beanie Multicolor',    'Handmade, boho vibes',                            160.00,'Like New','Free Size',NULL,1,8,1),
('Baseball Cap Vintage Wash',    'Distressed effect, curved brim',                  170.00,'Lightly Used','Free Size',NULL,1,8,2),
('Fedora Black',                 'Classic felt fedora',                              340.00,'Like New','Free Size',NULL,1,8,3),
('Sailor Hat White',             'Nautical style, classic look',                    180.00,'Like New','Free Size',NULL,1,8,4),
('Porkpie Hat Plaid',            'Vintage jazz aesthetic',                           260.00,'Lightly Used','Free Size',NULL,1,8,1),
('Leopard Print Headband',       'Thick padded headband',                           100.00,'Like New','Free Size',NULL,1,8,2),
('Chain Headband Gold',          'Dainty chain, adjustable',                        140.00,'Lightly Used','Free Size',NULL,1,8,3);

-- Cat 9: Luxury Designer Items
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('LV Speedy 25 Monogram',        'Authentic, with dust bag, patina on handles',    18500.00,'Lightly Used','Free Size',NULL,1,9,1),
('Gucci Belt Black GG',          'Authentic, size 85, minor scratches',             5800.00,'Lightly Used','Free Size',NULL,1,9,2),
('Hermes Silk Scarf',            'Authentic, vintage pattern, no damage',           8200.00,'Like New','Free Size',NULL,1,9,3),
('Chanel Quilted Wallet',        'Black caviar, silver hardware, card slots',       7600.00,'Lightly Used','Free Size',NULL,1,9,4),
('Prada Nylon Mini Bag',         'Re-edition 2000, authentic',                      9800.00,'Like New','Free Size',NULL,1,9,1),
('YSL Envelope Clutch Black',    'Grain leather, gold YSL logo',                    7200.00,'Lightly Used','Free Size',NULL,1,9,2),
('Balenciaga Triple S Sneakers', 'US9, white/beige, light sole yellowing',          6500.00,'Lightly Used','Free Size',NULL,1,9,3),
('Burberry Check Scarf',         'Classic nova check, authentic',                   4200.00,'Like New','Free Size',NULL,1,9,4),
('Tory Burch Fleming Bag',       'Burgundy leather, gold logo',                     3800.00,'Lightly Used','Free Size',NULL,1,9,1),
('Kate Spade Crossbody Pink',    'Straw + leather, summer style',                   2800.00,'Like New','Free Size',NULL,1,9,2),
('Coach Tabby 26 Chalk',         'Original, minor scuff on bottom',                 4600.00,'Lightly Used','Free Size',NULL,1,9,3),
('Marc Jacobs Snapshot Bag',     'Black multi, silver hardware',                    3200.00,'Like New','Free Size',NULL,1,9,4),
('Valentino Garavani Shoes EU37','Rockstud kitten heel, nude',                      6800.00,'Lightly Used','Free Size',NULL,1,9,1),
('Bottega Veneta Pouch',         'Small woven clutch, intrecciato',                12000.00,'Lightly Used','Free Size',NULL,1,9,2),
('Dior Saddle Bag Oblique',      'Canvas and leather, with dust bag',               16500.00,'Lightly Used','Free Size',NULL,1,9,3);

-- Cat 10: Vintage Collectibles
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Vintage Walkman Sony 1985',    'Functional, original foam pads',                 1200.00,'Lightly Used','Free Size',NULL,1,10,1),
('Polaroid OneStep Camera',      'Works perfectly, with flash bar',                 980.00,'Lightly Used','Free Size',NULL,1,10,2),
('70s Bell Bottom Jeans',        'Original bell bottoms, woven detail',             480.00,'Well Used','M',        NULL,1,10,3),
('Vintage Film Posters Set',     '4 posters, 80s classics, framed',                 640.00,'Lightly Used','Free Size',NULL,1,10,4),
('Retro Lunchbox Metal',         'Classic cartoon character, original',             360.00,'Well Used','Free Size',NULL,1,10,1),
('Vintage Typewriter Olivetti',  'Manual typewriter, fully functional',            2200.00,'Lightly Used','Free Size',NULL,1,10,2),
('80s Boombox Portable',         'Cassette player, FM radio works',                1600.00,'Lightly Used','Free Size',NULL,1,10,3),
('Vinyl Record Collection 10pc', 'Assorted 70s/80s albums',                         880.00,'Lightly Used','Free Size',NULL,1,10,4),
('Vintage Cabbage Patch Doll',   'Original tag, complete outfit',                   560.00,'Lightly Used','Free Size',NULL,1,10,1),
('Gameboy Color Purple',         'Original, with 2 game cartridges',                740.00,'Lightly Used','Free Size',NULL,1,10,2),
('Vintage Tin Toy Car Set',      '6 tin cars, 1950s reproduction',                  480.00,'Lightly Used','Free Size',NULL,1,10,3),
('Polaroid Photo Album 80s',     'Full of vintage photos, memories',                320.00,'Well Used','Free Size',NULL,1,10,4),
('Vintage Baseball Card Set',    '1982 Topps complete set',                         1800.00,'Lightly Used','Free Size',NULL,1,10,1),
('Retro Alarm Clock Flip',       'Flip number display, works',                       420.00,'Lightly Used','Free Size',NULL,1,10,2),
('Comic Book Collection 1990s',  '15 comics, near mint condition',                   960.00,'Lightly Used','Free Size',NULL,1,10,3);

-- Cat 11: Home & Lifestyle Items
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Rattan Magazine Rack',         'Boho interior, natural weave',                    480.00,'Lightly Used','Free Size',NULL,1,11,1),
('Macrame Wall Hanging',         'Handmade, 60cm diameter',                         320.00,'Like New','Free Size',NULL,1,11,2),
('Vintage Ceramic Vase Set',     '3 piece, earth tones',                            560.00,'Lightly Used','Free Size',NULL,1,11,3),
('Linen Table Runner',           'Stonewashed linen, natural',                      180.00,'Like New','Free Size',NULL,1,11,4),
('Soy Wax Candle Set',           'Lavender and eucalyptus scents',                  260.00,'Like New','Free Size',NULL,1,11,1),
('Woven Storage Basket Set',     'Seagrass, set of 3 sizes',                        380.00,'Lightly Used','Free Size',NULL,1,11,2),
('Vintage Record Player Stand',  'Wood and metal, holds 100 records',               680.00,'Lightly Used','Free Size',NULL,1,11,3),
('Terrarium Glass Bowl',         'Open dish terrarium, medium',                     280.00,'Like New','Free Size',NULL,1,11,4),
('Retro Kitchen Scale',          'Cast iron, vintage aesthetic',                    340.00,'Lightly Used','Free Size',NULL,1,11,1),
('Handwoven Throw Blanket',      'Cotton blend, earth tones',                       420.00,'Like New','Free Size',NULL,1,11,2),
('Bamboo Cutting Board Set',     'Set of 3, food safe finish',                      200.00,'Like New','Free Size',NULL,1,11,3),
('Vintage Enamel Mug Set',       '4 mugs, speckled enamel, camping style',          320.00,'Lightly Used','Free Size',NULL,1,11,4),
('Framed Botanical Prints Set',  '4 prints, A4 size, pressed flowers',              480.00,'Lightly Used','Free Size',NULL,1,11,1),
('Reed Diffuser Set',            'Sandalwood scent, 200ml',                         220.00,'Like New','Free Size',NULL,1,11,2),
('Ceramic Planter Set Matte',    '3 sizes, sage green glaze',                       360.00,'Like New','Free Size',NULL,1,11,3);

-- Cat 12: Aesthetic Bundles
INSERT INTO LISTINGS (title,description,price,item_condition,size,image_url,is_active,category_id,seller_id) VALUES
('Y2K Bundle Set S',             '5 items: cami, mini skirt, belt, bag, bracelet',  680.00,'Lightly Used','S',NULL,1,12,1),
('Cottagecore Bundle M',         '4 items: floral dress, cardigan, bag, scarf',     780.00,'Lightly Used','M',NULL,1,12,2),
('Streetwear Bundle L',          '5 items: hoodie, cargo pants, cap, bag, shoes',   1200.00,'Lightly Used','L',NULL,1,12,3),
('Dark Academia Bundle S',       '4 items: blazer, trousers, loafers, bag',         1400.00,'Lightly Used','S',NULL,1,12,4),
('Boho Summer Bundle M',         '5 items: blouse, maxi skirt, bag, earrings, hat', 860.00,'Lightly Used','M',NULL,1,12,1),
('90s Grunge Bundle M',          '4 items: flannel, band tee, jeans, boots',        980.00,'Lightly Used','M',NULL,1,12,2),
('Minimalist Bundle S',          '5 items: white shirt, black jeans, shoes, bag',   1100.00,'Like New','S',NULL,1,12,3),
('Preppy Bundle M',              '4 items: polo shirt, chinos, loafers, watch',     1300.00,'Lightly Used','M',NULL,1,12,4),
('Resort Wear Bundle S',         '4 items: linen co-ord, sandals, bag, hat',         920.00,'Like New','S',NULL,1,12,1),
('Gym & Athleisure Bundle M',    '5 items: sports top, leggings, sneakers, bag',     760.00,'Lightly Used','M',NULL,1,12,2),
('Vintage Lover Bundle L',       '5 items: band tee, jeans, jacket, sneakers, cap', 1080.00,'Lightly Used','L',NULL,1,12,3),
('K-Fashion Bundle XS',          '4 items: blouse, mini skirt, platform, bag',      840.00,'Like New','XS',NULL,1,12,4),
('Smart Casual Bundle M',        '4 items: blazer, turtleneck, trousers, belt',     1250.00,'Lightly Used','M',NULL,1,12,1),
('Beach Day Bundle S',           '4 items: bikini top, shorts, cover-up, sandals',   580.00,'Like New','S',NULL,1,12,2),
('Cozy Fall Bundle L',           '4 items: knit sweater, corduroys, boots, scarf',   880.00,'Lightly Used','L',NULL,1,12,3);

-- ── AUCTIONS (mix of active and closed for realistic report data) ──
INSERT INTO AUCTIONS (start_bid,min_increment,current_highest_bid,start_time,end_time,status,listing_type,listing_id) VALUES
(200.00,  25.00, 420.00,  NOW()-INTERVAL 2 DAY,  NOW()+INTERVAL 1 DAY,  'Active','auction',1),
(300.00,  50.00, 580.00,  NOW()-INTERVAL 1 DAY,  NOW()+INTERVAL 2 DAY,  'Active','auction',6),
(400.00,  50.00, 780.00,  NOW()-INTERVAL 3 DAY,  NOW()+INTERVAL 4 HOUR,'Active','live',   16),
(2000.00,100.00,3200.00,  NOW()-INTERVAL 2 DAY,  NOW()+INTERVAL 6 HOUR,'Active','live',   46),
(12000.00,500.00,18500.00,NOW()-INTERVAL 1 DAY,  NOW()+INTERVAL 3 DAY, 'Active','auction',91),
(600.00,  100.00,980.00,  NOW()-INTERVAL 1 DAY,  NOW()+INTERVAL 5 DAY, 'Active','auction',31),
(1200.00, 100.00,1800.00, NOW()-INTERVAL 2 DAY,  NOW()+INTERVAL 2 DAY, 'Active','auction',71),
(300.00,  50.00, 640.00,  NOW()-INTERVAL 10 DAY, NOW()-INTERVAL 3 DAY, 'Closed','auction',11),
(150.00,  25.00, 310.00,  NOW()-INTERVAL 8 DAY,  NOW()-INTERVAL 2 DAY, 'Closed','auction',21),
(500.00,  50.00, 980.00,  NOW()-INTERVAL 15 DAY, NOW()-INTERVAL 5 DAY, 'Closed','auction',36),
(8000.00, 500.00,12600.00,NOW()-INTERVAL 20 DAY, NOW()-INTERVAL 7 DAY, 'Closed','auction',92),
(400.00,  50.00, 840.00,  NOW()-INTERVAL 12 DAY, NOW()-INTERVAL 4 DAY, 'Closed','auction',56);

-- ── BIDDINGS ─────────────────────────────────────────────────
INSERT INTO BIDDINGS (bid_amount,auction_id,buyer_id) VALUES
(225.00,1,1),(300.00,1,2),(350.00,1,4),(420.00,1,1),
(350.00,2,3),(450.00,2,5),(580.00,2,2),
(450.00,3,1),(550.00,3,4),(680.00,3,2),(780.00,3,1),
(2100.00,4,3),(2500.00,4,5),(2800.00,4,1),(3200.00,4,2),
(12500.00,5,6),(14000.00,5,4),(16000.00,5,2),(18500.00,5,6),
(650.00,6,3),(780.00,6,1),(980.00,6,5),
(1300.00,7,4),(1500.00,7,2),(1800.00,7,1),
(310.00,8,3),(640.00,8,5),
(180.00,9,1),(310.00,9,4),
(560.00,10,2),(840.00,10,6),(980.00,10,3),
(8500.00,11,1),(10000.00,11,5),(12600.00,11,2),
(450.00,12,4),(700.00,12,1),(840.00,12,6);

-- ── ORDERS (varied statuses for full reporting) ──────────────
INSERT INTO ORDERS (order_date,status,listing_id,buyer_id,seller_id) VALUES
(NOW()-INTERVAL 30 DAY, 'Delivered',        2,  1, 1),  
(NOW()-INTERVAL 25 DAY, 'Delivered',        18, 2, 2),  
(NOW()-INTERVAL 20 DAY, 'Delivered',        33, 3, 3),  
(NOW()-INTERVAL 18 DAY, 'Delivered',        48, 4, 4),  
(NOW()-INTERVAL 15 DAY, 'Delivered',        62, 5, 1),  
(NOW()-INTERVAL 14 DAY, 'Delivered',        72, 1, 2),  
(NOW()-INTERVAL 12 DAY, 'Delivered',        83, 2, 3),  
(NOW()-INTERVAL 10 DAY, 'Delivered',        97, 3, 4),  
(NOW()-INTERVAL 9 DAY,  'Delivered',        107,4, 1),  
(NOW()-INTERVAL 8 DAY,  'Delivered',        113,5, 2),  
(NOW()-INTERVAL 7 DAY,  'Delivered',        124,6, 3),  
(NOW()-INTERVAL 6 DAY,  'Delivered',        135,1, 4),  
(NOW()-INTERVAL 25 DAY, 'Shipped',          3,  2, 1),  
(NOW()-INTERVAL 5 DAY,  'Shipped',          19, 3, 2),  
(NOW()-INTERVAL 4 DAY,  'Out for Delivery', 34, 4, 3),  
(NOW()-INTERVAL 3 DAY,  'Out for Delivery', 50, 5, 4),  
(NOW()-INTERVAL 2 DAY,  'Preparing',        63, 6, 1),  
(NOW()-INTERVAL 1 DAY,  'Preparing',        73, 1, 2),  
(NOW()-INTERVAL 1 DAY,  'Preparing',        87, 2, 3),  
(NOW(),                 'Preparing',        98, 3, 4);  

-- ── PAYMENTS ─────────────────────────────────────────────────
INSERT INTO PAYMENTS (payment_method,amount_paid,payment_status,payment_date,order_id) VALUES
('GCash', 150.00,'Completed',NOW()-INTERVAL 30 DAY,1),
('Bank',  320.00,'Completed',NOW()-INTERVAL 25 DAY,2),
('GCash', 380.00,'Completed',NOW()-INTERVAL 20 DAY,3),
('GCash', 480.00,'Completed',NOW()-INTERVAL 18 DAY,4),
('Bank',  480.00,'Completed',NOW()-INTERVAL 15 DAY,5),
('GCash', 180.00,'Completed',NOW()-INTERVAL 14 DAY,6),
('GCash', 180.00,'Completed',NOW()-INTERVAL 12 DAY,7),
('GCash', 180.00,'Completed',NOW()-INTERVAL 10 DAY,8),
('Bank', 2800.00,'Completed',NOW()-INTERVAL 9 DAY, 9),
('GCash', 740.00,'Completed',NOW()-INTERVAL 8 DAY, 10),
('GCash', 260.00,'Completed',NOW()-INTERVAL 7 DAY, 11),
('GCash', 680.00,'Completed',NOW()-INTERVAL 6 DAY, 12),
('Bank',  240.00,'Completed',NOW()-INTERVAL 25 DAY,13),
('GCash', 190.00,'Pending',  NOW()-INTERVAL 5 DAY, 14),
('GCash', 290.00,'Pending',  NOW()-INTERVAL 4 DAY, 15);

-- ── TRANSACTIONS ─────────────────────────────────────────────
INSERT INTO TRANSACTIONS (amount,transaction_date,order_id,payment_id) VALUES
(150.00, NOW()-INTERVAL 30 DAY,1,1),(320.00,NOW()-INTERVAL 25 DAY,2,2),
(380.00, NOW()-INTERVAL 20 DAY,3,3),(480.00,NOW()-INTERVAL 18 DAY,4,4),
(480.00, NOW()-INTERVAL 15 DAY,5,5),(180.00,NOW()-INTERVAL 14 DAY,6,6),
(180.00, NOW()-INTERVAL 12 DAY,7,7),(180.00,NOW()-INTERVAL 10 DAY,8,8),
(2800.00,NOW()-INTERVAL 9 DAY, 9,9),(740.00, NOW()-INTERVAL 8 DAY,10,10),
(260.00, NOW()-INTERVAL 7 DAY,11,11),(680.00,NOW()-INTERVAL 6 DAY,12,12),
(240.00, NOW()-INTERVAL 25 DAY,13,13);

-- ── SHIPMENTS ────────────────────────────────────────────────
INSERT INTO SHIPMENTS (order_id,courier_id,tracking_number,status,shipped_date,delivered_date) VALUES
(1, 1,'JT2024001','Delivered',NOW()-INTERVAL 28 DAY,NOW()-INTERVAL 26 DAY),
(2, 2,'LBC2024002','Delivered',NOW()-INTERVAL 23 DAY,NOW()-INTERVAL 20 DAY),
(3, 3,'FX2024003', 'Delivered',NOW()-INTERVAL 18 DAY,NOW()-INTERVAL 15 DAY),
(4, 4,'GX2024004', 'Delivered',NOW()-INTERVAL 16 DAY,NOW()-INTERVAL 13 DAY),
(5, 1,'JT2024005', 'Delivered',NOW()-INTERVAL 13 DAY,NOW()-INTERVAL 10 DAY),
(6, 5,'NV2024006', 'Delivered',NOW()-INTERVAL 12 DAY,NOW()-INTERVAL 9 DAY),
(7, 2,'LBC2024007','Delivered',NOW()-INTERVAL 10 DAY,NOW()-INTERVAL 7 DAY),
(8, 1,'JT2024008', 'Delivered',NOW()-INTERVAL 8 DAY, NOW()-INTERVAL 5 DAY),
(9, 3,'FX2024009', 'Delivered',NOW()-INTERVAL 7 DAY, NOW()-INTERVAL 4 DAY),
(10,4,'GX2024010', 'Delivered',NOW()-INTERVAL 6 DAY, NOW()-INTERVAL 3 DAY),
(11,1,'JT2024011', 'Delivered',NOW()-INTERVAL 5 DAY, NOW()-INTERVAL 2 DAY),
(12,2,'LBC2024012','Delivered',NOW()-INTERVAL 4 DAY, NOW()-INTERVAL 1 DAY),
(13,3,'FX2024013', 'Delivered',NOW()-INTERVAL 23 DAY,NOW()-INTERVAL 20 DAY),
(14,1,'JT2024014', 'Shipped',  NOW()-INTERVAL 4 DAY, NULL),
(15,4,'GX2024015', 'Shipped',  NOW()-INTERVAL 3 DAY, NULL);

-- ── REVIEWS ──────────────────────────────────────────────────
INSERT INTO REVIEWS (buyer_id,seller_id,order_id,rating,review_text,review_date) VALUES
(1,1,1, 5,'Super fast shipping! Item exactly as described. Love it!',NOW()-INTERVAL 26 DAY),
(2,2,2, 4,'Good quality, slight color difference but overall happy.',NOW()-INTERVAL 20 DAY),
(3,3,3, 5,'Perfect condition. Seller was very responsive!',NOW()-INTERVAL 15 DAY),
(4,4,4, 3,'Item took a while to ship but arrived safely.',NOW()-INTERVAL 13 DAY),
(5,1,5, 5,'Exactly as described, great packaging!',NOW()-INTERVAL 10 DAY),
(1,2,6, 4,'Nice item, good deal!',NOW()-INTERVAL 9 DAY),
(2,3,7, 5,'Beautiful necklace, fast shipping!',NOW()-INTERVAL 7 DAY),
(3,4,8, 4,'Good condition, packaging could be better.',NOW()-INTERVAL 5 DAY),
(4,1,9, 5,'Authentic, with receipt. Very professional seller!',NOW()-INTERVAL 4 DAY),
(5,2,10,4,'Works perfectly, happy with the purchase.',NOW()-INTERVAL 3 DAY),
(6,3,11,5,'Love the candles, amazing scent!',NOW()-INTERVAL 2 DAY),
(1,4,12,5,'Great bundle, all items in excellent condition!',NOW()-INTERVAL 1 DAY);

-- ── NOTIFICATIONS ────────────────────────────────────────────
INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type,is_read) VALUES
(5,'You have been outbid!','Someone placed a higher bid on Vintage Levi''s 501.','BID',0),
(6,'Bid placed!','Your bid of ₱3,200 on Coach Bag is now the highest.','BID',0),
(2,'Payment Received!','Payment for order #1 received. Please ship!','ORDER',1),
(3,'Payment Received!','Payment for order #2 received. Please ship!','ORDER',1),
(5,'Order Shipped!','Your order has been shipped via J&T. Tracking: JT2024005','ORDER',0),
(6,'Order Delivered!','Your order #9 has been delivered. Please confirm.','ORDER',0),
(1,'Welcome back!','You have logged in to ThriftBid.','SYSTEM',1),
(8,'Auction Ending Soon!','LV Speedy auction ends in less than 3 hours!','AUCTION',0),
(9,'You have been outbid!','Someone placed a higher bid on Polo Ralph Lauren Shirt.','BID',0),
(2,'New Order Received!','A buyer purchased your item. Please prepare for shipment.','ORDER',0),
(1,'Bid placed!','Your bid of ₱18,500 on LV Speedy is the highest!','BID',1),
(11,'Auction Ending Soon!','Trench Coat auction ends in 5 hours!','AUCTION',0),
(5,'Auction Ending Soon!','Dr. Martens boots auction ends in 2 days!','AUCTION',0);

-- ── DISPUTES ─────────────────────────────────────────────────
INSERT INTO DISPUTES (order_id,buyer_id,seller_id,reason,status,opened_at) VALUES
(4, 4, 4, 'Item took longer than 5 days to ship, no tracking provided.', 'Resolved', NOW()-INTERVAL 12 DAY),
(15,5, 4, 'Wrong item received, not as described in listing.', 'Open', NOW()-INTERVAL 3 DAY);

-- ── PENALTIES ────────────────────────────────────────────────
INSERT INTO PENALTIES (seller_id,reason,status,issued_at,period_end) VALUES
(4,'Late shipment: failed to ship within 48 hours.','Served',NOW()-INTERVAL 12 DAY,NOW()-INTERVAL 5 DAY);

-- ── AWARDS ───────────────────────────────────────────────────
INSERT INTO AWARDS (seller_id,reason,status,issued_at,period_end) VALUES
(1,'Top Seller of the Month — Highest Revenue','Active',NOW()-INTERVAL 5 DAY,NOW()+INTERVAL 25 DAY),
(2,'Most 5-Star Reviews — March 2025','Active',NOW()-INTERVAL 3 DAY,NOW()+INTERVAL 27 DAY);

-- ── BUNDLES ──────────────────────────────────────────────────
INSERT INTO BUNDLES (seller_id,bundle_name,bundle_price,created_at) VALUES
(1,'Leila Y2K Starter Pack',680.00,NOW()-INTERVAL 20 DAY),
(2,'Dhens Streetwear Bundle',1200.00,NOW()-INTERVAL 15 DAY),
(3,'Marco Luxury Collection',8500.00,NOW()-INTERVAL 10 DAY),
(4,'Nina Home Essentials Set',960.00,NOW()-INTERVAL 7 DAY);

-- ── TRACKING LOGS ────────────────────────────────────────────
INSERT INTO TRACKING_LOGS (shipment_id,location,status,updated_at) VALUES
(1,'Makati Sortation Center','Picked Up',NOW()-INTERVAL 28 DAY),
(1,'Manila Distribution Hub','In Transit',NOW()-INTERVAL 27 DAY),
(1,'QC Delivery Branch','Out for Delivery',NOW()-INTERVAL 26 DAY),
(14,'Pasig Sortation Center','Picked Up',NOW()-INTERVAL 4 DAY),
(14,'Manila Distribution Hub','In Transit',NOW()-INTERVAL 3 DAY);

-- ── FRAUD FLAGS (for admin dashboard testing) ────────────────
INSERT INTO FRAUD_FLAGS (auction_id,buyer_id,seller_id,reason,status,created_at) VALUES
(4, 3, 2, 'Suspicious bidding pattern: buyer and seller IP addresses match.','Pending',NOW()-INTERVAL 2 DAY),
(5, 6, 1, 'Multiple accounts bidding from same household IP.','Pending',NOW()-INTERVAL 1 DAY);

-- ── WALLET TRANSACTIONS ──────────────────────────────────────
INSERT INTO WALLET_TRANSACTIONS (user_id,amount,transaction_type,transaction_date,status) VALUES
(5, 150.00,'Hold',   NOW()-INTERVAL 30 DAY,'Completed'),
(5, 150.00,'Release',NOW()-INTERVAL 26 DAY,'Completed'),
(6, 320.00,'Hold',   NOW()-INTERVAL 25 DAY,'Completed'),
(6, 320.00,'Release',NOW()-INTERVAL 20 DAY,'Completed'),
(7, 380.00,'Hold',   NOW()-INTERVAL 20 DAY,'Completed'),
(7, 380.00,'Release',NOW()-INTERVAL 15 DAY,'Completed'),
(8, 480.00,'Hold',   NOW()-INTERVAL 18 DAY,'Completed'),
(8, 480.00,'Release',NOW()-INTERVAL 13 DAY,'Completed'),
(6,2800.00,'Hold',   NOW()-INTERVAL 9 DAY, 'Completed'),
(9, 740.00,'Hold',   NOW()-INTERVAL 8 DAY, 'Completed'),
(5, 260.00,'Hold',   NOW()-INTERVAL 7 DAY, 'Completed'),
(5, 680.00,'Hold',   NOW()-INTERVAL 6 DAY, 'Completed'),
(6, 240.00,'Hold',   NOW()-INTERVAL 25 DAY,'Completed');