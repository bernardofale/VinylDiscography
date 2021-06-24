----------------------
--UDFS
------------------------
---getSellerUDF
-------------------------
go
CREATE FUNCTION Discografia.getSeller(@AD_ID int)
returns VARCHAR(30)
AS
BEGIN
DECLARE @seller VARCHAR(30)
			SET @seller = (Select sellers_username 
			from Discografia.Anuncio
			where ad_id = @AD_ID)
			RETURN @seller;
END
go

-----------------------
-----getBuyerUDF
----------------------
go
CREATE FUNCTION Discografia.getBuyer(@AD_ID int)
returns VARCHAR(30)
AS
BEGIN
DECLARE @buyer VARCHAR(15)
			SET @buyer = (Select buyer_username 
			from Anuncio
			where ad_id = @AD_ID)
			RETURN @buyer;
END
go
-----------------------
----getUsernameUDF
-------------------
go
CREATE FUNCTION Discografia.getUser(@email varchar(18))
returns VARCHAR(30)
AS
BEGIN
DECLARE @username VARCHAR(15)
			SET @username = (Select username
			from Utilizador
			where email = @email)
			RETURN @username;
END
go

------------------------
----getAdsUDF
---------------------
go
CREATE FUNCTION Discografia.getAds()
returns table
AS

	return (SELECT * FROM Anuncio WHERE buyer_username is NULL);
go
select * from Discografia.getAds();
-----------------------
---AdsHistoryUDF
--------------------
go
CREATE FUNCTION Discografia.AdsHistory(@user varchar(30))
returns table
AS

	return (SELECT * FROM Anuncio WHERE buyer_username=@user);
go
select * from Discografia.AdsHistory('Yen')
---------------------------
--avgRatingofVinylUDF
---------------------
go
CREATE FUNCTION Discografia.avgRatingOfVinyl(@vinyl_id int)
returns decimal
AS
BEGIN
	DECLARE @avgRat decimal
	SELECT @avgRat=round(avg(cast(rating AS decimal)),1)
	FROM Vinil JOIN Rating ON Vinil.n_catalog=Rating.n_catalog
	WHERE Vinil.n_catalog=@vinyl_id;

	return @avgRat
END
go
-------------------------------