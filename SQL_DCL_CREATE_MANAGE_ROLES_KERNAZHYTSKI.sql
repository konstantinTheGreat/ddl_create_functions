--1)
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
ALTER USER rentaluser WITH LOGIN;

--2)
GRANT SELECT ON TABLE customer TO rentaluser;

SET ROLE rentaluser;

SELECT * FROM customer

RESET ROLE;

--3)
CREATE GROUP rental;

ALTER GROUP rental ADD USER rentaluser;

--4)

GRANT SELECT, INSERT, UPDATE ON rental TO rental;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO GROUP rental;

SET ROLE rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES (CURRENT_DATE, 4, 4, NULL, 4, CURRENT_TIMESTAMP);

UPDATE rental
SET staff_id = 2
WHERE rental_id = 2;

RESET ROLE;


--5)
SELECT * from rental
REVOKE INSERT ON TABLE rental FROM GROUP rental;
SET ROLE rental;
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES (CURRENT_DATE, 3, 4, NULL, 4, CURRENT_TIMESTAMP);
RESET ROLE;

--6)
CREATE ROLE client_Mary_Smith WITH LOGIN PASSWORD 'Mary_Smith';

ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

CREATE POLICY rental_policy ON rental FOR SELECT USING (customer_id = 1);
CREATE POLICY payment_policy ON payment FOR SELECT USING (customer_id = 1);

GRANT SELECT ON rental TO client_Mary_Smith;
GRANT SELECT ON payment TO client_Mary_Smith;

SET ROLE client_Mary_Smith;
SELECT * FROM rental;
SELECT * FROM payment ;
RESET ROLE;

