CREATE DATABASE DISCOGS;

CREATE TABLE Vinil(
	n_catalog INT not null,
	release_year DATE,
	country VARCHAR(15),
	genre VARCHAR(10) not null,
	artist_name VARCHAR(20) not null,
	vin_name VARCHAR(20) not null,
	records_id INT ,
	PRIMARY KEY(n_catalog),
	UNIQUE(vin_name),
	FOREIGN KEY(artist_name) REFERENCES Artista(name),
	FOREIGN KEY(records_id) REFERENCES Editora(id)
	);

CREATE TABLE Utilizador(
	username VARCHAR(15) not null,
	email VARCHAR(18) not null,
	name VARCHAR(20) not null,
	register_date TIMESTAMP,
	PRIMARY KEY(username),
	UNIQUE(email)
	);

CREATE TABLE Colecao(
	username VARCHAR(15) not null,
	n_items INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	ON DELETE CASCADE
	);
	--quando adicionarmos um item a colecao_com_vinil incrementar o n_items

CREATE TABLE Editora(
	name VARCHAR(20) not null,
	id INT IDENTITY(1,1) not null,
	PRIMARY KEY(id),
	);

CREATE TABLE Artista(
	name VARCHAR(20) not null,
	records_id INT,
	PRIMARY KEY(name),
	FOREIGN KEY(records_id) REFERENCES Editora(id)
	);

CREATE TABLE Pessoa(
	artist_name VARCHAR(20) not null,
	PRIMARY KEY(artist_name),
	FOREIGN KEY(artist_name) REFERENCES Artista(name)
	);

CREATE TABLE Grupo(
	band_name VARCHAR(20) not null,
	n_elements INT not null,
	PRIMARY KEY(band_name),
	FOREIGN KEY(band_name) REFERENCES Artista(name)
	);

CREATE TABLE Pertence(
	band_name VARCHAR(20) not null,
	artist_name VARCHAR(20) not null,
	PRIMARY KEY(band_name,artist_name),
	FOREIGN KEY(band_name) REFERENCES Grupo(band_name),
	FOREIGN KEY(artist_name) REFERENCES Pessoa(artist_name)
	);

CREATE TABLE Vendedor(
	username VARCHAR(15) not null,
	sellers_rating INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	);
	
CREATE TABLE Comprador(
	username VARCHAR(15) not null,
	buyer_rating INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	);
	
CREATE TABLE Anuncio(
	ad_id INT IDENTITY(1,1) not null,
	price INT not null,
	creation_date DATE not null,
	n_catalog INT not null,
	sellers_username VARCHAR(15) not null,
	buyer_username VARCHAR(15),
	PRIMARY KEY(ad_id),
	FOREIGN KEY(n_catalog) REFERENCES Vinil(n_catalog),
	FOREIGN KEY(sellers_username) REFERENCES Vendedor(username),
	FOREIGN KEY(buyer_username) REFERENCES Comprador(username)
	);

CREATE TABLE Rating(
	n_catalog INT not null,
	username VARCHAR(15) not null,
	rating INT CHECK(rating>=0 AND rating <=5) not null,
	PRIMARY KEY(n_catalog),
	FOREIGN KEY(n_catalog) REFERENCES Vinil(n_catalog)
	ON DELETE CASCADE,
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	ON DELETE CASCADE
	);

CREATE TABLE Wishlist(
	n_items INT DEFAULT 0,
	username VARCHAR(15) not null,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	ON DELETE CASCADE
	);
--quando adicionarmos um item a wishlist_com_vinil incrementar o n_items

CREATE TABLE Musicas(
	songs_name VARCHAR(20) not null,
	songs_length TIME not null,
	id_vinyl INT not null,
	PRIMARY KEY(songs_name),
	FOREIGN KEY(id_vinyl) REFERENCES Vinil(n_catalog)
	);

	
CREATE TABLE Wishlist_contem_Vinil(
	n_catalog INT not null,
	username VARCHAR(15) not null,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	ON DELETE CASCADE,
	FOREIGN KEY(n_catalog) REFERENCES Vinil(n_catalog)
	ON DELETE CASCADE
	);

CREATE TABLE Colecao_com_Vinil(
	n_catalog INT not null,
	username VARCHAR(15) not null,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Utilizador(username)
	ON DELETE CASCADE,
	FOREIGN KEY(n_catalog) REFERENCES Vinil(n_catalog)
	ON DELETE CASCADE
	);
