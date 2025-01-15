-----------------------------------------
-- Drop old schema
-----------------------------------------
DROP SCHEMA IF EXISTS lbaw2496 CASCADE;
CREATE SCHEMA lbaw2496;
SET search_path TO lbaw2496;

DROP TABLE IF EXISTS Wishlist CASCADE;
DROP TABLE IF EXISTS ShoppingCart_Game CASCADE;
DROP TABLE IF EXISTS game_category  CASCADE;
DROP TABLE IF EXISTS GameOrderDetails CASCADE;
DROP TABLE IF EXISTS CustomerSupportAdministrator CASCADE;
DROP TABLE IF EXISTS Notification CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Image CASCADE;
DROP TABLE IF EXISTS game CASCADE;
DROP TABLE IF EXISTS Administrator CASCADE;
DROP TABLE IF EXISTS Seller CASCADE;
DROP TABLE IF EXISTS Buyer CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS ShoppingCart CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS HelpSupport CASCADE;
DROP TABLE IF EXISTS Storage CASCADE;
DROP TABLE IF EXISTS GraphicsCard CASCADE;
DROP TABLE IF EXISTS Processor CASCADE;
DROP TABLE IF EXISTS MemoryRAM CASCADE;
DROP TABLE IF EXISTS OperatingSystem CASCADE;
DROP TABLE IF EXISTS category CASCADE;

DROP DOMAIN IF EXISTS RatingRange CASCADE;
DROP DOMAIN IF EXISTS Positive CASCADE;

DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS items CASCADE;

-----------------------------------------
-- Types
-----------------------------------------

CREATE DOMAIN RatingRange AS NUMERIC CHECK (VALUE >= 0 AND VALUE <= 5);
CREATE DOMAIN Positive AS NUMERIC CHECK (VALUE >= 0);

-----------------------------------------
-- Tables
-----------------------------------------

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    bio TEXT,
    registrationDate TIMESTAMP DEFAULT CURRENT_DATE NOT NULL,
    role INTEGER NOT NULL DEFAULT 1 CHECK (role IN (1, 2, 3)),
    profile_picture TEXT,
    is_review_blocked BOOLEAN DEFAULT FALSE
);


CREATE TABLE cards (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  user_id INTEGER REFERENCES users NOT NULL
);

CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  card_id INTEGER NOT NULL REFERENCES cards ON DELETE CASCADE,
  description VARCHAR NOT NULL,
  done BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE Buyer (
    id_user INTEGER PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE Seller (
    id_user INTEGER PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    rating RatingRange,
    total_sales_number INTEGER DEFAULT 0,
    total_earned Positive  DEFAULT 0
);

CREATE TABLE Administrator (
    id_user INTEGER PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE Payment (
    id SERIAL PRIMARY KEY,
    amount Positive NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE Storage (
    id SERIAL PRIMARY KEY,
    storage INTEGER NOT NULL
);

CREATE TABLE GraphicsCard (
    id SERIAL PRIMARY KEY,
    graphicscard TEXT NOT NULL
);

CREATE TABLE Processor (
    id SERIAL PRIMARY KEY,
    processor TEXT NOT NULL
);

CREATE TABLE MemoryRAM (
    id SERIAL PRIMARY KEY,
    memoryram INTEGER NOT NULL
);

CREATE TABLE OperatingSystem (
    id SERIAL PRIMARY KEY,
    operatingsystem TEXT NOT NULL
);

CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE game (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    price Positive NOT NULL,
    release_date TIMESTAMP DEFAULT CURRENT_DATE NOT NULL,
    description TEXT,
    rating RatingRange,
    stock Positive NOT NULL,
    id_seller INTEGER NOT NULL REFERENCES Seller (id_user),
    id_operatingsystem INTEGER NOT NULL REFERENCES OperatingSystem (id),
    id_memoryram INTEGER REFERENCES MemoryRAM (id),
    id_processor INTEGER REFERENCES Processor (id),
    id_graphicscard INTEGER REFERENCES GraphicsCard (id),
    id_storage INTEGER REFERENCES Storage (id),
    is_highlighted BOOLEAN DEFAULT FALSE NOT NULL,
    is_on_sale BOOLEAN DEFAULT FALSE NOT NULL,
    discount_price Positive
);

CREATE TABLE ShoppingCart (
    id_buyer INTEGER NOT NULL REFERENCES Buyer (id_user) ON DELETE CASCADE,
    id_game INTEGER NOT NULL REFERENCES game (id) ON DELETE CASCADE,
    PRIMARY KEY (id_buyer, id_game)
);

-- Note that a plural 'Orders' name was adopted because Order is a reserved word in PostgreSQL.
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    order_date TIMESTAMP DEFAULT CURRENT_DATE NOT NULL,
    total_price Positive NOT NULL,
    id_payment INTEGER NOT NULL REFERENCES Payment (id),
    id_buyer INTEGER NOT NULL REFERENCES Buyer (id_user) ON DELETE CASCADE
);

CREATE TABLE Image (
    id SERIAL PRIMARY KEY,
    image_path TEXT NOT NULL,
    id_game INTEGER REFERENCES game (id) ON DELETE CASCADE,
    id_user INTEGER REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT GameOrImage CHECK ((id_game IS NOT NULL AND id_user IS NULL) OR (id_game IS NULL AND id_user IS NOT NULL))
);

CREATE TABLE GameOrderDetails (
    id_order INTEGER REFERENCES Orders (id) ON DELETE CASCADE,
    id_game INTEGER REFERENCES game (id) ON DELETE CASCADE,
    review_rating RatingRange,
    review_comment TEXT,
    review_date TIMESTAMP,
    purchase_price Positive NOT NULL,
    PRIMARY KEY (id_order, id_game)
);

CREATE TABLE game_category  (
    id_game INTEGER NOT NULL REFERENCES game (id) ON DELETE CASCADE,
    id_category INTEGER NOT NULL REFERENCES category (id) ON DELETE CASCADE,
    PRIMARY KEY (id_game, id_category)
);

CREATE TABLE Wishlist (
    id_buyer INTEGER NOT NULL REFERENCES Buyer (id_user) ON DELETE CASCADE,
    id_game INTEGER UNIQUE NOT NULL REFERENCES game (id) ON DELETE CASCADE,
    PRIMARY KEY (id_buyer, id_game)
);

CREATE TABLE helpsupport (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    help_date TIMESTAMP DEFAULT CURRENT_DATE NOT NULL,
    type TEXT CHECK (type IN ('CS', 'GS')),
    id_buyer INTEGER NOT NULL REFERENCES Buyer (id_user) ON DELETE CASCADE
);
CREATE TABLE SupportConversations (
    id SERIAL PRIMARY KEY,
    id_buyer INTEGER NOT NULL REFERENCES Buyer(id_user) ON DELETE CASCADE,
    id_seller INTEGER NOT NULL REFERENCES Seller(id_user) ON DELETE CASCADE,
    id_game INTEGER NOT NULL REFERENCES Game(id) ON DELETE CASCADE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE SupportMessages (
    id SERIAL PRIMARY KEY,
    id_conversation INTEGER NOT NULL REFERENCES SupportConversations(id) ON DELETE CASCADE,
    sender_role TEXT NOT NULL CHECK (sender_role IN ('buyer', 'seller')),
    response_message TEXT NOT NULL,
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Notification (
    id SERIAL PRIMARY KEY,
    notification_date TIMESTAMP DEFAULT CURRENT_DATE NOT NULL,
    isread BOOLEAN NOT NULL,
    id_order INTEGER REFERENCES Orders (id) ON DELETE CASCADE,
    id_game INTEGER REFERENCES game (id) ON DELETE CASCADE,
    customer_support_not INTEGER REFERENCES HelpSupport (id),
    price_change_not INTEGER REFERENCES game (id),
    product_availability_not INTEGER REFERENCES game (id),
    id_user INTEGER NULL REFERENCES users (id),
    CONSTRAINT WitchNot CHECK (
        (id_order IS NOT NULL AND id_game IS NOT NULL AND customer_support_not IS NULL AND price_change_not IS NULL AND product_availability_not IS NULL) OR
        (id_order IS NULL AND id_game IS NULL AND customer_support_not IS NOT NULL AND price_change_not IS NULL AND product_availability_not IS NULL) OR
        (id_order IS NULL AND id_game IS NULL AND customer_support_not IS NULL AND price_change_not IS NOT NULL AND product_availability_not IS NULL) OR
        (id_order IS NULL AND id_game IS NULL AND customer_support_not IS NULL AND price_change_not IS NULL AND product_availability_not IS NOT NULL)
    )
);

CREATE TABLE CustomerSupportAdministrator (
    id_cs INTEGER NOT NULL REFERENCES HelpSupport (id) ON DELETE CASCADE,
    id_admin INTEGER NOT NULL REFERENCES Administrator (id_user)ON DELETE CASCADE,
    PRIMARY KEY (id_cs, id_admin)
);

CREATE TABLE password_resets (
    email VARCHAR(255) NOT NULL,
    token VARCHAR(60) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (email, token)
);

-----------------------------------------
-- INDEXES
-----------------------------------------

CREATE INDEX IDX_user_username ON users USING btree (username);
CREATE INDEX IDX_game_seller_price ON game USING btree (id_seller, price);
CREATE INDEX IDX_notifications_user ON Notification USING btree (id_user, notification_date);

-- FTS INDEXES

-----------------------------------------
-- Add column to Game to store computed ts_vectors.
ALTER TABLE Game
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors for Game.
CREATE FUNCTION game_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (NEW.name <> OLD.name OR NEW.description <> OLD.description)) THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', NEW.description), 'B')
        );
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Create trigger before insert or update on Game.
CREATE TRIGGER game_search_update
BEFORE INSERT OR UPDATE ON Game
FOR EACH ROW
EXECUTE PROCEDURE game_search_update();

-- Finally, create a GIN index for ts_vectors in Game.
CREATE INDEX search_idx_game ON game USING GIN (tsvectors);
-----------------------------------------

-----------------------------------------
-- Add column to GameOrderDetails to store computed ts_vectors.
ALTER TABLE GameOrderDetails 
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors for GameOrderDetails.
CREATE FUNCTION review_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.review_comment <> OLD.review_comment) THEN
        NEW.tsvectors = to_tsvector('english', NEW.review_comment);
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Create trigger before insert or update on GameOrderDetails.
CREATE TRIGGER review_search_update BEFORE INSERT OR UPDATE ON GameOrderDetails FOR EACH ROW EXECUTE PROCEDURE review_search_update();

-- Finally, create a GIN index for ts_vectors in GameOrderDetails.
CREATE INDEX search_idx_review ON GameOrderDetails USING GIN (tsvectors);
-----------------------------------------

-----------------------------------------
-- Add column to HelpSupport to store computed ts_vectors.
ALTER TABLE HelpSupport
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors for HelpSupport.
CREATE FUNCTION support_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.message <> OLD.message) THEN
        NEW.tsvectors = to_tsvector('english', NEW.message);
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Create trigger before insert or update on HelpSupport.
CREATE TRIGGER support_search_update
BEFORE INSERT OR UPDATE ON HelpSupport
FOR EACH ROW
EXECUTE PROCEDURE support_search_update();

-- Finally, create a GIN index for ts_vectors in HelpSupport.
CREATE INDEX search_idx_support ON HelpSupport USING GIN (tsvectors);
-----------------------------------------

-----------------------------------------
-- TRIGGERS and UDFs
-----------------------------------------

-- TRIGGER01
-- Send a notification to users who have a game in their shopping cart or wishlist whenever the price of that game changes.
CREATE OR REPLACE FUNCTION notify_price_change() RETURNS TRIGGER AS
$BODY$
BEGIN
    -- Check if the price has changed
    IF OLD.price <> NEW.price THEN
        -- Insert notifications for all users with this game in their shopping cart
        INSERT INTO lbaw2496.Notification (
            notification_date, 
            isread, 
            id_order, 
            id_game, 
            customer_support_not, 
            price_change_not, 
            product_availability_not, 
            id_user
        )
        SELECT  
            CURRENT_TIMESTAMP,
            FALSE,
            NULL,
            NULL,
            NULL,
            NEW.id AS price_change_not,
            NULL,
            ShoppingCart.id_buyer
        FROM lbaw2496.ShoppingCart AS ShoppingCart
        WHERE ShoppingCart.id_game = NEW.id;

        -- Insert notifications for all users with this game in their wishlist
        INSERT INTO lbaw2496.Notification (
            notification_date, 
            isread, 
            id_order, 
            id_game, 
            customer_support_not, 
            price_change_not, 
            product_availability_not, 
            id_user
        )
        SELECT  
            CURRENT_TIMESTAMP,
            FALSE,
            NULL,
            NULL,
            NULL,
            NEW.id AS price_change_not,
            NULL,
            Wishlist.id_buyer
        FROM lbaw2496.Wishlist AS Wishlist
        WHERE Wishlist.id_game = NEW.id;
    END IF;
    RETURN NEW;
END
$BODY$
LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER notify_price_change_trigger 
    AFTER UPDATE ON game 
    FOR EACH ROW 
    WHEN (OLD.price IS DISTINCT FROM NEW.price) 
    EXECUTE FUNCTION notify_price_change();

	
-- TRIGGER02
-- Update Total Price in ShoppingCart
/*CREATE OR REPLACE FUNCTION update_total_price() RETURNS TRIGGER AS $$
BEGIN
    UPDATE ShoppingCart
    SET total_price = (SELECT COALESCE(SUM(price), 0)
                      FROM game g
                      JOIN ShoppingCart_Game scg ON g.id = scg.id_game
                      WHERE scg.id_shoppingcart = NEW.id_shoppingcart)
    WHERE id = NEW.id_shoppingcart;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_total_price
AFTER INSERT OR DELETE ON ShoppingCart_Game
FOR EACH ROW EXECUTE FUNCTION update_total_price();*/

-- TRIGGER03
-- Automatically Update TotalSalesNumber and TotalEarned for Seller
CREATE OR REPLACE FUNCTION update_seller_stats() RETURNS TRIGGER AS $$
DECLARE
    v_id_seller INTEGER;
BEGIN
    -- Loop through each game in the order
    FOR v_id_seller IN
        SELECT DISTINCT g.id_seller
        FROM GameOrderDetails god
        JOIN Game g ON g.id = god.id_game
        WHERE god.id_order = NEW.id
    LOOP
        -- Update the seller stats for each seller in the order
        UPDATE Seller
        SET total_sales_number = total_sales_number + 1,
            total_earned = total_earned + NEW.total_price
        WHERE id_user = v_id_seller;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_seller_stats
AFTER INSERT ON Orders
FOR EACH ROW EXECUTE FUNCTION update_seller_stats();


-- TRIGGER04
-- Update Seller Rating on New Review
CREATE OR REPLACE FUNCTION update_seller_rating() RETURNS TRIGGER AS $$
DECLARE
    v_id_seller INTEGER;
BEGIN
    -- Fetch the id_seller from the Game table
    SELECT id_seller INTO v_id_seller
    FROM lbaw2496.Game
    WHERE id = NEW.id_game;

    -- Only update if the seller exists
    IF v_id_seller IS NOT NULL THEN
        -- Update the average rating for the seller
        UPDATE Seller
        SET rating = (SELECT AVG(review_rating) FROM GameOrderDetails god
                      JOIN game g ON god.id_game = g.id
                      WHERE g.id_seller = v_id_seller AND review_rating IS NOT NULL)
        WHERE id_user = v_id_seller;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_seller_rating
AFTER INSERT OR UPDATE ON GameOrderDetails
FOR EACH ROW EXECUTE FUNCTION update_seller_rating();



-- TRIGGER05
-- Game Sold Notifications

CREATE OR REPLACE FUNCTION send_game_sold_notification() RETURNS TRIGGER AS $$
DECLARE
    v_id_user INTEGER;
BEGIN
    -- Fetch the id_user (id_seller)
    SELECT id_seller INTO v_id_user
    FROM Game
    WHERE id = NEW.id_game;

    -- Insert notification
    INSERT INTO Notification (notification_date, isread, id_order, id_game, id_user)
    VALUES (NOW(), FALSE, NEW.id_order, NEW.id_game, v_id_user);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_send_game_sold_notification
AFTER INSERT ON GameOrderDetails
FOR EACH ROW EXECUTE FUNCTION send_game_sold_notification(); 


-- TRIGGER06
-- Product Availability Notifications
CREATE OR REPLACE FUNCTION send_product_availability_notification() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO lbaw2496.Notification (notification_date, isread, product_availability_not, id_user)
    SELECT NOW(), FALSE, NEW.id, Wishlist.id_buyer
    FROM lbaw2496.Wishlist
    WHERE Wishlist.id_game = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_send_product_availability_notification
AFTER UPDATE OF stock ON Game
FOR EACH ROW
WHEN (NEW.stock > 0 AND OLD.stock = 0)
EXECUTE FUNCTION send_product_availability_notification();

-- TRIGGER07
-- Customer Support Notifications
CREATE OR REPLACE FUNCTION send_customer_support_notification() RETURNS TRIGGER AS $$
DECLARE
    v_id_buyer INTEGER;
BEGIN
    -- Fetch the id_buyer from the HelpSupport table
    SELECT id_buyer INTO v_id_buyer
    FROM HelpSupport
    WHERE id = NEW.id_cs;

    -- Insert notification
    INSERT INTO Notification (notification_date, isread, customer_support_not, id_user)
    VALUES (NOW(), FALSE, NEW.id_cs, v_id_buyer);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_send_customer_support_notification
AFTER INSERT ON CustomerSupportAdministrator
FOR EACH ROW EXECUTE FUNCTION send_customer_support_notification();


-- TRIGGER08
-- Updating Game Rating on New Review
CREATE OR REPLACE FUNCTION update_game_rating() RETURNS TRIGGER AS $$
BEGIN
    -- Update the average rating for the game
    UPDATE Game
    SET rating = (SELECT AVG(review_rating) 
                  FROM GameOrderDetails 
                  WHERE id_game = NEW.id_game 
                  AND review_rating IS NOT NULL)
    WHERE id = NEW.id_game;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_game_rating
AFTER INSERT OR UPDATE OF review_rating ON GameOrderDetails
FOR EACH ROW EXECUTE FUNCTION update_game_rating();


-- TRIGGER09
-- Manage Game Discounts
CREATE OR REPLACE FUNCTION enforce_discount_price_null()
RETURNS TRIGGER AS $$
BEGIN
    -- If the game is not on sale, set discount_price to NULL
    IF NEW.is_on_sale = FALSE THEN
        NEW.discount_price := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER discount_price_null_trigger
BEFORE INSERT OR UPDATE ON game
FOR EACH ROW
EXECUTE FUNCTION enforce_discount_price_null();


CREATE OR REPLACE FUNCTION sync_category_sequence() 
RETURNS trigger AS $$
BEGIN
    PERFORM setval('lbaw2496.category_id_seq', (SELECT MAX(id) FROM lbaw2496.category), true);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_category_sequence_trigger
AFTER INSERT OR DELETE ON category
FOR EACH ROW
EXECUTE FUNCTION sync_category_sequence();

-----------------------------------------
-- Default User
-----------------------------------------
-- Create a default user with id = 1 called Anonymous
INSERT INTO users (name, username, email, password, bio, registrationDate, role)
VALUES ('Anonymous', 'anonymous', 'anonymous@example.com', '$2y$10$nG2GuJmTSpU3EOlh79eZQuCGLh2B6RONzBHg2jA13AYgMDv4FnatC', 'Default anonymous user', CURRENT_DATE, 2);

-----------------------------------------
-- Transactions
-----------------------------------------
-- Buying a game, updating stock and creating an entry order
CREATE OR REPLACE FUNCTION process_purchase(p_game_id INT, p_total_price NUMERIC, p_payment_id INT, p_buyer_id INT)
RETURNS VOID AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    -- Start transaction with repeatable read isolation level
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    -- Check stock
    SELECT stock INTO v_stock
    FROM game 
    WHERE id = p_game_id;

    -- Ensure there is enough stock before proceeding
    IF v_stock > 0 THEN
        -- Update stock
        UPDATE Game
        SET stock = stock - 1
        WHERE id = p_game_id AND stock > 0;

        -- Insert order
        INSERT INTO Orders (order_date, total_price, id_payment, id_buyer)
        VALUES (NOW(), p_total_price, p_payment_id, p_buyer_id);

        COMMIT;
    ELSE
        RAISE EXCEPTION 'Insufficient stock for game id %', p_game_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Announcing a game for sale by creating a new game entry in the Game table and associating categories
CREATE OR REPLACE FUNCTION list_game(
    p_name TEXT, p_price NUMERIC, p_release_date TIMESTAMP, p_description TEXT, p_rating NUMERIC, p_stock NUMERIC, 
    p_id_payment INTEGER, p_id_seller INTEGER, p_id_operating_system INTEGER, p_id_memory_ram INTEGER, 
    p_id_processor INTEGER, p_id_graphics_card INTEGER, p_id_storage INTEGER, p_id_category INTEGER, 
    p_image_path TEXT ,p_is_highlighted BOOLEAN, p_is_on_sale BOOLEAN
)
RETURNS VOID AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    -- Insert game
    INSERT INTO game (name, price, release_date, description, rating, stock, id_seller, 
                      id_operatingsystem, id_memoryram, id_processor, id_graphicscard, id_storage, 
                      is_highlighted, is_on_sale)
    VALUES (p_name, p_price, p_release_date, p_description, p_rating, p_stock, p_id_seller, 
            p_id_operating_system, p_id_memory_ram, p_id_processor, p_id_graphics_card, p_id_storage, 
            p_is_highlighted, p_is_on_sale);

    -- Insert related categories
    INSERT INTO game_category (id_game, id_category)
    VALUES (currval('game_id_seq'), p_id_category);

    -- Insert images for the game
    INSERT INTO Image (image_path, id_game)
    VALUES (p_image_path, currval('game_id_seq'));

    -- Commit the transaction
    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Deleting an account and anonymizing public content
CREATE OR REPLACE FUNCTION delete_user_account(p_user_id INTEGER)
RETURNS VOID AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    -- Anonymize user
    UPDATE GameOrderDetails
    SET id_buyer = 1
    WHERE id_order IN (SELECT id FROM Orders WHERE id_buyer = p_user_id);

    -- Update orders to reflect the anonymized user
    UPDATE Orders
    SET id_buyer = 1
    WHERE id_buyer = p_user_id;

    -- Delete the user from users table
    DELETE FROM users
    WHERE id = p_user_id;

    -- Commit the transaction
    COMMIT;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------
-- End of Schema
-----------------------------------------


