

-- Stored Procedure

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_deliveryorders_cod]
	-- Add the parameters for the stored procedure here
		@Token AS VARCHAR(50)    = '078c6f38f79816bf9ad01d70181b3101', --Prod '078c6f38f79816bf9ad01d70181b3101'
		@Rol AS BIGINT 			 =   874,  --874 Prod
		@BeginDate AS VARCHAR(50) = '11/09/2020',
		@EndDate AS VARCHAR(50)  = '18/09/2020',
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdToken AS VARCHAR(50);
	DECLARE @IdRol AS BIGINT; 
	DECLARE @IdVisitPoint AS BIGINT;
	DECLARE @DateIni AS DATE;
	DECLARE @DateFin AS DATE;

	SET DATEFORMAT DMY;
	SET @IdToken = @Token;
	SET @IdRol =  @Rol;
	SET @DateIni = CONVERT(DATE, @BeginDate);
	SET @DateFin = CONVERT(DATE, @EndDate);

	DECLARE @StartDateTime AS DATETIME;
	DECLARE @EndDateTime AS DATETIME;
  

	SET @StartDateTime = CAST(@DateIni AS DATETIME) + '00:00:00'; -- Añadimos el tiempo para incluir toda la fecha del primer día
	SET @EndDateTime = CAST(@DateFin AS DATETIME) + '23:59:59';

	DECLARE @IdSystem AS INT 

	SELECT @IdSystem = ROL.LGN_IdSystem FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH(NOLOCK) WHERE ROL.LGN_IdRol = @IdRol
	
	
	IF (
		SELECT COUNT(logtoken.SSN_IdToken) SSN_IdToken
		FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH(NOLOCK)
		WHERE logtoken.SSN_IdToken = @IdToken 
		AND logtoken.SSN_IdSystem = @IdSystem 
		AND logtoken.SSN_TokenStatus = 1
	   ) > 0 
	BEGIN 

		IF (@GuideNumber = 0)
		BEGIN
			SELECT  
				CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				isnull(UPPER(serv.Sender_FirstName),'') + ' '+ isnull(UPPER(serv.Sender_LastName),'') [NameOfSender],
				isnull(UPPER(serv.Receiver_FirstName),'') + ' ' + isnull(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
				ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
				CONVERT(varchar,serv.DateCreated,103) [PickUpDateTime],
				CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
				ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId IN (5,22) ),103),'') AS	[RealDeliveryDate],
				serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
				so.OrderDescription AS [OrderStatus],
				serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
				IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
				Collect_OnDelivery [CollectOnDelivery],
				ISNULL(Guide_Collected, 'FALSE') [GuideCollected],
				ISNULL(serv.Deposit_Number,'') [DepositCOD],
				ISNULL(CONVERT(VARCHAR(10), paidguide.DateCreated, 103) + ' '  + convert(VARCHAR(8), GETDATE(), 14),'') [FechaPagoCOD],
				COALESCE(serv.PriceShippment,0) PriceShippment,
				COALESCE(batch.Amount,0) SettledAmountCOD,
				COALESCE(batch.Commission, 0) CommissionCOD,
				CAST(ROUND(((COALESCE(batch.Commission, 0))/(Collect_OnDelivery)*100), 0) AS INT) ComissionPercentCOD
			FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide WITH(NOLOCK)
				on paidguide.Guide_Serie = serv.Guide_Serie
				and paidguide.Guide_Number = serv.Guide_Number
				and paidguide.Deposit_Number = serv.Deposit_Number
				and paidguide.IdStatus = 'TRUE'
			LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
				ON serv.StatusOrderId = so.StatusOrderId
			LEFT JOIN DeliveryBackOffice.DBO.BatchDetailCOD batch WITH(NOLOCK)
				ON batch.GuideSerie = serv.Guide_Serie
				AND batch.GuideNumber = serv.Guide_Number
				AND batch.CatConceptCODId = 2
			LEFT JOIN DeliveryBackOffice.dbo.catCurrencyCOD ccCOD WITH(NOLOCK)
				ON ccCOD.IdCatCurrencyCOD = IIF(batch.CatCurrencyCODId IS NULL, 1, batch.CatCurrencyCODId)
			WHERE (serv.DateCreated BETWEEN  @StartDateTime AND @EndDateTime)
				AND serv.StatusOrderId <> 7 -- No guías anuladas
				AND serv.StatusOrderId <> 15 -- No guías generadas
				AND serv.Collect_OnDelivery > 0
		END
		ELSE
		BEGIN
			SELECT  
				CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				isnull(UPPER(serv.Sender_FirstName),'') + ' '+ isnull(UPPER(serv.Sender_LastName),'') [NameOfSender],
				isnull(UPPER(serv.Receiver_FirstName),'') + ' ' + isnull(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
				ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
				CONVERT(varchar,serv.DateCreated,103) [PickUpDateTime],
				CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
				ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId IN(5,22) ),103),'') AS	[RealDeliveryDate],
				serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
				so.OrderDescription AS [OrderStatus],
				serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
				IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
				Collect_OnDelivery [CollectOnDelivery],
				ISNULL(Guide_Collected, 'FALSE') [GuideCollected],
				ISNULL(serv.Deposit_Number,'') [DepositCOD],
				ISNULL(CONVERT(VARCHAR(10), paidguide.DateCreated, 103) + ' '  + convert(VARCHAR(8), GETDATE(), 14),'') [FechaPagoCOD],
				COALESCE(serv.PriceShippment,0) PriceShippment,
				COALESCE(batch.Amount,0) SettledAmountCOD,
				COALESCE(batch.Commission, 0) CommissionCOD,
				CAST(ROUND(((COALESCE(batch.Commission, 0))/(Collect_OnDelivery)*100), 0) AS INT) ComissionPercentCOD
			FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide WITH (NOLOCK)
				on paidguide.Guide_Serie = serv.Guide_Serie
				and paidguide.Guide_Number = serv.Guide_Number
				and paidguide.Deposit_Number = serv.Deposit_Number
				and paidguide.IdStatus = 'TRUE'
			LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
				ON serv.StatusOrderId = so.StatusOrderId
			LEFT JOIN DeliveryBackOffice.DBO.BatchDetailCOD batch WITH (NOLOCK)
				ON batch.GuideSerie = serv.Guide_Serie
				AND batch.GuideNumber = serv.Guide_Number
				AND batch.CatConceptCODId = 2
			LEFT JOIN DeliveryBackOffice.dbo.catCurrencyCOD ccCOD WITH (NOLOCK)
				ON ccCOD.IdCatCurrencyCOD = IIF(batch.CatCurrencyCODId IS NULL, 1, batch.CatCurrencyCODId)
			WHERE serv.Guide_Serie = @GuideSerie 
				AND serv.Guide_Number = @GuideNumber 
				AND serv.StatusOrderId <> 7 -- No guías anuladas
				AND serv.StatusOrderId <> 15 -- No guías generadas
				AND serv.Collect_OnDelivery > 0
		END
		
	END
	ELSE
	BEGIN
		SELECT   --NULL			    [Id],
				''					[NameOfSender],
				''					[NameOfReceiver], 
				''					[ReceiverName],
				''					[PickUpDateTime],
				''					[ScheduledDeliveryDate],
				''					[RealDeliveryDate],
				''					[GuideNumber],
				'INACTIVE TOKEN '	[OrderStatus],
				''					[ManifestNumber],
				''					[CollectOnDelivery],
				''					[GuideCollected],
				''					[DepositCOD],
				''					[FechaPagoCOD],
				-1					[PriceShippment]
	END 




END
