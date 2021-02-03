USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spsSetAccountFavCOD]    Script Date: 27/01/2021 19:17:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-27>
-- Description:	<Registrar favoritos >
-- =============================================
CREATE PROCEDURE [dbo].[spsSetAccountFavCOD]
	
	@Id int = null,
	@Alias VARCHAR(50),
	@IDBank int,
	@NameAccount NVARCHAR(30),
	 @TypeAccount varchar(30),
	 @DocID varchar(30),
	 @IdAcount int,
	 @Token  varchar (30) = null,
	 @NumberAcc varchar(30),
	 @TokenUpdate varchar(30) = null


AS
BEGIN
Declare @Filter varchar(50) = null;
declare @idAccount int = null;

set @Filter = (select TOP 1 AliasFavCOD from DeliveryBackOffice.dbo.DeliveryFavCOD where AliasFavCOD = @Alias and IdAccountFavCOD = @IdAcount  )
set @idAccount = ( select TOP 1 IdAccountFavCOD from DeliveryBackOffice.dbo.DeliveryFavCOD where IdAccountFavCOD = @IdAcount)

IF(@Id is null or @Id = 0)
BEGIN
	INSERT INTO DeliveryBackOffice.dbo.DeliveryFavCOD (AliasFavCOD, NameAccountFavCOD, TypeAccountFavCOD, DocumentIdFavCOD, StatusFavCOD, IdAccountFavCOD,TokenCreated, DateCreated, TokenUpdate, DateUpdate ,IdBank, NumberAccFavCOD)
	VALUES (@Alias, @NameAccount, @TypeAccount, @DocID, 1,@IdAcount, @Token,GETDATE(), NULL, NULL, @IdBank, @NumberAcc)
	
	SELECT  'Se ha guardado correctamente sus registros' as Response 
END

IF(@Filter = @Alias and @Id is not null )
BEGIN 

	UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD
	SET  NameAccountFavCOD = @NameAccount, TypeAccountFavCOD = @TypeAccount, DocumentIdFavCOD = @DocID, StatusFavCOD = 1, IdAccountFavCOD = @IdAcount, TokenCreated = @TokenUpdate, DateUpdate = GETDATE(), IdBank = @IDBank, NumberAccFavCOD = @NumberAcc 
	WHERE IdDeliveryFavCOD = @Id

	SELECT  'Se ha actualizado actualizado sus registros' as Response

END

END
GO


