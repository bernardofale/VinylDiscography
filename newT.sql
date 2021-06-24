
go
create schema Discografia
go

CREATE TABLE Discografia.Musicas(
	id int IDENTITY(1,1) not null,
	songs_name VARCHAR(20) not null,
	songs_length int not null,
	id_vinyl INT not null,
	PRIMARY KEY(id),
	FOREIGN KEY(id_vinyl) REFERENCES Discografia.Vinil(n_catalog),
	UNIQUE(songs_name)
	);

CREATE TABLE Discografia.Vinil (
	n_catalog INT not null,
	release_year DATE,
	country VARCHAR(25),
	genre VARCHAR(10) not null,
	artist_name VARCHAR(30) not null,
	vin_name VARCHAR(30) not null,
	records_id INT ,
	PRIMARY KEY(n_catalog),
	FOREIGN KEY(artist_name) REFERENCES Discografia.Artista(name),
	FOREIGN KEY(records_id) REFERENCES Discografia.Editora(id)

);

CREATE TABLE Discografia.Artista(
	id int IDENTITY(1,1) not null,
	name VARCHAR(30) not null,
	records_id INT,
	PRIMARY KEY(id),
	FOREIGN KEY(records_id) REFERENCES Discografia.Editora(id),
	UNIQUE(name)
	);

CREATE TABLE Discografia.Editora(
	name VARCHAR(30) not null,
	id INT IDENTITY(1,1) not null,
	PRIMARY KEY(id),
	UNIQUE(name)
	);

CREATE TABLE Discografia.Utilizador(
	username VARCHAR(30) not null,
	email VARCHAR(30) not null,
	name VARCHAR(30) not null,
	register_date TIMESTAMP,
	PRIMARY KEY(username),
	UNIQUE(email)
	);

CREATE TABLE Discografia.Colecao(
	username VARCHAR(30) not null,
	n_items INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Discografia.Utilizador(username)
	ON DELETE CASCADE
	);
	--Insert Colecao (usar Trigger, aquando da insercao de um utilizador, criar Colecao desse utilizador
	
CREATE TABLE Discografia.Pessoa(
	artist_name VARCHAR(30) not null,
	PRIMARY KEY(artist_name),
	FOREIGN KEY(artist_name) REFERENCES Discografia.Artista(name)
	);

CREATE TABLE Discografia.Grupo(
	id INT IDENTITY(1,1) not null,
	band_name VARCHAR(30) not null,
	n_elements INT not null,
	PRIMARY KEY(band_name),
	FOREIGN KEY(band_name) REFERENCES Discografia.Artista(name),
	);

CREATE TABLE Discografia.Pertence(
	band_name VARCHAR(30) not null,
	artist_name VARCHAR(30) not null,
	PRIMARY KEY(band_name,artist_name),
	FOREIGN KEY(band_name) REFERENCES Discografia.Grupo(band_name),
	FOREIGN KEY(artist_name) REFERENCES Discografia.Pessoa(artist_name)
	);

CREATE TABLE Discografia.Vendedor(
	username VARCHAR(30) not null,
	sellers_rating INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Discografia.Utilizador(username) ON DELETE CASCADE
	);

CREATE TABLE Discografia.Comprador(
	username VARCHAR(30) not null,
	buyer_rating INT DEFAULT 0,
	PRIMARY KEY(username),
	FOREIGN KEY(username) REFERENCES Discografia.Utilizador(username) ON DELETE CASCADE
	);
	
CREATE TABLE Discografia.Anuncio(
	ad_id INT IDENTITY(1,1) not null,
	price INT not null,
	creation_date DATE not null default GETDATE(),
	n_catalog INT not null,
	sellers_username VARCHAR(30) not null,
	buyer_username VARCHAR(30) default null,
	PRIMARY KEY(ad_id),
	FOREIGN KEY(n_catalog) REFERENCES Discografia.Vinil(n_catalog) ON DELETE CASCADE,
	FOREIGN KEY(sellers_username) REFERENCES Discografia.Vendedor(username) ,
	FOREIGN KEY(buyer_username) REFERENCES Discografia.Comprador(username) 
	);

CREATE TABLE Discografia.Rating(
	n_catalog INT not null,
	username VARCHAR(30) not null,
	rating INT CHECK(rating>=0 AND rating <=5) not null,
	PRIMARY KEY(n_catalog,username),
	FOREIGN KEY(n_catalog) REFERENCES Discografia.Vinil(n_catalog)
	ON DELETE CASCADE,
	FOREIGN KEY(username) REFERENCES Discografia.Utilizador(username)
	ON DELETE CASCADE
	);

CREATE TABLE Discografia.Colecao_com_Vinil(
	n_catalog INT not null,
	username VARCHAR(30) not null,
	PRIMARY KEY(username,n_catalog),
	FOREIGN KEY(username) REFERENCES Discografia.Utilizador(username)
	ON DELETE CASCADE,
	FOREIGN KEY(n_catalog) REFERENCES Discografia.Vinil(n_catalog)
	ON DELETE CASCADE
	);