-- Populate users
INSERT INTO users (name, username, email, password, bio, registrationDate, role) VALUES
('John Doe', 'johndoe', 'johndoe@example.com', '$2y$10$CPIAdzuXC5YJJevC1pArjOakPg/PWKepIPDv.mxy.9IR1w.kybZzC', 'Gamer and developer', CURRENT_DATE, 2), -- 'password123' id(2) seller
('Jane Smith', 'janesmith', 'janesmith@example.com', '$2y$10$bP6KooDp6BK4dFivPimS9.LVGTtoPsdNVhm9BlM6vxvbVYiVaVbP2', 'Game enthusiast', CURRENT_DATE, 1), -- 'securepass' id(3) buyer
('Alice Johnson', 'alicej', 'alice@example.com', '$2y$10$sG8aOdH4A4sX7WjUnjmP9uzNg2aQV7uroXHlvqvgLO9bQxTRfAwWW', 'Love RPG games', CURRENT_DATE, 1), -- 'alicepass' id(4) buyer
('Bob Brown', 'bobb', 'bob@example.com', '$2y$10$RKWYNKNZZq7Hs8ibGN3XXuCFhDrX8tQLGiCfq7Vng1AKynixoTypO', 'Action game lover', CURRENT_DATE, 3), -- 'bobpass' id(5) admin
('Charlie Black', 'charlie', 'charlie@example.com', '$2y$10$Fa7XuvZZ3xXTrIfYXKRMjejafIbA3d5UHp8DDq2QrfiFFSEkzqWaW', 'Casual gamer', CURRENT_DATE, 3), -- 'charliepass' id(6) admin
('David Green', 'davidg', 'david@example.com', '$2y$10$UaecTbcfHIb.jMrMSFLlh.8rAu.oaKQHuqsoGeRjMhE9jeymX7mfa', 'Strategy game lover', CURRENT_DATE, 1), -- 'davidpass' id(7) buyer
('Emma White', 'emmaw', 'emma@example.com', '$2y$10$v3CLSs3GFyZ79b14yj936O1A.zFULtnFZKVl6iuT9ko7CZpg49YJe', 'Puzzle game enthusiast', CURRENT_DATE, 1), -- 'emmapass' id(8) buyer
('Frank Miller', 'frankm', 'frank@example.com', '$2y$10$16Fi0n/1ehhtMlt.Tvita.9/76g.hO55eYhwmGitdGCviKBzYt6c6', 'Adventure game fan', CURRENT_DATE, 1), -- 'frankpass' id(9) buyer
('Grace Lee', 'gracel', 'grace@example.com', '$2y$10$/47H5wR5ieuNSbAuHn5LiuyzY49NJoUPP4sfrWTWWh2sFSD9jFjRa', 'Horror game enthusiast', CURRENT_DATE, 1), -- 'gracepass' id(10) buyer
('Henry Adams', 'henrya', 'henry@example.com', '$2y$10$Umee1QBFZszpL.mmn6Ivsu7ZQ2/xaNgL57R1QY1g2xzffo9VMrZvm', 'Sci-Fi game lover', CURRENT_DATE, 1), -- 'henrypass' id(11) buyer
('Ivy Brown', 'ivyb', 'ivy@example.com', '$2y$10$p9TGSDqZ7S9Q7gvqCOgCT.4emddA.xBIeWo55GYJV2fAcxDAwE1uu', 'Fantasy game enthusiast', CURRENT_DATE, 1), -- 'ivypass' id(12) buyer
('Jack Clark', 'jackc', 'jack@example.com', '$2y$10$JqQKMeBL2wvGYJKN343JXeL5SrnnXcGxjJ2hm8/iEZiJ10sJTI4Em', 'Sports game fan', CURRENT_DATE, 1), -- 'jackpass' id(13) buyer
('Karen Davis', 'karend', 'karen@example.com', '$2y$10$wF5OnNIpXjeB.wA0EBqOIO0b1nznA1YRyvxRKDXzbcwahlGUE3J/y', 'Simulation game lover', CURRENT_DATE, 1), -- 'karenpass' id(14) buyer
('Laura Johnson', 'lauraj', 'laura@example.com', '$2y$10$WkukqMgBDtn1if2cbUkWG.s9EeJ9Dc4qozdHIkp1EWlUHQ/F6T3B2', 'Puzzle game expert', CURRENT_DATE, 1), -- 'laurapass' id(15) buyer
('Michael Evans', 'michaele', 'michael@example.com', '$2y$10$zrZQ9v8h4YvcMoQ6ZHu62uHBAmUuxErEb/Z2iYdbCkdHnPOYe7UZK', 'Racing game enthusiast', CURRENT_DATE, 1), -- 'michaelpass' id(16) buyer
('Nina Harris', 'ninah', 'nina@example.com', '$2y$10$oR4CIYSwMcSBxoZ8e3u9s.3U/BYg3NOrZdNNlVsuTpa/v36ZG8EaO', 'Adventure game fan', CURRENT_DATE, 1), -- 'ninapass' id(17) buyer
('Oscar Wilson', 'oscarw', 'oscar@example.com', '$2y$10$XeDXZpWqMkawizSZPagP8.YeLsdmN8gnJG5b4IivCnEFFeyq0rucy', 'Strategy game enthusiast', CURRENT_DATE, 1), -- 'oscarpass' id(18) buyer
('Paula Thomas', 'paulat', 'paula@example.com', '$2y$10$NgYsPoYVnWprNrdkJ81r9OU55Lft6IS0/NF0FAbYqNm3TejN8Oy4e', 'Action game lover', CURRENT_DATE, 1), -- 'paulapass' id(19) buyer
('Melissa Corker', 'mcorker0', 'mcorker0@cocolog-nifty.com', '$2a$04$5Hld.jxdZuLiu7UEUIZvlOhhnp3O7KrtB.xzk4BWho6Upe0AnPHiC', 'Casual gamer who enjoys playing on weekends', '2024-10-08 16:53:19', 1), -- password = username until the end
('Emlen Akroyd', 'eakroyd1', 'eakroyd1@bing.com', '$2a$04$7P8t2LzdoSVQzFdnLg7HtehucCt8EiauLUCHFqVVrbSzp/nIkboSm', 'Casual gamer who enjoys playing on weekends', '2024-05-03 12:48:27', 1),
('Elsey Lammerts', 'elammerts2', 'elammerts2@sfgate.com', '$2a$04$/sK8OXLuOaiygX6.gtZ4tOM/6T0z/gF0lGBQliOKe16nhrB3pd80y', 'Competitive gamer specializing in first-person shooters', '2024-10-06 20:19:26', 1),
('Hagen Bartosinski', 'hbartosinski3', 'hbartosinski3@altervista.org', '$2a$04$IvhVW9jh3rhmshvlVfY8WetaCYbYMxhu29SMTJHoaB62RiaizUpSq', 'Professional gamer with over 10 years of experience', '2024-06-21 12:25:26', 1),
('Alleyn Landman', 'alandman4', 'alandman4@sciencedaily.com', '$2a$04$RBGZgFgEpbUSM.TqOawV6e6iqlZW156fZG8rCHXisRQ6qrVLcK4cS', 'Casual gamer who enjoys playing on weekends', '2024-02-16 00:49:22', 1),
('Catherin Killeen', 'ckilleen5', 'ckilleen5@java.com', '$2a$04$6MHay49o2R1VPL7pVqBAjeysB7BldYDMZIsESaWSaId4JGudbHaGG', 'Casual gamer who enjoys playing on weekends', '2024-04-16 20:46:13', 1),
('Petunia Bevis', 'pbevis6', 'pbevis6@reference.com', '$2a$04$NW2wUFBMwaRhmHxcf95WLuy9dlV0aOl3HFP59otjHoZ037sqSARRG', 'Competitive gamer specializing in first-person shooters', '2024-02-04 23:19:36', 1),
('Tandy Rilings', 'trilings7', 'trilings7@huffingtonpost.com', '$2a$04$qeck03ssiZZEjCahc8XNv.c9O3cJfA6YIEe73wAyGkechGi2aNT/C', 'Competitive gamer specializing in first-person shooters', '2024-05-19 15:22:33', 1),
('Buckie Caras', 'bcaras8', 'bcaras8@apple.com', '$2a$04$F0MpWXSkZdQg3yZlkaF28uBLCn3BOjwFs5y8b9j18DMCP7a7lMqYe', 'Competitive gamer specializing in first-person shooters', '2024-03-20 03:27:00', 1),
('Kelly Sabbin', 'ksabbin9', 'ksabbin9@example.com', '$2a$04$6wfjNQxA1CiGtk4d4oKRWeM8flLEGLwm6gDsz.byObzj1Xs5ZuZNi', 'Competitive gamer specializing in first-person shooters', '2024-08-03 22:10:07', 1),
('Dmitri Magner', 'dmagnera', 'dmagnera@goo.ne.jp', '$2a$04$rhVla832/OsZDUvD7xbeV.ePUTDatUrpkKluIwKNKcOtg060w5Ux6', 'Competitive gamer specializing in first-person shooters', '2024-08-18 02:54:34', 1),
('Vivia Gilvear', 'vgilvearb', 'vgilvearb@ftc.gov', '$2a$04$6vBnpby9mrKNuRurzbdLqeGgiRD1SJCsWuIkjkJKe4vliU3q7OMyK', 'Casual gamer who enjoys playing on weekends', '2024-02-20 17:32:44', 1),
('Alexina Turney', 'aturneyc', 'aturneyc@seesaa.net', '$2a$04$8cKm/s3EjlxDuNEGQ/VCwuUwMUUNzi3gyYpgc5q.ViDVzrA3cQa8i', 'Competitive gamer specializing in first-person shooters', '2024-01-25 01:10:07', 1),
('Christin Shepstone', 'cshepstoned', 'cshepstoned@tmall.com', '$2a$04$zzgs3TPeMLczEH.49D7Wfe85qk/5pb0kicGb5ymiA./8i6vl9k3FK', 'Professional gamer with over 10 years of experience', '2024-11-18 07:39:52', 1),
('Jolyn Wreak', 'jwreake', 'jwreake@google.com.hk', '$2a$04$odcOUiW.yfBjtkZ0r1vQSe6adJmwmdVCNy9tPg5ATxXcZUz7pEDea', 'Competitive gamer specializing in first-person shooters', '2024-11-27 22:57:40', 1),
('Sonni Barca', 'sbarcaf', 'sbarcaf@gov.uk', '$2a$04$r615jI2dMmEsWm.XIQFg5.xSVPYUQceQIY17aIXvdfvNq.RHn.m.q', 'Casual gamer who enjoys playing on weekends', '2024-11-04 17:07:40', 1),
('Honoria Bruntje', 'hbruntjeg', 'hbruntjeg@smugmug.com', '$2a$04$/pNp.BQGLux1KI/3jKR7JOBSXdEDKRJ7JQRBh4C2LHRSxzNpm5/Z2', 'Professional gamer with over 10 years of experience', '2024-07-08 20:58:20', 1),
('Katrina Shilvock', 'kshilvockh', 'kshilvockh@google.ru', '$2a$04$V2Kzoc/P6SpHW4x76zvZPu9yhC6yl.hm76eoykeOJGJRUY5CtS3Uy', 'Competitive gamer specializing in first-person shooters', '2024-03-17 20:19:00', 1),
('Gayleen Evers', 'geversi', 'geversi@blinklist.com', '$2a$04$YBXTKxYhwgYaoSHsJpz71e6of2C2spkhzg2J2lMJynantQ4cV35Si', 'Professional gamer with over 10 years of experience', '2024-09-30 12:31:48', 1),
('Ezequiel Greves', 'egrevesj', 'egrevesj@dion.ne.jp', '$2a$04$2vCbQ9QuBnRfmmCM/AAM7ODdVsF98h8bsTdgcY.9PUAs/gq67rOim', 'Casual gamer who enjoys playing on weekends', '2024-03-12 19:04:56', 1),
('Chelsy Othen', 'cothenk', 'cothenk@stumbleupon.com', '$2a$04$Q8iU0u.kjBjFkbUIFwfG9eEvP5LZDwv8Rm7NIG8tQyiSOJtfYldi.', 'Professional gamer with over 10 years of experience', '2024-10-29 08:24:12', 1),
('Monte Ladbury', 'mladburyl', 'mladburyl@barnesandnoble.com', '$2a$04$d/5bUi0wyj5tfA9VXdcnpux95t/svDYqoywdoAIRn7Bmmv9RJKXnq', 'Competitive gamer specializing in first-person shooters', '2024-05-26 11:01:05', 1),
('Kellyann O''Carran', 'kocarranm', 'kocarranm@washington.edu', '$2a$04$.iuWs/mtm7ND2Ev/MuS9HOombNhHWR2JGGiHgVOo6nDdRlGq6v362', 'Competitive gamer specializing in first-person shooters', '2024-04-21 00:20:27', 1),
('Dulcinea Ding', 'ddingn', 'ddingn@wp.com', '$2a$04$AM6D9Vxepo/52JPS73qaDOqfCtotygx4VrUZk7.cKFRxsBwHnuasO', 'Casual gamer who enjoys playing on weekends', '2024-03-09 09:56:00', 1),
('Skye Ashurst', 'sashursto', 'sashursto@sakura.ne.jp', '$2a$04$7GyMa74ohJgiHFcK33rDdOYGr22WMhfm4LIK.F3xu90nnNok3GFvK', 'Competitive gamer specializing in first-person shooters', '2024-02-02 23:01:53', 1),
('Bordie Paddington', 'bpaddingtonp', 'bpaddingtonp@chron.com', '$2a$04$7mai9LQtug.QSqs9g1xkhO3OzyruJX3rjTZzoicqH.pqM50ZzuAly', 'Professional gamer with over 10 years of experience', '2024-07-31 12:01:50', 1),
('Lexine Oels', 'loelsq', 'loelsq@i2i.jp', '$2a$04$1j7.ZH7VYiUEgYnnCp9SHeE4u64R97a91AdljGimerNQ9c/YRu8Fm', 'Casual gamer who enjoys playing on weekends', '2024-02-09 20:44:13', 1),
('Zia Ubee', 'zubeer', 'zubeer@dot.gov', '$2a$04$C6X8Ae/NhSXmxr1eQukwKuSCDvVmaRyylDzA5f4VKC6VgewQXu5KK', 'Professional gamer with over 10 years of experience', '2024-12-05 06:17:39', 1),
('Dorthea Crasswell', 'dcrasswells', 'dcrasswells@theguardian.com', '$2a$04$ZZtLMKws.C3LBw/ihIEaoOJWNIxWqHXWLJ/G1AoQJxf4uvQvoKDf.', 'Competitive gamer specializing in first-person shooters', '2024-04-10 05:07:26', 1),
('Efren MacKay', 'emackayt', 'emackayt@patch.com', '$2a$04$USVGdBvzSbVso/Pmn3B7V.uJ0FwxmtX3v4gjzMpm44oWQLjV8WnEi', 'Competitive gamer specializing in first-person shooters', '2024-04-16 02:45:36', 1),
('Laetitia Reide', 'lreideu', 'lreideu@skype.com', '$2a$04$QCD3Eexj0tL10dKuDf2EUOXCFVqnMtO9aHhP0JkFUhG0aZoBgdJ4S', 'Casual gamer who enjoys playing on weekends', '2024-02-13 13:01:28', 1),
('Parker Staniland', 'pstanilandv', 'pstanilandv@uol.com.br', '$2a$04$EZXOrBlVmstqa.FCQfuNW.ppEr/A5AzuWuGeC9t74ZqF6AcnrOwh.', 'Competitive gamer specializing in first-person shooters', '2024-06-21 23:28:53', 1),
('Sadye Crumbie', 'scrumbiew', 'scrumbiew@mit.edu', '$2a$04$jAls.ZCdYjKvtzPMdUHyaucGLvovbal5rV4apQrpNB6SUKucofK36', 'Casual gamer who enjoys playing on weekends', '2024-03-18 07:08:24', 1),
('Powell Franssen', 'pfranssenx', 'pfranssenx@live.com', '$2a$04$9RTsPr58r7Bvv0KoNwJsT..FADRHC82.W/CXaVnW9JASa6uEbZjWO', 'Competitive gamer specializing in first-person shooters', '2024-05-25 04:33:26', 1),
('Gustavus Geibel', 'ggeibely', 'ggeibely@addthis.com', '$2a$04$IK6HsTZmsowiOSkfxeEnOOMEnjtIiag8N8AuV3j5dprUmCNCjCi92', 'Professional gamer with over 10 years of experience', '2024-09-15 04:08:13', 1),
('Etty Clulee', 'ecluleez', 'ecluleez@soup.io', '$2a$04$mGnO6nqiV2.n6sPIRY0dceGFB3NUVTR0UoL2AWn.L1kCjmt98KNna', 'Competitive gamer specializing in first-person shooters', '2023-12-23 17:50:09', 1),
('Sven Airey', 'sairey10', 'sairey10@live.com', '$2a$04$srI77vBSKLt7aBnb6FWWROnvUKW01l/lnwEJ6KlyA.tlJgHfBNLfm', 'Casual gamer who enjoys playing on weekends', '2024-08-01 16:38:24', 1),
('Latisha Heersma', 'lheersma11', 'lheersma11@soup.io', '$2a$04$V5NfCY9aiVbco1Svmh9KwuhvAlArtL214LDZSz6zfcBDtMYvyVy0a', 'Professional gamer with over 10 years of experience', '2024-10-26 04:36:05', 1),
('Peggi Maiden', 'pmaiden12', 'pmaiden12@techcrunch.com', '$2a$04$l2b0P0atun8xFIn41UortuDnDDa2G1xkTXTGj6ViUlHd0FpDOBQ6C', 'Professional gamer with over 10 years of experience', '2024-11-04 17:31:15', 1),
('Sloan Housaman', 'shousaman13', 'shousaman13@hp.com', '$2a$04$pdMCCv7j8jFvGAk86oHwcOLbA8Sd8hAIehU6tWOl1wCJQJQGI8sZW', 'Casual gamer who enjoys playing on weekends', '2024-01-01 12:08:44', 1),
('Ulrika Georgeou', 'ugeorgeou14', 'ugeorgeou14@bloglovin.com', '$2a$04$uU.X5wafPUQ/hGYoVBkyzeIQwftFV2GP4YZ/pcHmQpuI4HNqnOdhO', 'Competitive gamer specializing in first-person shooters', '2024-03-09 06:55:49', 1),
('Orson Trevallion', 'otrevallion15', 'otrevallion15@wikimedia.org', '$2a$04$/UAxui1zDWckl447b1Pay.bMOg1SOnxZHGXcRFEdOgdV3H9/BaAk6', 'Competitive gamer specializing in first-person shooters', '2024-05-29 21:04:46', 1),
('Inglebert Edds', 'iedds16', 'iedds16@flavors.me', '$2a$04$Ls29VraaSUFoo.gB.iobEuvpTN0nEbIjbSBks0ocfQ/F3DJajyPXm', 'Professional gamer with over 10 years of experience', '2024-03-09 06:54:33', 1),
('Johny Stayt', 'jstayt17', 'jstayt17@digg.com', '$2a$04$BynvoOTikpbYqFHIGifOhOX9UU9hbWY/xlvQ2iYTngZsFDhI5HNye', 'Casual gamer who enjoys playing on weekends', '2024-06-10 02:53:51', 1),
('Mellie Shilliday', 'mshilliday18', 'mshilliday18@newyorker.com', '$2a$04$sQl/M3QQRMoamnFD0uYwwezEsMzMnzVWkIlmpZ3wBLPd/bd4MDoCK', 'Casual gamer who enjoys playing on weekends', '2024-07-23 05:39:31', 1),
('Ive Bromwich', 'ibromwich19', 'ibromwich19@ifeng.com', '$2a$04$zdPqmnoqLAs9hXgSdsqdPe2/xLnBQiZbU08rf7JgXtMWxwWd2i/Tq', 'Professional gamer with over 10 years of experience', '2024-03-22 08:05:52', 1),
('Clarissa Mompesson', 'cmompesson1a', 'cmompesson1a@artisteer.com', '$2a$04$2voXwTFMxSvoonrbwuCLvOnRQefb9P5cHl7/AXG62w12hz.XRWnNC', 'Casual gamer who enjoys playing on weekends', '2024-03-10 07:41:18', 1),
('Sergio Mathivon', 'smathivon1b', 'smathivon1b@dropbox.com', '$2a$04$AjvwyvSLV/Ujqg2EavPxRupd4w4LjBZFZmikqKgLVKIPDSDskhVnC', 'Casual gamer who enjoys playing on weekends', '2024-07-21 22:13:32', 1),
('Dionisio Collough', 'dcollough1c', 'dcollough1c@howstuffworks.com', '$2a$04$Bw9N6kCF4nCgWrTiGp8giOgvxisQiCdTscedvlVE2csz4EBtwmzRq', 'Competitive gamer specializing in first-person shooters', '2024-01-26 23:00:58', 1),
('Reta Luckman', 'rluckman1d', 'rluckman1d@creativecommons.org', '$2a$04$3OcTYUSeAWcVrgTgpOl5/.TJFv.sjNXajzkNYPqUOOSlqPDILHpJa', 'Casual gamer who enjoys playing on weekends', '2024-04-04 07:20:55', 1),
('Cassi Pocklington', 'cpocklington1e', 'cpocklington1e@domainmarket.com', '$2a$04$MDnZ0YmehLqz/2dgDWVR6earUEMJMNtXMx1px6nUAeEEiMFXVT9OC', 'Professional gamer with over 10 years of experience', '2024-05-16 09:37:41', 1),
('Carrissa Sambath', 'csambath1f', 'csambath1f@usnews.com', '$2a$04$timXHLI1e0PDne3lKhUeHO492jJTq80xKxsCmJeW8ohDM3GR71OPS', 'Professional gamer with over 10 years of experience', '2024-02-17 01:38:41', 1),
('Cherri Bode', 'cbode1g', 'cbode1g@google.com', '$2a$04$AmjbaEFIDaFIcn1JGAqFTOoBEQbrUGof5b8A0QSpR5SLG/eT4hFdK', 'Casual gamer who enjoys playing on weekends', '2024-03-29 12:00:25', 1),
('Alida Dickens', 'adickens1h', 'adickens1h@cornell.edu', '$2a$04$bQfYgfqDWQS6p3wHdZTj8.KjOCEhJ8VHzlglyFTs47tp25Oc/fx9m', 'Professional gamer with over 10 years of experience', '2024-07-13 14:26:14', 1),
('Chicky Knowller', 'cknowller1i', 'cknowller1i@cyberchimps.com', '$2a$04$2kS1UQEZ1y0zbu9q6XxjouK71S3rQgbHen.hpGFZREByy2yoifP0y', 'Competitive gamer specializing in first-person shooters', '2024-03-25 21:10:57', 1),
('Zola Penney', 'zpenney1j', 'zpenney1j@angelfire.com', '$2a$04$oYhycxcbL8QFgLIBQJ1tVOoGzsSw/gK8DZ.1x9PC5aMhL.rqhXnfm', 'Casual gamer who enjoys playing on weekends', '2024-01-02 19:47:00', 1),
('Marilyn Forton', 'mforton1k', 'mforton1k@artisteer.com', '$2a$04$h4izKpGWrXFvQeNbRS9YVeADDf81tGXAON/fSxTxlcZ.lxU3jI5OW', 'Competitive gamer specializing in first-person shooters', '2024-02-28 14:15:09', 1),
('Clarita Torrent', 'ctorrent1l', 'ctorrent1l@globo.com', '$2a$04$wbEw0/ruBeUl1pgtjmmV5uX5oGSgAaCxo27Nw0D6kavGX/99Bq4UG', 'Competitive gamer specializing in first-person shooters', '2024-01-05 06:46:55', 1),
('Juanita Sturmey', 'jsturmey1m', 'jsturmey1m@icq.com', '$2a$04$o/fsLJ2ONVxjjld9B7/tzuQVZvKPtEIQDXsB9YxKfpj.7l5HFuj6S', 'Casual gamer who enjoys playing on weekends', '2024-02-17 16:21:55', 1),
('Andris Lehrian', 'alehrian1n', 'alehrian1n@npr.org', '$2a$04$/lSDu.dGVoYFGbk7yWnOiezqHlduyFxGwM2CsRL0mfJEufPqNgi/i', 'Competitive gamer specializing in first-person shooters', '2024-10-09 21:11:28', 1),
('Brooks Mellmer', 'bmellmer1o', 'bmellmer1o@slashdot.org', '$2a$04$.pt3KqbhtuMdM22AWRysruTDQxQ9xiV7ecPeg6tpemBPQOR.P3eUu', 'Competitive gamer specializing in first-person shooters', '2024-07-28 00:06:34', 1),
('Lauren Haysom', 'lhaysom1p', 'lhaysom1p@sitemeter.com', '$2a$04$.2uWZoukvMyU2NRpfzNX0.B7LzktUDgk3Hwz5KAH9hXVAoYFso9su', 'Competitive gamer specializing in first-person shooters', '2024-04-11 22:26:28', 1),
('Britni Purton', 'bpurton1q', 'bpurton1q@4shared.com', '$2a$04$16lmozozNa/49qI3oNNGIeF5IpQE4VT6jcAgUATZyj31vsl0UUIPO', 'Casual gamer who enjoys playing on weekends', '2024-11-11 06:16:52', 1),
('Alla Swanston', 'aswanston1r', 'aswanston1r@marriott.com', '$2a$04$XY3EZ10lt4vO4uybhuMDX.olKeFhUsMFzw3Uy3BhgaypGlWzQUpf6', 'Competitive gamer specializing in first-person shooters', '2024-05-06 01:28:02', 1),
('Killie Grewer', 'kgrewer1s', 'kgrewer1s@hud.gov', '$2a$04$i6xEeWv90dyyFvVHzmxh5.WGwnCIXkmdPKhcJ8nzXS5wae9GtlVza', 'Competitive gamer specializing in first-person shooters', '2023-12-30 15:43:37', 1),
('Justina Normanville', 'jnormanville1t', 'jnormanville1t@archive.org', '$2a$04$humGe9vhx5LOsO4PZDLhf.SA69nW9bObtDlDQsDtsAYa4AR/JEe4W', 'Competitive gamer specializing in first-person shooters', '2024-09-25 23:32:28', 1),
('Tamarah Males', 'tmales1u', 'tmales1u@fc2.com', '$2a$04$cO7YE5Uo8jJ..AOs3Vf7lu1o/Yzvv.dROyoTV.nwyJluwubwwk8na', 'Professional gamer with over 10 years of experience', '2024-07-20 18:32:34', 1),
('Bea Filipiak', 'bfilipiak1v', 'bfilipiak1v@google.pl', '$2a$04$j8gR32wSqNKGyWIW//TvceccRM.yocvBesZS12Z2xWgoe/8YpFcFu', 'Casual gamer who enjoys playing on weekends', '2024-04-04 01:15:23', 1),
('Delly Slee', 'dslee1w', 'dslee1w@blogger.com', '$2a$04$Oetl7nUmuIVi62nT6oF5ieyBUrkeSGvfbq2g.oX8hYyOBLDbTbeHG', 'Competitive gamer specializing in first-person shooters', '2024-02-23 09:09:13', 1),
('Tamqrah Boston', 'tboston1x', 'tboston1x@uiuc.edu', '$2a$04$AgA2xlF9x.88ov1zbbHZ4O9Zkb74ZxF18VhK1RYraz5d7lDPnsNrK', 'Professional gamer with over 10 years of experience', '2024-03-23 23:29:56', 1),
('Nert Gladdish', 'ngladdish1y', 'ngladdish1y@altervista.org', '$2a$04$XM.1vq7ZqKx.rhkmAKGvD.PFPl4WAkaFrVE2H6PEjF68VxPbAki6m', 'Casual gamer who enjoys playing on weekends', '2024-10-25 08:47:21', 1),
('Carolee Keasley', 'ckeasley1z', 'ckeasley1z@seesaa.net', '$2a$04$a5jJn/rVsjq5jw6oLAGeWuPkZs/UUglHoy5lw53Fg0wJ9ls/ODgRu', 'Casual gamer who enjoys playing on weekends', '2024-07-10 19:44:41', 1),
('Kiley Leefe', 'kleefe20', 'kleefe20@hexun.com', '$2a$04$dtjA./FnjKtdfaMi8VIqoOBCroNWL96zpUvnWx8NGUNktB6d2Ef1.', 'Casual gamer who enjoys playing on weekends', '2024-12-12 17:42:37', 1),
('Selle Abramson', 'sabramson21', 'sabramson21@com.com', '$2a$04$wZjjI8nxsSaBP.TFkUtqSOdRSE.B6y.IB5YnUhRsqRQpcJn7x0WMy', 'Professional gamer with over 10 years of experience', '2024-01-21 18:00:03', 1),
('Addy Norster', 'anorster22', 'anorster22@hubpages.com', '$2a$04$KbjjsdMAH1laAyzoeXYIleg/fZ/EO0dPePyoiX07WtR9xdc7fNaOu', 'Competitive gamer specializing in first-person shooters', '2024-09-08 00:51:26', 1),
('Estell Crinion', 'ecrinion23', 'ecrinion23@1und1.de', '$2a$04$yinuKue4rCJn1CXSqfqXEOyA4nXUd6uomryth9gHRQVS7Occv/5sa', 'Professional gamer with over 10 years of experience', '2024-08-07 03:30:42', 1),
('Maurizio Antic', 'mantic24', 'mantic24@netscape.com', '$2a$04$H3sLnQWOjfNmkRbNTDR7gegoiL8rF.bjuirLQ8KYBB12.WAhCHIz6', 'Professional gamer with over 10 years of experience', '2024-10-13 09:37:14', 1),
('Torey Darby', 'tdarby25', 'tdarby25@answers.com', '$2a$04$6IoOVjhjkAiOI7ySiADmOuvSH3kAU4.iiJJExOng6Zv7KQG/L8KGm', 'Competitive gamer specializing in first-person shooters', '2024-05-18 14:47:54', 1),
('Mariquilla Cheak', 'mcheak26', 'mcheak26@themeforest.net', '$2a$04$8H/YPcetWO8wtIzuPZBuR.kyVp3RqkdLHX6ldjzS3rztiBPAh8h2G', 'Competitive gamer specializing in first-person shooters', '2024-07-02 07:58:19', 1),
('Lewiss McKennan', 'lmckennan27', 'lmckennan27@squidoo.com', '$2a$04$DWUj0IKM8rMRgOj/Tkdnpeunw9/Si7.eyyz/y6N8G3FN5m0MF8zdO', 'Casual gamer who enjoys playing on weekends', '2024-09-28 15:50:25', 1),
('Rorie Oakton', 'roakton28', 'roakton28@goodreads.com', '$2a$04$7gm9ENK.LqBHB6Wue4YYYOd2XI9dNKYs56Y/cgNCIoyKypZ1y00k2', 'Professional gamer with over 10 years of experience', '2023-12-29 07:02:10', 1),
('Katine Braybrooks', 'kbraybrooks29', 'kbraybrooks29@homestead.com', '$2a$04$KVyqE77Iefuz6vWdY2eXvO93o9kOfJwXWpvcjYqeEPcQLRAvn8hlK', 'Professional gamer with over 10 years of experience', '2024-06-13 09:56:36', 1),
('Penni Hatherleigh', 'phatherleigh2a', 'phatherleigh2a@sun.com', '$2a$04$iXpElxjfaJ5.li06kAK2OOKFzC1puyztWTYgXVDngnErMmPhZz9uy', 'Casual gamer who enjoys playing on weekends', '2024-11-13 14:09:15', 1),
('Leann Antonik', 'lantonik2b', 'lantonik2b@so-net.ne.jp', '$2a$04$4VD4Oa/AOamoFTFs5zJVLODsw7.jWm0ZpypkXxvkrY9PatzZ3w6Ra', 'Casual gamer who enjoys playing on weekends', '2024-03-05 03:55:17', 1),
('Eb Beardwell', 'ebeardwell2c', 'ebeardwell2c@google.ru', '$2a$04$YxI8b.1RYSqYnpPJP8Axg.MJ4p6QUvxnxTawwNZN57Ar9Rno/aocu', 'Casual gamer who enjoys playing on weekends', '2024-03-16 17:34:29', 1),
('Adela Jotcham', 'ajotcham2d', 'ajotcham2d@dailymail.co.uk', '$2a$04$.AJcA3E06m21pB/xe0O7IeKJcmqiw2KxetwY2DNwEHjcLcjzbo21i', 'Competitive gamer specializing in first-person shooters', '2024-02-16 02:43:58', 1),
('Giulio Priditt', 'gpriditt2e', 'gpriditt2e@europa.eu', '$2a$04$W0ovOY7El/XRUWzqK3J.OeHqeQX7KeDSPWwMDztDDhSNXDzS8Nbjm', 'Casual gamer who enjoys playing on weekends', '2023-12-30 09:41:02', 1),
('Guillaume Rannigan', 'grannigan2f', 'grannigan2f@qq.com', '$2a$04$v8aDWc56L2n12dWLGCSzyub4n4HKCxfD5UyIEUnkhi/ujcTprzxa2', 'Casual gamer who enjoys playing on weekends', '2024-11-01 10:07:37', 1),
('Leonard Rapinett', 'lrapinett2g', 'lrapinett2g@simplemachines.org', '$2a$04$6SWy2IgmzKPPhahPput4FO9KhT3t.WdHki2N2dui33VWId8hbNx56', 'Casual gamer who enjoys playing on weekends', '2024-04-05 02:11:58', 1),
('Nolly Lempel', 'nlempel2h', 'nlempel2h@sourceforge.net', '$2a$04$elAv7KHWEf.LrrW8nu7BkOl7VTllR82W77fuJzRTeJ.aUjpTLUKV2', 'Professional gamer with over 10 years of experience', '2024-06-06 19:34:36', 1),
('Kurt Hatje', 'khatje2i', 'khatje2i@ifeng.com', '$2a$04$JGsJYr3QyFAsC/SlZ2Yj7O5w97Ln0p.hhOnYp7F.zSSmw8MtJgAT2', 'Casual gamer who enjoys playing on weekends', '2024-07-12 14:27:35', 1),
('Iago Callaway', 'icallaway2j', 'icallaway2j@usnews.com', '$2a$04$g6eaozqa92CdUyLlq7ffKOp6I4x/.XRo3oqB4UwlxzNIPt8Z0zhNi', 'Casual gamer who enjoys playing on weekends', '2024-05-18 14:46:37', 1),
('Deny Woodburne', 'dwoodburne2k', 'dwoodburne2k@blogger.com', '$2a$04$zRSxEbsK2HsGhOMMlZUBHOUNe.ne.hvAkq8FXoVrD.vQp.4JqKTEW', 'Professional gamer with over 10 years of experience', '2023-12-28 00:05:18', 1),
('Paolo Gisbye', 'pgisbye2l', 'pgisbye2l@cmu.edu', '$2a$04$sRX20SwVLSwlxSk5Vh5sD.tNpGVl2sDJ7GTw6Kx.lfT/plVfA/b9S', 'Professional gamer with over 10 years of experience', '2024-07-28 19:14:19', 1),
('Dicky Manon', 'dmanon2m', 'dmanon2m@examiner.com', '$2a$04$FxCruuu98PWPgPrfI7iXRu3g/CPy8JT/HWw6nlyucPYeHxxZMOlYm', 'Casual gamer who enjoys playing on weekends', '2024-08-27 04:26:08', 1),
('Trace Ianitti', 'tianitti2n', 'tianitti2n@shutterfly.com', '$2a$04$6a0owKJWOqkDVkZA/zxhduTsflgBBrCIVp2.OhL9TNIM7trO9HfdO', 'Casual gamer who enjoys playing on weekends', '2024-07-18 02:54:56', 1),
('Hinze Jillions', 'hjillions2o', 'hjillions2o@yelp.com', '$2a$04$MaOz5Gm67fxNB4qwl16VMubB4dX.gaVlwq60DEj61b9zUhDr53stG', 'Competitive gamer specializing in first-person shooters', '2024-09-13 17:12:45', 1),
('Martynne Penley', 'mpenley2p', 'mpenley2p@bigcartel.com', '$2a$04$jsLVHkRKLbGgr.sWSOuyr.eqfy0Z18Zkeo74juKs4gjCtjwqjb4dS', 'Professional gamer with over 10 years of experience', '2024-03-04 08:16:03', 1),
('Darcy Jerrard', 'djerrard2q', 'djerrard2q@csmonitor.com', '$2a$04$OpkPSK/KfJUSfjGw7OW57ufMZkmzNOgEzYS2g0FjHuXj43/SEL3wK', 'Professional gamer with over 10 years of experience', '2024-12-17 00:57:28', 1),
('Eudora Cianelli', 'ecianelli2r', 'ecianelli2r@artisteer.com', '$2a$04$aBBeUECbSUY2zsQAe7UcqeQ//NRW6jie.Ybi/eMyifEkFRodZIwSi', 'Professional gamer with over 10 years of experience', '2024-04-07 19:55:14', 1),
('Polly Yeatman', 'pyeatman2s', 'pyeatman2s@geocities.com', '$2a$04$I4QyGqri8CINkfHwlLnoseagZhCEsx/r/AbYC8uLQAv7ycFQt7JB.', 'Professional gamer with over 10 years of experience', '2024-05-06 16:04:58', 1),
('Moishe Thewlis', 'mthewlis2t', 'mthewlis2t@weather.com', '$2a$04$OJgWy9Ai/OR/AzhbfYLyo.B9562lC3Qb34kTYCssuNtJnLzZbVNY6', 'Casual gamer who enjoys playing on weekends', '2024-03-21 21:23:36', 1),
('Dilan Axby', 'daxby2u', 'daxby2u@google.com.br', '$2a$04$O/e/KowhdBui0.Z645DycevrVNuBs.j3hnMEe6ZGzfY4IDzDT0kga', 'Casual gamer who enjoys playing on weekends', '2024-04-11 02:24:24', 1),
('Cortney Gudgin', 'cgudgin2v', 'cgudgin2v@ucsd.edu', '$2a$04$I6OmS3aDKmnTY4i7dZgI6u/1Gm9dvTD1XKe1TgqOVgMNYb4LYIJYu', 'Professional gamer with over 10 years of experience', '2024-02-09 15:20:17', 1),
('Melisent Bolton', 'mbolton2w', 'mbolton2w@ucla.edu', '$2a$04$envkRON65tq.3J9VcWQbTePosSXjd0aURbF23BsxGTTRvXxqdP2ZS', 'Professional gamer with over 10 years of experience', '2024-01-30 10:50:06', 1),
('Cad McNess', 'cmcness2x', 'cmcness2x@omniture.com', '$2a$04$ZE9EAS7YI.DZmWdye1hpfuwl0n3glbg7xibAuV./VvHrjKLTr7e.K', 'Competitive gamer specializing in first-person shooters', '2024-01-30 04:46:34', 1),
('Teriann Paunsford', 'tpaunsford2y', 'tpaunsford2y@howstuffworks.com', '$2a$04$naWFhHH3U/EN9vK2IE1SN.k/6VaBKxuki/RHXYKV1z9L41Mvbgize', 'Casual gamer who enjoys playing on weekends', '2024-02-23 23:26:27', 1),
('Ula Najara', 'unajara2z', 'unajara2z@seattletimes.com', '$2a$04$ioYheL25MizDXTT4xWjT0ex8h0M8JV3XZFu5Fz/ngJR68KoLVXBNa', 'Casual gamer who enjoys playing on weekends', '2024-04-01 12:27:03', 1),
('Spense Middup', 'smiddup30', 'smiddup30@fotki.com', '$2a$04$OtxNnR766En7LtzgJE3ceupQCx7Iu64taiVwRRSpVsp4Cx4aMyNtu', 'Casual gamer who enjoys playing on weekends', '2024-02-17 04:40:54', 1),
('Chrisy Mifflin', 'cmifflin31', 'cmifflin31@gov.uk', '$2a$04$QKfmR5cLekN48rcf0tFasOLZtReZRnilMBsysHoGRKJx168dw4i5G', 'Professional gamer with over 10 years of experience', '2024-09-01 04:25:35', 1),
('Tris Cowing', 'tcowing32', 'tcowing32@apache.org', '$2a$04$NU16PMbWkWwYok5vShzG6.A0.yMXPfHnFDog37QpLGCMA8mcFGwDa', 'Casual gamer who enjoys playing on weekends', '2024-07-10 22:18:59', 1),
('Dotti McGovern', 'dmcgovern33', 'dmcgovern33@loc.gov', '$2a$04$FxE1L5uy8oNm3Y0HjV5mCOBKu7faKW.DnG4HdDN2AF1KWWgr4gRWG', 'Competitive gamer specializing in first-person shooters', '2024-01-28 02:09:24', 1),
('Sallyann Matzke', 'smatzke34', 'smatzke34@arizona.edu', '$2a$04$hIkWUDd/.qCemZLNVP6KeeIt1ZPD8GMtT7KBy/9FIeDf9XHXNMyFK', 'Casual gamer who enjoys playing on weekends', '2024-04-04 22:05:04', 1),
('Page Ruegg', 'pruegg35', 'pruegg35@dyndns.org', '$2a$04$3fpVwRhp2N7dhYgzQYh/YewoXlJTsh44Kmsk2I7J/HhmRLXJzwC7q', 'Casual gamer who enjoys playing on weekends', '2024-08-06 21:49:42', 1),
('Debbi Dreakin', 'ddreakin36', 'ddreakin36@wiley.com', '$2a$04$PaBYwPGzoXKkcsOxXN/t4.4VVBqXSVVFnrK6UTZnVBz2dgSJYZ2Hu', 'Professional gamer with over 10 years of experience', '2024-04-25 23:26:38', 1),
('Elsey Bendik', 'ebendik37', 'ebendik37@symantec.com', '$2a$04$OAqUchutsof.bTIHLQfs1uMmdi6EfPvUbThnRUr2pJmJUwcKAZdfi', 'Professional gamer with over 10 years of experience', '2023-12-30 14:38:50', 1),
('Querida Warricker', 'qwarricker38', 'qwarricker38@usda.gov', '$2a$04$9hdPVIW7kBkf.0rNfnt/teakuJrOj0IsQEsABiWvP9/YSQvAnv1Vm', 'Casual gamer who enjoys playing on weekends', '2024-12-10 19:40:28', 1),
('Kippie Lilly', 'klilly39', 'klilly39@angelfire.com', '$2a$04$xA1AqJdJhn4otWREbcr6nOGkEp0JLDrYYr5AdO7X5TLuMS3MzK9Vy', 'Casual gamer who enjoys playing on weekends', '2024-12-02 17:30:25', 1),
('Randa Welham', 'rwelham3a', 'rwelham3a@ucsd.edu', '$2a$04$0XTb3.PrBVVxrUDUJdx1h.UomNjLypUC5w0UhhpRSjMMviCZLi7oS', 'Professional gamer with over 10 years of experience', '2024-11-26 03:45:19', 1),
('Tami Cornew', 'tcornew3b', 'tcornew3b@hp.com', '$2a$04$QIOAbbSKSBL77LDEpStc4uOZ8j3VZx1iu0DFUmJ9Qd/4/7xBlEOXm', 'Competitive gamer specializing in first-person shooters', '2024-09-10 17:34:18', 1),
('Burnaby Tattersall', 'btattersall3c', 'btattersall3c@addtoany.com', '$2a$04$2ncLknCkM4YigU1FlPLCZeyuDAEpMtQU8kU0FSH7eBskoaWzKzhF2', 'Professional gamer with over 10 years of experience', '2024-03-01 11:27:58', 1),
('Thaddeus Tippin', 'ttippin3d', 'ttippin3d@goo.ne.jp', '$2a$04$ZO25As3gYzJhNggWjiUAte.xN2B8M8f5dly2uDtHaRgYuqXoSDF/K', 'Professional gamer with over 10 years of experience', '2024-06-21 11:59:21', 1),
('Conney Hastings', 'chastings3e', 'chastings3e@godaddy.com', '$2a$04$zaNdkWf9JaNRAekkIMF6suRnRc2TQTT8JUkeO3VWyMOpefo6tTHUq', 'Casual gamer who enjoys playing on weekends', '2024-06-12 10:30:32', 1),
('Kaylyn Doles', 'kdoles3f', 'kdoles3f@odnoklassniki.ru', '$2a$04$CC1qsG0.jxw2sNvmk2AQtOrH6oKHUHv08TzaoqihAn8O2juMPVlsy', 'Professional gamer with over 10 years of experience', '2024-01-13 12:11:01', 1),
('Mathe Grigoryev', 'mgrigoryev3g', 'mgrigoryev3g@bbc.co.uk', '$2a$04$nwsL6P5SNRWZTAK/vkJQW.bBnUOFM8qAxzapwg2KWQtmHUVB3QIS2', 'Competitive gamer specializing in first-person shooters', '2024-11-30 11:53:38', 1),
('Shandee Binley', 'sbinley3h', 'sbinley3h@liveinternet.ru', '$2a$04$POz.OIxKIRtiAPd5dNgnl.IyDRCRbH3jrkC0XprnMnMNzwV/vNqBi', 'Professional gamer with over 10 years of experience', '2024-04-18 10:44:57', 1),
('Bordie Shulem', 'bshulem3i', 'bshulem3i@cdbaby.com', '$2a$04$Jb5wpwOMsURM4B5zioK00emGPkgStHGwdU3oSn66cO8UVbN5E8a92', 'Competitive gamer specializing in first-person shooters', '2024-06-27 05:47:54', 1),
('Ninnette Stoyle', 'nstoyle3j', 'nstoyle3j@icio.us', '$2a$04$CGzR3eCQWrNMtHEoerjkouzPbROSel2tyCEjD7qHvNAFurhThxwWi', 'Professional gamer with over 10 years of experience', '2023-12-30 00:29:02', 1),
('Madelena Stollwerck', 'mstollwerck3k', 'mstollwerck3k@google.co.jp', '$2a$04$tMfKvTA4eFTPQQcgusi8ReOARhTZXy80IoPZi466BPmzXEqfLrExu', 'Competitive gamer specializing in first-person shooters', '2024-05-26 16:33:21', 1),
('Jayne Klaggeman', 'jklaggeman3l', 'jklaggeman3l@admin.ch', '$2a$04$bzpQtXxZkfbi3j/xwp/qkOJf7.ZjtA3gz1ZV8RCSYepR4Zx53aDN6', 'Professional gamer with over 10 years of experience', '2024-10-08 09:52:23', 1),
('Odille Lillecrap', 'olillecrap3m', 'olillecrap3m@weibo.com', '$2a$04$mgUYV.P.D1gK2C.iYHh4xeF0x0clklk7SQhddKjTZEZd77clKScIO', 'Competitive gamer specializing in first-person shooters', '2024-06-20 09:26:21', 1),
('Marleah Hegley', 'mhegley3n', 'mhegley3n@scientificamerican.com', '$2a$04$Hhhi8VZCZScw3.u3CE9RiOp6A6yWmZDOgdirhEe3Ghd6yxjRtvlWO', 'Competitive gamer specializing in first-person shooters', '2024-10-25 23:06:42', 1),
('Jdavie Proudler', 'jproudler3o', 'jproudler3o@newsvine.com', '$2a$04$GCCvxjZ9ZNQCVWNgPfXSEuDHebDtlPD0DaFMeY1KSehyL4GtB.3ri', 'Casual gamer who enjoys playing on weekends', '2024-01-19 06:31:57', 1),
('Joanie Harley', 'jharley3p', 'jharley3p@blinklist.com', '$2a$04$/4AzpOevSNIAb11rLfKn.eZK8Gh46ydIYKVfpWljHAMHILg0ZOgGO', 'Competitive gamer specializing in first-person shooters', '2024-07-25 13:29:24', 1),
('Myrvyn Burlay', 'mburlay3q', 'mburlay3q@nih.gov', '$2a$04$NQ3VW3OPNCnHUGT1ezSLkeFvIqPE6iQvks83F3eeyVvxlFbnE99cq', 'Casual gamer who enjoys playing on weekends', '2024-06-15 10:02:59', 1),
('Anabel Stathers', 'astathers3r', 'astathers3r@people.com.cn', '$2a$04$.lp2kz6wcaBlp2oHu.dHje1EzGTCc7pKCa6Fkct9miYBvUOp6LRJG', 'Casual gamer who enjoys playing on weekends', '2024-02-01 09:19:27', 1),
('Felicia More', 'fmore3s', 'fmore3s@yale.edu', '$2a$04$vVMFie.hQRCpac2hZTA8Le52.oAmR.E98XXhfDuJYCCnEfNe5OCuG', 'Casual gamer who enjoys playing on weekends', '2024-07-04 04:52:44', 1),
('Marline Franzini', 'mfranzini3t', 'mfranzini3t@xing.com', '$2a$04$5WpkE136HI3RKRxtHFKfWO6bhK8OyEcsmmYK/m0lTRnSA3dUIOqm.', 'Casual gamer who enjoys playing on weekends', '2024-05-21 03:29:14', 1),
('Jania Felgate', 'jfelgate3u', 'jfelgate3u@mac.com', '$2a$04$fIM9DWuDOihzq7yxt6XhhOSghrKsz.L/nWK40iP1LX84xwEkXioa.', 'Professional gamer with over 10 years of experience', '2024-09-02 01:57:50', 1),
('Cesare Isac', 'cisac3v', 'cisac3v@homestead.com', '$2a$04$HyLe6dyLSaV6DgximH9LWecFTCEYQStuI7ppUtkAMEzQGcPAmm.Hy', 'Casual gamer who enjoys playing on weekends', '2024-02-17 10:18:01', 1),
('Averil Houlahan', 'ahoulahan3w', 'ahoulahan3w@google.com.hk', '$2a$04$VNBIO8cXKuZI.5kMdMxRxuXWXo54S.3ZDSC85sK5tpL.LhcZZX2RW', 'Professional gamer with over 10 years of experience', '2024-11-11 12:46:21', 1),
('Feliza Farlow', 'ffarlow3x', 'ffarlow3x@posterous.com', '$2a$04$fi7nyzHvLxQXZpjVI/6vZOKaC9W6kKcHVixUvRy.zGErlQsxuyOBW', 'Professional gamer with over 10 years of experience', '2024-10-26 18:37:34', 1),
('Peirce Macartney', 'pmacartney3y', 'pmacartney3y@cdbaby.com', '$2a$04$lLcXVGG061Yd0Xx.kImzcu969Ot4LumS37WozEM0fdWvtjvAf.Gp2', 'Competitive gamer specializing in first-person shooters', '2024-11-08 20:22:03', 1),
('Nestor Dumini', 'ndumini3z', 'ndumini3z@amazonaws.com', '$2a$04$bkCv1Zvw59lNqxoS8gRmzuJUh9OFvZky.I0Sr58/9wwHy.qUYOEXC', 'Competitive gamer specializing in first-person shooters', '2024-09-11 06:48:13', 1),
('Erroll Ferretti', 'eferretti40', 'eferretti40@blogger.com', '$2a$04$cXn9MFxlmODxZrUGovf7ZuQhczPjlKV/e6q9RXbIQb6YHSW8HVKqO', 'Professional gamer with over 10 years of experience', '2024-04-10 19:13:28', 1),
('Harv de Cullip', 'hde41', 'hde41@dmoz.org', '$2a$04$4CY5Jq.on.vAnpwFxffAj.1DmYggv6q/Cy.sFEu0p/bWuO4l.4mfK', 'Casual gamer who enjoys playing on weekends', '2024-10-19 11:48:25', 1),
('Ricca Coviello', 'rcoviello42', 'rcoviello42@taobao.com', '$2a$04$c46g4aAkJHSYibanDc4hSOir1mkqhjv3p1l.dKDkNHHRfp3Hxs4vq', 'Casual gamer who enjoys playing on weekends', '2024-05-13 02:03:57', 1),
('Dorris Pitceathly', 'dpitceathly43', 'dpitceathly43@theatlantic.com', '$2a$04$tAisPKDRbjLOVoPPgisU3ei7rqhTu7u4yJO9jPKbiFik4/5cUujcG', 'Casual gamer who enjoys playing on weekends', '2024-03-13 19:59:30', 1),
('Shina Lillyman', 'slillyman44', 'slillyman44@oakley.com', '$2a$04$5k3sSzhhrzYR4ISwRLOUMe1srifC/zja8BkUU5LNhDm4iU.VoSOUa', 'Competitive gamer specializing in first-person shooters', '2024-06-09 15:51:12', 1),
('Emily Etherson', 'eetherson45', 'eetherson45@usnews.com', '$2a$04$cxbWDWrYnQ/outVd.ktEAudX6/s5avPPKfbnxFq2otSwZFk1o5/FS', 'Casual gamer who enjoys playing on weekends', '2024-10-05 04:01:53', 1),
('Burtie Feldmark', 'bfeldmark46', 'bfeldmark46@sourceforge.net', '$2a$04$gbMf5ZcFZBDUJd4lIi7UueHOyxUDdfwOJyUMckcX0m/sdhLDSOASO', 'Competitive gamer specializing in first-person shooters', '2024-04-03 14:46:46', 1),
('Alyosha Umpleby', 'aumpleby47', 'aumpleby47@hao123.com', '$2a$04$le2qeEdfY5kKLDm68Pl7juwV8DgZnYYCs6btmD1J.ZlPsZR26jssG', 'Competitive gamer specializing in first-person shooters', '2024-01-02 14:52:30', 1),
('Reynolds Dmych', 'rdmych48', 'rdmych48@jimdo.com', '$2a$04$oJX7z/ACWkZ8KJG/U/ptueVPuLgTQwW7qELMbsRzRW3B1xpaTeUzq', 'Professional gamer with over 10 years of experience', '2024-06-17 04:55:31', 1),
('Bev Muirden', 'bmuirden49', 'bmuirden49@weather.com', '$2a$04$Nw6XdEqEv9x70w0AkIv91ext2xkjOlG13I2Kl4N2rfkzqonYjZFjq', 'Professional gamer with over 10 years of experience', '2024-02-28 08:14:20', 1),
('Piotr Lodeke', 'plodeke4a', 'plodeke4a@webeden.co.uk', '$2a$04$IgwGErxC0ZRFkG2o3uYmbuVxq402gv5lvSI7BURu/8TXVJx88c9Yu', 'Professional gamer with over 10 years of experience', '2024-03-19 20:56:04', 1),
('Dedra Ragat', 'dragat4b', 'dragat4b@ox.ac.uk', '$2a$04$Hwc2dRLsi4sQQq8F6OiSGOaV58crFD/mxt2kr05VH0B8w6EjouTpW', 'Casual gamer who enjoys playing on weekends', '2024-04-08 13:41:54', 1),
('Pammie Gascard', 'pgascard4c', 'pgascard4c@adobe.com', '$2a$04$pwWeh4yUPxrs/tS/5JJDdeKNo2Hf8NURiZqCQaEzB.xNV1q3cGJ4u', 'Casual gamer who enjoys playing on weekends', '2024-09-15 23:22:39', 1),
('Nye Gauntlett', 'ngauntlett4d', 'ngauntlett4d@cnet.com', '$2a$04$znas0P7ysm0XA2gRyGdNjePMlqNthMntdgpU4f353DiSOFsICSvNm', 'Professional gamer with over 10 years of experience', '2024-05-12 11:02:02', 1),
('Corri Hoy', 'choy4e', 'choy4e@google.ru', '$2a$04$toII2pKIZdfOcArufmvsYeor1D53zm75uu5qDhDjKZFI2dl1z6JX2', 'Professional gamer with over 10 years of experience', '2024-11-18 17:25:44', 1),
('Dalenna Okroy', 'dokroy4f', 'dokroy4f@cargocollective.com', '$2a$04$uDIJFhqtKDQ4I252uYvVpeoWwHHvwWzHQjs1E2nQ957btk25FPVAK', 'Professional gamer with over 10 years of experience', '2024-03-07 16:31:13', 1),
('Cate McFeat', 'cmcfeat4g', 'cmcfeat4g@joomla.org', '$2a$04$vI4CJBBMoVsqCUOyCSFqkuX02k.4f4BYmoz6f52P.15PcbhJWvgJm', 'Professional gamer with over 10 years of experience', '2024-04-23 22:43:30', 1),
('Gunar Meates', 'gmeates4h', 'gmeates4h@virginia.edu', '$2a$04$XJi9kVgMv5CV7m.10PuFeupKtOo6YPRviInRaJusU809rgn5C0XVO', 'Casual gamer who enjoys playing on weekends', '2024-03-24 13:45:42', 1),
('Martha Oakey', 'moakey4i', 'moakey4i@histats.com', '$2a$04$ORfzNd4mEgLjp3JKjA9E4.Rqnaz3br/Yw0k.3CLPt45UxptAPhZ.m', 'Professional gamer with over 10 years of experience', '2024-03-26 14:28:17', 1),
('Kora Renzullo', 'krenzullo4j', 'krenzullo4j@wix.com', '$2a$04$fLgHgR1s0iSgksVTo2o9re1/68N6JcRvsR1cPTmG0DWwxBANS8XP2', 'Professional gamer with over 10 years of experience', '2024-08-27 12:45:38', 1),
('Esteban Rosenfrucht', 'erosenfrucht4k', 'erosenfrucht4k@instagram.com', '$2a$04$561R8snAbKKgJyS203hLsuH4nEJbaHiPcRvMMKBXxzDpluzVxXJVu', 'Professional gamer with over 10 years of experience', '2024-06-10 08:37:33', 1),
('Lotte Seldner', 'lseldner4l', 'lseldner4l@tiny.cc', '$2a$04$OXYjBwgwquRogC1MqoCLdOQoMqdOhqDrz/72hJaFtK1pytyOWZgoe', 'Casual gamer who enjoys playing on weekends', '2024-09-13 03:40:49', 1),
('Doyle Fabbro', 'dfabbro4m', 'dfabbro4m@msn.com', '$2a$04$wblsQGhk6pzaDD7NefaspOwjOHmKAG62/e4NHCmBeicUs457E0K2W', 'Casual gamer who enjoys playing on weekends', '2024-11-12 08:45:48', 1),
('Andree Ducarel', 'aducarel4n', 'aducarel4n@ft.com', '$2a$04$lfMqdXuaRE8qGK4zBuIx9uAk8ZQJgHDfZ8K8LWI0S4CsrwwGehUjy', 'Professional gamer with over 10 years of experience', '2024-03-06 10:56:06', 1),
('Parrnell Loggie', 'ploggie4o', 'ploggie4o@netlog.com', '$2a$04$JuzcvwPFwEWupmhAPyp9Weubo5h3HmIG.OPNYwQpuUzAVDm/4vTNy', 'Casual gamer who enjoys playing on weekends', '2024-05-21 06:05:04', 1),
('Shannen Longfellow', 'slongfellow4p', 'slongfellow4p@com.com', '$2a$04$2vtzXntTD.d7TOB.nPQAe.XdIaxvFTRyJ2zXQw1iJrL5gAAfKIPdG', 'Professional gamer with over 10 years of experience', '2024-09-03 09:45:32', 1),
('Jethro Paynton', 'jpaynton4q', 'jpaynton4q@unesco.org', '$2a$04$ayFwXcwHGBj4tyEroWrU0e1HJC4SVX5TKxvMXGpyNZw1Ri.ykdODi', 'Casual gamer who enjoys playing on weekends', '2024-06-28 17:09:23', 1),
('Codi Sandes', 'csandes4r', 'csandes4r@engadget.com', '$2a$04$Qhont.rJiH/4CP04qFxd/ehnqRrx1hEywTd2v39OW9Xfvc.16gxZ2', 'Casual gamer who enjoys playing on weekends', '2024-12-20 06:21:40', 1),
('Sybilla Andrat', 'sandrat4s', 'sandrat4s@e-recht24.de', '$2a$04$dkJ1TX7mesp2WDfHiIL9z.Ayhz1a/7FmCyztbPYjAjKiDMpLChIjy', 'Competitive gamer specializing in first-person shooters', '2024-03-23 05:26:16', 1),
('Kirk Ragless', 'kragless4t', 'kragless4t@loc.gov', '$2a$04$BJSuCPiAJdBkMK1.8GD1eu1Zos.K8jf4X5yRrtlGs/gRzvATBEZvm', 'Casual gamer who enjoys playing on weekends', '2024-09-03 16:20:30', 1),
('Sheridan Dugue', 'sdugue4u', 'sdugue4u@cnet.com', '$2a$04$E50Nbjwgz5RauGTpTM0.DewUM/gVmNvun0eQOqWRQGffF..3xuvxe', 'Casual gamer who enjoys playing on weekends', '2024-03-07 01:08:28', 1),
('Marleen Pennino', 'mpennino4v', 'mpennino4v@narod.ru', '$2a$04$uRS1o36bpPbnKomyx/0xtO5HE.o.pOMAUDHFg5BZa.3W0.tdqgrJG', 'Casual gamer who enjoys playing on weekends', '2024-07-11 19:41:29', 1),
('Sheridan Teulier', 'steulier4w', 'steulier4w@furl.net', '$2a$04$4pPMrL.vVPG9g.T.82AEd.tAfdrB4m1pZEgl/hVh6mM1RKk0riFsK', 'Professional gamer with over 10 years of experience', '2024-11-25 04:14:30', 1),
('Jethro Stolberger', 'jstolberger4x', 'jstolberger4x@google.it', '$2a$04$JkVOeP6hHMCa1AyksgRDje2DCrpQrLdnXb.XmIy9DZHV9J6yJmc9O', 'Competitive gamer specializing in first-person shooters', '2024-01-17 05:05:30', 1),
('Tabitha Gerbi', 'tgerbi4y', 'tgerbi4y@deviantart.com', '$2a$04$iGPCJT38AJzPtK/Jve8vp.g0/4.J77FsP.c7vXoSZkoekRN5BNCQO', 'Competitive gamer specializing in first-person shooters', '2024-12-20 12:18:15', 1),
('Hastie Loade', 'hloade4z', 'hloade4z@liveinternet.ru', '$2a$04$8j94WAO4foD9sJFnCgFfYOyuJEXeYnLPfYuyEABscWjgLEN8faVY2', 'Professional gamer with over 10 years of experience', '2024-01-01 14:25:06', 1),
('Woodman Tutton', 'wtutton50', 'wtutton50@google.ru', '$2a$04$qwcfUHNgrb.81PhrmbROz.XU./gupDf4I71LONEtvM4G01/5PC.6y', 'Professional gamer with over 10 years of experience', '2024-10-19 22:32:37', 1),
('Florenza Wolford', 'fwolford51', 'fwolford51@bbb.org', '$2a$04$aCN0sYF5AAhJLN7hTkKtn.o9PTwmoimOhjEidEDUUzhG7NI4zNaBa', 'Casual gamer who enjoys playing on weekends', '2024-01-08 09:14:51', 1),
('Vanda Lent', 'vlent52', 'vlent52@rambler.ru', '$2a$04$a3E6H5XA2o.4ospsyw3Ew.OZsYwoC.FT75bbQAwXBunCMaRfb5nR2', 'Competitive gamer specializing in first-person shooters', '2024-11-18 20:46:31', 1),
('Elliot Dealtry', 'edealtry53', 'edealtry53@nhs.uk', '$2a$04$8pmS56xMFY52kf9rCivgxuXD5MZZ1WJ/VqCiSclCXyiDC7DkHHbL.', 'Casual gamer who enjoys playing on weekends', '2024-04-23 16:29:34', 1),
('Torrey Limbrick', 'tlimbrick54', 'tlimbrick54@4shared.com', '$2a$04$ClE0GliC32HJJ3cz1eBfz.nfpz9qNlvuFJBdtUxz4.t8J64HCr4K2', 'Professional gamer with over 10 years of experience', '2024-03-24 10:25:32', 1),
('Clywd Cranmere', 'ccranmere55', 'ccranmere55@cisco.com', '$2a$04$Zm/n9kLTabdRXQ1A4P8J0upRrfEdEYcpCVIli.epJS5SxO7.1VtEu', 'Casual gamer who enjoys playing on weekends', '2024-02-15 16:07:07', 1),
('Ezequiel Dorrell', 'edorrell56', 'edorrell56@1688.com', '$2a$04$W0lGFtWUaslf6YwRFkzuJu6KllpmWkTqjjSRtS7POqgpV/C.XryDu', 'Casual gamer who enjoys playing on weekends', '2024-07-04 17:29:52', 1),
('Malinda Sitlington', 'msitlington57', 'msitlington57@house.gov', '$2a$04$raSiEoQ65CGpgyYdOq0VVuJXocc9lK./XmmQMhkmlK5uV3thhv2Iq', 'Competitive gamer specializing in first-person shooters', '2024-01-03 03:12:22', 1),
('Susann Geaney', 'sgeaney58', 'sgeaney58@shareasale.com', '$2a$04$Jpz4sq9Hf5jWHJYVPo/h5OjswxD8tNsEdIxNNikMJgvl3Wgk1bg4q', 'Casual gamer who enjoys playing on weekends', '2024-06-21 07:04:22', 1),
('Dominica Manach', 'dmanach59', 'dmanach59@imageshack.us', '$2a$04$BHvQu0sssGb6xeVhFSV1NuMOXqmkHokrhj/7SPglb1Ey4BdD9qyy.', 'Competitive gamer specializing in first-person shooters', '2024-07-14 17:47:41', 1),
('Consolata Graybeal', 'cgraybeal5a', 'cgraybeal5a@irs.gov', '$2a$04$0zTAp.VXX9hILh/WUfnwteDn1KrriR3Qne1unJiGCo1o5QUGN.VOe', 'Casual gamer who enjoys playing on weekends', '2024-07-31 19:19:46', 1),
('Elmore Tineman', 'etineman5b', 'etineman5b@cornell.edu', '$2a$04$EO4w0EpmGnurQzP1VL5Kd.LPfQLBLi8yLAJ8cVo6msDcavWo2zkUS', 'Competitive gamer specializing in first-person shooters', '2024-05-29 13:01:22', 1),
('Cesaro Eskriet', 'ceskriet5c', 'ceskriet5c@php.net', '$2a$04$tMEeScwhJRRbdTSmVYzuW.iDwIvGtgOIYLLeCScWYPA6P/88lkUmy', 'Competitive gamer specializing in first-person shooters', '2024-10-17 20:29:21', 1),
('Cornie Cattellion', 'ccattellion5d', 'ccattellion5d@cnn.com', '$2a$04$1Y7gOXuJEwkTzo4uPMBWTO//EQKT7FAumDA4J82zvzZKXEKS/pkS6', 'Professional gamer with over 10 years of experience', '2024-01-06 11:09:18', 1),
('Ashley Gunn', 'agunn5e', 'agunn5e@youku.com', '$2a$04$I1n5kJUxl95k5vfV8noiauMKvCiKV/UkL4ftHN2z9rvJqIKLOZswO', 'Competitive gamer specializing in first-person shooters', '2024-08-31 04:01:49', 1),
('Merry Mackelworth', 'mmackelworth5f', 'mmackelworth5f@skyrock.com', '$2a$04$XMwHkcmzEhHPjmEQx./T/OX24lSuuBkf9MD/qsrdvY7N3IoVvXx9G', 'Casual gamer who enjoys playing on weekends', '2024-02-03 08:23:06', 1),
('Farlay Eilhermann', 'feilhermann5g', 'feilhermann5g@t-online.de', '$2a$04$LaY0DWv1haFlHLWWW0uAvORibIjLrSrKJ7sjtny6VEhqfhoXFEAS2', 'Professional gamer with over 10 years of experience', '2024-09-03 00:54:08', 1),
('Henrietta Gribbell', 'hgribbell5h', 'hgribbell5h@bluehost.com', '$2a$04$JFV1XtRe8baKurW1Rb6LdupxmVhEacvq2c8RAR.5zzWkkaKDAbv6e', 'Competitive gamer specializing in first-person shooters', '2024-11-27 22:00:46', 1),
('Peri Pirrey', 'ppirrey5i', 'ppirrey5i@noaa.gov', '$2a$04$M0ja//H.FQNUtNblKLqjjOtm.pJaWMQzMaqPi3UNZijR0t6KTVIXK', 'Competitive gamer specializing in first-person shooters', '2024-05-19 17:38:42', 1),
('Bert Puttock', 'bputtock5j', 'bputtock5j@yelp.com', '$2a$04$Y2UB9qmXtqe.IHfIqQ2C9ea9Wj3Ez.l9oIgEB2G6FNoYYvOdDWaFC', 'Professional gamer with over 10 years of experience', '2024-09-11 22:40:09', 1),
('Anastasia Lowman', 'alowman5k', 'alowman5k@sciencedirect.com', '$2a$04$rMI/PBFG5N8xNMmLG3rd.uiS9kN2ex2qiCPCN4jKj.751eNhQ5zgu', 'Competitive gamer specializing in first-person shooters', '2024-06-25 07:35:35', 1),
('Yorgo Glass', 'yglass5l', 'yglass5l@spotify.com', '$2a$04$lXTT7k1nerk5mMGHBKecFOajlljrrmtd9GHtZOjbk/6SFBghSfJta', 'Professional gamer with over 10 years of experience', '2024-10-20 04:12:52', 1),
('Gene Clail', 'gclail5m', 'gclail5m@stanford.edu', '$2a$04$QxYCBERuEw/ERqv2SYjU3eMzSHBt2EIKRb1iY5y8r94cBScbo9Yuu', 'Competitive gamer specializing in first-person shooters', '2024-09-13 03:27:00', 1),
('Frederick Islep', 'fislep5n', 'fislep5n@yelp.com', '$2a$04$UtpgzlTxjrMKuhUXIabV6.AZo9bsE/xDRGNGjjnHxnGxGvzuSZYcy', 'Professional gamer with over 10 years of experience', '2024-08-04 14:54:38', 1),
('Chrystel Cattlemull', 'ccattlemull5o', 'ccattlemull5o@hatena.ne.jp', '$2a$04$5ARHoQjqXLDjE5urVdpz5OD9C5Jc/fRNznJpBS9MD8zvKMfB1a0ZO', 'Competitive gamer specializing in first-person shooters', '2024-02-12 01:18:20', 1),
('Cybil Beamond', 'cbeamond5p', 'cbeamond5p@jigsy.com', '$2a$04$tvUdx9heIE0LGrm.IaJ9refGyKfNImm/IDiTXinAxQEeuNloZjHU6', 'Professional gamer with over 10 years of experience', '2024-09-06 04:43:43', 1),
('Lurline Volonte', 'lvolonte5q', 'lvolonte5q@usgs.gov', '$2a$04$mhPbezMQvnS.hiEnI3gLJOjh30kXxsw4Qr4f/T1hQWEGBwpmc4Fv2', 'Casual gamer who enjoys playing on weekends', '2024-01-19 01:12:03', 1),
('Rodrick Sealy', 'rsealy5r', 'rsealy5r@slideshare.net', '$2a$04$6rnLuQMazg.yTQj5JvMCbOxKi64KDxOswg4hCicUzEVFFDHchfJnG', 'Competitive gamer specializing in first-person shooters', '2024-12-07 11:56:13', 1),
('Alon Fennelow', 'afennelow5s', 'afennelow5s@buzzfeed.com', '$2a$04$eTuk/oXACCvzSl5frcZxFuhXjt2qk/mR5hMQESBq4uSotQbdXbfX.', 'Casual gamer who enjoys playing on weekends', '2024-01-27 01:49:30', 1),
('Didi Kimberly', 'dkimberly5t', 'dkimberly5t@live.com', '$2a$04$rn3JnVH.dhRkdrGc4rOFMe0D6n087r4WFpYt6Z29UIYoCSa0.8.VG', 'Competitive gamer specializing in first-person shooters', '2024-03-10 18:54:10', 1),
('Yvor Komorowski', 'ykomorowski5u', 'ykomorowski5u@canalblog.com', '$2a$04$ND1uHhjJ8fWel49vHA1q/ePbkOSn2bTRv0awA4IY4EHMIbgJ7zICC', 'Competitive gamer specializing in first-person shooters', '2024-04-08 01:29:15', 1),
('Salvidor Sinson', 'ssinson5v', 'ssinson5v@nba.com', '$2a$04$dJsU8k0B0QF/DPVInQEexunofVzZrTNNqyxfkKwjpE.oZwWlgRV1m', 'Competitive gamer specializing in first-person shooters', '2023-12-31 15:36:38', 1),
('Zebulon Samett', 'zsamett5w', 'zsamett5w@sogou.com', '$2a$04$iLYYEBg8eHW5xMZMHi.qmeglxqcmQWBeofzBJDhcEG8wzJ020V3AO', 'Professional gamer with over 10 years of experience', '2024-08-14 03:02:45', 1),
('Elana Brewis', 'ebrewis5x', 'ebrewis5x@soundcloud.com', '$2a$04$sVbCatMAjBNyoEh/Vy5ik.lmnDjqpQNsfmQeh9zvIPuE7zsO0WNBu', 'Competitive gamer specializing in first-person shooters', '2024-04-06 11:05:44', 1),
('Brynn Chessill', 'bchessill5y', 'bchessill5y@mediafire.com', '$2a$04$xzexpCHsD6DeNLvJaTJaf.8kZ7eNp4FlYgvqUcPXCvUXr1OgEfC5u', 'Professional gamer with over 10 years of experience', '2024-01-18 20:21:18', 1),
('Robbi McGrotty', 'rmcgrotty5z', 'rmcgrotty5z@nhs.uk', '$2a$04$WNq6hCHi4uXULDVoEDPGpuuwf9Thv.ROqTInkpzeuHtFBFbl3NDvi', 'Casual gamer who enjoys playing on weekends', '2024-01-24 04:23:10', 1),
('Michell Spittle', 'mspittle60', 'mspittle60@msu.edu', '$2a$04$mLGVQ948RKYoCvKftTn/WeMtN9nglLdX8y2bROm7fCko9NKhoFDpy', 'Casual gamer who enjoys playing on weekends', '2024-12-18 23:17:55', 1),
('Joete Peirce', 'jpeirce61', 'jpeirce61@wikia.com', '$2a$04$PjiMj9GISep9pjwIsb8RxOyFLSZjLcgwg.s7zn1cWABUy1NAeqqyi', 'Casual gamer who enjoys playing on weekends', '2024-12-02 04:49:25', 1),
('Tarra Calf', 'tcalf62', 'tcalf62@omniture.com', '$2a$04$uJnVX8kwEjsaIgCecpqqReDfWZ4M6Vt9S1/bqnL2unZESXBhLsWD2', 'Professional gamer with over 10 years of experience', '2024-02-07 01:24:02', 1),
('Jordan Mochar', 'jmochar63', 'jmochar63@imgur.com', '$2a$04$wCM1L4es9ZrULuE1GyMdPOsezQtRy3WM4GxhMS2DPEitw3bf2Cs6i', 'Professional gamer with over 10 years of experience', '2024-07-04 18:24:57', 1),
('Maryjo Bearcroft', 'mbearcroft64', 'mbearcroft64@ehow.com', '$2a$04$HD3UeIpd2Ybr5d6T6AC36OR.DnKJDz2/UtcwGTS7RGTjqGRa4HXIO', 'Professional gamer with over 10 years of experience', '2024-04-10 13:33:51', 1),
('Selig Shrieve', 'sshrieve65', 'sshrieve65@umn.edu', '$2a$04$Kr6qmtDUhrRUwyB2w6QPhODWxlOjpRBgHmwZuBLF.cmf5lgrZhXY.', 'Casual gamer who enjoys playing on weekends', '2024-09-24 15:13:08', 1),
('Garnet Gresswood', 'ggresswood66', 'ggresswood66@usnews.com', '$2a$04$wMWbiAqhNu/NBrlfqsgTau9Ncx3BQq0GSOrZ5oHcsNtAdZxZdufeG', 'Professional gamer with over 10 years of experience', '2024-06-01 14:06:33', 1),
('Cinderella Cramphorn', 'ccramphorn67', 'ccramphorn67@mail.ru', '$2a$04$c0Dg0ZWU0Izxoy0CjyZjoOcxxRUtfWICRo2LFBp4SEjapi.8.D932', 'Professional gamer with over 10 years of experience', '2024-10-20 07:45:15', 1),
('Basilio McCuish', 'bmccuish68', 'bmccuish68@tripod.com', '$2a$04$UX2VIqoPCIHPTsXMaqKxPOqKSQK5w90LIo0joFavPQXpGIYkHjY1i', 'Casual gamer who enjoys playing on weekends', '2024-03-18 06:42:54', 1),
('Klara Melonby', 'kmelonby69', 'kmelonby69@yellowpages.com', '$2a$04$4mBM9WrvtflVw7o0AKjKEuklihHc.M97osuB/1xCbhXO9MS9jhAay', 'Competitive gamer specializing in first-person shooters', '2024-11-19 12:44:36', 1),
('Cornelia Scyner', 'cscyner6a', 'cscyner6a@hexun.com', '$2a$04$wqzv2zSeoenF/3ZSDLegvO.7v.ZsxeJ6LOcgFzNcpeN5G5Bw6JRia', 'Professional gamer with over 10 years of experience', '2024-08-27 07:40:18', 1),
('Thornie Piwell', 'tpiwell6b', 'tpiwell6b@engadget.com', '$2a$04$YulZQMp9/jGt.KkXnWL3N.j6Hr7qrjEjiY1ONN4cXlLqUYRhMTQZC', 'Professional gamer with over 10 years of experience', '2024-05-01 17:46:57', 1),
('Lily Ransley', 'lransley6c', 'lransley6c@newyorker.com', '$2a$04$xwnVn4/Lldww12lCrXc7kebzPHOnaLQYW.EJitGCTgT1jexYKklNm', 'Competitive gamer specializing in first-person shooters', '2024-06-25 02:10:26', 1),
('Brandea Flay', 'bflay6d', 'bflay6d@pcworld.com', '$2a$04$CVx9/YwOmIGM0IssSebekOeLvA3gqocOmNmgqMbYRniXiaT2KhN5y', 'Casual gamer who enjoys playing on weekends', '2024-07-20 04:01:28', 1),
('Zorina Greenstock', 'zgreenstock6e', 'zgreenstock6e@bloomberg.com', '$2a$04$TYcg2DxgcpnMisdFMqoqY.EhwDsdaa6x8OTjiihkLjD0pJTj5VY0W', 'Competitive gamer specializing in first-person shooters', '2024-03-31 07:08:14', 1),
('Cariotta Ferruzzi', 'cferruzzi6f', 'cferruzzi6f@wikimedia.org', '$2a$04$XNJfN9K1gKpCz88KKtijAOQDcExlGLBsbUGIB9ntZPzbDFxraFChC', 'Professional gamer with over 10 years of experience', '2023-12-28 17:10:15', 1),
('Meghan Partleton', 'mpartleton6g', 'mpartleton6g@dion.ne.jp', '$2a$04$tGnI9zjtgSlRv1hb7Jrp9ugwmkfEy9ZKR3nE8rNKtqQVErh7eBPcW', 'Competitive gamer specializing in first-person shooters', '2024-12-01 16:46:53', 1),
('Hogan Tipler', 'htipler6h', 'htipler6h@newyorker.com', '$2a$04$UibIDhYam3rDTCU9Z8QT9.IEKqqbPLNyuJWcvzkaI8tjeZpsueYza', 'Competitive gamer specializing in first-person shooters', '2024-07-08 10:36:16', 1),
('Tonia Smyth', 'tsmyth6i', 'tsmyth6i@joomla.org', '$2a$04$uboYkmW4ZOIK42wAqIN5YuqEu/8Endp/tVRQyrDxOjx7BNZqPi8ha', 'Casual gamer who enjoys playing on weekends', '2024-06-30 18:38:49', 1),
('Sigfrid Doonican', 'sdoonican6j', 'sdoonican6j@ask.com', '$2a$04$l6V6UKYQIS0fFivu0xhnAeFipIHMUu6vcQJy7SrP3QBQjz6bpq.JO', 'Casual gamer who enjoys playing on weekends', '2024-08-12 16:12:26', 1),
('Hasheem Forman', 'hforman6k', 'hforman6k@sitemeter.com', '$2a$04$6Vq9cDYgCq9gg4yhTCthLeQ9gmBvAnhWwF7Tru45m06dE6dIaty1W', 'Professional gamer with over 10 years of experience', '2024-07-09 15:55:36', 1),
('Gaynor Tidey', 'gtidey6l', 'gtidey6l@dagondesign.com', '$2a$04$AQ5Hu4hhpzNpqg4nIhFiv.QuvfpW8.rZACYiyFXHUYZkLADhT8VtK', 'Casual gamer who enjoys playing on weekends', '2023-12-23 11:05:10', 1),
('Monika Martinie', 'mmartinie6m', 'mmartinie6m@tinyurl.com', '$2a$04$EZLGNucksXJp3g3ejWOgEeAkuSzErToAyIoxhm/bueppCcnpP/voq', 'Casual gamer who enjoys playing on weekends', '2024-06-21 22:09:23', 1),
('Marnie Izchaki', 'mizchaki6n', 'mizchaki6n@eventbrite.com', '$2a$04$LlGBc/1B5eYmrXaUAvwZnOlAHJ5xJeJgXCjHnbHj5ppyWRVr2TXC2', 'Competitive gamer specializing in first-person shooters', '2024-09-24 22:01:03', 1),
('Bran Christophe', 'bchristophe6o', 'bchristophe6o@salon.com', '$2a$04$Lgc84uDcWPSRYpykLTP9quqKEZR953CdmEfT2Ag0oCNVSrwHocLHC', 'Casual gamer who enjoys playing on weekends', '2024-09-25 18:34:32', 1),
('Berny Euler', 'beuler6p', 'beuler6p@techcrunch.com', '$2a$04$DR1hPBbM.cF0t4kYq2M4ne2/BOnJPokgSeLIMha2CQBd9uEbGQ9Pi', 'Professional gamer with over 10 years of experience', '2024-12-16 20:12:37', 1),
('Bordy Harris', 'bharris6q', 'bharris6q@netvibes.com', '$2a$04$5IepwP.FfXpdW4ex3GrKLuLUFTgznTenJVtGux74iuTGOoSNw6gcm', 'Professional gamer with over 10 years of experience', '2024-01-16 09:30:54', 1),
('Drusy Hindsberg', 'dhindsberg6r', 'dhindsberg6r@ebay.com', '$2a$04$BVTYg2k3L5m30ylwcCfbOehAAs2pnvYe.bfttXjXTNwgNsW0CpJDK', 'Casual gamer who enjoys playing on weekends', '2024-11-24 10:35:13', 1),
('Eli Kynman', 'ekynman6s', 'ekynman6s@theguardian.com', '$2a$04$yotfqe2cxe1Vx1j6RSh0DOf3i3CY.LgSId8qxRL9enbZtiYfAZcyO', 'Professional gamer with over 10 years of experience', '2024-10-20 11:36:54', 1),
('Shandeigh Cutchey', 'scutchey6t', 'scutchey6t@people.com.cn', '$2a$04$KFC6oTK44ieqslxMtRqdDuAMxSalVD/VQsq.5B2nVv3lAaoSeypc6', 'Professional gamer with over 10 years of experience', '2024-04-04 18:19:48', 1),
('Carolyn Carlens', 'ccarlens6u', 'ccarlens6u@tiny.cc', '$2a$04$PMFW2hMN7/3K7Gk9v0Ten.Kwc/hVd7kTGbb2Pc1DrN2rFc5vf2gmG', 'Casual gamer who enjoys playing on weekends', '2024-06-11 01:24:30', 1),
('Latrina Denecamp', 'ldenecamp6v', 'ldenecamp6v@adobe.com', '$2a$04$nkOViyUuaKRqWsjqNA6eju/GNDGna2DviEcH1rGKY8d.0P23nLtfS', 'Professional gamer with over 10 years of experience', '2024-02-10 03:14:14', 1),
('Kristopher Kersaw', 'kkersaw6w', 'kkersaw6w@last.fm', '$2a$04$QXX80SLecOc46OsOh9xhw.wYsT5NPGR1T.SnZfVll8xl3b7fv4Hyq', 'Professional gamer with over 10 years of experience', '2024-10-22 21:52:20', 1),
('Matthieu Feltham', 'mfeltham6x', 'mfeltham6x@cmu.edu', '$2a$04$wFPObys1WJsk0lnZGtb0O.T1GX9Tu9X68TEMta9r4/ZPKvtcvQyTC', 'Competitive gamer specializing in first-person shooters', '2024-05-18 12:26:20', 1),
('Rennie Lundon', 'rlundon6y', 'rlundon6y@shinystat.com', '$2a$04$zL5wbU5yTycRnsZ9kPgnIO7EfoJ7nUbAcpXPbZ2LdhClBht3JuJ6G', 'Professional gamer with over 10 years of experience', '2024-08-24 02:12:46', 1),
('Mable Crannell', 'mcrannell6z', 'mcrannell6z@fotki.com', '$2a$04$.yd7V4FDgfrsv38v2hY9Quu1YPjBBwV1HtwDtFB2R/Dd24vMR8WNC', 'Casual gamer who enjoys playing on weekends', '2024-01-15 07:53:09', 1),
('Archibaldo Rosettini', 'arosettini70', 'arosettini70@cisco.com', '$2a$04$nzQZF2vDc87xRlU08sF73OtMa8hchwlGIgelaaXfo0sKuExfptHkS', 'Casual gamer who enjoys playing on weekends', '2024-02-03 16:49:01', 1),
('Brit Skewis', 'bskewis71', 'bskewis71@amazon.de', '$2a$04$EyAhTqQnGj1tBea1G1JyeenFpbW2Uv5ybn4K74Ju6hBfNIDjWBAXW', 'Casual gamer who enjoys playing on weekends', '2024-04-08 11:14:54', 1),
('Astrix Seifert', 'aseifert72', 'aseifert72@lycos.com', '$2a$04$wAzu0q.0cuZWQ3TJVszNwuzTbDW4b4Etjo/Z1TD/Mjy/ESs4O6AGW', 'Casual gamer who enjoys playing on weekends', '2024-04-18 05:12:11', 1),
('Octavia Simonard', 'osimonard73', 'osimonard73@acquirethisname.com', '$2a$04$sKhuSUY0jIFYJbu6qfZFZu7N2dUG2lcvNM60UrPM.n/PfkjXvW40u', 'Professional gamer with over 10 years of experience', '2024-05-27 21:16:55', 1),
('Lorry Gawkes', 'lgawkes74', 'lgawkes74@discuz.net', '$2a$04$/gmdoLUJDxmnveFY8krvJOuixd7SgBx4hDbhm/AOpgT2dRC20yr66', 'Professional gamer with over 10 years of experience', '2024-08-28 12:41:35', 1),
('Tatiana Caldwell', 'tcaldwell75', 'tcaldwell75@tripadvisor.com', '$2a$04$9SEUhZvlP96vUs8c3G89H.RJaVKiIWVhXt9zpWvOhgiTghtw3UHfi', 'Competitive gamer specializing in first-person shooters', '2024-04-28 10:07:52', 1),
('Annnora Keam', 'akeam76', 'akeam76@bbb.org', '$2a$04$JB3F2cZZUzZQbUwe.YJNZONbh6ip8cUoknoCd4vnoPYF5/BNfi/yW', 'Casual gamer who enjoys playing on weekends', '2024-05-09 14:36:41', 1),
('Bennie Meltetal', 'bmeltetal77', 'bmeltetal77@flavors.me', '$2a$04$QA0yO.1jn42DKwRSmdFGJOyxiFkFV3kdks4jiEhDaTjIR3UjzPr4i', 'Casual gamer who enjoys playing on weekends', '2024-01-21 09:24:14', 1),
('Xenia Bagot', 'xbagot78', 'xbagot78@facebook.com', '$2a$04$osAgHIk/YPwwGE9vc.aVOOTSRKkPYAWrwHtBCAQyEMsIH8OuVYMBe', 'Casual gamer who enjoys playing on weekends', '2024-07-24 05:34:44', 1),
('Willette Scimoni', 'wscimoni79', 'wscimoni79@amazon.de', '$2a$04$Xm.QNZukxA/kOlpT6pjK6OpvElT3nCnATC5.R7PNb7kL7jwoQuoYu', 'Competitive gamer specializing in first-person shooters', '2024-06-11 19:50:58', 1),
('Anjanette Diemer', 'adiemer7a', 'adiemer7a@independent.co.uk', '$2a$04$zybA9TzgFFkXRNAn6XYDo.uC8HsuIeIfOYYiJ/Zjgz8OkJCCWu3CS', 'Casual gamer who enjoys playing on weekends', '2024-02-05 06:08:06', 1),
('Byran Benech', 'bbenech7b', 'bbenech7b@ted.com', '$2a$04$bAdn7sVVvy7UMuvndyFv4eRPvcpIv.rDVNKWFh81.1UzierajGPKu', 'Casual gamer who enjoys playing on weekends', '2024-08-17 11:25:16', 1),
('Almeria Grigorkin', 'agrigorkin7c', 'agrigorkin7c@naver.com', '$2a$04$AQKI2rnqGFz5RWSVEnKjK.yZucCfSwR9967Dzy5rhM3ht6O6u6Iv6', 'Professional gamer with over 10 years of experience', '2024-08-07 22:53:31', 1),
('Normy Vernalls', 'nvernalls7d', 'nvernalls7d@posterous.com', '$2a$04$Pd059auXjb6pky95HOsrCuQXF0qiY7TDm4K2TJWNdTgMfBmg.nkMW', 'Professional gamer with over 10 years of experience', '2024-05-12 03:51:51', 1),
('Marwin Fredi', 'mfredi7e', 'mfredi7e@techcrunch.com', '$2a$04$4C3ABtri03BanlreH6cMTujsMDEHpvgo58/yLs4RiFD6lS2v5h3rC', 'Competitive gamer specializing in first-person shooters', '2024-06-23 02:09:08', 1),
('Beverie McRonald', 'bmcronald7f', 'bmcronald7f@amazon.co.jp', '$2a$04$fx93m6rwVF9TSwpp.MS2zOqNAnR9Ya5yyMmipBK6nfm2sd/dZEaQe', 'Professional gamer with over 10 years of experience', '2024-09-21 12:14:35', 1),
('Carroll Beadon', 'cbeadon7g', 'cbeadon7g@cisco.com', '$2a$04$t2v6JuLImALt37DZuLsJxehcnbGN4csLRh7oQJ9HIt8bFzp5B5A1G', 'Casual gamer who enjoys playing on weekends', '2024-03-10 08:58:56', 1),
('Iorgo Milhench', 'imilhench7h', 'imilhench7h@51.la', '$2a$04$jTVTP7p/nHfwf7pl8tJvV.ogL8tcEWN0lyhtk22JYS.CZ5GKsgyj2', 'Casual gamer who enjoys playing on weekends', '2024-07-01 04:52:26', 1),
('Chelsae Habbema', 'chabbema7i', 'chabbema7i@imdb.com', '$2a$04$yD0DRS.0lKB/ipDQJTU9DuAOHQg4D2ZDyFywmW1O2/CH3G3CPUxUe', 'Casual gamer who enjoys playing on weekends', '2024-03-04 20:49:21', 1),
('Faulkner Bellefant', 'fbellefant7j', 'fbellefant7j@bluehost.com', '$2a$04$dtLl8rT1rtwbbkQRvURE0.dL/jZY3.p/S.WEkm196pZm2DwZBDpPG', 'Competitive gamer specializing in first-person shooters', '2024-06-03 08:36:46', 1),
('Davine Bernardet', 'dbernardet7k', 'dbernardet7k@wiley.com', '$2a$04$6uNaS/dam3TGTv28xrt4keoxNZGzaEcYWdyMjEWKNb8Z3OxWUJ9mS', 'Competitive gamer specializing in first-person shooters', '2024-05-21 11:04:51', 1),
('Elsi M''Quharg', 'emquharg7l', 'emquharg7l@virginia.edu', '$2a$04$f4h0tq4y39HKr4ZEV/8faenMZ1ktWdyvWJYtzIwmPH5Sr3DFd9Dl2', 'Professional gamer with over 10 years of experience', '2024-03-04 18:22:30', 1),
('Murry Kemmis', 'mkemmis7m', 'mkemmis7m@wordpress.org', '$2a$04$Z6eC1IntuaVBe7IakMtlUOLoovIz792lAVtAivHgm1bHj7SOqzMtO', 'Competitive gamer specializing in first-person shooters', '2024-09-01 21:55:46', 1),
('Letisha Fleming', 'lfleming7n', 'lfleming7n@weather.com', '$2a$04$u9g2.zrs85.6lkWmKmR7PumsvmV8nk8ChK8.GTP/uK4.qgXXSH92a', 'Competitive gamer specializing in first-person shooters', '2024-04-24 22:44:19', 1),
('Carmine Solano', 'csolano7o', 'csolano7o@i2i.jp', '$2a$04$BTwyPU1p3XT4dzmmQ797f.y1z3uD7792JwUrETRy3pzv8IqHrHVYu', 'Competitive gamer specializing in first-person shooters', '2024-05-25 17:26:59', 1),
('Alwin Prozescky', 'aprozescky7p', 'aprozescky7p@xrea.com', '$2a$04$KifvXahOP2AhqLuhEa7w8eVwHgvv9ItrrmWJ.d/rClwm32wdyfaEm', 'Professional gamer with over 10 years of experience', '2024-12-15 21:29:22', 1),
('Adelaida Buswell', 'abuswell7q', 'abuswell7q@yelp.com', '$2a$04$6ZguVw01ahbC4WT/2QkZAe4sL9FsCmZHb4IcQCVi2Az17jjOeMhyy', 'Professional gamer with over 10 years of experience', '2024-08-01 08:47:14', 1),
('Wyndham Galland', 'wgalland7r', 'wgalland7r@tumblr.com', '$2a$04$yx5P7AbkVekYpnYkq3hn2.vkFCbqtfwIH95UkESdqNDty441hoEli', 'Competitive gamer specializing in first-person shooters', '2024-09-12 16:38:19', 1),
('Wileen Routley', 'wroutley7s', 'wroutley7s@mapy.cz', '$2a$04$VqJ2Ht43HKRhQ02LLSgYz.2cVFhcIcOCytD8HTf85qgRVpsAxTeCW', 'Casual gamer who enjoys playing on weekends', '2024-04-11 15:11:02', 1),
('Halli Rushsorth', 'hrushsorth7t', 'hrushsorth7t@wired.com', '$2a$04$qjHj5S2IDd02BYKUHBRt2OcmXtvJvE4Ob2t9FG7fsDKzU2ZT0X9V2', 'Competitive gamer specializing in first-person shooters', '2024-09-15 19:23:16', 1),
('Birgitta Shimmings', 'bshimmings7u', 'bshimmings7u@miibeian.gov.cn', '$2a$04$yxvBUN.GWOVhOSC00MYxeOxeKS3Bluzyw9YjOKe7q1wHq.x29L4hy', 'Professional gamer with over 10 years of experience', '2024-09-22 19:00:42', 1),
('Conney Jonin', 'cjonin7v', 'cjonin7v@qq.com', '$2a$04$TD.eTmfg2S6YvcNGK5UIROLD8vCyQ3XnAd4.IrVZQ2xV5VDnvYqde', 'Professional gamer with over 10 years of experience', '2024-02-12 04:43:58', 1),
('Vinnie Whodcoat', 'vwhodcoat7w', 'vwhodcoat7w@msn.com', '$2a$04$Nm0WBYLd4.wAoFXBFRk7Vevh0o5Kea1HBg1TfOt9GiEZ/9uYd8c8S', 'Competitive gamer specializing in first-person shooters', '2024-06-28 21:09:59', 1),
('Hayley Grime', 'hgrime7x', 'hgrime7x@ucoz.ru', '$2a$04$/JYVz0l2AfdglKdfZgXfyu3vqOYzU7o92Gp/jlpnWBDfPUXKhCiPO', 'Competitive gamer specializing in first-person shooters', '2024-07-28 04:18:24', 1),
('Evelyn Muckian', 'emuckian7y', 'emuckian7y@desdev.cn', '$2a$04$NvcyR6iDlTo2NyyQ5nC9eu.58m23sUyyPAD1YKPiLTBRCFrG/ny2q', 'Competitive gamer specializing in first-person shooters', '2024-11-06 15:24:13', 1),
('Nessa Srutton', 'nsrutton7z', 'nsrutton7z@timesonline.co.uk', '$2a$04$ABTiTPDzEmaI7jODqcYz2e1SQNWGhjqbOWBLxOc0g1UHm1fvfSDwK', 'Competitive gamer specializing in first-person shooters', '2024-01-13 14:49:28', 1),
('Cirilo Jurick', 'cjurick80', 'cjurick80@shutterfly.com', '$2a$04$9KgczBgE6BMmmvd1eX0m1OUOp/mAf.5mfCWH7yxevJZjbLOYvjrHK', 'Professional gamer with over 10 years of experience', '2024-09-24 22:01:02', 1),
('Tabbi Ruecastle', 'truecastle81', 'truecastle81@ucoz.ru', '$2a$04$QyW7bwJFnIXgMWf1gDESZuroNlLoDFZQuuBkvtTogABzIasUnLOQe', 'Casual gamer who enjoys playing on weekends', '2024-02-14 22:17:55', 1),
('Falkner Lightbourn', 'flightbourn82', 'flightbourn82@uiuc.edu', '$2a$04$7z9CHrVDSA27Mck5SfqM8.A7VDt1el1AseNc2iIkHBAuZGL/qXvgy', 'Competitive gamer specializing in first-person shooters', '2024-06-29 20:13:39', 1),
('Emery McCloch', 'emccloch83', 'emccloch83@stumbleupon.com', '$2a$04$pGUfrKt9Wb.okUn9QgVE2Oja0u.YFWDtQz1SX0CCOxwmPB0Zv6.3K', 'Professional gamer with over 10 years of experience', '2024-02-16 02:30:14', 1),
('Keelby Coursor', 'kcoursor84', 'kcoursor84@mayoclinic.com', '$2a$04$eW2dqsSU4bhCqbYWj8xD/.E2YZFxdzit3.igZ42hIG/PJDhqNxzxy', 'Professional gamer with over 10 years of experience', '2024-09-25 02:54:22', 1),
('Aimil Caldicott', 'acaldicott85', 'acaldicott85@statcounter.com', '$2a$04$Pp.44cl5otNMc47FPL9Hge21fd8fYXV3GnsCCfGYsYOuxc84XInKa', 'Professional gamer with over 10 years of experience', '2024-07-09 07:30:25', 1),
('Townie Delgaty', 'tdelgaty86', 'tdelgaty86@sina.com.cn', '$2a$04$7L51ewbi8Q88GaM8bS8Ac.ogAn8xjUhXEwURKXdcNVpARvjc00z/W', 'Professional gamer with over 10 years of experience', '2024-07-29 02:17:00', 1),
('Janie Locarno', 'jlocarno87', 'jlocarno87@mayoclinic.com', '$2a$04$/l0ORkMeFrmEMlkMJ29By.UJfKqJ6DkoWapd4ZJ7vYUvjzDbhGTM.', 'Professional gamer with over 10 years of experience', '2024-12-14 03:38:22', 1),
('Fernanda Maryan', 'fmaryan88', 'fmaryan88@princeton.edu', '$2a$04$558h8jw7cZEHQcm3/0ZTJ.6naLT/TrVmOrlxyFd26.kxyePGB0TF6', 'Competitive gamer specializing in first-person shooters', '2024-05-24 15:06:26', 1),
('Kristin Shee', 'kshee89', 'kshee89@senate.gov', '$2a$04$l.AND4.3/wenSQBQf5OYcucQVzoIJr1/wCMDRc/YjO9Gu8wWJ10GO', 'Professional gamer with over 10 years of experience', '2024-11-10 21:15:26', 1),
('Shelley Rooper', 'srooper8a', 'srooper8a@theglobeandmail.com', '$2a$04$fAVxltl13sYcTsuVMNIKQeBxq6zmpFR0eOUuVNEcuzWaIUiRyewJe', 'Competitive gamer specializing in first-person shooters', '2024-03-31 01:16:04', 1),
('Valentin Antunez', 'vantunez8b', 'vantunez8b@abc.net.au', '$2a$04$pOIs56lXjLbfuoyOfjFr/.cHkF5F6Si9k1IBDpq7cktCoq8oFk.u6', 'Casual gamer who enjoys playing on weekends', '2024-06-03 03:08:01', 1),
('Sheryl Meake', 'smeake8c', 'smeake8c@discuz.net', '$2a$04$VVXC0M069Jv1Iday6cM1O.NkGJDj0NKx7.jyRtU99stzrC2pBFC0W', 'Professional gamer with over 10 years of experience', '2024-05-11 04:58:49', 1),
('Wilow Laws', 'wlaws8d', 'wlaws8d@virginia.edu', '$2a$04$5jx/kw8jw9Sq5VsLGZXav.Er4ZSFkZ4siUxXEbGM5NgWZ7QVXgEvK', 'Competitive gamer specializing in first-person shooters', '2024-02-17 02:26:22', 1),
('Christoph Heims', 'cheims8e', 'cheims8e@etsy.com', '$2a$04$T9e897O5ATPSE.AlkOvEDO5l/PqVCw/RHOxSqCBKP.Lb3zvqmL1pC', 'Competitive gamer specializing in first-person shooters', '2024-05-23 08:09:40', 1),
('Woodie O''Fogerty', 'wofogerty8f', 'wofogerty8f@over-blog.com', '$2a$04$aKVdUI5M3cKm0y4/j2ZoWOULylxEXqcsWcYNnK1t2.Loy7cekA6rW', 'Casual gamer who enjoys playing on weekends', '2024-04-03 10:42:32', 1),
('Eyde Wheeliker', 'ewheeliker8g', 'ewheeliker8g@wufoo.com', '$2a$04$iATfM7HOFY803qeww9GdHewmfnFE/oSnZ6jHUF08nmfzeSH29CxuS', 'Professional gamer with over 10 years of experience', '2024-06-04 11:45:24', 1),
('Jerri Strainge', 'jstrainge8h', 'jstrainge8h@europa.eu', '$2a$04$v4PBSp1QXt0mUrv0TarOleuP0EtOqpSqpRxzFEmqmWqcNTLNaVP1q', 'Casual gamer who enjoys playing on weekends', '2024-06-28 12:52:37', 1),
('Leontyne Kenchington', 'lkenchington8i', 'lkenchington8i@creativecommons.org', '$2a$04$2HQT6l9agQcZvXBSofCw4emzdiPyDv1y5n.Dati.V/efFE94giwnS', 'Competitive gamer specializing in first-person shooters', '2024-09-03 07:49:20', 1),
('Darnall Josephsen', 'djosephsen8j', 'djosephsen8j@domainmarket.com', '$2a$04$z0olZW1n/JzA1TzHhf191OS7NjxGE2PEzqUX3rjG.HExzQe10uxom', 'Competitive gamer specializing in first-person shooters', '2024-02-23 15:59:37', 1),
('Tod Meakes', 'tmeakes8k', 'tmeakes8k@accuweather.com', '$2a$04$/xxeRe2sR7RzWJpggjEKfOvPLiQU/.QnbJkVIUhp958I.pNghM.A6', 'Professional gamer with over 10 years of experience', '2024-05-08 06:46:53', 1),
('Karina Casham', 'kcasham8l', 'kcasham8l@mozilla.org', '$2a$04$E3a0L7oY0VSv76T3FATU9exsFFRQdLPUwA.LBuITtG1FwbchAp9r6', 'Professional gamer with over 10 years of experience', '2024-04-23 19:05:48', 1),
('Dolf Joannic', 'djoannic8m', 'djoannic8m@homestead.com', '$2a$04$fmrdkW.Tx9ODthP3V9K/2OV7q1MG.SlNyrdplZxS1H1V1m0LGY7GC', 'Professional gamer with over 10 years of experience', '2024-07-18 02:46:22', 1),
('Fergus Edscer', 'fedscer8n', 'fedscer8n@seesaa.net', '$2a$04$QlI7MnxOlZxgXhoed1x/quckAmGtU2nkUXJj6xxnPwWq0VkHj6coi', 'Casual gamer who enjoys playing on weekends', '2024-06-20 01:12:01', 1),
('Shurlock Sproul', 'ssproul8o', 'ssproul8o@utexas.edu', '$2a$04$liKMvkS6msvFZP6UNuA7ZOrNgXRO.SVlovdzgEuUbn2NBW2mmHWHa', 'Professional gamer with over 10 years of experience', '2024-05-11 16:56:20', 1),
('Gaylor Lippatt', 'glippatt8p', 'glippatt8p@hexun.com', '$2a$04$CPk8POX7a0XePpJQKw7ZzevpX.AONEst6MjEgcwkbNNEtt20VNL7m', 'Competitive gamer specializing in first-person shooters', '2024-08-31 12:17:48', 1),
('Shaylyn Heatly', 'sheatly8q', 'sheatly8q@usnews.com', '$2a$04$9ahKzAye.RkQPkXxn.vVne8OdfxGVvG.qPFROYCAPyBm10yKJ0kYe', 'Casual gamer who enjoys playing on weekends', '2024-08-29 10:35:20', 1),
('Claiborne Halfhide', 'chalfhide8r', 'chalfhide8r@twitter.com', '$2a$04$15AfCCD/N3qP/WlkErCh7.EMQffzusPtMGOxKTaWTjv.eEjk7zG5C', 'Competitive gamer specializing in first-person shooters', '2024-02-23 20:46:16', 1),
('Garrard Aviss', 'gaviss8s', 'gaviss8s@storify.com', '$2a$04$ktvgWExryalmpQj0ib5yyeZnQrKp3kmW.pjNsrkyT1UxZjJWbYaU2', 'Competitive gamer specializing in first-person shooters', '2024-08-01 21:08:44', 1),
('Reese Trusler', 'rtrusler8t', 'rtrusler8t@cam.ac.uk', '$2a$04$YXpyGUlqPKEL83P4tLpoHOIbfb.jFN4oOfpwJd5KCymoliRnewQY.', 'Competitive gamer specializing in first-person shooters', '2024-10-29 16:42:56', 1),
('Kenny Formie', 'kformie8u', 'kformie8u@virginia.edu', '$2a$04$faVh9bXvRqvkf4zhNhMFhelxkCspzjL0EfWWSJ37wCaHshX7pme8S', 'Competitive gamer specializing in first-person shooters', '2024-10-03 03:35:40', 1),
('Prudy McSparran', 'pmcsparran8v', 'pmcsparran8v@edublogs.org', '$2a$04$121yiOAtHMSHoq9Xkm/5C.eQo.QXE7X/R18Ams263Hm1YrcHEXxzu', 'Competitive gamer specializing in first-person shooters', '2024-01-31 00:56:37', 1),
('Stillman Dobrovsky', 'sdobrovsky8w', 'sdobrovsky8w@yahoo.com', '$2a$04$Wz7jpQlvPh8AFCc/vy.ZP.s9mhpPEdgOIiph/Y3bDBEkkAp8Cf4L.', 'Casual gamer who enjoys playing on weekends', '2024-06-15 03:47:46', 1),
('Salim Born', 'sborn8x', 'sborn8x@nba.com', '$2a$04$mQ4zmZN57dMd6msf2lX4QeZWLGMi.5A14I9yZL.i5kJBlTuveqfhe', 'Casual gamer who enjoys playing on weekends', '2024-06-22 05:34:16', 1),
('Kathi Cultcheth', 'kcultcheth8y', 'kcultcheth8y@wp.com', '$2a$04$tmYWoRq6tNnutHDnLv5cMuevtX/r.ZEVI/2fcxI.fXedLiL.1JuN2', 'Competitive gamer specializing in first-person shooters', '2024-01-07 17:53:39', 1),
('Marven Leeman', 'mleeman8z', 'mleeman8z@discuz.net', '$2a$04$oKvjLjnl/gUQFP4urIz.aOBVij1JBgPqvfQ.SuehSyKZVXDJagsjy', 'Professional gamer with over 10 years of experience', '2024-06-12 10:52:42', 1),
('Arlina Casini', 'acasini90', 'acasini90@nifty.com', '$2a$04$WzHTXW24sTcl82x2dv4qGOnJwHF56KNlCGukYxCc9pNeQnbMLP0em', 'Professional gamer with over 10 years of experience', '2024-08-02 00:39:00', 1),
('Jaime Ducket', 'jducket91', 'jducket91@mlb.com', '$2a$04$K3jMIrqj7UkTkLxJDpR7a.Fpe/..tL717lGoq3QVwu19IVEShRR2a', 'Competitive gamer specializing in first-person shooters', '2024-07-05 09:59:51', 1),
('Myrta Ovesen', 'movesen92', 'movesen92@amazon.co.uk', '$2a$04$GB6NG1s84mE8TqbjHK.F6uAv2eIwLJleFsCHhf32FIZXsss1Sp6Hi', 'Casual gamer who enjoys playing on weekends', '2024-10-29 01:00:41', 1),
('Fayth Vinnicombe', 'fvinnicombe93', 'fvinnicombe93@usda.gov', '$2a$04$X935jHiGdrv04S7VLorPnuUzI.CaA8C5la1xnV/bSLLYwh/Ioq/ry', 'Competitive gamer specializing in first-person shooters', '2024-11-22 17:30:45', 1),
('Ardelia Joselson', 'ajoselson94', 'ajoselson94@odnoklassniki.ru', '$2a$04$hWtQcODt4CMWZInMTGhlMu8elpTgBDEJ3tntNxA15zKRCiyOd8rVO', 'Competitive gamer specializing in first-person shooters', '2024-03-09 17:23:35', 1),
('Mollee Dollen', 'mdollen95', 'mdollen95@opera.com', '$2a$04$AWgJfV20FM20AOL/4PVZzuc4BMEZyHfajfD9XPAIGj8xpIym48gke', 'Professional gamer with over 10 years of experience', '2024-09-04 19:31:48', 1),
('Ardenia Unitt', 'aunitt96', 'aunitt96@netscape.com', '$2a$04$RqYuX5SrmFw5m.esebukmeM20prguh40uDw.RaHw/XAJ7kbIom2eS', 'Competitive gamer specializing in first-person shooters', '2024-03-10 01:12:34', 1),
('Carrol Truckell', 'ctruckell97', 'ctruckell97@photobucket.com', '$2a$04$uWy7vkUuvEJN2gDBMXAOkOKpWcrbuFnC9N7gA4jsv60tcoPzF1cB2', 'Professional gamer with over 10 years of experience', '2024-04-28 14:45:33', 1),
('Karia Gregorowicz', 'kgregorowicz98', 'kgregorowicz98@nbcnews.com', '$2a$04$UIwWp1dm51bWCR1z.7L.5O4GEWQYERmYAeaiOGKLfRbTFETfZqlJq', 'Competitive gamer specializing in first-person shooters', '2023-12-25 16:12:01', 1),
('Carry Carlisi', 'ccarlisi99', 'ccarlisi99@toplist.cz', '$2a$04$Vrqegd2gBp.cyVjh/v6S2ONFknkqyW9yASWYQF/8PGI03EGbVx1yu', 'Competitive gamer specializing in first-person shooters', '2024-08-24 17:32:32', 1),
('Daffie Formigli', 'dformigli9a', 'dformigli9a@biglobe.ne.jp', '$2a$04$DdMQBezK9KKNt67oSt8AJOPsjBWue2Pb7wv5UVdUJn0PsyMNRHcji', 'Competitive gamer specializing in first-person shooters', '2024-01-19 09:26:15', 1),
('Ailina De Cristoforo', 'ade9b', 'ade9b@angelfire.com', '$2a$04$6AkXseQcVYtxQ9JVo2sJoux1OptF3tu2SAT.wCuwW/gBWllF2RbhG', 'Professional gamer with over 10 years of experience', '2024-08-31 02:01:10', 1),
('Dionne Studde', 'dstudde9c', 'dstudde9c@about.me', '$2a$04$ZYOHFYlBlEG5TwizrJ0QG.Y8fW1XJV6dBBiwqURfvsuFehKXBvCE.', 'Casual gamer who enjoys playing on weekends', '2024-03-13 08:13:46', 1),
('Freedman Grunder', 'fgrunder9d', 'fgrunder9d@discuz.net', '$2a$04$o5Qj6U2ccJVE7eQK09.T7.9LuZ8//ssM6UzlvEKmVerpXb8rqEjim', 'Casual gamer who enjoys playing on weekends', '2024-10-14 12:20:12', 1),
('Aldis Longo', 'alongo9e', 'alongo9e@nba.com', '$2a$04$dB2x0g4RuyRSwxuNMEZrJeTXwQPHAMzwrhjYoy2H5YHkATnMipqLm', 'Professional gamer with over 10 years of experience', '2024-08-05 21:20:53', 1),
('Reynold Gadault', 'rgadault9f', 'rgadault9f@hatena.ne.jp', '$2a$04$MgRsNJ1VQu.cmr9fnurrJOQGE3PZBqFWA0ZjOv/FYBmfchsx5GZ1C', 'Casual gamer who enjoys playing on weekends', '2024-07-27 07:17:07', 1),
('Rollo Carsey', 'rcarsey9g', 'rcarsey9g@ow.ly', '$2a$04$LNJcw7lLjs5WzGQ.iD8WUuK2HkyHxJAJ5DwXeBmZgULavVQQPf4Ym', 'Casual gamer who enjoys playing on weekends', '2024-10-28 18:42:50', 1),
('Agnesse Phear', 'aphear9h', 'aphear9h@huffingtonpost.com', '$2a$04$4E0YiPIknp22ShMgTVu2eeEwV05HBIIEVUduzrimpcfPEnj/XnpHK', 'Competitive gamer specializing in first-person shooters', '2024-07-11 19:57:15', 1),
('Paulita Antonat', 'pantonat9i', 'pantonat9i@bloglines.com', '$2a$04$k2b/c/0DJz7ucpGZSoxSwOa6BEysDAERAbAW4CucCwYVldLD4e6.i', 'Casual gamer who enjoys playing on weekends', '2024-10-03 20:10:34', 1),
('Courtenay Wallett', 'cwallett9j', 'cwallett9j@google.co.jp', '$2a$04$ORS5KoaooOM46y1mj2fJv.6um0pdmlI4jFm45oHgJ933tMp86vQ/i', 'Casual gamer who enjoys playing on weekends', '2024-11-16 13:28:42', 1),
('Serena Skym', 'sskym9k', 'sskym9k@weibo.com', '$2a$04$dipxXEB5AEa5GDQ476WPFOYhK1CEZR/x.4SvbrW9ioHh0awtBCJ/m', 'Professional gamer with over 10 years of experience', '2024-04-14 05:06:00', 1),
('Sandy Smeeth', 'ssmeeth9l', 'ssmeeth9l@omniture.com', '$2a$04$1smmhRa0gIGSET5XruZ0WuFAQVuysgltrD6DGdfBg1aHz8onxbtoe', 'Casual gamer who enjoys playing on weekends', '2024-04-19 18:01:16', 1),
('Livvy Yoakley', 'lyoakley9m', 'lyoakley9m@tumblr.com', '$2a$04$lbnsy4BahsnSYga4meb97e7uT3A2e6Da9eNFGk1uZEeU46Fsj2ghm', 'Professional gamer with over 10 years of experience', '2024-05-16 21:09:10', 1),
('Sibeal Worham', 'sworham9n', 'sworham9n@weebly.com', '$2a$04$eEfyfh71Ax1tSm.3AVYdlOYsRyptdaawCaFyPLE/ArTfaqw8/teC.', 'Casual gamer who enjoys playing on weekends', '2024-09-01 03:44:39', 1),
('Francoise Triplett', 'ftriplett9o', 'ftriplett9o@go.com', '$2a$04$t4DoY9AVGmQOrypKZ6FUM.W7iaULS/xNQ6ToVMbpRtbLyXQfmvE0W', 'Competitive gamer specializing in first-person shooters', '2024-02-02 07:54:19', 1),
('Roanna Hanwright', 'rhanwright9p', 'rhanwright9p@ox.ac.uk', '$2a$04$cEHJFDCrz/NrQFoTT5zLdeuxbAEVXX1IS8uIJU7PxO7mS7zkZMRne', 'Competitive gamer specializing in first-person shooters', '2024-04-23 10:13:01', 1),
('Jamesy Osbiston', 'josbiston9q', 'josbiston9q@go.com', '$2a$04$MHMMwYH7WVUL70S.Dt82JOlooiwlECd/Lby0YUGjJ3ltat35vwpl2', 'Competitive gamer specializing in first-person shooters', '2024-06-03 04:05:27', 1),
('Melina Jurczyk', 'mjurczyk9r', 'mjurczyk9r@howstuffworks.com', '$2a$04$h8bewezic/8XeVoSCU./1OJVG1M2op76YVHL9Z/DXw93ONrcd50QK', 'Competitive gamer specializing in first-person shooters', '2024-08-02 01:43:33', 1),
('Shirleen Gillivrie', 'sgillivrie9s', 'sgillivrie9s@miibeian.gov.cn', '$2a$04$zIIZ9tPEj.V5BXo7Etc5keJa4WlxdT.VFNNVts46vNBswtc6tHQXG', 'Competitive gamer specializing in first-person shooters', '2024-01-07 12:00:32', 1),
('Brittan Malacrida', 'bmalacrida9t', 'bmalacrida9t@homestead.com', '$2a$04$bp27JgjSgPaKQBU/cOT84OjyBEWAkHJ/wD5UAdK1SI8YX9sTNEtYy', 'Casual gamer who enjoys playing on weekends', '2024-01-27 14:59:43', 1),
('Vere Bortolotti', 'vbortolotti9u', 'vbortolotti9u@adobe.com', '$2a$04$u1W2XDrgso0leadn/hXwsewWT3/tIGUC9DHMUlYXHJcBjevO/W4WC', 'Professional gamer with over 10 years of experience', '2024-06-06 04:17:30', 1),
('Harriette Whitwam', 'hwhitwam9v', 'hwhitwam9v@dmoz.org', '$2a$04$bf2DIsJXg5zaFmG6/CHwye2CYzStdoxkcRGWaVczotLanJryYELay', 'Professional gamer with over 10 years of experience', '2024-08-21 09:15:13', 1),
('Natalie Feldon', 'nfeldon9w', 'nfeldon9w@youku.com', '$2a$04$r2sbUgIlKDi7pcqldabZd.CBcM1TJ7Xa3zU.w9fen/zbsHqfm9KjW', 'Professional gamer with over 10 years of experience', '2024-12-05 09:52:14', 1),
('Fairfax Staggs', 'fstaggs9x', 'fstaggs9x@blogtalkradio.com', '$2a$04$THvfZNN1vf6JBlsWfcJRpuqXJk14HtmrHx1uwAEWb6JYyLs2kMvti', 'Professional gamer with over 10 years of experience', '2024-03-09 04:55:54', 1),
('Nanny Mickleborough', 'nmickleborough9y', 'nmickleborough9y@moonfruit.com', '$2a$04$ag8.T4x8M1mPxdNW40/Ik.5NSSxUL96evuOjmChky61/JzgQ18WRW', 'Professional gamer with over 10 years of experience', '2024-09-02 16:25:06', 1),
('Frieda Benck', 'fbenck9z', 'fbenck9z@nature.com', '$2a$04$49GGzbfBJf9KDQEs9rb9xejUKDYIru15rb.zHksSz39VjJVf18ksm', 'Casual gamer who enjoys playing on weekends', '2024-01-25 17:59:58', 1),
('Birgitta Brayshaw', 'bbrayshawa0', 'bbrayshawa0@typepad.com', '$2a$04$8ZKNrQOUOXp0ZF1e//NbYeHd1PwvpKZfScD3mr6Mydha6Z0VWInU6', 'Competitive gamer specializing in first-person shooters', '2024-09-28 07:44:10', 1),
('Kirby Berwick', 'kberwicka1', 'kberwicka1@adobe.com', '$2a$04$6XDDO7jTpcD0cvYKE9UUJOj4v5ZV/2M5TVJVrEOX72sG70Mfq88QO', 'Professional gamer with over 10 years of experience', '2024-05-02 12:22:33', 1),
('Marnia Gonthier', 'mgonthiera2', 'mgonthiera2@dropbox.com', '$2a$04$gsXMiyOlpzv2OwFJJgYQz.bjoyS.uWOSiziZO0qNlq2aMC4UCnDPW', 'Casual gamer who enjoys playing on weekends', '2024-01-26 20:55:21', 1),
('Cleve Blaszczynski', 'cblaszczynskia3', 'cblaszczynskia3@opera.com', '$2a$04$W5zm6TGbRV1xPsLwlIgCtO4eyEt87CG2m88yWQzTP.Qc5ox9/bpjO', 'Competitive gamer specializing in first-person shooters', '2024-05-03 11:55:45', 1),
('Aile MacPharlain', 'amacpharlaina4', 'amacpharlaina4@dion.ne.jp', '$2a$04$sMEHyIypclLSANgGJQJ5Vedby5xbKMofHdhXyaaZ98w4GY/P/sGMe', 'Competitive gamer specializing in first-person shooters', '2024-07-02 08:48:16', 1),
('Oates Bingle', 'obinglea5', 'obinglea5@studiopress.com', '$2a$04$1z1LzFX9SJEqPQivgTREWOyhogbcvnEWSyze5fqSVDemOhWBUzYuO', 'Professional gamer with over 10 years of experience', '2024-10-23 21:41:38', 1),
('Kelly McKim', 'kmckima6', 'kmckima6@unc.edu', '$2a$04$BdD4JRg5MYg62jryGe5ncuVHoDRY4LIB7iBnMUBKLkImIqYrq5vMa', 'Competitive gamer specializing in first-person shooters', '2024-02-20 19:18:38', 1),
('Lammond Spark', 'lsparka7', 'lsparka7@w3.org', '$2a$04$56utxUFksfsz.v.TikSESuGgsSqbLcV6D.AXGkOrhhpt.hGfFkyTm', 'Professional gamer with over 10 years of experience', '2024-11-12 11:21:41', 1),
('Lindon Limbrick', 'llimbricka8', 'llimbricka8@pagesperso-orange.fr', '$2a$04$yeqKwgHJAvDDjkcqMUlAuOOBdKysZOwEWjH75Z43wXTpyGzg1eUra', 'Competitive gamer specializing in first-person shooters', '2024-11-01 15:44:55', 1),
('Sherlock Bearward', 'sbearwarda9', 'sbearwarda9@squarespace.com', '$2a$04$t/RJSeD50CSPWCOnfPz6Y.qbhNk9wAMwFKQP8550CaWv7fMv1PBKO', 'Competitive gamer specializing in first-person shooters', '2024-08-24 14:49:17', 1),
('Fedora Voules', 'fvoulesaa', 'fvoulesaa@surveymonkey.com', '$2a$04$5TB94stfmCjyupK9v2u0FeArJSHbQbPb6WlpLQUcd1PmupQIGuWzG', 'Casual gamer who enjoys playing on weekends', '2024-04-14 09:11:30', 1),
('Arlana O Sullivan', 'aoab', 'aoab@gov.uk', '$2a$04$T1E/7JCtwQLxnh54mPkGLOTmGjZIF.IIbm8OC9.wdI5PX4hsJFSo6', 'Casual gamer who enjoys playing on weekends', '2024-04-22 15:41:29', 1),
('Letitia Margery', 'lmargeryac', 'lmargeryac@buzzfeed.com', '$2a$04$DYq/aHT12M6is0mmwJB5ZO8b3zqZ/lDBB7Qr7WWR7l8wXFKnZbltC', 'Professional gamer with over 10 years of experience', '2024-04-24 23:28:02', 1),
('Chip Woodvine', 'cwoodvinead', 'cwoodvinead@godaddy.com', '$2a$04$pbi5CZbD/r0ow5Cz2C932u1iFsqDwFHDph5334ACnSAosPDE.BKA6', 'Professional gamer with over 10 years of experience', '2024-01-08 13:18:32', 1),
('Pavel Showen', 'pshowenae', 'pshowenae@dailymotion.com', '$2a$04$jIbV0xPr/vncJRbFrcM1Uewu23pubhCtTcoUynw8iC6fkDvZ.lrT.', 'Casual gamer who enjoys playing on weekends', '2024-01-22 05:24:56', 1),
('Elicia Godson', 'egodsonaf', 'egodsonaf@tinyurl.com', '$2a$04$ZZk06q5fDoFACTzxcTzrH.6xGDDjg9nQs15rq2s1PTwNc.XyqNmKW', 'Casual gamer who enjoys playing on weekends', '2024-06-27 03:53:37', 1),
('Loria Klass', 'lklassag', 'lklassag@imdb.com', '$2a$04$TvnW0Ko33oq2kmmCQfY1j.vthkUWxPmeiLkeaeb582YQFCCddIFxm', 'Casual gamer who enjoys playing on weekends', '2024-02-05 14:11:29', 1),
('Ethyl Gianullo', 'egianulloah', 'egianulloah@smugmug.com', '$2a$04$QY.915SB2apIOuugC416ZedcE4m9RVck/3bZ7XtDnxlu.Irdpp/Iq', 'Professional gamer with over 10 years of experience', '2024-06-24 20:52:07', 1),
('Rupert Alenov', 'ralenovai', 'ralenovai@tuttocitta.it', '$2a$04$PWIACTS9aeeGx9x3r4SuA.52E0QKQ0mBxuuxzJL4E989ITKnG2GkW', 'Casual gamer who enjoys playing on weekends', '2024-08-20 04:12:36', 1),
('Lanny Salmen', 'lsalmenaj', 'lsalmenaj@state.tx.us', '$2a$04$Y7gwxt2J.zR4YsToFHHS5uLgIkHGhve/fwYl4la8MneeSHulQNuUe', 'Competitive gamer specializing in first-person shooters', '2023-12-22 05:08:07', 1),
('Juliann Urien', 'jurienak', 'jurienak@constantcontact.com', '$2a$04$LxVcKi7ytvgWK27uDC5wl.jNQRQyVOa6.vooT3K2b1QPPthQxcDKS', 'Professional gamer with over 10 years of experience', '2024-04-06 02:06:54', 1),
('Ethelda Shepley', 'eshepleyal', 'eshepleyal@ucoz.com', '$2a$04$oqoiUh4exY6dN0yZPwchpuRIhIj7fTjkhcdE12yLFyt7PPhBn29jm', 'Professional gamer with over 10 years of experience', '2024-02-01 14:38:20', 1),
('Prisca Carnilian', 'pcarnilianam', 'pcarnilianam@state.tx.us', '$2a$04$d63PrNn/Wvv4a6x3uzOq4uZYfy9HdAfnN/YdMz8aSATdG4Us9DU/C', 'Casual gamer who enjoys playing on weekends', '2024-05-30 23:45:30', 1),
('Melodie Grinaugh', 'mgrinaughan', 'mgrinaughan@t.co', '$2a$04$ebuLybkK7k91AuZawpJ.a.JlsGSL1H.bF2IKFTVfoP8nEK7bGWs/W', 'Competitive gamer specializing in first-person shooters', '2024-06-02 10:42:21', 1),
('Osmund Lawty', 'olawtyao', 'olawtyao@springer.com', '$2a$04$dgELJAKaF8ylnRYXwmVGx.TBdf8UPkE2V5HtA8d93IdopkVZok.MO', 'Professional gamer with over 10 years of experience', '2024-09-16 15:38:41', 1),
('Filide Batkin', 'fbatkinap', 'fbatkinap@craigslist.org', '$2a$04$aPwdYfBTuNskhqKXTMMJmOqkULIhYDRFoTNVKObvN0oCcRpw6V2pC', 'Competitive gamer specializing in first-person shooters', '2023-12-29 19:13:15', 1),
('Elwin Rosenberg', 'erosenbergaq', 'erosenbergaq@i2i.jp', '$2a$04$OleDEkghl5wFzIWV5y6YqO3XlyEQKWxHGHZBvjj8hekapsgxrfFra', 'Competitive gamer specializing in first-person shooters', '2024-01-26 00:35:04', 1),
('Madella Jaram', 'mjaramar', 'mjaramar@free.fr', '$2a$04$Lrnqg2gt6.0P.fRMLAe5CuRCcadJ1K2Byy71Tpv9p0YfW2HqQEh9q', 'Competitive gamer specializing in first-person shooters', '2024-12-15 16:17:24', 1),
('Gwyneth Lampitt', 'glampittas', 'glampittas@goo.ne.jp', '$2a$04$WRIwrLQqRtZUjoItoj8OtenIT3Hcg5qjbRGla/U5j13Tn3ih9EOti', 'Professional gamer with over 10 years of experience', '2024-10-19 16:33:03', 1),
('Paige Devorill', 'pdevorillat', 'pdevorillat@google.nl', '$2a$04$MwF3JbgFEPdT5a2HLUcJm.AZr2oxxXZeKPCuxRWyglkVdoZxAlyFe', 'Competitive gamer specializing in first-person shooters', '2024-04-22 03:59:31', 1),
('Kat Heskin', 'kheskinau', 'kheskinau@posterous.com', '$2a$04$BQ46fqiQuY4dR5xtcMKGsu9hAgUVnGAAf3/w1b.VkrPfEb2TZfqtW', 'Casual gamer who enjoys playing on weekends', '2024-07-12 18:34:18', 1),
('Corrianne Bartleman', 'cbartlemanav', 'cbartlemanav@123-reg.co.uk', '$2a$04$v5TxZ2sucRezzfgmbVpOj.JA6PHSKsDtfe8LT1ajb3Ocfqj/JmL7m', 'Casual gamer who enjoys playing on weekends', '2024-03-04 22:09:47', 1),
('Kaylee Dooher', 'kdooheraw', 'kdooheraw@usatoday.com', '$2a$04$5..DrSni3WolaHw1fs07jOrzblTKseAp5ln.nSFoJPRUGLR5NJhOu', 'Casual gamer who enjoys playing on weekends', '2024-06-30 12:17:04', 1),
('Derrik Franceschi', 'dfranceschiax', 'dfranceschiax@elpais.com', '$2a$04$qwtEyo1FFiYLzicdHHfC0uEyOQK5p1L6GDUZBzYPxa8NOUBTv5gje', 'Professional gamer with over 10 years of experience', '2024-01-08 21:49:38', 1),
('Shae MacGillicuddy', 'smacgillicuddyay', 'smacgillicuddyay@nih.gov', '$2a$04$hMImhgXO6fMghvhOFDNVg.fEphvHxCmu6MszF0C.NTRlKzjVqkZcy', 'Casual gamer who enjoys playing on weekends', '2024-07-11 04:39:12', 1),
('Genia Scogin', 'gscoginaz', 'gscoginaz@simplemachines.org', '$2a$04$SUodsuyuXNwNbXw/EJSfR.MeZaHHFxJEilw6Nl4PmUHw8CM.RJZr2', 'Competitive gamer specializing in first-person shooters', '2024-02-18 14:24:45', 1),
('Gavra Shay', 'gshayb0', 'gshayb0@google.cn', '$2a$04$ig43C.02mzFVZQe2gwjs8OsYp4pLIL3fzNoQ1gWOO9MHZ7auTP39C', 'Professional gamer with over 10 years of experience', '2024-04-25 18:27:48', 1),
('Joete Jozwicki', 'jjozwickib1', 'jjozwickib1@ucoz.com', '$2a$04$SCV07nOcyZBxi6iiR1kxyuL6EQ6uhjyRg8AhX1LU9CV1A1TgoKKSe', 'Competitive gamer specializing in first-person shooters', '2024-12-04 14:50:41', 1),
('Neille Sproston', 'nsprostonb2', 'nsprostonb2@nba.com', '$2a$04$PYeLhpvULOMFcoo/8UXSJebB4qgL.SD7wTfEurWU6D0xYccSw5efK', 'Competitive gamer specializing in first-person shooters', '2024-08-15 13:39:00', 1),
('Serge Errett', 'serrettb3', 'serrettb3@umich.edu', '$2a$04$fa1/Upy4HbAnWgQg9gXUs.S4/kq8/poesvRqCPdHMoJdPLwrb/WVm', 'Professional gamer with over 10 years of experience', '2024-01-02 15:08:04', 1),
('Tiertza Rooksby', 'trooksbyb4', 'trooksbyb4@4shared.com', '$2a$04$UNEDAKKCMbb4USO.7XV0y.QmNiSXiaiLfNre0FIPwaGQGvfAxFTRC', 'Professional gamer with over 10 years of experience', '2024-04-03 09:35:46', 1),
('Essa Armiger', 'earmigerb5', 'earmigerb5@ezinearticles.com', '$2a$04$saplNHjzW7ZON.4ALosJC.uptHmXERoVPQuXNre9KXLnVO1MRLZdW', 'Casual gamer who enjoys playing on weekends', '2024-05-08 00:13:46', 1),
('Marten Chismon', 'mchismonb6', 'mchismonb6@ifeng.com', '$2a$04$NFmFDq9KeINDp.3yeYjTdeC2JM68NC8wXIAVozq2QJl2AX/gd1kEm', 'Competitive gamer specializing in first-person shooters', '2024-09-08 22:56:01', 1),
('Dianna Zannuto', 'dzannutob7', 'dzannutob7@blinklist.com', '$2a$04$FteaiyPoL/3a310v5GyAguWjzZ1AM9sck5OwyAnBATMRfHUs2EexC', 'Competitive gamer specializing in first-person shooters', '2024-12-04 01:45:54', 1),
('Hunfredo Hummerston', 'hhummerstonb8', 'hhummerstonb8@mapquest.com', '$2a$04$peSDvChpnDSdR5u8bnjkFOhzwJuJopAvs0sqx4d8Vx4u7VVXareUO', 'Competitive gamer specializing in first-person shooters', '2024-09-08 22:28:31', 1),
('Ingrim Scarr', 'iscarrb9', 'iscarrb9@amazon.co.uk', '$2a$04$Qfr84uBz.aTcqDFX1yjkKu4a3hmG28x8IKu8sJEiEgU9MCrAgUrTu', 'Professional gamer with over 10 years of experience', '2024-02-06 00:12:27', 1),
('Duffie Penniall', 'dpenniallba', 'dpenniallba@ucla.edu', '$2a$04$KPRQUt8q95b6R.KQgmn11eDxLbuGQbCncWSq.zq7DpGNlrW03AKbS', 'Casual gamer who enjoys playing on weekends', '2024-03-18 00:52:08', 1),
('Carie Doe', 'cdoebb', 'cdoebb@hao123.com', '$2a$04$RGpqIKsy1QMeQFu7vZjA/.UHUtucuYG.n.Uk8DepPyqCSdY6E7/66', 'Professional gamer with over 10 years of experience', '2024-07-03 17:14:27', 1),
('Dimitry MacIan', 'dmacianbc', 'dmacianbc@mac.com', '$2a$04$Ok6cMKC.wY3wn.oD9mdMSu6b/nXRwkXd0tElf5NQerlVS7WSOfIkm', 'Casual gamer who enjoys playing on weekends', '2024-12-01 19:12:10', 1),
('Kurtis Mortell', 'kmortellbd', 'kmortellbd@paginegialle.it', '$2a$04$8SpVhEMcpLuc2QS2HP.UhOHCGcT8RmqdAhj9a/IKvRvXua/y6oaJS', 'Professional gamer with over 10 years of experience', '2024-08-29 14:58:00', 1),
('Sandro Hills', 'shillsbe', 'shillsbe@printfriendly.com', '$2a$04$Ive7MosNottfdwvuNO4L6eWrUJzZU9DY0eq8g5MrdAsOsAeIw6p7K', 'Professional gamer with over 10 years of experience', '2024-01-27 21:06:15', 1),
('Conroy Pavlov', 'cpavlovbf', 'cpavlovbf@jimdo.com', '$2a$04$kzyfcNu0lmDrMa0.uTLY1efktwaGDf6W6rgUSRMTiWBmzmvjjo8vS', 'Professional gamer with over 10 years of experience', '2024-11-28 08:16:35', 1),
('Lyn Andriveaux', 'landriveauxbg', 'landriveauxbg@usatoday.com', '$2a$04$muCRUOG1O9bEV7UIrPSeZubY.rNKZxE/2P83QSAsjpbd.MH25rBUm', 'Casual gamer who enjoys playing on weekends', '2024-11-27 22:00:36', 1),
('Rodrique Kendal', 'rkendalbh', 'rkendalbh@123-reg.co.uk', '$2a$04$qGZHGZChDfa.gLBhWIZkGewskUiUT5JI6PDt22Q6pqqFQ/e2KRClK', 'Competitive gamer specializing in first-person shooters', '2024-01-12 12:50:56', 1),
('Violante Anwell', 'vanwellbi', 'vanwellbi@macromedia.com', '$2a$04$huhqRTYjNFqDb3JZQm7GpOVnHbDdphP.U17axui/KmIfe4w8sYUhO', 'Professional gamer with over 10 years of experience', '2024-07-04 19:13:31', 1),
('Laura Tompsett', 'ltompsettbj', 'ltompsettbj@livejournal.com', '$2a$04$GOfstNtD9oNuFMefDH.jSO8peobqtduJ9Dswp9AKtolOy4fhEC//2', 'Competitive gamer specializing in first-person shooters', '2024-12-04 12:05:09', 1),
('Jozef Kobiela', 'jkobielabk', 'jkobielabk@163.com', '$2a$04$gaHzhQmxtkhhHGWf3Bu81.alIxhslZrsv4BcZ1JgpVa/yzNtk29rC', 'Competitive gamer specializing in first-person shooters', '2024-07-10 15:41:10', 1),
('Liz Birden', 'lbirdenbl', 'lbirdenbl@cornell.edu', '$2a$04$5MLO02sA6lJLQf0j3Y3lgOzlMogxq1GVCrjLmzgI9OS142FOrMVVO', 'Professional gamer with over 10 years of experience', '2024-12-04 21:44:53', 1),
('Celine Stammirs', 'cstammirsbm', 'cstammirsbm@techcrunch.com', '$2a$04$UBti.bji3uUq4qZF.s4T.OqNxPVFa4T2iCsZQhVSc2juASJLhMX7C', 'Competitive gamer specializing in first-person shooters', '2024-08-15 18:26:45', 1),
('Cooper Nertney', 'cnertneybn', 'cnertneybn@meetup.com', '$2a$04$rPl2a6Erar6EJ2n3F1mIy.xSfQjxsUdWQBJGjGCC0pZvOptFlQF9S', 'Casual gamer who enjoys playing on weekends', '2024-10-23 19:06:40', 1),
('Frasier Patley', 'fpatleybo', 'fpatleybo@noaa.gov', '$2a$04$ogyCc0x9NyqJQQMHjp.ACeq48yFIaT1RYbIRdbNXLlmFskFauizVm', 'Professional gamer with over 10 years of experience', '2024-10-24 12:02:12', 1),
('Patricia Tookill', 'ptookillbp', 'ptookillbp@princeton.edu', '$2a$04$jfikwIy6rTJvpB86SuOsqeXjMpNHnznXnzj9dfBJVKpeFhBJwabhe', 'Casual gamer who enjoys playing on weekends', '2024-08-29 00:53:16', 1),
('Ammamaria Catterson', 'acattersonbq', 'acattersonbq@toplist.cz', '$2a$04$rGIL7f74I860jgDp6iv/i.9dVds.JOtRnNRbTp8h3nwEOSduLPQ7W', 'Casual gamer who enjoys playing on weekends', '2024-01-24 18:18:52', 1),
('Lennard Corr', 'lcorrbr', 'lcorrbr@yandex.ru', '$2a$04$4e9m8V0/yjPZ51poXkFWQeiepCwNbXFb7u0PISm0s8naJz8iUztdK', 'Competitive gamer specializing in first-person shooters', '2023-12-25 09:16:57', 1),
('Keir Hewes', 'khewesbs', 'khewesbs@answers.com', '$2a$04$7xt4E3Ztk5NeGI74FEUKxOxJoDOUU6vmQEVqin/MRO0Ods5i29mim', 'Casual gamer who enjoys playing on weekends', '2023-12-26 14:10:19', 1),
('Fina Brettelle', 'fbrettellebt', 'fbrettellebt@hexun.com', '$2a$04$LagXdzhjkOTuoECjqePVCOgEcTCQNh39CwVcAod..uwY4KZ1q0Cne', 'Professional gamer with over 10 years of experience', '2024-03-23 07:19:47', 1),
('Mureil Elsip', 'melsipbu', 'melsipbu@hugedomains.com', '$2a$04$vl4TNW2yJKx9vvyFY9.eEOxKlNB1U0jX3nFtM6VTNIT.evv0hdxPS', 'Casual gamer who enjoys playing on weekends', '2024-12-02 02:15:48', 1),
('Garnette Bushnell', 'gbushnellbv', 'gbushnellbv@hp.com', '$2a$04$4F93s4L9zG56c456e3prtuz5BCQnr2bDAOxbH98xYeiEwnvW0Nqiy', 'Casual gamer who enjoys playing on weekends', '2024-02-08 03:35:14', 1),
('Emlynne Sculley', 'esculleybw', 'esculleybw@com.com', '$2a$04$JMq/qCTNpINSb8lRXebbYOfxunIO9zSRGD0ELd9d44Zv/2ztjMT/6', 'Competitive gamer specializing in first-person shooters', '2024-11-25 11:33:38', 1),
('Ashley Genicke', 'agenickebx', 'agenickebx@comcast.net', '$2a$04$6UrRCKlAKFlXkB1Wvgb5YekOp18CSE4ZOcgrL306PKyBzKNWnSIy2', 'Competitive gamer specializing in first-person shooters', '2024-05-16 00:46:22', 1),
('Timothea Firmager', 'tfirmagerby', 'tfirmagerby@un.org', '$2a$04$xjLJrWiziBUeB60dmKpJSeG6Se9nWe8/kVgcNehgFzkrpu4QrMfOm', 'Competitive gamer specializing in first-person shooters', '2024-09-19 13:25:34', 1),
('Georgy Rowledge', 'growledgebz', 'growledgebz@cloudflare.com', '$2a$04$LJRY3ZJ8ZfzpxQoAYuduaOFI2Qdga3Yd0137RNJDrxRHzivSvsd36', 'Professional gamer with over 10 years of experience', '2024-01-23 21:35:19', 1),
('Elissa Ellson', 'eellsonc0', 'eellsonc0@skype.com', '$2a$04$WiXj4irLE9614XmxrYHzF.WJuFi5nKLSGDDdEPy5SY5u683dbeAdC', 'Casual gamer who enjoys playing on weekends', '2024-02-15 22:27:44', 1),
('Janela Alldre', 'jalldrec1', 'jalldrec1@vistaprint.com', '$2a$04$wM6Ak40Gtohh/pUdetRi6emwqlUBWJgjs.djPi1/V.eixt2WorjJO', 'Professional gamer with over 10 years of experience', '2024-12-19 14:50:54', 1),
('Iain Faiers', 'ifaiersc2', 'ifaiersc2@mashable.com', '$2a$04$IkNlhGesMjop8pNJfF2iPenZfjgF/dFFJaSl51yAs/lHe165JTM4u', 'Casual gamer who enjoys playing on weekends', '2024-11-13 23:56:10', 1),
('Paxon Libreros', 'plibrerosc3', 'plibrerosc3@xing.com', '$2a$04$BPEHsSNwa6TxhrvhdXgnK.deomFd2/1iqucT7bt5t7I0Dz/ASWnhC', 'Competitive gamer specializing in first-person shooters', '2024-11-05 20:55:09', 1),
('Scotti Hugill', 'shugillc4', 'shugillc4@google.com.br', '$2a$04$aH8i4OzL8Hoa3NRDuQp/5uFhnWAEa2v1mNgzN7xSycXugOXPE8qxm', 'Competitive gamer specializing in first-person shooters', '2024-06-08 01:06:06', 1),
('Marylee Penchen', 'mpenchenc5', 'mpenchenc5@alexa.com', '$2a$04$HxbngsYaLUQKZoo.LfubOeZka8Q8rKBHMMPdg.nJp7yz8Lcn9lAbm', 'Professional gamer with over 10 years of experience', '2024-08-28 23:18:02', 1),
('Berrie MacCarroll', 'bmaccarrollc6', 'bmaccarrollc6@bloomberg.com', '$2a$04$RZ1v9sA.57Juqd9Lo9fzPe1ubCXxOY58uMvJkVoAXUNeYByJNAMg2', 'Professional gamer with over 10 years of experience', '2024-02-16 10:19:00', 1),
('Beatrisa Sebright', 'bsebrightc7', 'bsebrightc7@ibm.com', '$2a$04$I.L/iHUpo7ZNYJvpPrUrJuKMQX2T.VtitxEfbIBBAfkkSO5To534G', 'Casual gamer who enjoys playing on weekends', '2024-05-13 21:26:38', 1),
('Palm Camoys', 'pcamoysc8', 'pcamoysc8@instagram.com', '$2a$04$ss5J9LKU7ezs2Wy8Yl3IWuDz1FY3SRxuXh/HTKX0HFZBNI0ZTrumS', 'Competitive gamer specializing in first-person shooters', '2024-09-30 09:25:17', 1),
('Rosetta Ridde', 'rriddec9', 'rriddec9@rediff.com', '$2a$04$jeSPJQhM3fL.qGUNhVGgmu88Uxbr0l1UUnydAJsv/gyKeoJzGGDqm', 'Competitive gamer specializing in first-person shooters', '2024-02-23 23:00:59', 1),
('Curran Caughte', 'ccaughteca', 'ccaughteca@bravesites.com', '$2a$04$4aCbQ5HSs.dO3S5rSE7Kkuf5dd2G/M4BReHgIq4dP8dZP0dicoKE2', 'Casual gamer who enjoys playing on weekends', '2024-09-13 01:02:45', 1),
('Ernest Willford', 'ewillfordcb', 'ewillfordcb@ted.com', '$2a$04$KspR9V.duWTGr1UBLIotqujjGhHlNuSB1fYXClBZfeVjDfsE18yyK', 'Competitive gamer specializing in first-person shooters', '2024-05-03 00:32:28', 1),
('Hatti Rubinfeld', 'hrubinfeldcc', 'hrubinfeldcc@about.me', '$2a$04$7vqvzuqu0n7obYH0/XI8iuCrHJniGwi1XbitPEpP7axyr7EKjiJmq', 'Casual gamer who enjoys playing on weekends', '2024-09-20 22:29:37', 1),
('Gifford Licari', 'glicaricd', 'glicaricd@wisc.edu', '$2a$04$gT2vL2a3M4lO4j4LnGxl2u5A63z2x.SOwi3jH7lMDEOr4DYPra8AW', 'Competitive gamer specializing in first-person shooters', '2024-05-26 15:14:16', 1),
('Margareta Uttley', 'muttleyce', 'muttleyce@ameblo.jp', '$2a$04$seaXpdwSwHaVL9eUami0zeWa/Pz2LcI4omnyayyNQJ/mkEv4hTY6e', 'Competitive gamer specializing in first-person shooters', '2024-07-18 14:03:34', 1),
('Norman Lewsley', 'nlewsleycf', 'nlewsleycf@e-recht24.de', '$2a$04$J6DfmacKQrC48pLYMVhH2u8l5tJy6u7OpxM1EseFuGfE/plzechZm', 'Professional gamer with over 10 years of experience', '2024-10-31 04:28:48', 1),
('Susie Rosindill', 'srosindillcg', 'srosindillcg@rediff.com', '$2a$04$Xp.pHGxiy56UNjLRdB9/y.ZqxyJaCuE.blyYv0ZfgYa3YsKsBip4m', 'Professional gamer with over 10 years of experience', '2024-06-04 10:19:47', 1),
('Kelila Poulston', 'kpoulstonch', 'kpoulstonch@hud.gov', '$2a$04$rQqWF8Buv1JIVOh988FSduBl5Ic.uMelDcIS7xaxfnQEOTMOy2NuW', 'Casual gamer who enjoys playing on weekends', '2024-09-18 17:54:33', 1),
('Shoshanna Geerling', 'sgeerlingci', 'sgeerlingci@wikimedia.org', '$2a$04$ADU5tRRh38JvFtUna5bLhOCszuIeCNq2Fg74zZR10AT3IwsYVIIRG', 'Professional gamer with over 10 years of experience', '2024-12-10 05:12:43', 1),
('Grantley Scammonden', 'gscammondencj', 'gscammondencj@auda.org.au', '$2a$04$oMYUvP9OQQr2.ZHLgg.ldOWcl6IrmIVgJHRQTu8wPelT9O/2734aG', 'Competitive gamer specializing in first-person shooters', '2024-03-01 12:39:55', 1),
('Randi Masson', 'rmassonck', 'rmassonck@alibaba.com', '$2a$04$iUQdAOKoPiOsjbnAvtXeHu5Ce/8oshep5W.mD.ZgUY4.NhOrvm/9C', 'Competitive gamer specializing in first-person shooters', '2024-01-28 08:09:26', 1),
('Hattie Stubbs', 'hstubbscl', 'hstubbscl@rambler.ru', '$2a$04$yVfaYsUiThP54JtQTxADtuf0hZL7g7j.QPrN1dOY59SgfdjV4F1De', 'Competitive gamer specializing in first-person shooters', '2024-07-08 10:27:18', 1),
('Amalita Heinonen', 'aheinonencm', 'aheinonencm@wufoo.com', '$2a$04$S9Nc1EPb7rC6SRfxZazlUeUkzzwACrsEY7fKx4rgjQ8CbIY7P/HHi', 'Competitive gamer specializing in first-person shooters', '2024-09-13 17:40:11', 1),
('Roseanne Meritt', 'rmerittcn', 'rmerittcn@wix.com', '$2a$04$kY2Q7iegvRsakKVJD5ACIOu86ScC7o6nBsWNWttwaZkj3EMff891O', 'Professional gamer with over 10 years of experience', '2024-12-03 23:49:49', 1),
('Thea Glenton', 'tglentonco', 'tglentonco@ifeng.com', '$2a$04$EAijbkgWn4PxWD9M/xWV4.nzwOx8pmaMlRIYM53eVaPLZHPvPMIs.', 'Competitive gamer specializing in first-person shooters', '2024-08-10 03:30:55', 1),
('Zechariah Jewiss', 'zjewisscp', 'zjewisscp@usatoday.com', '$2a$04$uNycwu8lt2icimD7/ENcBuwGGbrqePjpBBT6vBtS.fb0KC2S7IB06', 'Professional gamer with over 10 years of experience', '2024-03-02 07:58:04', 1),
('Garold Brooke', 'gbrookecq', 'gbrookecq@sourceforge.net', '$2a$04$TaWgImcSvtHN/DdLIbEW2uFqkl1rlfo7VpWwmi0MNJHhIsCY5Lkd.', 'Competitive gamer specializing in first-person shooters', '2024-06-10 08:48:45', 1),
('Beryle Lewsey', 'blewseycr', 'blewseycr@linkedin.com', '$2a$04$jp1/IPeFv1Q36xXKeVKYwe2a1hkr7eT0hWNBcra9VK3qPrWjHo1V6', 'Competitive gamer specializing in first-person shooters', '2024-07-16 23:22:35', 1),
('Nicoli Rigts', 'nrigtscs', 'nrigtscs@webs.com', '$2a$04$OPa3.iURAb1kZsYPCCZzveyWra08gt/WuNpVY4oEAruleRqpHSxO6', 'Professional gamer with over 10 years of experience', '2024-09-15 04:40:24', 1),
('Guendolen Scutter', 'gscutterct', 'gscutterct@tinyurl.com', '$2a$04$1ow5WAOl1KYd9uNBYkW7M.oD/NGKv9XgAA5UzCmguTs0FTyhfji7q', 'Competitive gamer specializing in first-person shooters', '2024-03-16 20:00:52', 1),
('Augusto Phillippo', 'aphillippocu', 'aphillippocu@chron.com', '$2a$04$Qdn7c6UfscmWUQcWpH.wyehdggrtpqOjnFQeqPE2121L0yBgFVrBm', 'Professional gamer with over 10 years of experience', '2024-07-26 22:20:37', 1),
('Gavra Fattore', 'gfattorecv', 'gfattorecv@ifeng.com', '$2a$04$MxWZaSVeYvAPE9.nptoA.eNpsSVeiVYigxq63lOo8l0UShDjBrf72', 'Casual gamer who enjoys playing on weekends', '2024-01-03 22:03:53', 1),
('Hyman Macrow', 'hmacrowcw', 'hmacrowcw@bloglovin.com', '$2a$04$uMXXA/guT7qfEdqitS8XMeWWR9ISqDvP6qtG5tmr3bdrbb7gC3MmC', 'Professional gamer with over 10 years of experience', '2024-10-12 11:19:04', 1),
('Hyacintha Schiersch', 'hschierschcx', 'hschierschcx@desdev.cn', '$2a$04$kUsIbcVOH6mZPyLsGYNpRO0gX0Oc78Vx/YKEuPt.XA0sCk0LvhwMK', 'Competitive gamer specializing in first-person shooters', '2024-09-20 22:37:53', 1),
('Mattie Latehouse', 'mlatehousecy', 'mlatehousecy@multiply.com', '$2a$04$vskirBBYyGxJBBe8oyqWn.ZQqJVomVkT1INQs/UVGlamdwI6f79iu', 'Professional gamer with over 10 years of experience', '2024-02-02 19:02:52', 1),
('Silvanus Bowra', 'sbowracz', 'sbowracz@mail.ru', '$2a$04$vqlBFXKkl713Fjzzqo09dO/MyPww3HaQpCIzjt4X0djB6/llRu3RO', 'Casual gamer who enjoys playing on weekends', '2024-06-21 08:02:55', 1),
('My Flay', 'mflayd0', 'mflayd0@mayoclinic.com', '$2a$04$pOOYC.HnkpSzjeG/4p/qqufTMvLghQZAY6wL1eBFz7H8W2K.aipn2', 'Professional gamer with over 10 years of experience', '2024-08-06 13:02:25', 1),
('Mohandis Redgrave', 'mredgraved1', 'mredgraved1@bing.com', '$2a$04$t3STuelCcFjJM4zzEghX0O6HnXytCKBDtpYw.8Aok488EP5QdkTIa', 'Professional gamer with over 10 years of experience', '2024-05-28 12:30:30', 1),
('Tillie Trillo', 'ttrillod2', 'ttrillod2@technorati.com', '$2a$04$ygE4.idyqzwLddIY.4mu9uvKFVHMqZfIr8NrVxxn/Gl/XpPExvaii', 'Casual gamer who enjoys playing on weekends', '2024-01-03 23:02:39', 1),
('Deana Siddens', 'dsiddensd3', 'dsiddensd3@npr.org', '$2a$04$T2FGbCHqHc3SIt8U8H/yxOTIEy25FxYjD1xs7rD.EBIQGXfr.rOE2', 'Professional gamer with over 10 years of experience', '2024-10-16 07:07:47', 1),
('Jarred Charrett', 'jcharrettd4', 'jcharrettd4@yolasite.com', '$2a$04$ACv3guTD8jeedn5rcJOyJ.CxV7z7CebsN/uqceLvsUGWZ10MKGTWC', 'Competitive gamer specializing in first-person shooters', '2023-12-23 12:30:08', 1),
('Tadeo Aizlewood', 'taizlewoodd5', 'taizlewoodd5@geocities.com', '$2a$04$RaVwueZEMoi1aKlPbnfKIOfoFbgOMdMcTdU9O5QgF90orshWNi7UK', 'Competitive gamer specializing in first-person shooters', '2024-09-21 05:40:58', 1),
('Carmelina Jarrett', 'cjarrettd6', 'cjarrettd6@over-blog.com', '$2a$04$rA98/GmAgLz6LfIPnHDh6ekGqeSS48aQp7JWZlOTD.dfkT3ym1c8m', 'Competitive gamer specializing in first-person shooters', '2024-03-11 03:47:50', 1),
('Liva Leahy', 'lleahyd7', 'lleahyd7@i2i.jp', '$2a$04$Go.Va/6b9kqEJSfTe1TEiuE9lA.W3MmFQeroizYGhE94gLp/DA5/2', 'Competitive gamer specializing in first-person shooters', '2024-07-02 00:41:12', 1),
('Burch Sprasen', 'bsprasend8', 'bsprasend8@uol.com.br', '$2a$04$xBNurkXHdUzgjFXu0qE0f.gqclnmqOfRfBVoxWbK5/R1dy87/pf0C', 'Professional gamer with over 10 years of experience', '2024-06-07 09:26:26', 1),
('Hollie Rihosek', 'hrihosekd9', 'hrihosekd9@yellowpages.com', '$2a$04$KhYQXCt4M3svPSitImL5deaEOSizXNxyIKa0Ll8lSMQT69YWpN4DS', 'Casual gamer who enjoys playing on weekends', '2024-10-23 16:15:46', 1),
('Flynn Sygrove', 'fsygroveda', 'fsygroveda@alexa.com', '$2a$04$J9bJSSCapdT.RkpkkbgEFePQR8T1T6AJ.RIzcHtfnkaPygh.IAO8e', 'Competitive gamer specializing in first-person shooters', '2024-04-28 03:15:44', 1),
('Krishna Consadine', 'kconsadinedb', 'kconsadinedb@boston.com', '$2a$04$YB.K6bE/MX4DFb5Zctqa2eu2IVOH/IvQh499AvVPdMqwX3fK8Qmpe', 'Competitive gamer specializing in first-person shooters', '2024-04-18 19:19:29', 1),
('Glynda Peppin', 'gpeppindc', 'gpeppindc@ask.com', '$2a$04$9nR0oWL6I/iZ85ckUpgHVOzOXfCKg4VBnU8ds7ZsFVEl4T0xD1Zgy', 'Professional gamer with over 10 years of experience', '2024-07-21 09:07:51', 1),
('Tressa Cathie', 'tcathiedd', 'tcathiedd@lycos.com', '$2a$04$xamu.EnDFwbUjz4WSOSF2OPrBhL4rrQkfdSuIJn2QfmxpYYOZ6SE.', 'Casual gamer who enjoys playing on weekends', '2024-07-20 18:10:39', 1),
('Faunie De Banke', 'fdede', 'fdede@homestead.com', '$2a$04$fLFwwyQ790LkQ.xZudmU6eCMH2y3O1xDjRQcup877yafu4jeSCyaO', 'Professional gamer with over 10 years of experience', '2024-10-09 10:42:18', 1),
('Siegfried Eads', 'seadsdf', 'seadsdf@paginegialle.it', '$2a$04$r8yGHS/GNOIUEm9p3RBpo.UoPvwq.r6uh291ipR4XCq7D2116CB.W', 'Casual gamer who enjoys playing on weekends', '2024-04-16 03:43:43', 1),
('Tonnie Vlasyuk', 'tvlasyukdg', 'tvlasyukdg@ycombinator.com', '$2a$04$tgaG/63yH3X3G2sXO63bjeN6X2onhN4KunI9u8tDiOqkVhVY6M4h6', 'Casual gamer who enjoys playing on weekends', '2024-03-16 11:32:58', 1),
('Lockwood Rowswell', 'lrowswelldh', 'lrowswelldh@illinois.edu', '$2a$04$UAtZdTg9i10uOYR4pfVAye9CbGpaNagdUy8FdyzLchIHwBdkmDXEC', 'Professional gamer with over 10 years of experience', '2024-12-09 14:34:26', 1),
('Toma Atwool', 'tatwooldi', 'tatwooldi@nyu.edu', '$2a$04$l3kzagnAadEl8RiOo7ypwOolmljQfETqArdssdVzh45Hjuxr0.VYe', 'Casual gamer who enjoys playing on weekends', '2024-01-15 13:38:41', 1),
('Lauren Gagin', 'lgagindj', 'lgagindj@hugedomains.com', '$2a$04$.ZJO4oS67HQeLwA9HV7nXe8sXawvdt/P3OaXK3dRCRaKkU3UF3ATK', 'Casual gamer who enjoys playing on weekends', '2024-03-12 06:09:42', 1),
('Amerigo Lamperti', 'alampertidk', 'alampertidk@jimdo.com', '$2a$04$Iu9Yyq8H4oidwDHUL1QIQ.IXkbK5KzgY4leIMTQef1Pa3rXAbFW7i', 'Competitive gamer specializing in first-person shooters', '2024-05-08 02:34:16', 1),
('Jeanette Rupprecht', 'jrupprechtdl', 'jrupprechtdl@si.edu', '$2a$04$r1DYe7Uu7XOHpi.yRIHUTe5lS1Xn8NLILgYBo8L9PrQ6tzz1ht2oy', 'Casual gamer who enjoys playing on weekends', '2024-05-01 15:28:59', 1),
('Dari Snawdon', 'dsnawdondm', 'dsnawdondm@deliciousdays.com', '$2a$04$K6XyATftK.SurG96G3IJLuidaUQOLj351zZw/FUq4NA1yG0N841Hm', 'Competitive gamer specializing in first-person shooters', '2024-02-27 04:49:16', 1),
('Ilario Paskell', 'ipaskelldn', 'ipaskelldn@tinypic.com', '$2a$04$fZ9kLTHgVc0mUO/oqEjtKOb4cRiEivxYAsAMcMpo5tzU7Mxx.B5ji', 'Casual gamer who enjoys playing on weekends', '2024-11-29 20:43:03', 1),
('Pris Wyman', 'pwymando', 'pwymando@goo.ne.jp', '$2a$04$dS.0RXqNDzm3Ti/Tsqp7S.5PB231OyxwHSW0ag04hBZZ8OE29Hlb6', 'Casual gamer who enjoys playing on weekends', '2024-06-03 10:10:39', 1),
('Westleigh Blowing', 'wblowingdp', 'wblowingdp@de.vu', '$2a$04$ikotyZc.u9vjx4ny0S2WauYy.zybzJg1DK2ASHc.Dm/yiBO/BPm96', 'Competitive gamer specializing in first-person shooters', '2024-12-12 10:52:58', 1),
('Merv Duffett', 'mduffettdq', 'mduffettdq@ibm.com', '$2a$04$6juwsAU1U6Di40rW4cDj5.DmgZOT28mINhfyV.jv3DCDahU6yiIvu', 'Professional gamer with over 10 years of experience', '2024-10-12 03:42:22', 1),
('Durward Silby', 'dsilbydr', 'dsilbydr@guardian.co.uk', '$2a$04$9FFxreiAEzuMX2hlL2RKnOZqUZ.KBP86UCMaxWNMu7zCWw9gyr.VG', 'Professional gamer with over 10 years of experience', '2024-02-02 00:25:35', 1),
('Leia Gethen', 'lgethends', 'lgethends@angelfire.com', '$2a$04$8nO6K/n2yzBtIS4o6V8jHuq/tTGDBDTgppQIrxHtteqnb647RGcUy', 'Competitive gamer specializing in first-person shooters', '2024-04-30 13:54:40', 1),
('Rea Dalinder', 'rdalinderdt', 'rdalinderdt@state.tx.us', '$2a$04$MIq3p4N3V9QZMMk5DS2fSu.8JIW7qQ9ZHKx2qsNqSITywdHGG6hCa', 'Professional gamer with over 10 years of experience', '2024-07-21 02:09:23', 1),
('Odelinda Roblett', 'oroblettdu', 'oroblettdu@mapquest.com', '$2a$04$WkEzn1zQOufCXvIW2YkWSeZt9dry3B/xQCeGye3EewBst0KfO08E6', 'Competitive gamer specializing in first-person shooters', '2024-07-08 14:14:05', 1),
('Jonie Treweke', 'jtrewekedv', 'jtrewekedv@reverbnation.com', '$2a$04$DylQkALYJ0aDM4aNYPrtkOnMw1ag5w.6QdtSCiys82llhDRxkF7ii', 'Casual gamer who enjoys playing on weekends', '2023-12-28 14:11:06', 1);

