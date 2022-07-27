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
