-- ============================================================
--  SHOPPING SYSTEM - COMPLETE SQL SCRIPT
--  Covers: DDL, Cart operations, Checkout, Order reporting
-- ============================================================


-- ============================================================
-- PART 2: CREATE TABLES
-- ============================================================

CREATE TABLE products_menu (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE users (
    user_id  SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL
);

CREATE TABLE cart (
    product_id INT PRIMARY KEY REFERENCES products_menu(id),
    qty        INT NOT NULL DEFAULT 1
);

CREATE TABLE order_header (
    order_id   SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES users(user_id),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

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
-- ============================================================

-- Scenario A: Add a Coke  (product does NOT yet exist in cart → insert qty 1)
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty = 1

-- Scenario B: Add a Coke again  (product EXISTS → increment qty)
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty = 2

-- Scenario C: Add Chips  (product does NOT yet exist in cart → insert qty 1)
IF EXISTS (SELECT * FROM cart WHERE product_id = 2) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 2;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (2, 1);
END IF;

SELECT * FROM cart;   -- expected: Coke qty 2, Chips qty 1


-- ============================================================
-- PART 4: REMOVE ITEMS FROM CART
-- ============================================================

-- Remove one Coke:
--   qty > 1  → subtract 1
--   qty = 1  → delete the row entirely

IF EXISTS (SELECT * FROM cart WHERE product_id = 1 AND qty > 1) THEN
    UPDATE cart SET qty = qty - 1 WHERE product_id = 1;
ELSE
    DELETE FROM cart WHERE product_id = 1;
END IF;

SELECT * FROM cart;   -- expected: Coke qty 1, Chips qty 1

-- Remove the last Coke (qty is now 1 → full row deleted)
IF EXISTS (SELECT * FROM cart WHERE product_id = 1 AND qty > 1) THEN
    UPDATE cart SET qty = qty - 1 WHERE product_id = 1;
ELSE
    DELETE FROM cart WHERE product_id = 1;
END IF;

SELECT * FROM cart;   -- expected: only Chips qty 1

-- Re-add Coke so the cart has items for checkout demos
IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 2);
END IF;

SELECT * FROM cart;   -- expected: Coke qty 2, Chips qty 1


-- ============================================================
-- PART 5: CHECKOUT  (user 1 = Arnold places ORDER 1)
-- ============================================================

-- Step A: insert into order_header
INSERT INTO order_header (user_id, order_date)
VALUES (1, CURRENT_TIMESTAMP);

-- Step B: copy cart rows into order_details using the new order_id
--         then clear the cart
INSERT INTO order_details (order_header_id, product_id, qty)
SELECT (SELECT MAX(order_id) FROM order_header),
       product_id,
       qty
FROM cart;

DELETE FROM cart;

SELECT * FROM order_header;   -- should show 1 row
SELECT * FROM order_details;  -- should show Coke x2 + Chips x1


-- ============================================================
-- SECOND SHOPPING SESSION  (user 2 = Sheryl places ORDER 2)
-- ============================================================

-- Sheryl adds two Chips and one Coke
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

IF EXISTS (SELECT * FROM cart WHERE product_id = 1) THEN
    UPDATE cart SET qty = qty + 1 WHERE product_id = 1;
ELSE
    INSERT INTO cart (product_id, qty) VALUES (1, 1);
END IF;

SELECT * FROM cart;   -- expected: Chips qty 2, Coke qty 1

-- Sheryl's checkout
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

-- Print a single order (order 1 - Arnold)
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    pm.name        AS product_name,
    pm.price,
    od.qty,
    (pm.price * od.qty) AS line_total
FROM order_header  oh
INNER JOIN users          u  ON u.user_id    = oh.user_id
INNER JOIN order_details  od ON od.order_header_id = oh.order_id
INNER JOIN products_menu  pm ON pm.id        = od.product_id
WHERE oh.order_id = 1
ORDER BY od.product_id;

-- Print all orders placed today
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    pm.name        AS product_name,
    pm.price,
    od.qty,
    (pm.price * od.qty) AS line_total
FROM order_header  oh
INNER JOIN users          u  ON u.user_id    = oh.user_id
INNER JOIN order_details  od ON od.order_header_id = oh.order_id
INNER JOIN products_menu  pm ON pm.id        = od.product_id
WHERE DATE(oh.order_date) = CURRENT_DATE
ORDER BY oh.order_id, od.product_id;


-- ============================================================
-- BONUS: STORED FUNCTIONS
-- ============================================================

-- Function: add an item to the cart
-- Usage: SELECT add_to_cart(1);   -- adds one Coke
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


-- Function: remove an item from the cart
-- Usage: SELECT remove_from_cart(1);   -- removes one Coke
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
SELECT add_to_cart(1);      -- add Coke
SELECT add_to_cart(1);      -- add Coke again
SELECT add_to_cart(2);      -- add Chips
SELECT * FROM cart;         -- Coke qty 2, Chips qty 1

SELECT remove_from_cart(1); -- remove one Coke
SELECT * FROM cart;         -- Coke qty 1, Chips qty 1

SELECT remove_from_cart(1); -- remove last Coke (row deleted)
SELECT * FROM cart;         -- only Chips qty 1