-- Populate Administrator
INSERT INTO Administrator (id_user) VALUES
(5),
(6);

-- Populate Storage
INSERT INTO Storage (storage) VALUES
(0.5),
(1),
(2),
(4),
(8),
(16),
(32),
(64),
(120),
(128),
(250),
(256),
(512),
(600),
(750),
(1000),
(1024),
(1500),
(2000),
(2048),
(2500),
(3000),
(4000),
(4096),
(5000),
(6000),
(8000);

-- Populate GraphicsCard
INSERT INTO GraphicsCard (graphicscard) VALUES
('NVIDIA GTX 1050'),
('NVIDIA GTX 1050 Ti'),
('NVIDIA GTX 1060'),
('NVIDIA GTX 1070'),
('NVIDIA GTX 1080'),
('NVIDIA GTX 1660'),
('NVIDIA GTX 1660 Ti'),
('NVIDIA RTX 2060'),
('NVIDIA RTX 2070'),
('NVIDIA RTX 2080'),
('NVIDIA RTX 3060'),
('NVIDIA RTX 3070'),
('NVIDIA RTX 3080'),
('NVIDIA RTX 3090'),
('NVIDIA RTX 4050'),
('NVIDIA RTX 4060'),
('NVIDIA RTX 4070'),
('NVIDIA RTX 4080'),
('NVIDIA RTX 4090'),
('NVIDIA RTX 5090'),
('NVIDIA RTX 5080'),
('NVIDIA RTX 5070 Ti'),
('NVIDIA RTX 5070'),
('AMD Radeon RX 570'),
('AMD Radeon RX 580'),
('AMD Radeon RX 590'),
('AMD Radeon RX 6700 XT'),
('AMD Radeon RX 6800'),
('AMD Radeon RX 6900 XT'),
('AMD Radeon RX 7600 XT'),
('AMD Radeon RX 7700 XT'),
('AMD Radeon RX 7800 XT'),
('AMD Radeon RX 7900 XT'),
('AMD Radeon RX 7900 XTX'),
('AMD Radeon RX 6600 XT'),
('AMD Radeon RX 6600'),
('AMD Radeon RX 6500 XT'),
('AMD Radeon RX 5500 XT'),
('AMD Radeon RX 5300M'),
('AMD Radeon RX 5700 XT'),
('AMD Radeon RX 5700'),
('AMD Radeon RX 5600 XT'),
('AMD Radeon RX 5600M'),
('AMD Radeon RX 5500M'),
('AMD Radeon RX 5300M');

