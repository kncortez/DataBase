-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_delivery_orders_track]
	-- Add the parameters for the stored procedure here
		@CodApp as nvarchar(50)		 =  'SIFDCECOM300720201459',
		@MerchantId	 AS BIGINT       ,
		@CodeOfReference as int      = 10024,
		@BeginDate AS VARCHAR(50)	 = '01/07/2020',
		@EndDate AS VARCHAR(50)		 = '02/11/2020',
		@IdDateOfType AS INT		 = 1  --1 PickUp 2 Delivery
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DateIni AS VARCHAR(50);
	DECLARE @DateFin AS VARCHAR(50);
	DECLARE @IdDateType AS INT;

	SET @DateIni = @BeginDate;
	SET @DateFin = @EndDate;
	SET @IdDateType =  @IdDateOfType;

	SET DATEFORMAT dmy;

    -- Insert statements for procedure here
	

	IF (
			select COUNT(ecom.IdEcommerce) from DeliveryBackOffice.dbo.Ecommerce ecom
			where (   ecom.UserKey = @CodApp  --'SIFDCECOM300720201459'
					  or ecom.IdCustomer = @MerchantId
				  )
			and ecom.EcommerceStatus  = 'TRUE'
	   ) > 0 
	BEGIN 

		SELECT  
			--serv.Ticket_Number [Id],
			CAST(serv.Sender_ID AS VARCHAR) + ' ' + 
			UPPER(serv.Sender_FirstName) + ' '+ UPPER(serv.Sender_LastName) [NameOfSender],
			--CAST(serv.Receiver_ID AS VARCHAR) + ' ' + 
			--CAST(serv.Receiver_SocialSecurity_ID AS VARCHAR) + ' ' +
			UPPER(serv.Receiver_FirstName) + ' ' + UPPER(serv.Receiver_LastName) [NameOfReceiver],
			ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
			CONVERT(varchar,serv.Preparation_Date,103) [PickUpDateTime],
			CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
			ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
			serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
			--serv.OrderStatus [OrderStatus]
			(SELECT so.OrderDescription FROM DeliveryBackOffice.dbo.StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) AS OrderStatus,
			serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber]
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference
		WHERE (@CodeOfReference = -1 or serv.Sender_ID  = @CodeOfReference)
		--and vpclient.IdKindOfVPClient = 1 --CORPORATIVO
		and vpclient.CustomerID = @MerchantId
		AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
		AND serv.StatusOrderId <> 7 --anulada
		AND serv.StatusOrderId <> 15 -- No guías generadas

	END
	
	ELSE
	BEGIN
		SELECT   --NULL			    [Id],
				NULL				[NameOfSender],
				''					[NameOfReceiver], 
				''					[ReceiverName],
				''					[PickUpDateTime],
				''					[ScheduledDeliveryDate],
				''					[RealDeliveryDate],
				''					[GuideNumber],
				'INACTIVE TOKEN '	[OrderStatus],
				''					[ManifestNumber]
	END 

END
