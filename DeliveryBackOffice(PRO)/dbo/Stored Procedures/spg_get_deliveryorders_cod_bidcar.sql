-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_deliveryorders_cod_bidcar]
	-- Add the parameters for the stored procedure here
		@Token AS VARCHAR(50)    = '078c6f38f79816bf9ad01d70181b3101', --Prod '078c6f38f79816bf9ad01d70181b3101'
		@Rol AS BIGINT 			 =   874,  --874 Prod
		@VisitPointID AS BIGINT = -1, --146290,
		@BeginDate AS VARCHAR(50) = '11/09/2020',
		@EndDate AS VARCHAR(50)  = '18/09/2020',
		@IdDateOfType AS INT = 1  --1 PickUp 2 Delivery
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdToken AS VARCHAR(50);
	DECLARE @IdRol AS BIGINT; 
	--DECLARE @IdModule AS INT;
	--DECLARE @IdCountry AS VARCHAR(3);
	DECLARE @IdVisitPoint AS BIGINT;
	DECLARE @DateIni AS VARCHAR(50);
	DECLARE @DateFin AS VARCHAR(50);
	DECLARE @IdDateType AS INT;

	SET @IdToken = @Token;
	SET @IdRol =  @Rol;
	--SET @IdModule = @Module;
	--SET @IdCountry = @Country;
	SET @IdVisitPoint = @VisitPointID;
	SET @DateIni = @BeginDate;
	SET @DateFin = @EndDate;
	SET @IdDateType =  @IdDateOfType;

	SET DATEFORMAT dmy;

	--SET @IdCountry = UPPER(@IdCountry)

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

		SELECT  
			--serv.Ticket_Number [Id],
			CAST(serv.Sender_ID AS VARCHAR) + ' ' + 
			isnull(UPPER(serv.Sender_FirstName),'') + ' '+ isnull(UPPER(serv.Sender_LastName),'') [NameOfSender],

			--CAST(serv.Receiver_ID AS VARCHAR) + ' ' + 
			--CAST(serv.Receiver_SocialSecurity_ID AS VARCHAR) + ' ' +
			isnull(UPPER(serv.Receiver_FirstName),'') + ' ' + isnull(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
			ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
			CONVERT(varchar,serv.Preparation_Date,103) [PickUpDateTime],
			CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
			ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
			serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
			--serv.OrderStatus [OrderStatus]
			(SELECT so.OrderDescription FROM DeliveryBackOffice.dbo.StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) AS [OrderStatus],
			serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
			Collect_OnDelivery [CollectOnDelivery],
			ISNULL(Guide_Collected, 'FALSE') [GuideCollected],
			ISNULL(serv.Deposit_Number,'') [DepositCOD],
			ISNULL(CONVERT(VARCHAR(10), paidguide.DateCreated, 103) + ' '  + convert(VARCHAR(8), GETDATE(), 14),'') [FechaPagoCOD],
			COALESCE(serv.PriceShippment,0) PriceShippment
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'
		WHERE (@IdVisitPoint = -1 or vpclient.VisitPointId = @IdVisitPoint)
		AND ((CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		OR (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2)) --Delivery
		--AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		--AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
		AND serv.StatusOrderId <> 7
		AND serv.StatusOrderId <> 15 -- No guías generadas

		AND serv.Collect_OnDelivery > 0
		
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
