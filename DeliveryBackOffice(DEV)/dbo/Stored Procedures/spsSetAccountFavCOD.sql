




-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-27>
-- Description:	<Registrar favoritos >
-- =============================================
-- Author:		<Recinos, Aylinne>
-- Create date: <2024-11-27>
-- Description:	<Modificación en bandera IsDefault >
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
	 @TokenUpdate varchar(30) = null,
	@Status int = 1,
	@IsDefault BIT = 0,
    @PhoneNumber AS INT=null,
    @NIT AS nvarchar(15)=null,
	@FlagInstantDeposits AS bit=null,
	@FlagApprovalofCODPaymentsWithTC as bit=null


AS
BEGIN
Declare @Filter varchar(50) = null;
declare @idAccount int = null;

set @Filter = (select TOP 1 AliasFavCOD from DeliveryBackOffice.dbo.DeliveryFavCOD where AliasFavCOD = @Alias and IdAccountFavCOD = @IdAcount  )
set @idAccount = ( select TOP 1 IdAccountFavCOD from DeliveryBackOffice.dbo.DeliveryFavCOD where IdAccountFavCOD = @IdAcount)

IF(@Id is null or @Id = 0)
BEGIN
	INSERT INTO DeliveryBackOffice.dbo.DeliveryFavCOD (AliasFavCOD, NameAccountFavCOD, TypeAccountFavCOD, DocumentIdFavCOD, StatusFavCOD, IdAccountFavCOD,TokenCreated, DateCreated, TokenUpdate, DateUpdate ,IdBank, NumberAccFavCOD, IsDefault)
	VALUES (@Alias, @NameAccount, @TypeAccount, @DocID, 1,@IdAcount, @Token,GETDATE(), NULL, NULL, @IdBank, @NumberAcc, @IsDefault)
	
	SELECT  'Se ha guardado correctamente sus registros' as Response 
END

IF( @Id is not null )
BEGIN 

	if (@Status =1) -- estado activo
		begin
			UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD
			SET  AliasFavCOD = @Alias , NameAccountFavCOD = @NameAccount, TypeAccountFavCOD = @TypeAccount, DocumentIdFavCOD = @DocID, StatusFavCOD = 1, IdAccountFavCOD = @IdAcount, TokenUpdate = @Token, DateUpdate = GETDATE(), IdBank = @IDBank, NumberAccFavCOD = @NumberAcc, IsDefault = @IsDefault 
			WHERE IdDeliveryFavCOD = @Id
			SELECT  'Se ha actualizado actualizado sus registros' as Response
		end
	else 
		begin
			UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD set StatusFavCOD = @Status
			WHERE IdDeliveryFavCOD = @Id
			SELECT  'Registro eliminado' as Response
		end
	

END

END


