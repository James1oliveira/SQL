-- ============================================================
--  SHOPPING SYSTEM - COMPLETE SQL SCRIPT
--  Covers: DDL, Cart operations, Checkout, Order reporting
-- ============================================================


-- ============================================================
-- PART 2: CREATE TABLES
-- ============================================================

-- The product catalogue (name + price)
CREATE TABLE products_menu (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Registered users who can place orders
CREATE TABLE users (
    user_id  SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL
);

-- Temporary holding area; one row per product, qty tracks how many
-- product_id is the PK so the same product can't appear twice
CREATE TABLE cart (
    product_id INT PRIMARY KEY REFERENCES products_menu(id),
    qty        INT NOT NULL DEFAULT 1
);

-- One row per order; links to the user and records when it was placed
CREATE TABLE order_header (
    order_id   SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES users(user_id),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Line items for an order; composite PK prevents duplicate products per order
CREATE TABLE order_details (
    order_header_id INT NOT NULL REFERENCES order_header(order_id),
    product_id      INT NOT NULL REFERENCES products_menu(id),
    qty             INT NOT NULL,
    PRIMARY KEY (order_header_id, product_id)
);


-- ============================================================
-- SEED DATA  (matches the sample data from the brief)
-- ============================================================

INSERT INTO products_menu (id, name, price) VALUES
    (1, 'Coke',  10.00),
    (2, 'Chips',  5.00);

INSERT INTO users (user_id, username) VALUES
    (1, 'Arnold'),
    (2, 'Sheryl');


-- ============================================================
-- PART 3: ADD ITEMS TO CART
-- Logic: if the product is already in the cart → increment qty
--        otherwise → insert a new row with qty = 1
-- ============================================================

-- Scenario A: Coke not yet in cart → inserts with qty 1
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty = 1

-- Scenario B: Coke already exists → increments to qty 2
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty = 2

-- Scenario C: Chips not yet in cart → inserts with qty 1
IF EXISTS (SELECT * FROM cart WHERE product_id = 2) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 2;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (2, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty 2, Chips qty 1


-- ============================================================
-- PART 4: REMOVE ITEMS FROM CART
-- Logic: if qty > 1 → subtract 1
--        if qty = 1 → delete the row (item fully removed)
-- ============================================================

-- Coke qty is 2 → decrements to 1
IF EXISTS (SELECT * FROM cart WHERE product_id = 1 AND qty > 1) THEN
    UPDATE cart SET qty = qty - 1 WHERE product_id = 1;
ELSE
    DELETE FROM cart WHERE product_id = 1;
END IF;

SELECT * FROM cart;   -- expected: Coke qty 1, Chips qty 1

-- Coke qty is now 1 → row deleted entirely
IF EXISTS (SELECT * FROM cart WHERE product_id = 1 AND qty > 1) THEN
    UPDATE cart SET qty = qty - 1 WHERE product_id = 1;
ELSE
    DELETE FROM cart WHERE product_id = 1;
END IF;

SELECT * FROM cart;   -- expected: only Chips qty 1

-- Re-add Coke (qty 2) so there are items ready for checkout
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 2);
END IF;

SELECT * FROM cart;   -- expected: Coke qty 2, Chips qty 1


-- ============================================================
-- PART 5: CHECKOUT  (user 1 = Arnold places ORDER 1)
-- Steps: 1) create the order header  2) copy cart → order_details
--        3) clear the cart
-- ============================================================

-- Step 1: open a new order for Arnold
INSERT INTO order_header (user_id, order_date)
VALUES (1, CURRENT_TIMESTAMP);

-- Step 2: snapshot the cart into order_details under the new order_id
--         MAX(order_id) safely retrieves the order just created above
INSERT INTO order_details (order_header_id, product_id, qty)
SELECT (SELECT MAX(order_id) FROM order_header),
       product_id,
       qty
FROM cart;

-- Step 3: cart is emptied after checkout
DELETE FROM cart;

