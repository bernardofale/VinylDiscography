
--------------------
--LISTAR,REMOVER,ADICIONAR,EDITAR USERS
--------------------
go
CREATE PROC removeUser @username varchar(15)
AS
DELETE FROM Utilizador WHERE username=@username;
go
--------------------
go
CREATE PROC insertUser @username varchar(15),@email varchar(18),@name varchar(20)
AS
BEGIN
INSERT INTO [Utilizador](
						[username],
						[email],
						[name]) VALUES(@username,@email,@name);
END
go
-------------------
go
CREATE PROC updateUser @username varchar(15),@email varchar(18),@name varchar(20)
AS
UPDATE Utilizador SET email=@email,name=@name WHERE username=@username;
go
-------------------
SELECT * FROM Utilizador;


---------------------------
--LISTAR,ADICIONAR,REMOVER VINIS
----------------------------
go
CREATE PROC removeVinyl @n_catalog int
AS
DELETE FROM Vinil WHERE n_catalog=@n_catalog;
--Cada vez que retirarmos um Vinil, accionar Trigger que remova tuplo na tabela de artista (feito)
go
-------------------
go
CREATE PROC insertVinyl @n_catalog int ,@release_year date,@country varchar(15),@genre varchar(20),@artist_name varchar(20),@vin_name varchar(20),@records_id int
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
-------------------------
SELECT * FROM Vinil;
SELECT COUNT(*) FROM Vinil --numero de vinis
--------------------


---------------------
--inserir e remover vinis da colecao do user, e lista-los
---------------------
go
CREATE PROC insertVinylintoCollection @n_catalog int, @username varchar(15)
AS
BEGIN
INSERT INTO [Colecao_com_Vinil](
					[n_catalog],
					[username]) VALUES (@n_catalog, @username);
--(depois de inserir vinil em coleção, accionar trigger que incrementa nº items na tabela colecao) (feito)
END
go
----------------------
go
CREATE PROC removeVinylintoCollection @n_catalog int, @username varchar(15)
AS
DELETE FROM Colecao_com_Vinil WHERE n_catalog=@n_catalog AND username=@username
--(depois de remover vinil em coleção, accionar trigger que decrementa nº items na tabela colecao) (feito)
go
----------------------
go
CREATE PROC listUserCollection @username varchar(15)
AS
SELECT Utilizador.username,Colecao_com_Vinil.n_catalog,Vinil.vin_name FROM Utilizador 
JOIN Colecao_com_Vinil ON Utilizador.username=Colecao_com_Vinil.username
JOIN Vinil ON Colecao_com_Vinil.n_catalog=Vinil.n_catalog
WHERE Utilizador.username=@username;
go
------------------------



----------------------
--listar artistas e editoras
---------------------
SELECT * FROM Artista;
-------------------
SELECT * FROM Editora;
----------------------


-----------------------------
--procurar vinil especifico e listar vinis por ano,genero,artista, nome de vinil,editora
---------------------------------------
go
CREATE PROC searchVinyl @n_catalog int
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.n_catalog=@n_catalog;
go
--------------------------
go
CREATE PROC listbyYear @year DATE
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.release_year=@year;
go
--------------------------
go
CREATE PROC listbyGenre @genre varchar(10)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.genre=@genre;
go
--------------------------
go
CREATE PROC listbyArtist @artist_name varchar(20)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.artist_name LIKE '%'+@artist_name+'%';
go
--------------------------
go
CREATE PROC listbyName @vin_name varchar(20)
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.vin_name LIKE '%'+@vin_name+'%';
go
--------------------------
go
CREATE PROC listbyRecords @rec_id int
AS
SELECT Vinil.n_catalog, Vinil.vin_name FROM Vinil
WHERE Vinil.records_id=@rec_id;
go
--------------------------


----------------------
--Trigger para Vinil
--------------------
go
CREATE TRIGGER insert_delete_Artist_Editora
ON Vinil
AFTER INSERT,DELETE
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT name FROM Artista WHERE name=(SELECT artist_name FROM inserted))
BEGIN
	INSERT INTO [Artista](name,records_id)
	SELECT artist_name,records_id FROM inserted;			
	--adiciona automaticamente na tabela de artistas o artista do vinil
END
else if NOT EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) AND EXISTS(SELECT name FROM Artista WHERE name=(SELECT artist_name FROM deleted)) AND (SELECT count(*) FROM Vinil WHERE artist_name=(SELECT artist_name FROM deleted))<2
	BEGIN
	DELETE FROM Artista WHERE name=(SELECT artist_name FROM deleted);
	--Remove automaticamente o artista quando e removido um vinil
	END
go
--------------------


------------------
--Trigger para Colecao_com_Vinil
------------------------
go
CREATE TRIGGER insert_delete_OnCollection
ON Colecao_com_Vinil
AFTER INSERT,DELETE 
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN
	UPDATE Colecao SET n_items=n_items+1 WHERE username=(SELECT username FROM inserted);
	--incremente a quantidade de items na colecao de um utilizador especifico aquando de um insert na tabela colecao com vinil
