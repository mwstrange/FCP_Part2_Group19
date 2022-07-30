CREATE TABLE G19.tags(
	tagId INT AUTO_INCREMENT NOT NULL,
    tag varchar(85) NOT NULL,
    PRIMARY KEY (tagId));
    
CREATE TABLE G19.genres(
	genreId INT AUTO_INCREMENT NOT NULL,
    genre varchar(77) NOT NULL,
    PRIMARY KEY (genreID));

CREATE TABLE G19.users(
	userId INT AUTO_INCREMENT NOT NULL,
    birthdate DATE,
    gender CHAR(1),
    zip CHAR(5),
    occupation VARCHAR(30),
    PRIMARY KEY (userID));

CREATE TABLE G19.movies(
	movieId INT AUTO_INCREMENT NOT NULL,
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
    
    
#Populating the tables with the FCP dataset

INSERT INTO G19.tags
SELECT tagId, tag
FROM fcp_2022.`genome-scores_csv`;

INSERT INTO G19.users
SELECT UserId, birthdate, gender, zip, occupation
FROM fcp_2022.ratings_csv;

INSERT INTO G19.tagged
SELECT T.userId, GS.tagId, T.movieId, T.timestamp
FROM fcp_2022.tagged_csv T
JOIN fcp_2022.`genome-scores_csv` GS ON T.movieId = GS.movieId;

INSERT INTO G19.movie_genome
SELECT movieID, tagId, relevance
FROM fcp_2022.`genome-scores_csv`;

INSERT INTO G19.genres
SELECT concat (movieId, genres) as genreId, genres
FROM fcp_2022.ratings_csv;

INSERT INTO G19.ratings
SELECT userId, movieId, rating, timestamp
FROM fcp_2022.ratings_csv;
 
INSERT INTO G19.movies
SELECT movieId, title, yearReleased, imdbId, tmdbId
FROM  fcp_2022.ratings_csv;
 
INSERT INTO G19.genres
SELECT concat (movieId, genres) as genreId, genres
FROM fcp_2022.ratings_csv;

INSERT INTO G19.movie_genre
SELECT movieId, genreId
FROM G19.genres, G19.movies; 


#IN ORDER OF POPULATION-----------------------------------------------------------

INSERT INTO G19.tags(tagId, tag)
SELECT tagId, tag
FROM fcp_2022.`genome-scores_csv`;

# The tagID is set to AutoIncrement so there may be an issue trying to insert
INSERT INTO G19.tags (tag)
SELECT DISTINCT(tag) FROM fcp_2022.tagged_csv;

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

INSERT INTO G19.users(userId, birthdate, gender, zip, occupation)
SELECT userId, birthdate, gender, zip, occupation
FROM fcp_2022.ratings_csv;

INSERT INTO G19.movies(movieId, title, yearReleased, imbId, tmbId)
SELECT movieId, title, yearReleased, imdbId, tmdbId
FROM  fcp_2022.ratings_csv;

INSERT INTO G19.movie_genre(movieId, genreId)
SELECT movieId, genreId
FROM G19.genres, G19.movies; 

INSERT INTO G19.movie_genome(movieId, tagId, relevance)
SELECT movieID, tagId, relevance
FROM fcp_2022.`genome-scores_csv`;

INSERT INTO G19.tagged(userId, tagId, movieId, timestamp)
SELECT T.userId, GS.tagId, T.movieId, T.timestamp
FROM fcp_2022.tagged_csv T
JOIN fcp_2022.`genome-scores_csv` GS ON T.movieId = GS.movieId;

INSERT INTO G19.ratings(userId, movieId, rating, timestamp)
SELECT userId, movieId, rating, timestamp
FROM fcp_2022.ratings_csv;
