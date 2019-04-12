-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
 	FROM actor;
    
-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
--     Name the column Actor Name.

SELECT upper(concat(first_name, " ", last_name))   "Actor Name"  
	FROM actor;
    
-- 2a. You need to find the ID number, first name, and last name of an actor, 
--	   of whom you know only the first name, "Joe." What is one query would you use to 
--     obtain this information?

SELECT actor_id, first_name, last_name
	FROM actor
    WHERE first_name = "Joe";
    
-- 2b. Find all actors whose last name contain the letters GEN:

SELECT first_name, last_name
	FROM actor
    WHERE upper(last_name) LIKE '%GEN%';
    
-- 2c. Find all actors whose last names contain the letters LI. This time, 
--     order the rows by last name and first name, in that order:

SELECT first_name, last_name
	FROM actor
    WHERE upper(last_name) LIKE '%LI%'
    ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
--     Afghanistan, Bangladesh, and China

SELECT country_id, country 
	FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
    
-- 3a. You want to keep a description of each actor. You don't think you will be 
--     performing queries on a description, so create a column in the table actor 
--     named description and use the data type BLOB 

ALTER TABLE actor 
	ADD (description	blob);
    
-- 3b. Very quickly you realize that entering descriptions for each actor is too 
--      much effort. Delete the description column.

ALTER TABLE actor
	DROP COLUMN description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
	count(last_name)     "Count"
    FROM actor
    GROUP BY last_name;
    
-- 4b. List last names of actors and the number of actors who have that last name, 
--     but only for names that are shared by at least two actors

SELECT last_name,
	count(last_name)     "Count"
    FROM actor
    GROUP BY last_name
    HAVING count(last_name) > 1;
    
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
--     Write a query to fix the record.

UPDATE actor	
	SET first_name = "HARPO"
    WHERE first_name = "GROUCHO"
		AND last_name = "WILLIAMS";
        
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO 
--     was the correct name after all! In a single query, if the first name of the actor 
--     is currently HARPO, change it to GROUCHO.

UPDATE actor	
	SET first_name = "GROUCHO"
    WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use 
--     to re-create it?

/* Here's a query to find what schema the table is in...   */

SELECT table_schema, 
         table_name
	FROM sys.schema_table_statistics
    WHERE table_name = "address";
    
/*  if it truly no longer exists, use this query to re-create it...    */

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
		
        
/* while you still have the tables, you can generate the above code using this query:  */

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of 
--     each staff member. Use the tables staff and address:

SELECT first_name, last_name, address
	FROM staff
    JOIN address
    ON staff.address_id = address.address_id;
    
/*  another way to do that:  */

SELECT first_name, last_name, address
	FROM staff, address
    WHERE staff.address_id = address.address_id;
    
-- 6b. Use JOIN to display the total amount rung up by each staff member in 
--     August of 2005. Use tables staff and payment.

SELECT first_name, last_name, 
	SUM(amount) 	"Total Amount",
    COUNT(amount)	"Number of Transactions"
	FROM staff
    JOIN payment
    ON staff.staff_id = payment.staff_id
    WHERE month(payment_date) = 8
		AND year(payment_date) = 2005
	GROUP BY first_name, last_name;
    
    
-- 6c. List each film and the number of actors who are listed for that film. 
--     Use tables film_actor and film. Use inner join.

SELECT title, 
       count(actor_id)  "Count of Actors"
	FROM film
    JOIN film_actor
    ON film.film_id = film_actor.film_id
    GROUP BY title;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title, count(inventory_id)  "Count"
	FROM film, inventory
	WHERE title = "Hunchback Impossible"
    	AND film.film_id = inventory.film_id;
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total 
--     paid by each customer. List the customers alphabetically by last name:

SELECT first_name,
		last_name,
        sum(amount)		"Total Amount"
	FROM customer
    JOIN payment
		on customer.customer_id = payment.customer_id
	GROUP BY first_name, last_name
	ORDER BY last_name, first_name;
    
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an 
--     unintended consequence, films starting with the letters K and Q have also soared 
--     in popularity. Use subqueries to display the titles of movies starting with the 
--      letters K and Q whose language is English.

SELECT title FROM film
	WHERE (title LIKE 'K%'  or title  LIKE 'Q%')
      AND "English" = (SELECT name FROM language WHERE language.language_id = film.language_id);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
	FROM actor
    WHERE actor.actor_id in (
		SELECT film_actor.actor_id 
			FROM film_actor
            WHERE film_actor.film_id = (
				SELECT film.film_id 
					FROM film
                    WHERE title = "Alone Trip"
				)
			);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
