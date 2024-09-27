CREATE PROCEDURE [dbo].[SPHW_CreateDeliveryLink]
  @AccountId INT,
  @CodeOfReference INT,
  @ReceiverName NVARCHAR(200),
  @ReceiverPhone INT,
  @ReceiverSettlementId INT,
  @ReceiverEmail NVARCHAR(100),
  @CatPaymentTypeId INT,
  @CatTypeServiceId INT,
  @IsInsurance BIT,
  @InsuranceAmount DECIMAL(14, 2),
  @DeliveryFavCODId INT,
  @CollectOnDelivery DECIMAL(14, 2)
AS 
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO DeliveryBackOffice.dbo.DeliveryLink 
		(Token,AccountId,OriginCodeOfReference,ReceiverName,ReceiverPhone,ReceiverSettlementId,ReceiverEmail,CatPaymentTypeId,CatTypeServiceId,
		IsInsurance,InsuranceAmount,DeliveryFacCODId,CollectOnDelivery,DeliveryLinkStatusId,ExpirationDate,RowStatus,UserCreated,DateCreated)
		VALUES
		('',@AccountId,@CodeOfReference,@ReceiverName,@ReceiverPhone,@ReceiverSettlementId,@ReceiverEmail,@CatPaymentTypeId,@CatTypeServiceId,
		@IsInsurance,@InsuranceAmount,@DeliveryFavCODId,@CollectOnDelivery,2,DATEADD(DAY, 1, GETDATE()),1,'SYSTEM',GETDATE())

		DECLARE @DeliveryLinkID INT;
		DECLARE @hash VARBINARY(32)
		DECLARE @hashResultado VARCHAR(64);
		SET @DeliveryLinkID = @@IDENTITY;
		SET @hash = HASHBYTES('SHA2_256', CONCAT(CAST(@DeliveryLinkID AS VARCHAR(50)),CAST(@AccountId AS VARCHAR(50))))
		SET @hashResultado = CONVERT(VARCHAR(64), @hash, 2)

		UPDATE DeliveryBackOffice.dbo.DeliveryLink
		SET Token = @hashResultado
		WHERE IdDeliveryLink = @DeliveryLinkID
		COMMIT TRANSACTION

		SELECT
		200 AS 'StatusCode',
		'Registro guardado correctamente' AS 'Description'

		SELECT
		@DeliveryLinkID AS 'IdDeliveryLink',
		@hashResultado AS 'Token',
		DATEADD(DAY, 1, GETDATE()) AS 'ExpirationDate',
		2 AS 'DeliveryLinkStatusId'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT
		400 AS 'StatusCode',
		'Error al registrar Link de Entrega' AS 'Description'
	END CATCH
END