SELECT * FROM order_header;   -- should show 1 row
SELECT * FROM order_details;  -- should show Coke x2 + Chips x1


-- ============================================================
-- SECOND SHOPPING SESSION  (user 2 = Sheryl places ORDER 2)
-- ============================================================

-- Sheryl adds Chips twice (same add logic as Part 3)
IF EXISTS (SELECT * FROM cart WHERE product_id = 2) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 2;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (2, 1);
END IF;

IF EXISTS (SELECT * FROM cart WHERE product_id = 2) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 2;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (2, 1);
END IF;

-- Sheryl adds one Coke
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Chips qty 2, Coke qty 1

-- Sheryl's checkout (same 3-step pattern as Arnold's)
INSERT INTO order_header (user_id, order_date)
VALUES (2, CURRENT_TIMESTAMP);

INSERT INTO order_details (order_header_id, product_id, qty)
SELECT (SELECT MAX(order_id) FROM order_header),
       product_id,
       qty
FROM cart;

DELETE FROM cart;

SELECT * FROM order_header;   -- 2 rows: Arnold + Sheryl
SELECT * FROM order_details;  -- 4 rows total across both orders


-- ============================================================
-- REPORTING QUERIES
-- ============================================================

-- Single order receipt: joins 4 tables to show product, price, qty, and line total
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    pm.name        AS product_name,
    pm.price,
    od.qty,
    (pm.price * od.qty) AS line_total   -- price × qty per line item
FROM order_header  oh
INNER JOIN users          u  ON u.user_id           = oh.user_id
INNER JOIN order_details  od ON od.order_header_id  = oh.order_id
INNER JOIN products_menu  pm ON pm.id               = od.product_id
WHERE oh.order_id = 1          -- filter to Arnold's order only
ORDER BY od.product_id;

-- All orders placed today; same joins, date filter swapped in
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    pm.name        AS product_name,
    pm.price,
    od.qty,
    (pm.price * od.qty) AS line_total
FROM order_header  oh
INNER JOIN users          u  ON u.user_id           = oh.user_id
INNER JOIN order_details  od ON od.order_header_id  = oh.order_id
INNER JOIN products_menu  pm ON pm.id               = od.product_id
WHERE DATE(oh.order_date) = CURRENT_DATE   -- today's orders only
ORDER BY oh.order_id, od.product_id;


-- ============================================================
-- BONUS: STORED FUNCTIONS
-- Wraps the cart add/remove logic into reusable functions
-- so callers don't repeat the IF/ELSE each time
-- ============================================================

-- Adds one unit of a product; inserts the row if new, increments if existing
-- Usage: SELECT add_to_cart(1);
CREATE OR REPLACE FUNCTION add_to_cart(p_product_id INT)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM cart WHERE product_id = p_product_id) THEN
        UPDATE cart
        SET    qty = qty + 1
        WHERE  product_id = p_product_id;
    ELSE
        INSERT INTO cart (product_id, qty)
        VALUES (p_product_id, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Removes one unit; deletes the row when qty reaches 0
-- Usage: SELECT remove_from_cart(1);
CREATE OR REPLACE FUNCTION remove_from_cart(p_product_id INT)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM cart WHERE product_id = p_product_id AND qty > 1) THEN
        UPDATE cart
        SET    qty = qty - 1
        WHERE  product_id = p_product_id;
    ELSE
        DELETE FROM cart
        WHERE  product_id = p_product_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ---- Demo using the functions ----
SELECT add_to_cart(1);      -- add Coke       → qty 1
SELECT add_to_cart(1);      -- add Coke again → qty 2
SELECT add_to_cart(2);      -- add Chips      → qty 1
SELECT * FROM cart;         -- Coke qty 2, Chips qty 1

SELECT remove_from_cart(1); -- remove one Coke → qty 1
SELECT * FROM cart;         -- Coke qty 1, Chips qty 1

SELECT remove_from_cart(1); -- remove last Coke → row deleted
SELECT * FROM cart;         -- only Chips qty 1