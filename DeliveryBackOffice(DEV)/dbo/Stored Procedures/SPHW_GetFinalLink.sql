-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-03>
-- Description:	<Link de entregas - Obtener la información necesaria para notificación de rastreo de guía.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetFinalLink]
@IdDeliveryLink INT,
@IsInsurance BIT = 'FALSE',
@InsuranceAmount DECIMAL(14,2) = 0.00,
@CollectOnDelivery DECIMAL(14,2) = NULL, --Monto de COD
@Token NVARCHAR(50) = 'SYSTEM',
@SubscriptionId INT = NULL,
@PaymentType INT = 1,
@TypeService INT = 5,
@DeliveryFacCODId NVARCHAR(20) = '',
@OnlyInfo INT = 0
AS
BEGIN
BEGIN TRY

	SELECT
		  RU.UsrNickName AS 'SenderName'
		, DL.ReceiverName AS 'ReceiverName'
		, ISNULL(DL.GuideSerie,'') AS 'GuideSerie'
		, ISNULL(DL.GuideNumber,0) AS 'GuideNumber'
		, DL.ReceiverPhone AS 'ReceiverPhone'
		, DL.ReceiverEmail AS 'ReceiverEmail'
		, CC.CountryNameES AS 'Pais'
		, ISNULL(DL.NirPhone, (SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
			WHERE [Name] = 'AreaCode' AND IdCountry = ISNULL(S.IdCountry,'GT'))) AS 'AreaCode'
		, (SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK) 
			WHERE [Name] = 'PBX' AND IdCountry = ISNULL(S.IdCountry,'GT')) AS 'PBX'
	FROM DeliveryBackOffice.dbo.DeliveryLink DL WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)
		ON DL.ReceiverSettlementId = S.IdSettlement
	LEFT JOIN DeliveryBackOffice.dbo.CatCountry CC WITH(NOLOCK)
		ON (S.IdCountry = CC.IdCountry OR (S.IdCountry IS NULL AND CC.IdCountry  = 'GT'))
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA WITH(NOLOCK)
		ON DL.AccountId  = RBUBA.RuaIdAccount
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH(NOLOCK)
		ON RBUBA.RuaIdUser = RU.UsrIdUser
	WHERE DL.IdDeliveryLink = @IdDeliveryLink

	IF(@OnlyInfo = 0)
	BEGIN
		BEGIN TRANSACTION;

		--Actualizar delivery link
		UPDATE [DeliveryBackOffice].[dbo].[DeliveryLink]
		SET 
		   [IsInsurance] = @IsInsurance
		  ,[CatPaymentTypeId] = @PaymentType
		  ,[CatTypeServiceId] = @TypeService
		  ,[InsuranceAmount] = @InsuranceAmount
		  ,[CollectOnDelivery] = @CollectOnDelivery
		  ,[SubscriptionId] = @SubscriptionId
		  ,[DeliveryFacCODId] = IIF(@DeliveryFacCODId = '', [DeliveryFacCODId],CAST(@DeliveryFacCODId AS INT))
		  ,[UserUpdated] = @Token
		  ,[DateUpdated] = GETDATE()
		WHERE [IdDeliveryLink] = @IdDeliveryLink

		--Actualizar stock de productos
		IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.Product P
						INNER JOIN DeliveryBackOffice.dbo.DeliveryLinkProducts DLP
							ON P.IdProduct = DLP.ProductId
						WHERE DLP.DeliveryLinkId = @IdDeliveryLink AND (P.Stock - DLP.Quantity) < 0)
		BEGIN

			UPDATE P
			SET P.Stock = P.Stock - DLP.Quantity
			FROM DeliveryBackOffice.dbo.Product P
			INNER JOIN DeliveryBackOffice.dbo.DeliveryLinkProducts DLP
				ON P.IdProduct = DLP.ProductId
			WHERE DLP.DeliveryLinkId = @IdDeliveryLink

		END;
		ELSE
		BEGIN

			SELECT
				  P.IdProduct
				, P.Stock
				, DLP.Quantity
				, DLP.DeliveryLinkId
				, DLP.IdDeliveryLinkProducts
			FROM DeliveryBackOffice.dbo.Product P
			INNER JOIN DeliveryBackOffice.dbo.DeliveryLinkProducts DLP
				ON P.IdProduct = DLP.ProductId
			WHERE DLP.DeliveryLinkId = @IdDeliveryLink AND (P.Stock - DLP.Quantity) < 0

		END;

		COMMIT TRANSACTION;
	END;
	
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;