-- Populate Processor
INSERT INTO Processor (processor) VALUES
('Intel i3'),
('Intel i5'),
('Intel i7'),
('Intel i9'),
('Intel Xeon'),
('AMD Ryzen 3'),
('AMD Ryzen 5'),
('AMD Ryzen 7'),
('AMD Ryzen 9'),
('AMD Threadripper'),
('AMD EPYC'),
('Apple M1'),
('Apple M1 Pro'),
('Apple M1 Max'),
('Apple M2'),
('Qualcomm Snapdragon 888'),
('Qualcomm Snapdragon 8 Gen 1'),
('Qualcomm Snapdragon 8 Gen 2'),
('Qualcomm Snapdragon 8cx Gen 3'),
('Intel Celeron'),
('Intel Pentium'),
('AMD Athlon'),
('AMD Ryzen Threadripper Pro'),
('AMD Ryzen 5 Pro'),
('AMD Ryzen 7 Pro'),
('AMD Ryzen 9 Pro'),
('Intel Core 2 Duo'),
('Intel Core 2 Quad'),
('Intel Core i5-12600K'),
('Intel Core i7-12700K'),
('Intel Core i9-12900K'),
('AMD Ryzen 5 5600X'),
('AMD Ryzen 7 5800X'),
('AMD Ryzen 9 5900X'),
('AMD Ryzen 9 5950X'),
('Apple M1 Ultra'),
('Apple M2 Pro'),
('Apple M2 Max'),
('Qualcomm Snapdragon 8cx Gen 4'),
('Qualcomm Snapdragon 7c Gen 3'),
('Qualcomm Snapdragon 7c+ Gen 3'),
('Qualcomm Snapdragon 4 Gen 1'),
('Intel Core i3-12100'),
('Intel Core i5-12400'),
('Intel Core i7-12700F'),
('Intel Core i9-12900F'),
('AMD Ryzen 3 4100'),
('AMD Ryzen 5 5500'),
('AMD Ryzen 7 5700X'),
('AMD Ryzen 9 5900HX'),
('AMD Ryzen 9 6900HX'),
('Apple M1 Max'),
('Apple M1 Pro'),
('Apple M1'),
('Qualcomm Snapdragon 8 Gen 1 Plus'),
('Qualcomm Snapdragon 8 Gen 2 Plus'),
('Qualcomm Snapdragon 8cx Gen 3 Plus'),
('Intel Core i5-12600F'),
('Intel Core i7-12700F'),
('Intel Core i9-12900F'),
('AMD Ryzen 5 5600G'),
('AMD Ryzen 7 5700G'),
('AMD Ryzen 9 5900G'),
('AMD Ryzen 9 5950G'),
('Apple M2 Ultra'),
('Apple M2 Pro'),
('Apple M2 Max'),
('Qualcomm Snapdragon 8cx Gen 4 Plus'),
('Qualcomm Snapdragon 7c Gen 4'),
('Qualcomm Snapdragon 7c+ Gen 4'),
('Qualcomm Snapdragon 4 Gen 2'),
('Intel Core i3-12300'),
('Intel Core i5-12600'),
('Intel Core i7-12700'),
('Intel Core i9-12900'),
('AMD Ryzen 3 4200'),
('AMD Ryzen 5 5500U'),
('AMD Ryzen 7 5700U'),
('AMD Ryzen 9 5900U'),
('AMD Ryzen 9 6900U'),
('Apple M1 Pro'),
('Apple M1 Max'),
('Apple M1'),
('Qualcomm Snapdragon 8 Gen 1'),
('Qualcomm Snapdragon 8 Gen 2'),
('Qualcomm Snapdragon 8cx Gen 3'),
('Qualcomm Snapdragon 7c Gen 3'),
('Qualcomm Snapdragon 7c+ Gen 3'),
('Qualcomm Snapdragon 4 Gen 1');