END
else if NOT EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	UPDATE Colecao SET n_items=n_items-1 WHERE username=(SELECT username FROM deleted);
	--decrementa a quantidade de items na colecao de um utilizador especifico aquando de um insert na tabela colecao com vinil
END
go

--------------------------
--Inserir,remover,comprar,listar anuncios
-----------------------
go
CREATE PROC insertAd @username varchar(15), @n_catalog int, @price int
AS
INSERT INTO [Anuncio](
			[price],
			[creation_date],
			[n_catalog],
			[sellers_username],
			[buyer_username]) VALUES (@price,GETDATE(),@n_catalog,@username,NULL);
			--quando o anuncio tiver comprador, dar update ao tuplo adicionando o username de comprador (feito)
			--accionar trigger que adicione o sellers_username a tabela de vendedores (feito)
go
----------------------------------
go
CREATE PROC removeAd @id int
AS
DELETE FROM Anuncio WHERE ad_id=@id;
go
-----------------------------
SELECT * FROM Anuncio WHERE buyer_username=NULL; --apenas lista aquelas que n\ao tem comprador
SELECT * FROM Anuncio Where buyer_username <> NULL; --lista os anuncios ja comprados
SELECT COUNT(*) FROM Anuncio; --numero de anuncios
--------------------------------
go
CREATE PROC buyAd @id int, @username varchar(15), @ratingComprador int, @ratingVendedor int --(rating do comprador e do vendedor)
AS
if (SELECT buyer_username FROM Anuncio) is NULL
BEGIN
UPDATE Anuncio SET buyer_username=@username WHERE ad_id=@id;

UPDATE Vendedor SET sellers_rating=(sellers_rating+@ratingVendedor)/2;	--updata o rating do vendedor
UPDATE Comprador SET buyer_rating=(buyer_rating+@ratingComprador)/2;	--updata o rating do comprador
END
	--accionar trigger que adicione o buyer_username a tabela de compradores (feito)
go
-----------------------------
go
CREATE PROC listAdbyCatalog @n_catalog int --listar anuncios de vinil com numero de catalogo
AS
SELECT * FROM Anuncio WHERE n_catalog=@n_catalog AND buyer_username=NULL;
go
-------------------------------
go
CREATE PROC listAdByUser @username varchar(15) --listar anuncios de vinil com certo username
AS 
SELECT * FROM Anuncio WHERE sellers_username=@username AND buyer_username=NULL;
go
----------------------------
go
CREATE PROC listAdByPrice @price int --listar anuncios de vinil por preco
AS 
SELECT * FROM Anuncio WHERE price <= @price AND buyer_username=NULL ORDER BY price;
go
-----------------------------
go
CREATE PROC listAdByMusic @music varchar(20) --listar anuncios de vinil com certa musica
AS 
SELECT ad_id,price,Anuncio.n_catalog,sellers_username,@music FROM Anuncio 
			JOIN Vinil ON Anuncio.n_catalog=Vinil.n_catalog 
			JOIN Musicas ON Vinil.n_catalog=Musicas.id_vinyl 
			WHERE songs_name=@music AND buyer_username=NULL;;
go
-------------------------
go
CREATE PROC listAdByRating --listar anuncios por ordem de rating de vendedor
AS
SELECT ad_id,price,n_catalog,sellers_username,sellers_rating FROM Anuncio	
		JOIN Vendedor ON Anuncio.sellers_username=Vendedor.username 
		WHERE buyer_username=NULL ORDER BY sellers_rating;
go
-------------------------------
--Triggers para Comprador e Vendedor
-----------------------------
go
CREATE TRIGGER buyUser
ON Anuncio
AFTER INSERT
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM Vendedor WHERE username=(SELECT sellers_username FROM inserted))
BEGIN
INSERT INTO [Vendedor](
			[username]) VALUES ((SELECT sellers_username FROM inserted))
END
go
----------------------
go
CREATE TRIGGER sellUser
ON Anuncio
AFTER UPDATE
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM Comprador WHERE username=(SELECT buyer_username FROM inserted))
BEGIN
INSERT INTO [Comprador](
			[username]) VALUES ((SELECT buyer_username FROM inserted))
END
go

-------------------------
--Dar rating a vinil, mudar rating, eliminar rating de vinil,
--listar vinis por rating
------------------------
go 
CREATE PROC insertRating @username varchar(15), @rating int, @n_catalog int
AS
BEGIN
INSERT INTO [Rating](
			[n_catalog],
			[rating],
			[username]) VALUES (@n_catalog,@rating,@username);
END
go
-------------------------
go
CREATE PROC updateRating @username varchar(15), @rating int, @n_catalog int
AS
UPDATE Rating SET rating=@rating WHERE username=@username AND n_catalog=@n_catalog;
go
----------------------
go 
CREATE PROC removeRating @username varchar(15), @n_catalog int
AS
DELETE FROM Rating WHERE username=@username AND n_catalog=@n_catalog;
go
---------------
go
CREATE PROC listVinylByRating
AS
SELECT Vinil.n_catalog,vin_name,AVG(rating) FROM Vinil	
		JOIN Rating ON Vinil.n_catalog=Rating.n_catalog
		GROUP BY vin_name,Vinil.n_catalog;
go
-----------------