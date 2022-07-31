CREATE TABLE G19.tags(
	tagId INT AUTO_INCREMENT NOT NULL,
    tag varchar(85) NOT NULL,
    PRIMARY KEY (tagId));
    
CREATE TABLE G19.genres(
	genreId INT AUTO_INCREMENT NOT NULL,
    genre varchar(77) NOT NULL,
    PRIMARY KEY (genreID));

CREATE TABLE G19.users(
	userId INT UNIQUE NOT NULL,
    birthdate DATE,
    gender CHAR(1),
    zip CHAR(5),
    occupation VARCHAR(30),
    PRIMARY KEY (userID));

CREATE TABLE G19.movies(
	movieId INT UNIQUE NOT NULL,
    title VARCHAR(83),
    yearReleased YEAR,
    imdbid CHAR(7),
    tmdbid INT,
    PRIMARY KEY (movieId));
    
CREATE TABLE G19.movie_genre(
	movieId INT,
    genreId INT,
    CONSTRAINT PK_movie_genre PRIMARY KEY (movieId, genreId),
    FOREIGN KEY (movieId) REFERENCES G19.movies(movieId),
    FOREIGN KEY (genreId) REFERENCES G19.genres(genreId));
    
CREATE TABLE G19.movie_genome(
	movieId INT,
    tagId INT,
    relevance DECIMAL(21, 20),
    CONSTRAINT PK_movie_genome PRIMARY KEY (movieId, tagId),
    FOREIGN KEY (movieId) REFERENCES G19.movies(movieId),
    FOREIGN KEY (tagId) REFERENCES G19.tags(tagId));
    
CREATE TABLE G19.tagged(
	userId INT,
    tagId INT,
    movieId INT,
    timestamp DATETIME,
    CONSTRAINT PK_tagged PRIMARY KEY (userId, tagId, movieId),
    FOREIGN KEY (userId) REFERENCES G19.users(userId),
    FOREIGN KEY (tagId) REFERENCES G19.tags(tagId),
    FOREIGN KEY (movieId) REFERENCES G19.movies(movieId));
    
CREATE TABLE G19.ratings(
	userId INT,
    movieId INT,
    rating DECIMAL(2,1),
    timestamp DATETIME,
    CONSTRAINT PK_ratings PRIMARY KEY (userId, movieId),
    FOREIGN KEY (userId) REFERENCES G19.users(userId),
    FOREIGN KEY (movieId) REFERENCES G19.movies(movieId));
    
#IN ORDER OF DATABASE POPULATION-----------------------------------------------------------

# The tagID is set to AutoIncrement so we only need to select the distinct tag from the tagged csv
INSERT INTO G19.tags (tag)
SELECT DISTINCT(tag) FROM
	(SELECT tag from fcp_2022.tagged_csv as t
	UNION
	SELECT tag from `fcp_2022`.`genome-scores_csv` as g) as tags;

/*
This will split each genre field by '|', stack them into a column and insert into genres table with auto increment ID
*/
INSERT INTO G19.genres(genre)
SELECT * FROM (
SELECT DISTINCT(genre1) FROM (SELECT Substring_Index(substring_index(genres, '|',1), '|', -1) as genre1 FROM fcp_2022.tagged_csv ) as split1
UNION
SELECT DISTINCT(genre2) FROM (SELECT Substring_Index(substring_index(genres, '|',2), '|', -1) as genre2 FROM fcp_2022.tagged_csv ) as split2
UNION
SELECT DISTINCT(genre3) FROM (SELECT Substring_Index(substring_index(genres, '|',3), '|', -1) as genre3 FROM fcp_2022.tagged_csv ) as split3
UNION
SELECT DISTINCT(genre4) FROM (SELECT Substring_Index(substring_index(genres, '|',4), '|', -1) as genre4 FROM fcp_2022.tagged_csv ) as split4
UNION
SELECT DISTINCT(genre5) FROM (SELECT Substring_Index(substring_index(genres, '|',5), '|', -1) as genre5 FROM fcp_2022.tagged_csv ) as split5
UNION
SELECT DISTINCT(genre6) FROM (SELECT Substring_Index(substring_index(genres, '|',6), '|', -1) as genre6 FROM fcp_2022.tagged_csv ) as split6
UNION
SELECT DISTINCT(genre7) FROM (SELECT Substring_Index(substring_index(genres, '|',7), '|', -1) as genre7 FROM fcp_2022.tagged_csv ) as split7) as split_genres;