-- Populate MemoryRAM
INSERT INTO MemoryRAM (memoryram) VALUES
(0.5),
(1),
(2),
(4),
(8),
(16),
(32),
(64),
(128),
(256),
(512),
(1024),
(2048);

-- Populate OperatingSystem
INSERT INTO OperatingSystem (operatingsystem) VALUES
('Windows 10'),
('Windows 11'),
('Windows 7'),
('Windows 8'),
('Linux'),
('Ubuntu'),
('Fedora'),
('Debian'),
('CentOS'),
('Arch Linux'),
('Manjaro'),
('Red Hat Enterprise Linux'),
('Mint Linux'),
('openSUSE'),
('Kali Linux'),
('Zorin OS'),
('Elementary OS'),
('MacOS'),
('macOS Ventura'),
('macOS Monterey'),
('macOS Big Sur'),
('iOS'),
('Android'),
('FreeBSD'),
('OpenBSD'),
('Raspberry Pi OS'),
('Chrome OS'),
('Solus'),
('Windows XP'),
('Windows Vista'),
('PlayStation 2'),
('PlayStation 3'),
('PlayStation 4'),
('PlayStation 5'),
('Nintendo Switch'),
('Nintendo 3DS'),
('Nintendo Wii U'),
('XBOX One'),
('XBOX Series X/S'),
('XBOX 360');

