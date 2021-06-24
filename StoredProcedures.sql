--------------------
--LISTAR,REMOVER,ADICIONAR,EDITAR USERS
--------------------
go
CREATE PROC Discografia.removeUser @username varchar(15)
AS
DELETE FROM Discografia.Utilizador WHERE username=@username;
go
exec Discografia.removeUser 'dvicente'
--------------------
go
CREATE PROC Discografia.insertUser @username varchar(15),@email varchar(18),@name varchar(20)
AS
BEGIN
INSERT INTO [Utilizador](
						[username],
						[email],
						[name]) VALUES(@username,@email,@name);
END
go
exec Discografia.insertUser 'dvicente','dvicente@ua.pt','Bernardo Fale'
-------------------
go
CREATE PROC Discografia.updateUser @username varchar(15),@email varchar(18),@name varchar(20)
AS
UPDATE Utilizador SET email=@email,name=@name WHERE username=@username;
go
exec Discografia.updateUser 'bernardofalle','mbfale@ua.pt','Diogo Vicente'
-------------------

---------------------------
--LISTAR,ADICIONAR,REMOVER VINIS
----------------------------
go
CREATE PROC Discografia.removeVinyl @n_catalog int
AS
DELETE FROM Discografia.Vinil WHERE n_catalog=@n_catalog;
--Cada vez que retirarmos um Vinil, accionar Trigger que remova tuplo na tabela de artista (feito)
go
exec Discografia.removeVinyl 1728
-------------------
go
CREATE PROC Discografia.insertVinyl @n_catalog int ,@release_year date,@country varchar(15),@genre varchar(20),@artist_name varchar(20),@vin_name varchar(20),@records_id int
AS
BEGIN
INSERT INTO [Vinil](
					[n_catalog],
					[release_year],
					[country],
					[genre],
					[artist_name],
					[vin_name],
					[records_id]) VALUES (@n_catalog, @release_year, @country, @genre, @artist_name, @vin_name, @records_id);

--Cada vez que inserirmos um Vinil, accionar Trigger que insere tuplo na tabela de artista (feito)
END
go
exec Discografia.insertVinyl 1,'1976-05-02','Portugal','Rock','Ronaldo','golos',5

---------------------
--inserir e remover vinis da colecao do user, e lista-los
---------------------
go
CREATE PROC Discografia.insertVinylintoCollection @n_catalog int, @username varchar(15)
AS
BEGIN
INSERT INTO [Colecao_com_Vinil](
					[n_catalog],
					[username]) VALUES (@n_catalog, @username);
--(depois de inserir vinil em coleção, accionar trigger que incrementa nº items na tabela colecao) (feito)
END
go
exec Discografia.insertVinylintoCollection '1','dvicente'
----------------------
go
CREATE PROC Discografia.removeVinylintoCollection @n_catalog int, @username varchar(15)
AS
DELETE FROM Colecao_com_Vinil WHERE n_catalog=@n_catalog AND username=@username
--(depois de remover vinil em coleção, accionar trigger que decrementa nº items na tabela colecao) (feito)
go
exec Discografia.removeVinylintoCollection '1','bernardofalle'
Select * from Discografia.Colecao
----------------------
go
CREATE PROC Discografia.listUserCollection @username varchar(15)
AS
SELECT Utilizador.username,Colecao_com_Vinil.n_catalog,Vinil.vin_name FROM Utilizador 
JOIN Colecao_com_Vinil ON Utilizador.username=Colecao_com_Vinil.username
JOIN Vinil ON Colecao_com_Vinil.n_catalog=Vinil.n_catalog
WHERE Utilizador.username=@username;
go
exec Discografia.listUserCollection 'dvicente'
-----------------------------
--procurar vinil especifico e listar vinis por ano,genero,artista, nome de vinil,editora
---------------------------------------
go
CREATE PROC Discografia.searchVinyl @n_catalog int
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.n_catalog=@n_catalog;
go
exec Discografia.searchVinyl 55
--------------------------
go
CREATE PROC Discografia.listbyGenre @genre varchar(10)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.genre=@genre;
go
exec Discografia.listByGenre 'Metal'
--------------------------
go
CREATE PROC Discografia.listbyArtist @artist_name varchar(20)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.artist_name LIKE '%'+@artist_name+'%';
go
--------------------------
go
CREATE PROC Discografia.listbyName @vin_name varchar(20)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.vin_name LIKE '%'+@vin_name+'%';
go
--------------------------
go
CREATE PROC Discografia.listbyRecords @rec_id int
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.records_id=@rec_id;
go
exec Discografia.listByRecords 1
--------------------------
--Inserir,remover,comprar,listar anuncios
-----------------------
go
CREATE PROC Discografia.insertAd @username varchar(15), @n_catalog int, @price int
AS
INSERT INTO [Vendedor]([username]) VALUES(@username)
INSERT INTO [Anuncio](
			[price],
			[creation_date],
			[n_catalog],
			[sellers_username],
			[buyer_username]) VALUES (@price,GETDATE(),@n_catalog,@username,NULL);
			--quando o anuncio tiver comprador, dar update ao tuplo adicionando o username de comprador (feito)
			--accionar trigger que adicione o sellers_username a tabela de vendedores (feito)
go
exec Discografia.insertAd 'bernardofalle',55,99
----------------------------------
go
CREATE PROC Discografia.removeAd @id int
AS
DELETE FROM Anuncio WHERE ad_id=@id;
go
exec Discografia.removeAd 1
-----------------------------
go
CREATE PROC Discografia.buyAd @id int, @username varchar(15), @ratingComprador int, @ratingVendedor int --(rating do comprador e do vendedor)
AS
INSERT INTO [Comprador]([username]) VALUES(@username)
if (SELECT buyer_username FROM Discografia.Anuncio WHERE ad_id=@id) is NULL
BEGIN
UPDATE Discografia.Anuncio SET buyer_username=@username WHERE ad_id=@id;

