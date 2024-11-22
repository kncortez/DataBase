
-- =============================================
-- Author:		<Marco,Jiménez>
-- Create date: <2021-09-28>
-- Description:	<Se actualiza el flag Notificated en la tabla ProccessGuideCOD para indicar que ya se envió el correo>
-- =============================================

CREATE PROCEDURE [dbo].[SetNotificatedDepositReportCOD]
    @IdCustomer INT,
    @IdBank INT,
	@SenderEmail VARCHAR(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY

	IF(ISNULL(@IdCustomer,0) <> 0)
	BEGIN
		 	UPDATE pg

			SET pg.[Notificated] = 1
			FROM [dbo].[ProcessedGuideCOD] pg WITH(NOLOCK)
			INNER JOIN (
					SELECT cu.[IdCustomer] IdCliente, 
					   CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber               
					FROM [dbo].[BatchDetailCOD] AS btd			WITH(NOLOCK)
					INNER JOIN [dbo].[ProcessedGuideCOD] AS pg  WITH(NOLOCK)
						ON btd.[GuideSerie] = pg.[GuideSerie]
						   AND btd.[GuideNumber] = pg.[GuideNumber]
					INNER JOIN [dbo].[DeliveryOrder] AS do		WITH(NOLOCK)
						ON btd.[GuideSerie] = do.[Guide_Serie]
						   AND btd.[GuideNumber] = do.[Guide_Number]
					LEFT JOIN dbo.Township twn					WITH(NOLOCK)
						ON twn.IdTownship = do.ReceiverIdTownship
					LEFT JOIN dbo.Township tw					WITH(NOLOCK)
						ON tw.TownshipName = do.Receiver_Town
					LEFT JOIN dbo.Province prv					WITH(NOLOCK)
						ON prv.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Province pr					WITH(NOLOCK)
						ON pr.IdProvince = tw.IdProvince
					LEFT JOIN dbo.VisitPointClient vpc			WITH(NOLOCK)
						ON vpc.CodeOfReference = do.Sender_ID
					LEFT JOIN dbo.Customer cu					WITH(NOLOCK)
						ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
					LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH(NOLOCK)
						ON dc.DCBA_Id = do.DCBA_ID
					LEFT JOIN dbo.DeliveryBank bk				WITH(NOLOCK)
						ON bk.Id_bank = dc.DCBA_Bank_Id
				WHERE pg.[Notificated] = 0					
					AND pg.BatchCODId IS NOT NULL
					AND pg.IsCompleted = 1
					AND btd.[AuthorizationNumber] IS NOT NULL					
					AND btd.BankId = @IdBank
					AND cu.IdCustomer = @IdCustomer
				GROUP BY btd.[GuideSerie], btd.GuideNumber, cu.IdCustomer
			)x 
			ON  CONCAT(pg.GuideSerie, pg.GuideNumber) = x.GuideNumber
			WHERE pg.[Notificated] = 0
				AND pg.IsCompleted = 1
				AND  x.IdCliente = @IdCustomer
	END
	ELSE
	BEGIN

		 	UPDATE pg
			SET pg.[Notificated] = 1
			FROM [dbo].[ProcessedGuideCOD] pg
			INNER JOIN (
					SELECT cu.[IdCustomer] IdCliente,   			 
							DO.Sender_Mail,
							CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber               
					FROM [dbo].[BatchDetailCOD] AS btd			WITH(NOLOCK)
					INNER JOIN [dbo].[ProcessedGuideCOD] AS pg	WITH(NOLOCK)
						ON btd.[GuideSerie] = pg.[GuideSerie]
						   AND btd.[GuideNumber] = pg.[GuideNumber]
					INNER JOIN [dbo].[DeliveryOrder] AS do		WITH(NOLOCK)
						ON btd.[GuideSerie] = do.[Guide_Serie]
						   AND btd.[GuideNumber] = do.[Guide_Number]
					LEFT JOIN dbo.Township twn					WITH(NOLOCK)
						ON twn.IdTownship = do.ReceiverIdTownship
					LEFT JOIN dbo.Township tw					WITH(NOLOCK)
						ON tw.TownshipName = do.Receiver_Town
					LEFT JOIN dbo.Province prv					WITH(NOLOCK)
						ON prv.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Province pr					WITH(NOLOCK)
						ON pr.IdProvince = tw.IdProvince
					LEFT JOIN dbo.VisitPointClient vpc			WITH(NOLOCK)
						ON vpc.CodeOfReference = do.Sender_ID
					LEFT JOIN dbo.Customer cu					WITH(NOLOCK)
						ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
					LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH(NOLOCK)
						ON dc.DCBA_Id = do.DCBA_ID
					LEFT JOIN dbo.DeliveryBank bk				WITH(NOLOCK)
						ON bk.Id_bank = dc.DCBA_Bank_Id
				WHERE pg.[Notificated] = 0
					AND pg.BatchCODId IS NOT NULL
					and pg.IsCompleted = 1
					AND btd.[AuthorizationNumber] IS NOT NULL
					AND btd.BankId = @IdBank
					AND do.Sender_Mail = @SenderEmail					
				GROUP BY btd.[GuideSerie],btd.GuideNumber, cu.IdCustomer,DO.Sender_Mail
			)x 
			ON  CONCAT(pg.GuideSerie, pg.GuideNumber) = x.GuideNumber
			WHERE pg.[Notificated] = 0
				AND pg.IsCompleted = 1
				AND x.Sender_Mail = @SenderEmail
			  
	END	
	
	END TRY
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			SELECT			  
				1 AS 'StatusCode',
				'Flag [Notificated] = 1 , registrado correctamente' AS 'Description', 
				1 AS 'NumTransferID'
			COMMIT TRANSACTION
	END
	ELSE
	BEGIN						
			SELECT 
				-1 AS 'StatusCode',
				'Error al actualizar registros' AS 'Description', 
				-1 AS 'NumTransferID'
						
			ROLLBACK TRANSACTION
	END

	 SET NOCOUNT OFF
END