--     names and email addresses of all Canadian customers. Use joins to retrieve this 
--     information.

/*  Here's my time-honored way of retrieving this using joins  */

SELECT first_name, last_name, email, city, country
	FROM customer  c1,
		address a1,
        city c2,
        country c3
    WHERE country = "Canada"
		AND c1.address_id = a1.address_id
        AND a1.city_id = c2.city_id
        AND c2.country_id = c3.country_id;
        
/* But if you insist on my coming up with a query that explicity uses the keyword "JOIN":  */

SELECT first_name, last_name, email, city, country
	FROM customer  c1
    INNER JOIN address a1 ON c1.address_id = a1.address_id
    INNER JOIN city c2    ON a1.city_id = c2.city_id
    INNER JOIN country c3 ON c2.country_id = c3.country_id
     WHERE country = "Canada";
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
--     for a promotion. Identify all movies categorized as family films.

SELECT title, name    "Category"
	FROM film  f
    INNER JOIN film_category  fc    ON f.film_id = fc.film_id
    INNER JOIN category c			ON fc.category_id = c.category_id
    WHERE name LIKE '%Family%';

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, 
		count(rental_id)  "Times Rented"
	FROM film  f
    INNER JOIN inventory	i	ON f.film_id = i.film_id
    INNER JOIN rental		r	ON i.inventory_id = r.inventory_id
    GROUP BY title
    ORDER BY count(rental_id)  desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

/*  I'm not sure of the best way to find this.  I can think of three different queries,  each
	yielding a different result.  Query 1:				*/
    
SELECT s.store_id     "Store ID",  
	sum(amount)		  "Gross Revenue"
FROM store  s
INNER JOIN inventory i 	on s.store_id = i.store_id
INNER JOIN rental r     on i.inventory_id = r.inventory_id
RIGHT JOIN payment p    on r.rental_id = p.rental_id
GROUP BY s.store_id;

/*   Query 2:   */

SELECT s.store_id     "Store ID",  
	sum(amount)		  "Gross Revenue"
FROM store  s
INNER JOIN staff 	on s.store_id = staff.store_id
INNER JOIN payment p   on staff.staff_id = p.staff_id
GROUP BY s.store_id;

/*   Query 3:   */

SELECT s.store_id     "Store ID",  
	sum(amount)		  "Gross Revenue"
	FROM store  s
	INNER JOIN staff 		on s.store_id = staff.store_id
    INNER JOIN rental r		on staff.staff_id = r.staff_id
	RIGHT JOIN payment p    on r.rental_id = p.rental_id
	GROUP BY s.store_id;
    
/*  First, the payment table is missing rental_id on five records (hence the need for a RIGHT JOIN).
	Second, the staff_id is not consistent between the payment table and the rental table
    for the same rental_id.  The contents and structure of the staff table implies that each
    staff member works at a single and different store - perhaps the company allows returns/payments
    at a different store than the one rented at?  If so, should the revenue be attributed to the
    store rented from or the store receiving payment?  And store_id (via inventory) is not consistent
    with either one.  Maybe instead, a staff member is primarily associated with one store but
    may be asked to fill in at another.  That would make paths through the staff table useless 
    for this purpose, so ultimately I am choosing query 1 as the most likely to be correct, 
    even if 9.95 worth of business remains unaccounted for by store.					*/
    
-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country
	FROM store		s,
		 address	a,
         city		c1,
         country	c2
	WHERE s.address_id = a.address_id
      AND a.city_id = c1.city_id
      AND c1.country_id = c2.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 

SELECT name				"Genre",
	   sum(amount)		"Gross Revenue"
	FROM category  c,
		film_category   fc,
        inventory  i,
        rental     r,
        payment    p
	WHERE c.category_id = fc.category_id
      AND fc.film_id = i.film_id
      AND i.inventory_id = r.inventory_id
      AND r.rental_id = p.rental_id
	GROUP BY genre
	ORDER BY sum(amount) DESC
    LIMIT 5;
    

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
--     Top five genres by gross revenue. Use the solution from the problem above to create 
--     a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT name				"Genre",
	   sum(amount)		"Gross Revenue"
	FROM category  c,
		film_category   fc,
        inventory  i,
        rental     r,
        payment    p
	WHERE c.category_id = fc.category_id
      AND fc.film_id = i.film_id
      AND i.inventory_id = r.inventory_id
      AND r.rental_id = p.rental_id
	GROUP BY genre
	ORDER BY sum(amount) DESC
    LIMIT 5;
    


-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres; 