-- Populate Category
INSERT INTO category (id, category_name) VALUES
(1, 'Action'),
(2, 'Adventure'),
(3, 'RPG'),
(4, 'Strategy'),
(5, 'Simulation'),
(6, 'Horror'),
(7, 'Fantasy'),
(8, 'Sci-Fi'),
(9, 'Sports'),
(10, 'Mystery'),
(11, 'Arcade'),
(12, 'Historical'),
(13, 'Space'),
(14, 'Western'),
(15, 'Medieval'),
(16, 'Zombie'),
(17, 'Underwater');

-- Populate Seller
INSERT INTO Seller (id_user, rating, total_sales_number, total_earned) VALUES
(1, '4', 10, 1000.00),
(2, '5', 150, 5214.5);

-- Populate Payment
INSERT INTO Payment (amount, payment_date) VALUES
(59.99, CURRENT_DATE),
(39.99, CURRENT_DATE),
(49.99, '2024-08-08 10:56:15'),
(49.99, '2024-08-17 01:05:48'),
(49.99, '2024-09-17 02:03:21'),
(49.99, '2024-03-04 17:36:27'),
(49.99, '2024-05-25 19:57:58'),
(49.99, '2024-07-13 21:52:05'),
(49.99, '2024-09-12 20:16:37'),
(49.99, '2024-03-01 11:46:02'),
(49.99, '2024-03-09 02:17:06'),
(49.99, '2024-06-27 05:25:26'),
(49.99, '2024-07-19 01:01:53'),
(49.99, '2024-01-20 08:36:01'),
(49.99, '2024-05-30 03:03:57'),
(49.99, '2024-02-14 18:46:42'),
(49.99, '2024-07-07 16:53:30'),
(49.99, '2024-01-09 02:26:40'),
(49.99, '2024-06-01 07:38:56'),
(49.99, '2024-10-24 17:37:19'),
(49.99, '2024-08-08 11:13:42'),
(49.99, '2024-12-16 21:37:27'),
(49.99, '2024-06-28 23:29:45'),
(49.99, '2024-09-23 12:21:45'),
(49.99, '2024-08-08 02:27:44'),
(49.99, '2024-06-10 19:23:14'),
(49.99, '2024-10-05 02:38:48'),
(49.99, '2024-06-22 11:25:20'),
(49.99, '2024-06-20 09:20:44'),
(49.99, '2024-03-18 13:09:48'),
(49.99, '2024-07-07 21:19:12'),
(49.99, '2024-06-26 15:24:05'),
(49.99, '2024-08-06 17:53:11'),
(49.99, '2024-07-10 17:55:35'),
(49.99, '2024-03-14 10:36:01'),
(49.99, '2024-08-30 06:28:34'),
(49.99, '2024-12-10 04:15:35'),
(49.99, '2024-08-30 14:32:19'),
(49.99, '2024-08-14 22:39:30'),
(49.99, '2024-06-19 04:13:50'),
(49.99, '2024-06-05 15:33:33'),
(49.99, '2024-04-02 03:43:02'),
(49.99, '2024-07-04 04:14:40'),
(49.99, '2024-10-06 17:23:01'),
(49.99, '2023-12-29 02:18:58'),
(49.99, '2024-09-24 06:40:12'),
(49.99, '2024-04-01 17:25:46'),
(49.99, '2024-03-13 02:02:45'),
(49.99, '2024-05-20 05:37:40'),
(49.99, '2024-08-17 11:00:14'),
(49.99, '2024-01-11 08:43:19'),
(49.99, '2023-12-22 17:15:44'),
(49.99, '2024-03-27 02:00:32'),
(49.99, '2024-04-29 23:07:30'),
(49.99, '2024-06-18 04:43:07'),
(49.99, '2024-06-07 06:34:32'),
(49.99, '2024-03-03 15:52:35'),
(49.99, '2024-07-21 21:02:07'),
(49.99, '2024-05-10 23:11:03'),
(49.99, '2024-12-12 03:37:05'),
(49.99, '2024-09-04 02:30:43'),
(49.99, '2024-12-08 05:35:28'),
(49.99, '2024-10-01 16:29:57'),
(49.99, '2024-05-16 03:13:31'),
(49.99, '2024-02-28 02:00:49'),
(49.99, '2024-06-20 21:49:45'),
(49.99, '2024-08-29 18:03:34'),
(49.99, '2024-05-11 12:00:39'),
(49.99, '2024-12-01 01:28:58'),
(49.99, '2024-09-25 18:11:03'),
(49.99, '2024-03-31 09:14:02'),
(49.99, '2024-06-28 14:33:00'),
(49.99, '2024-02-20 01:57:01'),
(49.99, '2024-10-21 07:46:15'),
(49.99, '2024-01-20 03:08:22'),
(49.99, '2024-09-10 22:32:10'),
(49.99, '2024-06-19 06:04:59'),
(49.99, '2024-07-16 19:49:01'),
(49.99, '2024-09-11 08:38:41'),
(49.99, '2024-07-11 04:28:00'),
(49.99, '2024-10-13 17:36:22'),
(49.99, '2024-09-11 02:52:17'),
(49.99, '2024-10-01 16:29:57'),
(49.99, '2024-05-16 03:13:31'),
(49.99, '2024-02-28 02:00:49'),
(49.99, '2024-06-20 21:49:45'),
(49.99, '2024-08-29 18:03:34'),
(49.99, '2024-05-11 12:00:39'),
(49.99, '2024-12-01 01:28:58'),
(49.99, '2024-09-25 18:11:03'),
(49.99, '2024-03-31 09:14:02'),
(49.99, '2024-06-28 14:33:00'),
(49.99, '2024-02-20 01:57:01'),
(49.99, '2024-10-21 07:46:15'),
(49.99, '2024-01-20 03:08:22'),
(49.99, '2024-09-10 22:32:10'),
(49.99, '2024-06-19 06:04:59'),
(49.99, '2024-07-16 19:49:01'),
(49.99, '2024-09-11 08:38:41'),
(49.99, '2024-07-11 04:28:00'),
(49.99, '2024-10-13 17:36:22'),
(49.99, '2024-09-11 02:52:17');

