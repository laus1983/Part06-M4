-- Buscá todas las películas filmadas en el año que naciste.

SELECT * FROM movies WHERE year=1983;

-- Cuantas películas hay en la DB que sean del año 1982?

SELECT count(*) FROM movies where year=1982;

-- Buscá actores que tengan el substring stack en su apellido. ILIKE no funciona en SQLite.

SELECT * FROM actors WHERE last_name LIKE '%stack%';

-- Buscá los 10 nombres y apellidos más populares entre los actores. Cuantos actores tienen cada uno de esos nombres y apellidos?

SELECT first_name, last_name, count(*) AS populares FROM  actors GROUP BY LOWER(first_name), LOWER(last_name) ORDER BY populares DESC LIMIT 10;

-- Listá el top 100 de actores más activos junto con el número de roles que haya realizado.
-- CREATE view top_actors AS
-- SELECT first_name, last_name, count(*) AS roles FROM actors INNER JOIN roles ON actors.id=roles.actor_id GROUP BY first_name, last_name ORDER BY roles DESC LIMIT 100;
-- SELECT * FROM top_actors;

SELECT a.first_name, a.last_name, count(*) AS total 
FROM actors AS a JOIN roles AS r ON a.id=r.actor_id
GROUP BY a.id
ORDER BY total DESC
LIMIT 100;

-- Cuantas películas tiene IMDB por género? Ordená la lista por el género menos popular.
-- CREATE view top_genres AS
-- SELECT id, count(*) AS id FROM movies INNER JOIN movies_genres ON movies.id=movies_genres.movie_id GROUP BY id ORDER BY id DESC;
-- SELECT * FROM top_genres;

SELECT genre, count(*) AS t FROM movies_genres GROUP BY genre ORDER BY t;

-- Listá el nombre y apellido de todos los actores que trabajaron en la película "Braveheart" de 1995, ordená la lista alfabéticamente por apellido.
-- SELECT first_name, last_name FROM actors INNER JOIN roles ON actors.id=roles.actor_id INNER JOIN movies ON roles.movie_id=movies.id WHERE movies.name='Braveheart' AND movies.year=1995 ORDER BY last_name;

SELECT a.first_name, a.last_name FROM actors AS a
JOIN roles AS r ON a.id=r.actor_id
JOIN movies AS m ON m.id=r.movie_id
WHERE m.name='Braveheart' AND m.year=1995
ORDER BY a.last_name;

-- Listá todos los directores que dirigieron una película de género 'Film-Noir' en un año bisiesto
-- (para reducir la complejidad, asumí que cualquier año divisible por cuatro es bisiesto).
-- Tu consulta debería devolver el nombre del director, el nombre de la peli y el año.
-- Todo ordenado por el nombre de la película.
-- SELECT id, first_name, last_name FROM directors INNER JOIN directors_genres ON directors.id=directors_genres.director_id INNER JOIN movies ON directors_genres.movie_id=movies.id WHERE movies.year%4=0 AND movies.year%100!=0 AND movies.year%400=0 AND movies_genres.genre_id=3 ORDER BY movies.name;

SELECT d.first_name, d.last_name, m.name, m.year FROM directors AS d
JOIN movies_directors AS md ON d.id=md.director_id
JOIN movies AS m ON m.id=md.movie_id
JOIN movies_genres AS mg ON m.id=mg.movie_id
WHERE m.year%4=0 AND mg.genre='Film-Noir' ORDER BY m.name;

-- Listá todos los actores que hayan trabajado con Kevin Bacon en películas de Drama (incluí el título de la peli). Excluí al señor Bacon de los resultados.

SELECT a.first_name, a.last_name FROM actors AS a
JOIN roles AS r ON a.id=r.actor_id
JOIN movies AS m ON m.id=r.movie_id
JOIN movies_genres AS mg ON m.id=mg.movie_id
WHERE mg.genre='Drama' AND m.id IN (
    SELECT r.movie_id FROM roles AS r
    JOIN actors AS a ON a.id=r.actor_id
    WHERE a.first_name='Kevin' AND a.last_name='Bacon'
)
AND (a.first_name || ' ' || a.last_name != 'Kevin Bacon');

-- Qué actores actuaron en una película antes de 1900 y también en una película después del 2000?
-- SELECT first_name, last_name FROM actors INNER JOIN roles ON actors.id=roles.actor_id INNER JOIN movies ON roles.movie_id=movies.id WHERE movies.year<1900 OR movies.year>2000;

SELECT * From actors WHERE id IN (
    SELECT r.actor_id FROM roles AS r
    JOIN movies AS m ON m.id=r.movie_id
    WHERE m.year<1900
)
AND id IN (
    SELECT r.actor_id FROM roles AS r
    JOIN movies AS m ON m.id=r.movie_id
    WHERE m.year>2000
);

-- Buscá actores que actuaron en cinco o más roles en la misma película después del año 1990.
-- Noten que los ROLES pueden tener duplicados ocasionales, sobre los cuales no estamos interesados:
-- queremos actores que hayan tenido cinco o más roles DISTINTOS (DISTINCT cough cough)
-- en la misma película. Escribí un query que retorne los nombres del actor, el título de la película
-- y el número de roles (siempre debería ser > 5).

SELECT a.first_name, a.last_name, m.name, count(DISTINCT(role)) AS total
FROM roles AS r
JOIN actors AS a ON a.id=r.actor_id
JOIN movies AS m ON m.id=r.movie_id
WHERE m.year>1990
GROUP BY actor_id, movie_id
HAVING total>5;

-- Para cada año, contá el número de películas en ese años que sólo tuvieron actrices femeninas.
-- TIP: Podrías necesitar sub-queries. Lee más sobre sub-queries acá.

SELECT year, count(DISTINCT(id)) AS total FROM movies
WHERE id IN (
    SELECT movie_id FROM roles AS r
    JOIN actors AS a ON a.id=r.actor_id
    WHERE a.gender='F'
)
GROUP BY year;