# Using a subquery to get each distinct user and then importing that into the table.
INSERT INTO G19.users(birthdate, gender, zip, occupation)
SELECT 
	birthdate, gender, zip, occupation
FROM 
	(SELECT userId, birthdate, gender, zip, occupation
	 FROM fcp_2022.ratings_csv
     	 GROUP BY userId, birthdate, gender, zip, occupation) as users;

# Using a subquery to get each distinct movie and then importing that into the table.
INSERT INTO G19.movies(movieId, title, yearReleased, imdbid, tmdbid)
SELECT DISTINCT(movieId), title, yearReleased, imdbId, tmdbId
FROM fcp_2022.ratings_csv;

---------------------------------------------

#each movie can have more than one genre so we split out to make sure we caught every genre for each movie in the tagged file. 
INSERT INTO G19.movie_genre (movieId, genreId)	
SELECT sg.movieId, g.genreId 
FROM 
(
	SELECT movieId, genre1 
	FROM (SELECT Substring_Index(substring_index(genres, '|',1), '|', -1) as genre1, movieId FROM fcp_2022.tagged_csv) as split1
UNION
	SELECT movieId, genre2 
    FROM (SELECT Substring_Index(substring_index(genres, '|',2), '|', -1) as genre2, movieId FROM fcp_2022.tagged_csv) as split2
UNION
	SELECT movieId, genre3 
    FROM (SELECT Substring_Index(substring_index(genres, '|',3), '|', -1) as genre3, movieId FROM fcp_2022.tagged_csv ) as split3
UNION
	SELECT movieId, genre4 
    FROM (SELECT Substring_Index(substring_index(genres, '|',4), '|', -1) as genre4, movieId FROM fcp_2022.tagged_csv ) as split4
UNION
	SELECT movieId, genre5 
    FROM (SELECT Substring_Index(substring_index(genres, '|',5), '|', -1) as genre5, movieId FROM fcp_2022.tagged_csv ) as split5
UNION
	SELECT movieId, genre6 
    FROM (SELECT Substring_Index(substring_index(genres, '|',6), '|', -1) as genre6, movieId FROM fcp_2022.tagged_csv ) as split6
UNION
	SELECT movieId, genre7 
    FROM (SELECT Substring_Index(substring_index(genres, '|',7), '|', -1) as genre7, movieId FROM fcp_2022.tagged_csv ) as split7) as sg 
    JOIN G19.genres g ON sg.genre1 = g.genre;

-----------------------------------------------------------    

INSERT INTO G19.movie_genome (movieId, tagId, relevance)
SELECT g.movieId, t.tagID, g.relevance
FROM `fcp_2022`.`genome-scores_csv` as g
JOIN G19.tags as t ON g.tag = t.tag;

INSERT INTO G19.tagged(userId, tagId, movieId, timestamp)
SELECT T.userId, GS.tagId, T.movieId, T.timestamp
FROM fcp_2022.tagged_csv T
JOIN fcp_2022.`genome-scores_csv` GS ON T.movieId = GS.movieId;

INSERT INTO G19.tagged(userId, tagId, movieId, timestamp)
SELECT T.userId, t2.tagId, T.movieId, T.timestamp
FROM fcp_2022.tagged_csv T
JOIN G19.tags as t2 ON t2.tag = T.tag;

INSERT INTO G19.ratings(userId, movieId, rating, timestamp)     
SELECT u.userId, m.movieId, r.rating, r.timestamp
FROM fcp_2022.ratings_csv r 
	 JOIN G19.users u ON r.userId = u.userId
     	 JOIN G19.movies m ON r.movieId = m.movieId
