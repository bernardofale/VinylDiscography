
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
CREATE PROC insertUser @username varchar(15),@email varchar(18),@name varchar(20),@date TIMESTAMP
AS
BEGIN
INSERT INTO [Utilizador](
						[username],
						[email],
						[name],
						[register_date]) VALUES(@username,@email,@name,@date);
END
go
-------------------
go
CREATE PROC updateUser @username varchar(15),@email varchar(18),@name varchar(20),@date TIMESTAMP
AS
UPDATE Utilizador SET email=@email,name=@name,register_date=@date WHERE username=@username;
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