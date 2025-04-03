/*	Question Set 1 - Easy */


-- Q1 who is senior most employee based on job title
select * from employee order by levels desc
limit 1;

-- ans: mohan madan

-- Q2 which country have the most invoices?

select billing_country,count(*) as total_invoices from invoice group by billing_country order by count(*) desc limit 1;

-- ans : USA

-- Q3 What ARE top 3 values of total invoice

select round(total) from invoice order by total desc limit 3;

-- ans : 24,20,20

/* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,round(sum(total)) as total_earning from invoice group by billing_city order by sum(total) desc limit 1;

-- Ans : Prague = 273

/* Q5: Who is the best customer? 
The customer who has spent the most money 
will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select inv.customer_id,concat(trim(first_name),' ',trim(last_name)) as full_name,round(sum(total)) as total_bill
from invoice as inv left join customer as cst on inv.customer_id=cst.customer_id
group by inv.customer_id,full_name
order by sum(total) desc limit 1;

-- ans: r madhav = 145

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & 
Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct trim(first_name) as first_name,trim(last_name) as last_name,email from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name = 'Rock'
)
ORDER BY email;

/* Q2: Let's invite the artists 
who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select * from artist;
select * from track;

select artist.name,count(track_id) from artist join
album on artist.artist_id=album.artist_id 
join track on album.album_id=track.album_id where
genre_id in 
(select track.genre_id from track join 
genre on track.genre_id=genre.genre_id
where genre.name = 'Rock')
group by artist.name
order by count(track_id) desc limit 10;

/* Q3: Return all the track names that have a song length 
longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track where
milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

select * from invoice_line;
with best_selling_artist as(
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1
order by 3 desc
limit 1
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as(
select inv.billing_country,gen.name,count(il.quantity) as purchases,
row_number() over(partition by inv.billing_country order by count(il.quantity) desc)
from invoice inv 
join invoice_line il on inv.invoice_id = il.invoice_id
join track tr on tr.track_id=il.track_id
join genre gen on gen.genre_id=tr.genre_id
group by 1,2
order by 1 asc, 3 desc
)

SELECT * FROM popular_genre where row_number<=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

-- 1ST METHOD

select * from invoice;
with recursive customer_with_country as(
select customer.customer_id,trim(first_name) first_name,trim(last_name) last_name,billing_country,
sum(total) as total_spending 
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 1,5 desc
),

country_max_recording as(
select billing_country,max(total_spending) max_spending
from customer_with_country
group by billing_country
)

select cc.billing_country,cc.total_spending,
cc.first_name,cc.last_name
from customer_with_country cc
join country_max_recording ms
on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by 2 desc;

-- 2ND METHOD

with customer_with_country as(select customer.customer_id,first_name,last_name,billing_country,
sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc)
as row_no
from invoice
join customer on customer.customer_id=invoice.customer_id
group by 1,4
order by 4 asc, 5 desc)

select * from customer_with_country where row_no <= 1
