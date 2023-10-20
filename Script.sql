--Demandes de la Direction :
--
--Liste des titres de films

SELECT film.title 
FROM film


--Nombre de films par catégorie

SELECT category.name, COUNT(*) AS nombre_films
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.name;



--Liste des films dont la durée est supérieure à 120 minutes

SELECT film.length, film.title  
FROM film
WHERE length > 120



--Liste des films sortis entre 2004 et 2006

SELECT *
FROM film f 
WHERE release_year BETWEEN 2004 AND 2006



--Liste des films de catégorie "Action" ou "Comedy"

SELECT title, name 
FROM film f  
JOIN film_category fc ON fc.film_id  = f.film_id 
JOIN category c ON c.category_id = fc.category_id 
WHERE name = "Action" OR name = "Comedy"



--Nombre total de films (définissez l'alias 'nombre de film' pour la valeur calculée)

SELECT COUNT(film_id) as nombre_de_films
FROM film f
; 

-- Les notes moyennes par catégorie

SELECT name AS catégorie, ROUND(AVG(rental_rate),2) AS notes_moyennes
FROM film f 	
JOIN film_category fc  ON f.film_id = fc.film_id 
JOIN category c ON c.category_id = fc.category_id 
GROUP BY name 

--Demandes de la Direction avec concepts associés (niveau plus avancé):
--
--Liste des 10 films les plus loués. (SELECT, JOIN, GROUP BY, ORDER BY, LIMIT)

SELECT title , COUNT(title) AS "nombre_location"
FROM rental r  
JOIN payment p ON r.rental_id = p.rental_id 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN film f ON f.film_id = i.film_id 
GROUP BY title 
ORDER BY nombre_location DESC
LIMIT 10


--Acteurs ayant joué dans le plus grand nombre de films. (JOIN, GROUP BY, ORDER BY, LIMIT)

SELECT last_name, first_name, COUNT(last_name) AS nombre_de_film 
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON f.film_id = fa.film_id 
GROUP BY last_name 
ORDER BY nombre_de_film DESC
LIMIT 10


--Revenu total généré par mois

SELECT STRFTIME('%Y-%m', payment_date) AS mois_annee, SUM(amount) AS revenu_total,*
FROM payment p 
GROUP BY mois_annee
ORDER BY mois_annee DESC


--Revenu total généré par chaque magasin par mois pour l'année 2005. (JOIN, SUM, GROUP BY, DATE functions)

WITH Revenu_Total_Mois AS (
SELECT STRFTIME('%Y-%m', payment_date) AS mois_annee, SUM(amount) AS revenu_total,*
FROM payment p 
GROUP BY mois_annee
ORDER BY mois_annee DESC
)
SELECT mois_annee, revenu_total, store_id AS magasin
FROM Revenu_Total_Mois
INNER JOIN staff s ON Revenu_Total_Mois.staff_id = s.staff_id 
WHERE mois_annee LIKE '2005%'




--Les clients les plus fidèles, basés sur le nombre de locations. (SELECT, COUNT, GROUP BY, ORDER BY)

SELECT COUNT(c.customer_id) AS nombres_de_location, first_name, last_name 
FROM rental r 
INNER JOIN customer c ON r.customer_id = c.customer_id  
GROUP BY c.customer_id
ORDER BY nombres_de_location DESC 


--Films qui n'ont pas été loués au cours des 6 derniers mois. (LEFT JOIN, WHERE, DATE functions, Sub-query)


WITH films_loues_pendant_periode AS (
    SELECT DISTINCT f.title
    FROM film f
    INNER JOIN inventory i ON f.film_id = i.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE r.rental_date IS NULL OR (DATE(r.rental_date) BETWEEN '2005-08-01' AND '2006-02-28')
)
SELECT DISTINCT f.title
FROM film f
WHERE f.title NOT IN (SELECT title FROM films_loues_pendant_periode);




--Le revenu total de chaque membre du personnel à partir des locations. (JOIN, GROUP BY, ORDER BY, SUM)

SELECT s.first_name , SUM(amount) AS revenu_total
FROM staff s 
INNER JOIN payment p  ON s.staff_id = p.staff_id
GROUP BY s.first_name
ORDER BY revenu_total DESC  


--Catégories de films les plus populaires parmi les clients. (JOIN, GROUP BY, ORDER BY, LIMIT)

SELECT c.name AS categorie, COUNT(c.name) AS nombre_location
FROM category c 
INNER JOIN film_category fc ON c.category_id = fc.category_id 
INNER JOIN inventory i ON fc.category_id = i.film_id 
INNER JOIN rental r ON i.inventory_id = r.inventory_id 
GROUP BY name 
ORDER BY nombre_location DESC 

--Durée moyenne entre la location d'un film et son retour. (SELECT, AVG, DATE functions)

SELECT CEIL(AVG(f.rental_duration)) AS duree_moyenne_loc
FROM film f;

--Acteurs qui ont joué ensemble dans le plus grand nombre de films. Afficher l'acteur 1, l'acteur 2 et le nombre de films en commun. Trier les résultats par ordre décroissant. Attention aux répétitons. (JOIN, GROUP BY, ORDER BY, Self-join)



WITH film_joue_acteur AS (
	SELECT title, last_name 
	FROM actor a
	INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
	INNER JOIN film f ON fa.film_id = f.film_id
)

SELECT f1.last_name AS acteur1, f2.last_name AS acteur2, COUNT(*) AS nombre_film_en_commun 
FROM film_joue_acteur f1
INNER JOIN film_joue_acteur f2 ON f1.title = f2.title AND f1.last_name < f2.last_name
GROUP BY f1.last_name, f2.last_name
ORDER BY nombre_film_en_commun DESC

--Bonus : Clients qui ont loué des films mais n'ont pas fait au moins une location dans les 30 jours qui suivent. (JOIN, WHERE, DATE functions, Sub-query)


WITH premiere_location AS (
	SELECT r.rental_date , last_name  
	FROM rental r 
	JOIN customer c ON r.customer_id = c.customer_id 
	
)

SELECT DISTINCT last_name
FROM premiere_location
WHERE date(rental_date, '+30 days') NOT IN rental_date
    SELECT rental_date
    FROM rental
    WHERE customer_id = (SELECT customer_id FROM customer WHERE last_name = premiere_location.last_name)
);






