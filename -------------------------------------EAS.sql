--_SQL QUERY SOLUTION OF PROBLEMS IN MUSIC STORE--
-------------------------------------EASY----------------------------------------------------
--Q1: Who is the senior most employee based on job title?--
SELECT title,first_name,last_name,levels
FROM
 `music_database.employee`
 order by levels DESC
 LIMIT 5
 --Q2: Which countries have the most Invoices?--
 -- Count the number of invoices for each billing country and order the results in descending order

SELECT COUNT(*) AS c, billing_country 
FROM `music_database.invoice`
GROUP BY billing_country
ORDER BY c DESC
--Q3: What are top 3 values of total invoice?--
SELECT invoice_id, billing_country, customer_id, total
FROM `music_database.invoice`
ORDER BY total DESC
LIMIT 3;

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.--
SELECT billing_city,SUM(total) AS InvoiceTotal
FROM `music_database.invoice`
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;
--Question 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.--
SELECT
    customer.first_name,
    customer.last_name
  FROM
    `music_database.customer` AS customer
  WHERE customer.customer_id IN(
    SELECT
        invoice.customer_id
      FROM
        `music_database.invoice` AS invoice
      GROUP BY 1
      ORDER BY
        sum(invoice.total) DESC
      LIMIT 1
  )
------------------------------Moderate-----------------------------------------------
--Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.--
SELECT DISTINCT
    cus.email,
    cus.first_name,
    cus.last_name,
    genre.name AS genre
FROM 
    `music_database.customer` AS cus
JOIN 
    `music_database.invoice` AS inv ON cus.customer_id = inv.customer_id
JOIN 
    `music_database.invoice_line` AS inv_line ON inv.invoice_id = inv_line.invoice_id
JOIN 
    `music_database.track` AS track ON inv_line.track_id = track.track_id
JOIN 
    `music_database.genre` AS genre ON track.genre_id = genre.genre_id
WHERE 
    genre.name LIKE 'Rock'
ORDER BY 
    cus.email ASC;
--Q2: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands--
SELECT ar.name AS Artist_Name, COUNT(t.track_id) AS Total_Track_Count
FROM `music_database.artist`as ar
JOIN `music_database.album` as al ON ar.artist_id = al.artist_id
JOIN `music_database.track` as t ON al.album_id = t.album_id
JOIN `music_database.genre` as g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY Total_Track_Count DESC
LIMIT 10;
--Q3: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.--
SELECT name AS Track_Name, milliseconds AS Milliseconds
FROM `music_database.track`
WHERE milliseconds > (
    SELECT AVG(milliseconds)
    FROM `music_database.track`
)
ORDER BY milliseconds DESC;
----------------------------------Advance -------------------------------------
--Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.--
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    `music_database.customer`as  c
JOIN `music_database.invoice`as  i ON c.customer_id = i.customer_id
JOIN `music_database.invoice_line` il ON i.invoice_id = il.invoice_id
JOIN `music_database.track` as t ON il.track_id = t.track_id
JOIN `music_database.album` as al ON t.album_id = al.album_id
JOIN `music_database.artist` as a ON al.artist_id = a.artist_id
GROUP BY
    c.customer_id, a.artist_id,c.first_name,c.last_name,a.name
ORDER BY
    c.first_name, c.last_name, total_spent DESC;
--Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.--
WITH popular_genre AS (
    SELECT
        COUNT(il.quantity) AS purchases,
        c.country,
        g.name,
        g.genre_id,
        ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
    FROM
        music_database.invoice_line as il
    JOIN
        music_database.invoice as i ON i.invoice_id = il.invoice_id
    JOIN
        music_database.customer as c ON c.customer_id = i.customer_id
    JOIN
        music_database.track as t ON t.track_id = il.track_id
    JOIN
        music_database.genre as g ON g.genre_id = t.genre_id
    GROUP BY
        c.country, g.name, g.genre_id
)
SELECT
    country,
    name AS genre_name,
    genre_id,
    purchases
FROM
    popular_genre
WHERE
    RowNo = 1;
--Q3: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount--
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        SUM(il.unit_price * il.quantity) AS total_spent,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS rank_customer
    FROM
        `music_database.customer` AS c
    JOIN `music_database.invoice` AS i ON c.customer_id = i.customer_id
    JOIN `music_database.invoice_line` AS il ON i.invoice_id = il.invoice_line_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name, c.country
)
SELECT DISTINCT
    country,
    first_name,
    last_name,
    total_spent
FROM
    customer_spending
WHERE
    rank_customer = 1
ORDER BY
    country;
