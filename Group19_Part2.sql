CREATE TABLE G19.tags_2(
	tagId INT AUTO_INCREMENT NOT NULL,
    tag varchar(85) NOT NULL,
    PRIMARY KEY (tagId));
    
CREATE TABLE G19.genres_2(
	genreId INT AUTO_INCREMENT NOT NULL,
    genre varchar(77) NOT NULL,
    PRIMARY KEY (genreID));

CREATE TABLE G19.users_2(
	userId INT UNIQUE NOT NULL,
    birthdate DATE,
    gender CHAR(1),
    zip CHAR(5),
    occupation VARCHAR(30),
    PRIMARY KEY (userID));

CREATE TABLE G19.movies_2(
	movieId INT UNIQUE NOT NULL,
    title VARCHAR(83),
    yearReleased YEAR,
    imdbid CHAR(7),
    tmdbid INT,
    PRIMARY KEY (movieId));
    
CREATE TABLE G19.movie_genre_2(
	movieId INT,
    genreId INT,
    CONSTRAINT PK_movie_genre_2 PRIMARY KEY (movieId, genreId),
    FOREIGN KEY (movieId) REFERENCES G19.movies_2(movieId),
    FOREIGN KEY (genreId) REFERENCES G19.genres_2(genreId));
    
CREATE TABLE G19.movie_genome_2(
	movieId INT,
    tagId INT,
    relevance DECIMAL(21, 20),
    CONSTRAINT PK_movie_genome_2 PRIMARY KEY (movieId, tagId),
    FOREIGN KEY (movieId) REFERENCES G19.movies_2(movieId),
    FOREIGN KEY (tagId) REFERENCES G19.tags_2(tagId));
    
CREATE TABLE G19.tagged_2(
	userId INT,
    tagId INT,
    movieId INT,
    timestamp DATETIME,
    CONSTRAINT PK_tagged_2 PRIMARY KEY (userId, tagId, movieId),
    FOREIGN KEY (userId) REFERENCES G19.users_2(userId),
    FOREIGN KEY (tagId) REFERENCES G19.tags_2(tagId),
    FOREIGN KEY (movieId) REFERENCES G19.movies_2(movieId));
    
CREATE TABLE G19.ratings_2(
	userId INT,
    movieId INT,
    rating DECIMAL(2,1),
    timestamp DATETIME,
    CONSTRAINT PK_ratings_2 PRIMARY KEY (userId, movieId),
    FOREIGN KEY (userId) REFERENCES G19.users_2(userId),
    FOREIGN KEY (movieId) REFERENCES G19.movies_2(movieId));
    
INSERT INTO G19.tags_2 (tag, tagId)
	SELECT DISTINCT(tag), tagId from `fcp_2022`.`genome-scores_csv`
	UNION
	SELECT DISTINCT(tag), null as tagid from fcp_2022.tagged_csv
	WHERE tag not in (SELECT DISTINCT(tag) from fcp_2022.`genome-scores_csv`);
/*
This will split each genre field by '|', stack them into a column and insert into genres table with auto increment ID
*/
INSERT INTO G19.genres_2(genre)
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
INSERT INTO G19.users_2(UserId, birthdate, gender, zip, occupation)
SELECT DISTINCT(userId), birthdate, gender, zip, occupation
FROM fcp_2022.ratings_csv;

INSERT INTO G19.movies_2
	SELECT Distinct(movieId), title, yearReleased, imdbId, tmdbID
	FROM fcp_2022.ratings_csv
	UNION
	SELECT Distinct(movieId), title, yearReleased, null as imdbId, null as tmdbID
	FROM fcp_2022.`genome-scores_csv`
	WHERE movieId NOT IN (SELECT DISTINCT(movieId) FROM fcp_2022.ratings_csv);

#each movie can have more than one genre so we split out to make sure we caught every genre for each movie in the tagged file. 
INSERT INTO G19.movie_genre_2 (movieId, genreId)	
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


/* If the tags are populated with the tagID in the genome file then we don't need a join to look up the tagid */
INSERT INTO G19.movie_genome_2 (movieId, tagId, relevance)
SELECT movieId, tagId, relevance
FROM `fcp_2022`.`genome-scores_csv`;


#I think this way the tagId will pull from our new database and include everything from the union statement in the tags table
INSERT INTO G19.tagged_2 (userId, tagId, movieId, timestamp)
SELECT T.userId, t2.tagId, T.movieId, T.timestamp
FROM fcp_2022.tagged_csv T
JOIN G19.tags_2 as t2 ON t2.tag = T.tag;

INSERT INTO G19.ratings_2(userId, movieId, rating, timestamp)     
SELECT u.userId, m.movieId, r.rating, r.timestamp
FROM fcp_2022.ratings_csv r 
	 JOIN G19.users_2 u ON r.userId = u.userId
     	 JOIN G19.movies_2 m ON r.movieId = m.movieId
    