UPDATE Discografia.Vendedor SET sellers_rating=(sellers_rating+@ratingVendedor)/2;	--updata o rating do vendedor
UPDATE Discografia.Comprador SET buyer_rating=(buyer_rating+@ratingComprador)/2;	--updata o rating do comprador
END
	--accionar trigger que adicione o buyer_username a tabela de compradores (feito)
go

exec Discografia.buyAd 3, 'dvicente', 2, 3 
-----------------------------
go
CREATE PROC Discografia.listAdbyCatalog @n_catalog int --listar anuncios de vinil com numero de catalogo
AS
SELECT * FROM Discografia.Anuncio WHERE n_catalog=@n_catalog AND buyer_username is NULL;
go

exec Discografia.listAdbyCatalog 55
-------------------------------
go
CREATE PROC Discografia.listAdByUser @username varchar(30) --listar anuncios de vinil com certo username
AS 
SELECT * FROM Discografia.Anuncio WHERE sellers_username=@username AND buyer_username is NULL;
go
exec Discografia.listAdByUser 'Yolanda'
----------------------------
go
CREATE PROC Discografia.listAdByPrice @price int --listar anuncios de vinil por preco
AS 
SELECT * FROM Discografia.Anuncio WHERE price <= @price AND buyer_username IS NULL ORDER BY price;
go

exec Discografia.listAdByPrice 47
-----------------------------
go
CREATE PROC Discografia.listAdByMusic @music varchar(20) --listar anuncios de vinil com certa musica
AS 
SELECT ad_id,price,Anuncio.n_catalog,sellers_username,vin_name FROM Discografia.Anuncio 
			JOIN Vinil ON Anuncio.n_catalog=Vinil.n_catalog 
			JOIN Musicas ON Vinil.n_catalog=Musicas.id_vinyl 
			WHERE songs_name LIKE '%'+@music+'%' AND buyer_username IS NULL;;
go

exec Discografia.listAdByMusic 'deja'

-------------------------
go
CREATE PROC Discografia.listAdByRating --listar anuncios por ordem de rating de vendedor
AS
SELECT ad_id,price,n_catalog,sellers_username,sellers_rating FROM Discografia.Anuncio	
		JOIN Vendedor ON Anuncio.sellers_username=Vendedor.username 
		WHERE buyer_username IS NULL ORDER BY sellers_rating DESC;
go

exec Discografia.listAdByRating 
-------------------------
--Dar rating a vinil, mudar rating, eliminar rating de vinil,
--listar vinis por rating
------------------------
go 
CREATE PROC Discografia.insertRating @username varchar(30), @rating int, @n_catalog int
AS
BEGIN
INSERT INTO [Rating](
			[n_catalog],
			[rating],
			[username]) VALUES (@n_catalog,@rating,@username);
END
go

exec Discografia.insertRating dvicente, 5, 775

-------------------------
go
CREATE PROC Discografia.updateRating @username varchar(15), @rating int, @n_catalog int
AS
UPDATE Discografia.Rating SET rating=@rating WHERE username=@username AND n_catalog=@n_catalog;
go

exec Discografia.updateRating dvicente, 4, 775
----------------------
go 
CREATE PROC Discografia.removeRating @username varchar(15), @n_catalog int
AS
DELETE FROM Discografia.Rating WHERE username=@username AND n_catalog=@n_catalog;
go

exec Discografia.removeRating dvicente, 775
---------------
go
CREATE PROC Discografia.listVinylByRating
AS
SELECT Vinil.n_catalog,vin_name,AVG(rating) FROM Vinil	
		JOIN Rating ON Vinil.n_catalog=Rating.n_catalog
		GROUP BY vin_name,Vinil.n_catalog ORDER BY AVG(rating) DESC;
go

exec Discografia.listVinylByRating

----------------
--Listar vinis de artistas que pertencem a bandas
---------------------------
go
CREATE PROC Discografia.listVinylByArtBand 
AS
SELECT Vinil.n_catalog,vin_name,Vinil.artist_name FROM Discografia.Vinil	
		JOIN Discografia.Artista ON Vinil.artist_name=Artista.name
		JOIN Discografia.Pessoa ON Artista.name=Pessoa.artist_name
		JOIN Discografia.Pertence ON Pessoa.artist_name=Pertence.artist_name;
		
go
exec Discografia.listVinylByArtBand 
----------------------------
--Listar vinis de artistas independentes
----------------------------
go 
CREATE PROC Discografia.listVinylIndependent
AS
SELECT Vinil.n_catalog,vin_name,Vinil.artist_name FROM Discografia.Vinil
		JOIN Artista ON Vinil.artist_name=Artista.name
		WHERE Artista.records_id IS NULL; 
go

drop proc Discografia.listVinylIndependent
exec Discografia.listVinylIndependent


--------------------------
--Lista de users que venderam mais vinis
-----------------------
go 
CREATE PROC Discografia.listMostSellers
AS
SELECT Utilizador.username,COUNT(*) FROM Discografia.Utilizador
	JOIN Vendedor ON Utilizador.username=Vendedor.username
	JOIN Anuncio ON Vendedor.username=Anuncio.sellers_username
	GROUP BY Utilizador.username ORDER BY COUNT(*) DESC
go

exec Discografia.listMostSellers
----------------------
--Artistas com mais Vinis
--------------------
go 
CREATE PROC Discografia.bestArtists
AS
SELECT artist_name,COUNT(*) AS Nr_Discos FROM Discografia.Vinil
		GROUP BY artist_name ORDER BY Nr_Discos DESC;
go

exec Discografia.bestArtists