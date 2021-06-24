--Trigger para User
-------------------
go
CREATE TRIGGER Discografia.insertUserOnCollection
ON Discografia.Utilizador
AFTER INSERT,DELETE
AS
if EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN

	INSERT INTO [Colecao](username)
	SELECT username FROM inserted;			
	--adiciona automaticamente na tabela da colecao o user
END
else if NOT EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
	DELETE FROM Discografia.Colecao WHERE username=(SELECT username FROM deleted);
	--Remove automaticamente o user quando ]e removido
	END
go


----------------------
--Trigger para Vinil
--------------------
go
CREATE TRIGGER Discografia.insert_delete_Artist_Editora
ON Discografia.Vinil
AFTER INSERT,DELETE
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT name FROM Discografia.Artista WHERE name=(SELECT artist_name FROM inserted))
BEGIN

	INSERT INTO [Artista](name,records_id)
	SELECT artist_name,records_id FROM inserted;			
	--adiciona automaticamente na tabela de artistas o artista do vinil
END
else if NOT EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) AND EXISTS(SELECT name FROM Discografia.Artista WHERE name=(SELECT artist_name FROM deleted)) AND (SELECT count(*) FROM Discografia.Vinil WHERE artist_name=(SELECT artist_name FROM deleted))<2
	BEGIN
	DELETE FROM Discografia.Artista WHERE name=(SELECT artist_name FROM deleted);
	--Remove automaticamente o artista quando e removido um vinil
	DELETE FROM Discografia.Pessoa WHERE artist_name=(SELECT artist_name FROM deleted);
	DELETE FROM Discografia.Grupo WHERE band_name=(SELECT artist_name FROM deleted);
	END
go
--------------------


------------------
--Trigger para Colecao_com_Vinil
------------------------
go
CREATE TRIGGER Discografia.insert_delete_OnCollection
ON Discografia.Colecao_com_Vinil
AFTER INSERT,DELETE 
AS

if EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN
	UPDATE Discografia.Colecao SET n_items=n_items+1 WHERE username=(SELECT username FROM inserted);
	--incremente a quantidade de items na colecao de um utilizador especifico aquando de um insert na tabela colecao com vinil
END
else if NOT EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	UPDATE Discografia.Colecao SET n_items=n_items-1 WHERE username=(SELECT username FROM deleted);
	--decrementa a quantidade de items na colecao de um utilizador especifico aquando de um insert na tabela colecao com vinil
END
go
----------------------

