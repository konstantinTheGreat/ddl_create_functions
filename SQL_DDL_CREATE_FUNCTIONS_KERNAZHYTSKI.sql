--1)
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    SUM(p.amount) AS total_sales_revenue
FROM
    category c
JOIN
    film_category fc ON c.category_id = fc.category_id
JOIN
    film f ON fc.film_id = f.film_id
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
JOIN
    payment p ON r.rental_id = p.rental_id
WHERE
    EXTRACT(QUARTER FROM CURRENT_DATE) = EXTRACT(QUARTER FROM r.rental_date)
GROUP BY
    c.name
HAVING
    SUM(p.amount) > 0;
--2)
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE (category TEXT, total_sales_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM
        category c
    JOIN
        film_category fc ON c.category_id = fc.category_id
    JOIN
        film f ON fc.film_id = f.film_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    JOIN
        payment p ON r.rental_id = p.rental_id
    WHERE
        current_quarter = EXTRACT(QUARTER FROM r.rental_date)
    GROUP BY
        c.name
    HAVING
        SUM(p.amount) > 0;

END;
$$ LANGUAGE plpgsql;

--3)
CREATE OR REPLACE PROCEDURE new_movie(movie_title VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE
    new_film_id INT;
    lang_id INT;
BEGIN
    SELECT language_id INTO lang_id FROM language WHERE name = 'Klingon';

    IF lang_id IS NULL THEN
        INSERT INTO language(name) VALUES ('Klingon') RETURNING language_id INTO lang_id;
    END IF;

    SELECT COALESCE(MAX(film_id), 0) + 1 INTO new_film_id FROM film;

    INSERT INTO film(film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES(new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), lang_id);
END;
$$;


