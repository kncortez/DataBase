-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-23>
-- Description:	<Obtiene información de recargos por pago con Visa On Link>
-- =============================================
CREATE PROCEDURE [dbo].[GetSurchargeForVisaOnLink]
	-- Add the parameters for the stored procedure here
	@TblGuides TblGuides READONLY,
	@FindEmail BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	BEGIN TRY

		--Verificar si se realizó el precálculo
		 IF ( SELECT
		 COUNT(1)
			 FROM @TblGuides)
		 = (SELECT
				 COUNT(1)
			 FROM DeliveryOrderSurcharge dos
			 INNER JOIN @TblGuides tb
				 ON tb.Guide_Serie = dos.GuideSerie
				 AND tb.Guide_Number = dos.GuideNumber
			 WHERE dos.RowStatus = 1)
		 BEGIN
			--Verificar que sean del mismo cliente
			IF ( SELECT
					COUNT(1)
				FROM (SELECT
						IdCustomer
					FROM DeliveryOrder do WITH (NOLOCK)
					INNER JOIN @TblGuides tg
						ON tg.Guide_Serie = do.Guide_Serie 
						AND tg.Guide_Number = do.Guide_Number
					GROUP BY do.IdCustomer) sub)
			= 1
			BEGIN
				SELECT
					1 'ResponseCode'
					,'Generación exitosa' 'Description'

				SELECT
					dos.GuideSerie
				   ,dos.GuideNumber
				   ,(dos.GuideSurchargedShipment + dos.GuideSurchargedCollectOnDelivery) GuidePrice
				FROM DeliveryOrderSurcharge dos
				INNER JOIN @TblGuides tb
					ON tb.Guide_Serie = dos.GuideSerie
						AND tb.Guide_Number = dos.GuideNumber
				WHERE dos.RowStatus = 1

				IF @FindEmail = 1
				BEGIN
					SELECT TOP 1
						ISNULL(CASE
							WHEN do.VisitpointClientPortfolioId IS NOT NULL THEN (SELECT
										Email
									FROM VisitPointByClientPortfolio
									WHERE IdVisitPointByClientPortfolio = do.VisitpointClientPortfolioId)
							WHEN do.Sender_Mail IS NOT NULL THEN do.Sender_Mail
							WHEN do.IdCustomer IS NOT NULL THEN (SELECT
										REPLACE(REPLACE(RegexEmail, '^', ''), '$', '')
									FROM Customer
									WHERE IdCustomer = do.IdCustomer)
							WHEN do.Sender_ID IS NOT NULL THEN (SELECT Email FROM VisitPointClient WHERE CodeOfReference = do.Sender_ID)
							ELSE ''
						END, '') Email
					FROM DeliveryOrder do WITH (NOLOCK)
					INNER JOIN @TblGuides tb
						ON tb.Guide_Serie = do.Guide_Serie
							AND tb.Guide_Number = do.Guide_Number
				END

				IF @@TRANCOUNT > 0
					COMMIT TRANSACTION
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					3 'ResponseCode'
				   ,'Las guías no pertenecen al mismo cliente' 'Description'
				END
		 END
		 ELSE 
		 BEGIN 
			ROLLBACK TRANSACTION

			SELECT
				2 'ResponseCode'
			   ,'Los recargos no han sido cálculados.' 'Description'
		 END
	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT
			0 'ResponseCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';

		
	END CATCH
END