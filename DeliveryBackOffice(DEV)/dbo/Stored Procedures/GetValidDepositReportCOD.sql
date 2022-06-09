--EXEC GetValidDepositReportCOD 0,5,'a58796600@gmail.com'
-- =============================================
-- Author:		<Marco Jiménez>
-- Create date: <2022-03-25>
-- Description:	<Validar si se tienen Guias por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[GetValidDepositReportCOD]
-- Add the parameters for the stored procedure here
@IdCustomer INT = -1,
@IdBank INT = -1,
@SenderEmail VARCHAR(MAX) = '0'
AS
BEGIN
	DECLARE @COUNT1 INT = 0;
	DECLARE @COUNT2 INT = 0;

	IF (@IdCustomer != 0)
	BEGIN
		PRINT 'OPCION 1'
		SELECT
			@COUNT1 = COUNT(1)
		FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
		INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
			ON btd.[GuideSerie] = pg.[GuideSerie]
				AND btd.[GuideNumber] = pg.[GuideNumber]
		INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
			ON btd.[GuideSerie] = do.[Guide_Serie]
				AND btd.[GuideNumber] = do.[Guide_Number]
		LEFT JOIN dbo.Township twn WITH (NOLOCK)
			ON twn.IdTownship = do.ReceiverIdTownship
		LEFT JOIN dbo.Township tw WITH (NOLOCK)
			ON tw.TownshipName = do.Receiver_Town
		LEFT JOIN dbo.Province prv WITH (NOLOCK)
			ON prv.IdProvince = twn.IdProvince
		LEFT JOIN dbo.Province pr WITH (NOLOCK)
			ON pr.IdProvince = tw.IdProvince
		LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
			ON vpc.CodeOfReference = do.Sender_ID
		LEFT JOIN dbo.Customer cu WITH (NOLOCK)
			ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
		LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
			ON dc.DCBA_ID = do.DCBA_ID
		LEFT JOIN dbo.DeliveryBank bk WITH (NOLOCK)
			ON bk.Id_bank = dc.DCBA_Bank_Id
		WHERE pg.[Notificated] = 0
		AND btd.[AuthorizationNumber] IS NOT NULL
		AND pg.BatchCODId IS NOT NULL
		AND cu.IdCustomer = @IdCustomer
		AND btd.BankId = @IdBank

	END
	ELSE
	IF (@SenderEmail != '0')
	BEGIN
		PRINT 'OPCION 2'
		SELECT
			@COUNT2 = COUNT(1)
		FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
		INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
			ON btd.[GuideSerie] = pg.[GuideSerie]
				AND btd.[GuideNumber] = pg.[GuideNumber]
		INNER JOIN [dbo].[DeliveryOrder] AS do
			ON btd.[GuideSerie] = do.[Guide_Serie]
				AND btd.[GuideNumber] = do.[Guide_Number]
		LEFT JOIN dbo.Township twn
			ON twn.IdTownship = do.ReceiverIdTownship
		LEFT JOIN dbo.Township tw
			ON tw.TownshipName = do.Receiver_Town
		LEFT JOIN dbo.Province prv
			ON prv.IdProvince = twn.IdProvince
		LEFT JOIN dbo.Province pr
			ON pr.IdProvince = tw.IdProvince
		LEFT JOIN dbo.VisitPointClient vpc
			ON vpc.CodeOfReference = do.Sender_ID
		LEFT JOIN dbo.Customer cu
			ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
		LEFT JOIN dbo.DeliveryCustomerBankAccount dc
			ON dc.DCBA_ID = do.DCBA_ID
		LEFT JOIN dbo.DeliveryBank bk
			ON bk.Id_bank = dc.DCBA_Bank_Id
		WHERE pg.[Notificated] = 0
		AND btd.[AuthorizationNumber] IS NOT NULL
		AND pg.BatchCODId IS NOT NULL
		AND LTRIM(RTRIM(do.Sender_Mail)) = @SenderEmail
		AND btd.BankId = @IdBank
	END

	SELECT @COUNT1 + @COUNT2 AS	RESPONSE

END;