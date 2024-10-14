CREATE PROCEDURE [dbo].[SPHW_CreateDeliveryLink]
  @AccountId INT,
  @CodeOfReference INT,
  @ReceiverName NVARCHAR(200),
  @ReceiverPhone BIGINT,
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
		DECLARE @StatusId INT = (SELECT TOP 1 IdDeliveryLinkStatus FROM dbo.DeliveryLinkStatus WHERE Name = 'Enviado')
		DECLARE @cadena NVARCHAR(20) = CONVERT(NVARCHAR(20), @ReceiverPhone)

		INSERT INTO DeliveryBackOffice.dbo.DeliveryLink 
		(Token,AccountId,OriginCodeOfReference,ReceiverName,ReceiverPhone,ReceiverSettlementId,ReceiverEmail,CatPaymentTypeId,CatTypeServiceId,
		IsInsurance,InsuranceAmount,DeliveryFacCODId,CollectOnDelivery,DeliveryLinkStatusId,ExpirationDate,RowStatus,UserCreated,DateCreated,NirPhone)
		VALUES
		('',@AccountId,@CodeOfReference,@ReceiverName,SUBSTRING(@cadena, 4, LEN(@cadena) - 3),@ReceiverSettlementId,@ReceiverEmail,@CatPaymentTypeId,@CatTypeServiceId,
		@IsInsurance,@InsuranceAmount,@DeliveryFavCODId,@CollectOnDelivery,@StatusId,DATEADD(DAY, 1, GETDATE()),1,'SYSTEM',GETDATE(),CONCAT('+',LEFT(@cadena, 3)))

		DECLARE @DeliveryLinkID INT;
		DECLARE @hash VARBINARY(16); -- El tamaño del hash MD5 es de 16 bytes (128 bits)
		DECLARE @hashResultado VARCHAR(32); -- El hash MD5 en formato hexadecimal tiene 32 caracteres
		SET @DeliveryLinkID = @@IDENTITY;
		SET @hash = HASHBYTES('MD5', CONCAT(CAST(@DeliveryLinkID AS VARCHAR(50)), CAST(@AccountId AS VARCHAR(50))));
		SET @hashResultado = CONVERT(VARCHAR(32), @hash, 2); -- El hash MD5 en hexadecimal tiene 32 caracteres

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