-- Populate Game

-- Insert games with new boolean columns
INSERT INTO game (name, price, release_date, description, rating, stock, id_seller, id_operatingsystem, id_memoryram, id_processor, id_graphicscard, id_storage, is_highlighted, is_on_sale, discount_price) VALUES
('Farming Simulator 25 (PC)', 50.99, '2024-11-12 00:00:00', 'Farming Simulator 25 floods the fields with a host of new machines, gameplay features, visual upgrades, and even fresh water to grow rice - adding even more agricultural depth and diversity to the family-friendly series.', 0, 20, 1, 1, 1, 1, 1, 1, TRUE, FALSE, NULL),
('Minecraft Java & Bedrock Edition (PC)', 19.99, '2024-06-07 00:00:00', 'Create, explore, survive, repeat. Minecraft: Java Edition and Bedrock Edition are now a package deal for Windows. Minecraft: Java & Bedrock Edition gives you access to both games in one purchase and one unified launcher, making it easier than ever to go from one edition to the other. Cross-play with any Minecrafter by simply switching to the edition your friends have. Now you can enjoy twice the mining and twice the crafting – with more Minecrafters than ever.', 0, 30, 2, 2, 2, 2, 2, 2, FALSE, TRUE, 11.99),
('S.T.A.L.K.E.R. 2: Heart of Chornobyl (PC)', 49.99, '2024-11-20 00:00:00', 'Chornobyl Exclusion Zone has changed dramatically after the second massive explosion in year 2006. Violent mutants, deadly anomalies, warring factions have made the Zone a very tough place to survive. Nevertheless, artifacts of unbelievable value attracted many people called S.T.A.L.K.E.R.s, who entered the Zone for their own risk striving to make a fortune out of it or even to find the Truth concealed in the Heart of Chornobyl.', 0, 15, 1, 3, 3, 3, 3, 3, FALSE, FALSE, NULL),
('The Last of Us Part I (PC)', 49.99, '2023-03-28 00:00:00', 'Experience the emotional storytelling and unforgettable characters in The Last of Us™, winner of over 200 Game of the Year awards. In a ravaged civilization, where infected and hardened survivors run rampant, Joel, a weary protagonist, is hired to smuggle 14-year-old Ellie out of a military quarantine zone. However, what starts as a small job soon transforms into a brutal cross-country journey.', 0, 25, 2, 1, 3, 2, 23, 6, TRUE, TRUE, 24.99),
('Ghost of Tsushima DIRECTOR''S CUT (PC)', 39.99, '2024-05-16 00:00:00', 'For the very first time on PC, play through Jin Sakai’s journey and discover the complete Ghost of Tsushima experience in this Director’s Cut. In the late 13th century, the Mongol empire has laid waste to entire nations along their campaign to conquer the East. Tsushima Island is all that stands between mainland Japan and a massive Mongol invasion fleet led by the ruthless and cunning general, Khotun Khan. As the island burns in the wake of the first wave of the Mongol assault, courageous samurai warrior Jin Sakai stands resolute. As one of the last surviving members of his clan, Jin is resolved to do whatever it takes, at any cost, to protect his people and reclaim his home. He must set aside the traditions that have shaped him as a warrior to forge a new path, the path of the Ghost, and wage an unconventional war for the freedom of Tsushima.', 0, 10, 1, 5, 5, 5, 5, 5, FALSE, FALSE, NULL),
('SILENT HILL 2 (PC)', 39.99, '2024-10-08 00:00:00', 'Experience a master-class in psychological horror―lauded as the best in the series―on the latest hardware with chilling visuals and visceral sounds.', 0, 20, 2, 1, 3, 2, 4, 6, TRUE, FALSE, NULL),
('Final Fantasy XVI Complete Edition (PC)', 59.99, '2024-09-17 00:00:00', 'An epic dark fantasy world where the fate of the land is decided by the mighty Eikons and the Dominants who wield them. This is the tale of Clive Rosfield, a warrior granted the title “First Shield of Rosaria” and sworn to protect his younger brother Joshua, the dominant of the Phoenix. Before long, Clive will be caught up in a great tragedy and swear revenge on the Dark Eikon Ifrit, a mysterious entity that brings calamity in its wake.', 0, 30, 1, 7, 7, 7, 7, 7, FALSE, TRUE, 51.99),
('Marvel''s Spider-Man: Miles Morales (PC)', 24.99, '2022-11-18 00:00:00', 'Following the events of Marvel’s Spider-Man Remastered, teenager Miles Morales is adjusting to his new home while following in the footsteps of his mentor, Peter Parker, as a new Spider-Man. But when a fierce power struggle threatens to destroy his new home, the aspiring hero realizes that with great power, there must also come great responsibility. To save all of Marvel’s New York, Miles must take up the mantle of Spider-Man and own it.', 0, 25, 2, 8, 8, 8, 8, 8, TRUE, FALSE, NULL),
('Red Dead Redemption 2 (PC)', 49.99, '2019-11-05 00:00:00', 'America, 1899. The end of the Wild West era has begun. After a robbery goes badly wrong in the western town of Blackwater, Arthur Morgan and the Van der Linde gang are forced to flee. With federal agents and the best bounty hunters in the nation massing on their heels, the gang must rob, steal and fight their way across the rugged heartland of America in order to survive. As deepening internal divisions threaten to tear the gang apart, Arthur must make a choice between his own ideals and loyalty to the gang who raised him.', 0, 20, 1, 9, 9, 9, 9, 9, FALSE, TRUE, 24.99),
('Marvel''s Spider - Man Remastered PS5', 34.99, '2020-11-12 00:00:00', 'This isn’t the Spider-Man you’ve met or ever seen before. In Marvel’s Spider-Man Remastered, we meet an experienced Peter Parker who’s more masterful at fighting big crime in New York City. At the same time, he’s struggling to balance his chaotic personal life and career while the fate of Marvel’s New York rests upon his shoulders.', 0, 15, 2, 34, NULL, NULL, NULL, NULL, TRUE, FALSE, NULL),
('Black Myth: Wukong (PC)', 59.99, '2024-08-20 00:00:00', 'Black Myth: Wukong is an action RPG rooted in Chinese mythology. The story is based on Journey to the West, one of the Four Great Classical Novels of Chinese literature. You shall set out as the Destined One to venture into the challenges and marvels ahead, to uncover the obscured truth beneath the veil of a glorious legend from the past.', 0, 30, 1, 1, 11, 11, 11, 11, FALSE, TRUE, 45.99),
('Call of Duty Black Ops Cold War - Ultimate Edition PS4', 79.99, '2020-11-13 00:00:00', 'Deep in the deserts of Angola, Central Africa, a top-secret, American-made reconnaissance satellite known as the KH-9 has been grounded, potentially by Perseus. Hired DGI forces are searching for the sensitive intel it holds, while NATO’s MI6 Squadron have been dispatched to secure the site and eliminate DGI stragglers. While just a sample of the broader array of maps that will be available at launch, these five maps are meticulously designed and based on authentic, real-world sources, as Treyarch’s visual research department visited real-life locations, photo-scanning thousands of physical objects, terrains, environments, and materials. VIP Escort: In this new 6v6 objective core game mode, teams either protect or subdue a randomly selected player who becomes a VIP. This Very Important Player only gets a kitted-out pistol, a smoke grenade, a UAV for team intel, and the satisfaction of having up to five other squadmates defend them. These protectors must escort the VIP to an extraction point as they fend off the attacking team, whose goal is to neutralize the VIP before they escape. A non-VIP who dies during the round is out until the next one, but a downed player at zero health can defend themselves in Last Stand or be revived by a teammate to get back into the fight.', 0, 25, 2, 33, NULL, NULL, NULL, NULL, TRUE, FALSE, NULL),
('Helldivers 2 PC', 59.99, '2024-02-08 00:00:00', 'Freedom. Peace. Managed Democracy. Your Super Earth-born rights. The key pillars of our civilization. These are under attack from deadly alien civilizations, conspiring to destroy the Super Earth and its values.You’ll step into the boots of an elite class of soldiers whose mission is to spread peace, liberty, and Managed Democracy using the biggest, baddest, and most explosive tools in the galaxy. Team up with up to four friends and wreak havoc on the alien scourge that threatens the safety of your home, Super Earth. The Helldivers must take on the role of galactic peacekeepers in this Galactic War and protect their home planet, spread the message of Democracy, and liberate the hostiles by force.', 0, 20, 1, 1, 13, 13, 13, 13, FALSE, TRUE, 34.49),
('Balatro (PC)', 15.99, '2024-02-20 00:00:00', 'Balatro is a poker-inspired roguelike deck builder all about creating powerful synergies and winning big. Combine valid poker hands with unique Joker cards in order to create varied synergies and builds. Earn enough chips to beat devious blinds, all while uncovering hidden bonus hands and decks as you progress. You’re going to need every edge you can get in order to reach the boss blind, beat the final ante and secure victory.', 0, 15, 2, 14, 12, 14, 14, 14, TRUE, FALSE, NULL),
('Ready or Not (PC)', 51.99, '2023-12-13 00:00:00', 'Los Sueños – The LSPD reports a massive upsurge in violent crime across the greater Los Sueños area. Special Weapons and Tactics (SWAT) teams have been dispatched to respond to various scenes involving high-risk hostage situations, active bomb threats, barricaded suspects, and other criminal activities. Citizens are being advised to practice caution when traveling the city or to stay at home.', 0, 30, 1, 1, 12, 15, 15, 15, FALSE, TRUE, 29.99),
('EA SPORTS FC 24 (PS5)', 49.99, '2023-09-29 00:00:00', 'EA SPORTS FC 24 is a new era for The World’s Game: 19,000+ fully licensed players, 700+ teams, and 30+ leagues playing together in the most authentic football experience ever created. Feel closer to the game with three cutting-edge technologies powering unparalleled realism in every match: HyperMotionV**, PlayStyles optimised by Opta, and an enhanced Frostbite Engine. HyperMotionV captures the game as it’s truly played, using volumetric data from 180+ pro men’s and women’s matches to ensure movement in-game accurately reflects real-world action on the pitch.', 0, 25, 2, 34, NULL, NULL, NULL, NULL, TRUE, FALSE, NULL),
('Hogwarts Legacy (PC)', 39.99, '2023-02-10 00:00:00', 'Hogwarts Legacy is an open-world action RPG set in the world first introduced in the Harry Potter books. Embark on a journey through familiar and new locations as you explore and discover magical beasts, customize your character and craft potions, master spell casting, upgrade talents and become the wizard you want to be.', 0, 20, 1, 1, 11, 17, 17, 17, FALSE, TRUE, 26.49),
('Days Gone (PC)', 29.99, '2021-05-18 00:00:00', 'Days Gone is an open-world action-adventure game set in a harsh wilderness two years after a devastating global pandemic. Step into the dirt flecked shoes of former outlaw biker Deacon St. John, a bounty hunter trying to find a reason to live in a land surrounded by death. Scavenge through abandoned settlements for equipment to craft valuable items and weapons, or take your chances with other survivors trying to eke out a living through fair trade… or more violent means.', 0, 15, 2, 1, 12, 18, 18, 18, TRUE, FALSE, NULL),
('Cyberpunk 2077: Ultimate Edition (PC)', 59.99, '2023-12-05 00:00:00', 'Cyberpunk 2077 is an open-world, action-adventure RPG set in the megalopolis of Night City, where you play as a cyberpunk mercenary wrapped up in a do-or-die fight for survival. Improved and featuring all-new free additional content, customize your character and playstyle as you take on jobs, build a reputation, and unlock upgrades. The relationships you forge and the choices you make will shape the story and the world around you. Legends are made here. What will yours be?', 0, 30, 1, 1, 12, 19, 19, 19, FALSE, TRUE, 41.49),
('God of War Ragnarök (PS5)', 59.99, '2022-11-09 00:00:00', 'From Santa Monica Studio comes the sequel to the critically acclaimed God of War (2018). Fimbulwinter is well underway. Kratos and Atreus must journey to each of the Nine Realms in search of answers as Asgardian forces prepare for a prophesied battle that will end the world. Along the way they will explore stunning, mythical landscapes, and face fearsome enemies in the form of Norse gods and monsters. The threat of Ragnarök grows ever closer. Kratos and Atreus must choose between their own safety and the safety of the realms.', 0, 25, 2, 34, NULL, NULL, NULL, NULL, TRUE, FALSE, NULL),
('Grand Theft Auto V (PC)', 24.99, '2017-12-14 00:00:00', 'Welcome to Los Santos. Switch between the interconnected lives of Michael, Trevor and Franklin as they participate in a series of heists across Los Santos and Blaine County in the biggest, deepest, richest open-world experience ever seen. New features in the game world include new wildlife, upgraded weather and damage effects, and a host of new details to discover.', 0, 80, 2, 1, 2, 4, 1, 6, FALSE, TRUE, 19.99);

-- Populate Buyer
INSERT INTO Buyer (id_user) VALUES
(1),
(3),
(4),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20),
(21),
(22),
(23),
(24),
(25),
(26),
(27),
(28),
(29),
(30),
(31),
(32),
(33),
(34),
(35),
(36),
(37),
(38),
(39),
(40),
(41),
(42),
(43),
(44),
(45),
(46),
(47),
(48),
(49),
(50),
(51),
(52),
(53),
(54),
(55),
(56),
(57),
(58),
(59),
(60),
(61),
(62),
(63),
(64),
(65),
(66),
(67),
(68),
(69),
(70),
(71),
(72),
(73),
(74),
(75),
(76),
(77),
(78),
(79),
(80),
(81),
(82),
(83),
(84),
(85),
(86),
(87),
(88),
(89),
(90),
(91),
(92),
(93),
(94),
(95),
(96),
(97),
(98),
(99),
(100),
(101),
(102),
(103),
(104),
(105),
(106),
(107),
(108),
(109),
(110),
(111),
(112),
(113),
(114),
(115),
(116),
(117),
(118),
(119),
(120),
(121),
(122),
(123),
(124),
(125),
(126),
(127),
(128),
(129),
(130),
(131),
(132),
(133),
(134),
(135),
(136),
(137),
(138),
(139),
(140),
(141),
(142),
(143),
(144),
(145),
(146),
(147),
(148),
(149),
(150),
(151),
(152),
(153),
(154),
(155),
(156),
(157),
(158),
(159),
(160),
(161),
(162),
(163),
(164),
(165),
(166),
(167),
(168),
(169),
(170),
(171),
(172),
(173),
(174),
(175),
(176),
(177),
(178),
(179),
(180),
(181),
(182),
(183),
(184),
(185),
(186),
(187),
(188),
(189),
(190),
(191),
(192),
(193),
(194),
(195),
(196),
(197),
(198),
(199),
(200),
(201),
(202),
(203),
(204),
(205),
(206),
(207),
(208),
(209),
(210),
(211),
(212),
(213),
(214),
(215),
(216),
(217),
(218),
(219),
(220),
(221),
(222),
(223),
(224),
(225),
(226),
(227),
(228),
(229),
(230),
(231),
(232),
(233),
(234),
(235),
(236),
(237),
(238),
(239),
(240),
(241),
(242),
(243),
(244),
(245),
(246),
(247),
(248),
(249),
(250),
(251),
(252),
(253),
(254),
(255),
(256),
(257),
(258),
(259),
(260),
(261),
(262),
(263),
(264),
(265),
(266),
(267),
(268),
(269),
(270),
(271),
(272),
(273),
(274),
(275),
(276),
(277),
(278),
(279),
(280),
(281),
(282),
(283),
(284),
(285),
(286),
(287),
(288),
(289),
(290),
(291),
(292),
(293),
(294),
(295),
(296),
(297),
(298),
(299),
(300),
(301),
(302),
(303),
(304),
(305),
(306),
(307),
(308),
(309),
(310),
(311),
(312),
(313),
(314),
(315),
(316),
(317),
(318),
(319),
(320),
(321),
(322),
(323),
(324),
(325),
(326),
(327),
(328),
(329),
(330),
(331),
(332),
(333),
(334),
(335),
(336),
(337),
(338),
(339),
(340),
(341),
(342),
(343),
(344),
(345),
(346),
(347),
(348),
(349),
(350),
(351),
(352),
(353),
(354),
(355),
(356),
(357),
(358),
(359),
(360),
(361),
(362),
(363),
(364),
(365),
(366),
(367),
(368),
(369),
(370),
(371),
(372),
(373),
(374),
(375),
(376),
(377),
(378),
(379),
(380),
(381),
(382),
(383),
(384),
(385),
(386),
(387),
(388),
(389),
(390),
(391),
(392),
(393),
(394),
(395),
(396),
(397),
(398),
(399),
(400),
(401),
(402),
(403),
(404),
(405),
(406),
(407),
(408),
(409),
(410),
(411),
(412),
(413),
(414),
(415),
(416),
(417),
(418),
(419),
(420),
(421),
(422),
(423),
(424),
(425),
(426),
(427),
(428),
(429),
(430),
(431),
(432),
(433),
(434),
(435),
(436),
(437),
(438),
(439),
(440),
(441),
(442),
(443),
(444),
(445),
(446),
(447),
(448),
(449),
(450),
(451),
(452),
(453),
(454),
(455),
(456),
(457),
(458),
(459),
(460),
(461),
(462),
(463),
(464),
(465),
(466),
(467),
(468),
(469),
(470),
(471),
(472),
(473),
(474),
(475),
(476),
(477),
(478),
(479),
(480),
(481),
(482),
(483),
(484),
(485),
(486),
(487),
(488),
(489),
(490),
(491),
(492),
(493),
(494),
(495),
(496),
(497),
(498),
(499);

-- Populate ShoppingCart
INSERT INTO ShoppingCart (id_buyer, id_game) VALUES
(3, 1),
(4, 3),
(4, 2),
(7, 4),
(8, 5),
(7, 6),
(8, 7),
(9, 8),
(10, 9),
(9, 10),
(10, 11),
(11, 12),
(12, 13),
(13, 14),
(14, 15),
(11, 16),
(12, 17),
(13, 18),
(14, 19),
(3, 5),
(4, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(327, 2),
(491, 4),
(183, 7),
(424, 20),
(164, 20),
(214, 8),
(486, 16),
(110, 2),
(411, 10),
(281, 19),
(201, 13),
(109, 19),
(121, 13),
(22, 20),
(489, 12),
(359, 15),
(25, 21),
(45, 9),
(444, 19),
(341, 12),
(20, 7),
(311, 7),
(371, 8),
(341, 5),
(359, 4),
(349, 5),
(413, 9),
(306, 21),
(343, 1),
(469, 3),
(447, 5),
(251, 10),
(450, 11),
(167, 19),
(129, 9),
(342, 12),
(267, 21),
(201, 1),
(437, 5),
(338, 7),
(304, 17),
(241, 12),
(371, 20),
(461, 12),
(391, 11),
(292, 13),
(460, 3),
(223, 21),
(497, 16),
(499, 7),
(302, 1),
(55, 18),
(403, 14),
(339, 9),
(249, 19),
(295, 12),
(465, 17),
(112, 8),
(473, 2),
(362, 11),
(138, 2),
(196, 21),
(416, 10),
(269, 8),
(31, 5),
(301, 19),
(277, 20),
(139, 20),
(123, 3),
(75, 4),
(455, 4),
(382, 10),
(178, 1),
(285, 14),
(429, 12),
(77, 12),
(406, 5),
(291, 9),
(463, 11),
(61, 19),
(125, 8),
(190, 12),
(172, 11),
(290, 9),
(371, 9),
(441, 7),
(326, 14),
(28, 19),
(272, 8),
(323, 15),
(65, 15),
(228, 5),
(129, 2),
(299, 18),
(468, 3),
(445, 10),
(118, 8),
(360, 3),
(422, 1),
(245, 4);

-- Populate Orders
INSERT INTO Orders (order_date, total_price, id_payment, id_buyer) VALUES
(CURRENT_DATE, 59.99, 1, 3),
(CURRENT_DATE, 39.99, 2, 4),
(CURRENT_DATE, 49.99, 1, 7),
(CURRENT_DATE, 39.99, 2, 8),
(CURRENT_DATE, 59.99, 1, 7),
(CURRENT_DATE, 29.99, 2, 8),
(CURRENT_DATE, 24.99, 1, 9),
(CURRENT_DATE, 49.99, 2, 10),
(CURRENT_DATE, 34.99, 1, 9),
(CURRENT_DATE, 59.99, 2, 10),
(CURRENT_DATE, 59.99, 1, 11),
(CURRENT_DATE, 39.99, 2, 12),
(CURRENT_DATE, 49.99, 1, 13),
(CURRENT_DATE, 29.99, 2, 14),
(CURRENT_DATE, 59.99, 1, 11),
(CURRENT_DATE, 39.99, 2, 12),
(CURRENT_DATE, 49.99, 1, 13),
(CURRENT_DATE, 29.99, 2, 14),
(CURRENT_DATE, 49.99, 1, 3),
(CURRENT_DATE, 39.99, 2, 4),
(CURRENT_DATE, 59.99, 1, 7),
(CURRENT_DATE, 29.99, 2, 8),
(CURRENT_DATE, 24.99, 1, 9),
(CURRENT_DATE, 49.99, 2, 10),
(CURRENT_DATE, 34.99, 1, 11),
(CURRENT_DATE, 59.99, 2, 12),
(CURRENT_DATE, 39.99, 1, 13),
(CURRENT_DATE, 29.99, 2, 14),
('2024-05-08 21:35:49', 49.99, 11, 29),
('2024-10-28 13:05:17', 49.99, 12, 33),
('2024-01-05 08:21:54', 49.99, 39, 36),
('2024-03-01 13:05:20', 49.99, 33, 98),
('2024-01-30 16:37:01', 49.99, 79, 79),
('2024-12-09 10:21:32', 49.99, 29, 68),
('2024-06-03 00:13:01', 49.99, 67, 92),
('2024-11-14 10:42:29', 49.99, 83, 70),
('2024-12-16 14:08:16', 49.99, 27, 22),
('2024-10-23 16:38:41', 49.99, 98, 29),
('2024-04-02 23:59:14', 49.99, 37, 78),
('2023-12-29 17:45:11', 49.99, 29, 72),
('2024-03-02 14:45:01', 49.99, 28, 76),
('2024-03-23 13:13:30', 49.99, 6, 79),
('2024-11-23 11:26:15', 49.99, 64, 62),
('2024-02-22 04:58:20', 49.99, 30, 22),
('2024-05-27 04:15:28', 49.99, 62, 82),
('2024-08-03 01:07:42', 49.99, 28, 84),
('2024-08-19 19:26:19', 49.99, 12, 79),
('2024-05-08 16:01:17', 49.99, 7, 31),
('2024-07-25 11:15:25', 49.99, 49, 78),
('2024-04-21 19:14:13', 49.99, 6, 97),
('2024-04-12 01:58:05', 49.99, 19, 59),
('2024-03-31 23:52:40', 49.99, 53, 73),
('2024-02-01 14:09:42', 49.99, 10, 25),
('2024-02-10 07:43:01', 49.99, 19, 33),
('2024-12-07 08:56:59', 49.99, 4, 97),
('2024-02-29 22:27:52', 49.99, 58, 31),
('2024-12-04 17:47:12', 49.99, 83, 85),
('2024-03-16 16:33:56', 49.99, 31, 60),
('2024-10-08 11:52:27', 49.99, 5, 92),
('2024-07-13 15:11:36', 49.99, 72, 89),
('2024-01-25 14:45:22', 49.99, 8, 81),
('2024-12-04 03:10:03', 49.99, 68, 79),
('2024-06-29 20:03:40', 49.99, 26, 52),
('2024-01-13 10:42:00', 49.99, 75, 88),
('2024-02-13 05:43:14', 49.99, 48, 96),
('2024-03-28 21:30:05', 49.99, 70, 75),
('2024-01-09 08:42:31', 49.99, 5, 46),
('2024-10-16 01:07:42', 49.99, 94, 36),
('2024-03-11 19:15:51', 49.99, 7, 21),
('2024-04-15 23:36:01', 49.99, 84, 52),
('2024-03-09 09:01:12', 49.99, 42, 22),
('2024-07-28 22:35:49', 49.99, 58, 38),
('2024-05-30 22:17:07', 49.99, 33, 85),
('2024-06-13 23:31:01', 49.99, 84, 48),
('2024-05-06 10:21:57', 49.99, 72, 77),
('2024-01-12 08:08:40', 49.99, 72, 88),
('2024-02-05 08:31:03', 49.99, 13, 81),
('2024-07-14 12:14:52', 49.99, 44, 41),
('2024-05-13 15:34:37', 49.99, 80, 70),
('2024-10-19 00:31:44', 49.99, 57, 54),
('2024-11-11 05:31:45', 49.99, 56, 64),
('2024-03-17 17:53:30', 49.99, 64, 54),
('2024-10-11 05:29:31', 49.99, 83, 22),
('2024-06-09 04:20:08', 49.99, 49, 62),
('2024-10-05 20:39:17', 49.99, 13, 41),
('2024-07-29 20:50:58', 49.99, 39, 79),
('2024-10-24 01:24:13', 49.99, 96, 71),
('2024-10-25 03:24:40', 49.99, 58, 85),
('2024-02-27 01:03:46', 49.99, 94, 33),
('2023-12-22 12:23:19', 49.99, 18, 32),
('2024-08-03 14:24:48', 49.99, 30, 76),
('2024-05-14 13:56:40', 49.99, 70, 31),
('2024-08-17 10:43:42', 49.99, 85, 79),
('2024-10-12 12:36:35', 49.99, 93, 51),
('2024-09-17 13:16:15', 49.99, 43, 37),
('2024-05-22 21:07:24', 49.99, 99, 24),
('2024-01-30 23:18:51', 49.99, 10, 47),
('2024-11-21 10:48:03', 49.99, 54, 38),
('2024-04-24 22:07:15', 49.99, 45, 96),
('2024-09-30 21:39:28', 49.99, 94, 30),
('2024-11-18 05:20:02', 49.99, 37, 94),
('2024-10-19 06:36:10', 49.99, 30, 45),
('2024-08-21 23:59:59', 49.99, 76, 35),
('2024-01-02 06:26:42', 49.99, 49, 26),
('2024-08-05 02:57:54', 49.99, 33, 61),
('2024-09-13 22:17:05', 49.99, 57, 42),
('2024-10-25 21:29:02', 49.99, 40, 26),
('2024-04-16 21:23:25', 49.99, 91, 72), -- id 108
('2024-01-01 09:00:00', 15.99, 29, 1),
('2024-01-01 11:00:00', 15.99, 33, 1),
('2024-01-01 13:00:00', 15.99, 36, 1),
('2024-01-01 15:00:00', 15.99, 98, 1),
('2024-01-01 17:00:00', 15.99, 79, 1),
('2024-01-01 19:00:00', 15.99, 68, 1),
('2024-01-01 21:00:00', 15.99, 92, 1),
('2024-01-05 08:00:00', 15.99, 70, 1),
('2024-01-05 09:00:00', 15.99, 22, 1),
('2024-01-05 10:00:00', 15.99, 29, 1),
('2024-01-05 12:00:00', 15.99, 78, 1),
('2024-01-05 14:00:00', 15.99, 72, 1),
('2024-01-05 16:00:00', 15.99, 76, 1),
('2024-01-05 18:00:00', 15.99, 79, 1),
('2024-01-10 08:00:00', 15.99, 62, 1),
('2024-01-10 09:00:00', 15.99, 22, 1),
('2024-01-10 10:00:00', 15.99, 82, 1),
('2024-01-10 11:00:00', 15.99, 84, 1),
('2024-01-10 13:00:00', 15.99, 79, 1),
('2024-01-10 15:00:00', 15.99, 31, 1),
('2024-01-10 17:00:00', 15.99, 78, 1),
('2024-01-10 19:00:00', 15.99, 97, 1),
('2024-01-10 21:00:00', 15.99, 59, 1),
('2024-01-15 08:00:00', 15.99, 73, 1),
('2024-01-15 09:00:00', 15.99, 25, 1),
('2024-01-15 10:00:00', 15.99, 33, 1),
('2024-01-15 11:00:00', 15.99, 97, 1),
('2024-01-15 12:00:00', 15.99, 31, 1),
('2024-01-15 13:00:00', 15.99, 85, 1),
('2024-01-15 15:00:00', 15.99, 60, 1),
('2024-01-15 17:00:00', 15.99, 92, 1),
('2024-01-15 19:00:00', 15.99, 89, 1),
('2024-01-15 21:00:00', 15.99, 81, 1),
('2024-01-20 08:00:00', 15.99, 79, 1),
('2024-01-20 09:00:00', 15.99, 52, 1),
('2024-01-20 10:00:00', 15.99, 88, 1),
('2024-01-20 11:00:00', 15.99, 96, 1),
('2024-01-20 12:00:00', 15.99, 75, 1),
('2024-01-20 13:00:00', 15.99, 46, 1),
('2024-01-20 15:00:00', 15.99, 36, 1),
('2024-01-20 17:00:00', 15.99, 21, 1),
('2024-01-20 19:00:00', 15.99, 52, 1),
('2024-01-20 21:00:00', 15.99, 22, 1),
('2024-01-25 08:00:00', 15.99, 38, 1),
('2024-01-25 09:00:00', 15.99, 85, 1),
('2024-01-25 10:00:00', 15.99, 48, 1),
('2024-01-25 11:00:00', 15.99, 77, 1),
('2024-01-25 12:00:00', 15.99, 88, 1),
('2024-01-25 13:00:00', 15.99, 81, 1),
('2024-01-25 15:00:00', 15.99, 41, 1),
('2024-01-25 17:00:00', 15.99, 70, 1),
('2024-01-25 19:00:00', 15.99, 54, 1),
('2024-01-25 21:00:00', 15.99, 64, 1),
('2024-01-30 08:00:00', 15.99, 54, 1),
('2024-01-30 09:00:00', 15.99, 22, 1),
('2024-01-30 10:00:00', 15.99, 62, 1),
('2024-01-30 11:00:00', 15.99, 41, 1),
('2024-01-30 12:00:00', 15.99, 79, 1),
('2024-01-30 13:00:00', 15.99, 71, 1),
('2024-01-30 15:00:00', 15.99, 85, 1),
('2024-01-30 17:00:00', 15.99, 33, 1),
('2024-01-30 19:00:00', 15.99, 32, 1),
('2024-01-30 21:00:00', 15.99, 76, 1),
('2024-01-30 23:00:00', 15.99, 42, 1),
('2024-02-01 08:00:00', 15.99, 26, 1),
('2024-02-01 09:00:00', 15.99, 61, 1),
('2024-02-01 10:00:00', 15.99, 26, 1),
('2024-02-01 12:00:00', 15.99, 79, 1);

-- Populate GameOrderDetails
INSERT INTO GameOrderDetails (id_order, id_game, review_rating, review_comment, review_date, purchase_price) VALUES
(1, 1, '5', 'Awesome game!', CURRENT_DATE, 59.99),
(2, 2, '4', 'Really enjoyed it.', CURRENT_DATE, 39.99),
(3, 4, '5', 'Great game!', CURRENT_DATE, 49.99),
(4, 5, '4', 'Enjoyed it.', CURRENT_DATE, 39.99),
(5, 6, '5', 'Amazing!', CURRENT_DATE, 59.99),
(6, 7, '4', 'Good game.', CURRENT_DATE, 29.99),
(7, 8, '5', 'Fantastic game!', CURRENT_DATE, 24.99),
(8, 9, '4', 'Very good.', CURRENT_DATE, 49.99),
(9, 10, '5', 'Loved it!', CURRENT_DATE, 34.99),
(10, 11, '4', 'Great experience.', CURRENT_DATE, 59.99),
(11, 12, '5', 'Excellent game!', CURRENT_DATE, 59.99),
(12, 13, '4', 'Very enjoyable.', CURRENT_DATE, 39.99),
(13, 14, '5', 'Loved it!', CURRENT_DATE, 15.99),
(14, 15, '4', 'Great game.', CURRENT_DATE, 29.99),
(15, 16, '5', 'Amazing!', CURRENT_DATE, 59.99),
(16, 17, '4', 'Good game.', CURRENT_DATE, 39.99),
(17, 18, '5', 'Fantastic!', CURRENT_DATE, 49.99),
(18, 19, '4', 'Very good.', CURRENT_DATE, 29.99),
(19, 5, '5', 'Excellent game!', CURRENT_DATE, 49.99),
(20, 6, '4', 'Very enjoyable.', CURRENT_DATE, 39.99),
(21, 7, '5', 'Loved it!', CURRENT_DATE, 59.99),
(22, 8, '4', 'Great game.', CURRENT_DATE, 29.99),
(23, 9, '5', 'Amazing!', CURRENT_DATE, 24.99),
(24, 10, '4', 'Good game.', CURRENT_DATE, 49.99),
(25, 11, '5', 'Fantastic!', CURRENT_DATE, 34.99),
(26, 12, '4', 'Very good.', CURRENT_DATE, 59.99),
(27, 13, '5', 'Excellent!', CURRENT_DATE, 39.99),
(28, 14, '4', 'Enjoyable.', CURRENT_DATE, 15.99),
(29, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-16 08:39:25', 49.99),
(30, 4, '4', 'Amazing graphics and gameplay.', '2024-12-20 18:49:52', 49.99),
(31, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-18 18:07:05', 49.99),
(32, 4, '4', 'Great storyline and characters.', '2024-12-20 08:50:26', 49.99),
(33, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-16 10:59:58', 49.99),
(34, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-20 04:11:29', 49.99),
(35, 4, '5', 'A must-play for any gamer.', '2024-12-20 05:48:34', 49.99),
(36, 4, '4', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-19 20:30:47', 49.99),
(37, 4, '4', 'Amazing graphics and gameplay.', '2024-12-18 15:45:50', 49.99),
(38, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 17:33:06', 49.99),
(39, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-18 20:33:10', 49.99),
(40, 4, '4', 'Great storyline and characters.', '2024-12-18 07:03:18', 49.99),
(41, 4, '5', 'A must-play for any gamer.', '2024-12-20 21:13:54', 49.99),
(42, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-19 14:37:15', 49.99),
(43, 4, '4', 'A must-play for any gamer.', '2024-12-19 02:18:50', 49.99),
(44, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 13:24:16', 49.99),
(45, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 21:44:14', 49.99),
(46, 4, '4', 'A must-play for any gamer.', '2024-12-17 02:52:57', 49.99),
(47, 4, '4', 'Great storyline and characters.', '2024-12-17 04:06:56', 49.99),
(48, 4, '5', 'A must-play for any gamer.', '2024-12-16 23:43:30', 49.99),
(49, 4, '4', 'Amazing graphics and gameplay.', '2024-12-16 00:25:18', 49.99),
(50, 4, '5', 'Great storyline and characters.', '2024-12-18 03:19:54', 49.99),
(51, 4, '4', 'Great storyline and characters.', '2024-12-19 04:56:06', 49.99),
(52, 4, '5', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 17:32:22', 49.99),
(53, 4, '4', 'Amazing graphics and gameplay.', '2024-12-20 20:30:14', 49.99),
(54, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-17 16:11:07', 49.99),
(55, 4, '5', 'Amazing graphics and gameplay.', '2024-12-18 13:00:02', 49.99),
(56, 4, '4', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-17 17:01:37', 49.99),
(57, 4, '2', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 03:25:31', 49.99),
(58, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-18 22:45:20', 49.99),
(59, 4, '4', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-20 10:06:13', 49.99),
(60, 4, '4', 'Amazing graphics and gameplay.', '2024-12-16 23:07:00', 49.99),
(61, 4, '5', 'Amazing graphics and gameplay.', '2024-12-18 13:27:30', 49.99),
(62, 4, '5', 'Great storyline and characters.', '2024-12-20 02:52:04', 49.99),
(63, 4, '5', 'Amazing graphics and gameplay.', '2024-12-16 14:36:57', 49.99),
(64, 4, '5', 'Great storyline and characters.', '2024-12-18 12:56:03', 49.99),
(65, 4, '4', 'Great storyline and characters.', '2024-12-16 04:40:05', 49.99),
(66, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 22:21:15', 49.99),
(67, 4, '2', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 11:53:40', 49.99),
(68, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-20 05:58:13', 49.99),
(69, 4, '4', 'Great storyline and characters.', '2024-12-16 21:06:15', 49.99),
(70, 4, '1', 'Disappointing ending but overall enjoyable experience.', '2024-12-18 07:16:00', 49.99),
(71, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-17 03:37:49', 49.99),
(72, 4, '4', 'A must-play for any gamer.', '2024-12-19 13:19:26', 49.99),
(73, 4, '4', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-19 12:10:58', 49.99),
(74, 4, '5', 'Amazing graphics and gameplay.', '2024-12-20 17:00:57', 49.99),
(75, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-16 13:03:15', 49.99),
(76, 4, '5', 'Disappointing ending but overall enjoyable experience.', '2024-12-17 00:37:44', 49.99),
(77, 4, '3', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 21:17:09', 49.99),
(78, 4, '4', 'Great storyline and characters.', '2024-12-18 00:41:24', 49.99),
(79, 4, '5', 'A must-play for any gamer.', '2024-12-17 20:39:40', 49.99),
(80, 4, '4', 'Amazing graphics and gameplay.', '2024-12-16 02:12:20', 49.99),
(81, 4, '5', 'Disappointing ending but overall enjoyable experience.', '2024-12-17 07:33:39', 49.99),
(82, 4, '4', 'Amazing graphics and gameplay.', '2024-12-20 12:16:19', 49.99),
(83, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-17 12:52:29', 49.99),
(84, 4, '5', 'A must-play for any gamer.', '2024-12-18 06:18:42', 49.99),
(85, 4, '5', 'Amazing graphics and gameplay.', '2024-12-17 01:23:22', 49.99),
(86, 4, '4', 'A must-play for any gamer.', '2024-12-17 22:30:05', 49.99),
(87, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-16 05:56:15', 49.99),
(88, 4, '5', 'Amazing graphics and gameplay.', '2024-12-17 13:43:51', 49.99),
(89, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-17 14:56:05', 49.99),
(90, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-20 16:27:43', 49.99),
(91, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 15:52:35', 49.99),
(92, 4, '4', 'A must-play for any gamer.', '2024-12-18 01:12:18', 49.99),
(93, 4, '5', 'Amazing graphics and gameplay.', '2024-12-16 06:37:41', 49.99),
(94, 4, '4', 'A must-play for any gamer.', '2024-12-18 09:17:36', 49.99),
(95, 4, '5', 'The Last of Us sets a new standard for storytelling in games.', '2024-12-19 18:57:13', 49.99),
(96, 4, '5', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 10:04:38', 49.99),
(97, 4, '5', 'Great storyline and characters.', '2024-12-18 16:44:36', 49.99),
(98, 4, '4', 'A must-play for any gamer.', '2024-12-19 09:03:32', 49.99),
(99, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 06:40:15', 49.99),
(100, 4, '4', 'Disappointing ending but overall enjoyable experience.', '2024-12-19 08:48:50', 49.99),
(108, 14, '5', 'Awesome game!', CURRENT_DATE, 15.99),
(109, 14, '4', 'Really enjoyed it.', CURRENT_DATE, 15.99),
(110, 14, '5', 'Great game!', CURRENT_DATE, 15.99),
(111, 14, '4', 'Enjoyed it.', CURRENT_DATE, 15.99),
(112, 14, '5', 'Amazing!', CURRENT_DATE, 15.99),
(113, 14, '4', 'Good game.', CURRENT_DATE, 15.99),
(114, 14, '5', 'Fantastic game!', CURRENT_DATE, 15.99),
(115, 14, '4', 'Very good.', CURRENT_DATE, 15.99),
(116, 14, '5', 'Loved it!', CURRENT_DATE, 15.99),
(117, 14, '4', 'Great experience.', CURRENT_DATE, 15.99),
(118, 14, '5', 'Excellent game!', CURRENT_DATE, 15.99),
(119, 14, '4', 'Very enjoyable.', CURRENT_DATE, 15.99),
(120, 14, '5', 'Loved it!', CURRENT_DATE, 15.99),
(121, 14, '4', 'Great game.', CURRENT_DATE, 15.99),
(122, 14, '5', 'Amazing!', CURRENT_DATE, 15.99),
(123, 14, '4', 'Good game.', CURRENT_DATE, 15.99),
(124, 14, '5', 'Fantastic!', CURRENT_DATE, 15.99),
(125, 14, '4', 'Very good.', CURRENT_DATE, 15.99),
(126, 14, '5', 'Excellent game!', CURRENT_DATE, 15.99),
(127, 14, '4', 'Very enjoyable.', CURRENT_DATE, 15.99),
(128, 14, '5', 'Loved it!', CURRENT_DATE, 15.99),
(129, 14, '4', 'Great game.', CURRENT_DATE, 15.99),
(130, 14, '5', 'Amazing!', CURRENT_DATE, 15.99),
(131, 14, '4', 'Good game.', CURRENT_DATE, 15.99),
(132, 14, '5', 'Fantastic!', CURRENT_DATE, 15.99),
(133, 14, '4', 'Very good.', CURRENT_DATE, 15.99),
(134, 14, '5', 'Excellent!', CURRENT_DATE, 15.99),
(135, 14, '4', 'Enjoyable.', CURRENT_DATE, 15.99),
(136, 14, '4', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(137, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(138, 14, '5', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(139, 14, '4', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(140, 14, '4', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(141, 14, '5', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(142, 14, '5', 'A must-play for any gamer.', CURRENT_DATE, 15.99),
(143, 14, '4', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(144, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(145, 14, '3', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(146, 14, '4', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(147, 14, '4', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(148, 14, '5', 'A must-play for any gamer.', CURRENT_DATE, 15.99),
(149, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(150, 14, '5', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(151, 14, '5', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(152, 14, '4', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(153, 14, '5', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(154, 14, '5', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(155, 14, '4', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(156, 14, '3', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(157, 14, '2', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(158, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(159, 14, '5', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(160, 14, '5', 'A must-play for any gamer.', CURRENT_DATE, 15.99),
(161, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(162, 14, '5', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(163, 14, '5', 'A must-play for any gamer.', CURRENT_DATE, 15.99),
(164, 14, '4', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(165, 14, '5', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99),
(166, 14, '5', 'The Last of Us sets a new standard for storytelling in games.', CURRENT_DATE, 15.99),
(167, 14, '5', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(168, 14, '3', 'Disappointing ending but overall enjoyable experience.', CURRENT_DATE, 15.99),
(169, 14, '4', 'Great storyline and characters.', CURRENT_DATE, 15.99),
(170, 14, '5', 'A must-play for any gamer.', CURRENT_DATE, 15.99),
(171, 14, '4', 'Amazing graphics and gameplay.', CURRENT_DATE, 15.99);


-- Populate Wishlist
INSERT INTO Wishlist (id_buyer, id_game) VALUES
(3, 2),
(4, 1);

-- Populate Notification
INSERT INTO Notification (notification_date, isread, id_order, id_game, customer_support_not, price_change_not, product_availability_not, id_user) VALUES
(CURRENT_DATE, FALSE, NULL, NULL, NULL, NULL, 1, 3),
(CURRENT_DATE, FALSE, NULL, NULL, NULL, 1, NULL, 3);

-- Populate HelpSupport
INSERT INTO HelpSupport (message, help_date, type, id_buyer) VALUES
('Need help with payment.', CURRENT_DATE, 'CS', 3),
('Game not launching.', CURRENT_DATE, 'GS', 4);

-- Populate Image
INSERT INTO Image (image_path, id_game, id_user) VALUES
('/img/fs25.png', 1, NULL),
('/img/minecraft.png', 2, NULL),
('path/to/image3.jpg', NULL, 3),
('path/to/image4.jpg', NULL, 4),
('img/stalker2.png', 3, NULL),
('img/thelastofus1.png', 4, NULL),
('img/ghostoftsushima.png', 5, NULL),
('img/silenthill2.png', 6, NULL),
('img/finalfantasyxvi.png', 7, NULL),
('img/spiderman.png', 8, NULL),
('img/rdr2.png', 9, NULL),
('img/spiderman-ps5.png', 10, NULL),
('img/blackmyth.png', 11, NULL),
('img/cod-ps4.png', 12, NULL),
('img/helldivers.png', 13, NULL),
('img/balatro.png', 14, NULL),
('img/readyornot.png', 15, NULL),
('img/fc24.png', 16, NULL),
('img/hogwarts.png', 17, NULL),
('img/daysgone.png', 18, NULL),
('img/cyberpunk2077.png', 19, NULL),
('img/godofwar.png', 20, NULL),
('img/gta1.png', 21, NULL),
('img/gta2.png', 21, NULL),
('img/gta3.png', 21, NULL);

-- Populate CustomerSupportAdministrator
INSERT INTO CustomerSupportAdministrator (id_cs, id_admin) VALUES
(1, 5),
(2, 6);

-- Populate Game_Category
INSERT INTO game_category  (id_game, id_category) VALUES
(1, 5), -- Farming Simulator 25 (PC) -> Simulation
(2, 2), -- Minecraft Java & Bedrock Edition (PC) -> Adventure
(2, 5), -- Minecraft Java & Bedrock Edition (PC) -> Simulation
(3, 1), -- S.T.A.L.K.E.R. 2: Heart of Chornobyl (PC) -> Action
(3, 8), -- S.T.A.L.K.E.R. 2: Heart of Chornobyl (PC) -> Sci-Fi
(4, 2), -- The Last of Us Part I (PC) -> Adventure
(4, 16), -- The Last of Us Part I (PC) -> Zombie
(5, 1), -- Ghost of Tsushima DIRECTOR''S CUT (PC)Strategy Master -> Action
(5, 2), -- Ghost of Tsushima DIRECTOR''S CUT (PC) -> Adventure
(5, 12), -- Ghost of Tsushima DIRECTOR''S CUT (PC) -> Historical
(6, 6), -- SILENT HILL 2 (PC) -> Horror
(7, 7), -- Final Fantasy XVI Complete Edition (PC) -> Fantasy
(8, 1), -- Marvel's Spider-Man: Miles Morales (PC) -> Action
(8, 8), -- Marvel's Spider-Man: Miles Morales (PC) -> Sci-Fi
(9, 1), -- Red Dead Redemption 2 (PC) -> Action
(9, 2), -- Red Dead Redemption 2 (PC) -> Adventure
(9, 14), -- Red Dead Redemption 2 (PC) -> Western
(10, 1), -- Marvel's Spider - Man Remastered PS5 -> Action
(10, 2), -- Marvel's Spider - Man Remastered PS5 -> Adventure
(11, 1), -- Black Myth: Wukong (PC) -> Action
(11, 2), -- Black Myth: Wukong (PC) -> Adventure
(11, 3), -- Black Myth: Wukong (PC) -> RPG
(12, 1), -- Call of Duty Black Ops Cold War - Ultimate Edition PS4 -> Action
(12, 3), -- Call of Duty Black Ops Cold War - Ultimate Edition PS4 -> RPG
(13, 1), -- Helldivers 2 PC -> Action
(13, 8), -- Helldivers 2 PC -> Sci-Fi
(14, 4), -- Balatro (PC) -> Strategy
(14, 5), -- Balatro (PC) -> Simulation
(14, 11), -- Balatro (PC) -> Arcade
(15, 1), -- Ready or Not (PC) -> Action
(15, 3), -- Ready or Not (PC) -> RPG
(16, 9), -- EA SPORTS FC 24 (PS5) -> Sports
(17, 2), -- Hogwarts Legacy (PC) -> Adventure
(17, 7), -- Hogwarts Legacy (PC) -> Fantasy
(18, 1), -- Days Gone (PC) -> Action
(18, 2), -- Days Gone (PC) -> Adventure
(18, 6), -- Days Gone (PC) -> Horror
(19, 1), -- Cyberpunk 2077: Ultimate Edition (PC) -> Action
(19, 8), -- Cyberpunk 2077: Ultimate Edition (PC) -> Sci-Fi
(20, 1), -- God of War Ragnarök (PS5) -> Action
(20, 7), -- God of War Ragnarök (PS5) -> Fantasy
(21, 1); -- Grand Theft Auto V (PC) -> Action

INSERT INTO SupportConversations (id_buyer, id_seller, id_game, start_date) VALUES
(3, 1, 1, CURRENT_TIMESTAMP), -- Buyer 3, Seller 1, Game 1
(4, 2, 2, CURRENT_TIMESTAMP), -- Buyer 4, Seller 2, Game 2
(3, 2, 3, CURRENT_TIMESTAMP), -- Buyer 3, Seller 2, Game 3
(4, 1, 4, CURRENT_TIMESTAMP); -- Buyer 4, Seller 1, Game 4

INSERT INTO SupportMessages (id_conversation, sender_role, response_message, response_date) VALUES
(1, 'buyer', 'Hello, I need help with my game.', CURRENT_TIMESTAMP),
(1, 'seller', 'Sure, what seems to be the problem?', CURRENT_TIMESTAMP),
(2, 'buyer', 'The game is not launching on my system.', CURRENT_TIMESTAMP),
(2, 'seller', 'Have you tried reinstalling it?', CURRENT_TIMESTAMP),
(3, 'buyer', 'I want a refund. The game does not match the description.', CURRENT_TIMESTAMP),
(3, 'seller', 'Please provide more details about your issue.', CURRENT_TIMESTAMP),
(4, 'buyer', 'When will the stock be replenished?', CURRENT_TIMESTAMP),
(4, 'seller', 'We expect new stock next week.', CURRENT_TIMESTAMP);
