
-- Stored Procedure

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
CREATE PROCEDURE [dbo].[spw_get_geliveryorders_track_tmp]
	-- Add the parameters for the stored procedure here
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1864,
		--@Module AS INT			 =  550,
		--@Country AS VARCHAR(3)	 = 'ALL',
		--@VisitPointID AS BIGINT = 146290,
		@BeginDate AS VARCHAR(50) = '11/05/2020',
		@EndDate AS VARCHAR(50)  = '12/05/2020',
		@IdDateOfType AS INT = 1,  --1 PickUp 2 Delivery
		@IdCustomer as int = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdToken AS VARCHAR(50);
	DECLARE @IdRol AS BIGINT; 
	--DECLARE @IdModule AS INT;
	--DECLARE @IdCountry AS VARCHAR(3);
	--DECLARE @IdVisitPoint AS BIGINT;
	DECLARE @DateIni AS VARCHAR(50);
	DECLARE @DateFin AS VARCHAR(50);
	DECLARE @IdDateType AS INT;
	DECLARE @CustomerId as int;

	SET @IdToken = @Token;
	SET @IdRol =  @Rol;
	--SET @IdModule = @Module;
	--SET @IdCountry = @Country;
	--SET @IdVisitPoint = @VisitPointID;
	SET @DateIni = @BeginDate;
	SET @DateFin = @EndDate;
	SET @IdDateType =  @IdDateOfType;
	set @CustomerId = @IdCustomer;
	SET DATEFORMAT dmy;

	--SET @IdCountry = UPPER(@IdCountry)

	DECLARE @IdSystem AS INT 

	SELECT @IdSystem = ROL.LGN_IdSystem FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH(NOLOCK) WHERE ROL.LGN_IdRol = @IdRol

	IF (
		SELECT COUNT(logtoken.SSN_IdToken) SSN_IdToken
		FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH(NOLOCK)
		WHERE logtoken.SSN_IdToken = @IdToken AND logtoken.SSN_IdSystem = @IdSystem 
		AND logtoken.SSN_TokenStatus = 1
	   ) >0 
	BEGIN 

	    if (@CustomerId = -1)
		BEGIN
		    	SELECT  
		    	--serv.Ticket_Number [Id],
		    	CAST(serv.Sender_ID AS VARCHAR) + ' ' + 
		    	ISNULL(UPPER(serv.Sender_FirstName),'') + ' '+ ISNULL(UPPER(serv.Sender_LastName),'') [NameOfSender],
		    
		    	--CAST(serv.Receiver_ID AS VARCHAR) + ' ' + 
		    	--CAST(serv.Receiver_SocialSecurity_ID AS VARCHAR) + ' ' +
		    	ISNULL(UPPER(serv.Receiver_FirstName),'') + ' ' + ISNULL(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
		    	ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
		    	CONVERT(varchar,serv.Preparation_Date,103) [PickUpDateTime],
		    	CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
		    	ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
		    	serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
		    	--serv.OrderStatus [OrderStatus]
		    	(SELECT so.OrderDescription FROM DeliveryBackOffice.dbo.StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) AS OrderStatus,
		    	serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
		    	ISNULL(serv.Receiver_Department, '')  [ReceiverDepartment]
		    FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)		  
		    WHERE @CustomerId = -1
		    AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		    AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
		    and serv.StatusOrderId <> 7
		    AND serv.StatusOrderId <> 15 -- No guías generadas

		END 
		ELSE
		BEGIN
		select * from
		(
		 	SELECT  
		    	--serv.Ticket_Number [Id],
		    	CAST(serv.Sender_ID AS VARCHAR) + ' ' + 
		    	ISNULL(UPPER(serv.Sender_FirstName),'') + ' '+ ISNULL(UPPER(serv.Sender_LastName),'') [NameOfSender],
		    
		    	--CAST(serv.Receiver_ID AS VARCHAR) + ' ' + 
		    	--CAST(serv.Receiver_SocialSecurity_ID AS VARCHAR) + ' ' +
		    	ISNULL(UPPER(serv.Receiver_FirstName),'') + ' ' + ISNULL(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
		    	ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
		    	CONVERT(varchar,serv.Preparation_Date,103) [PickUpDateTime],
		    	CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
		    	ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
		    	serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
		    	--serv.OrderStatus [OrderStatus]
		    	(SELECT so.OrderDescription FROM DeliveryBackOffice.dbo.StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) AS OrderStatus,
		    	serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
		    	ISNULL(serv.Receiver_Department, '')  [ReceiverDepartment]
		    FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		    JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
		    	ON serv.Sender_ID = vpclient.CodeOfReference	   		    
			WHERE 
			(
			    vpclient.CustomerID = @CustomerId 		
				
			)
		    AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		    AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
		    and serv.StatusOrderId <> 7
		    AND serv.StatusOrderId <> 15 -- No guías generadas
			and SERV.Sender_ID > 0

			UNION
			
			SELECT  
			--serv.Ticket_Number [Id],
			CAST(serv.Sender_ID AS VARCHAR) + ' ' + 
			ISNULL(UPPER(serv.Sender_FirstName),'') + ' '+ ISNULL(UPPER(serv.Sender_LastName),'') [NameOfSender],

			--CAST(serv.Receiver_ID AS VARCHAR) + ' ' + 
			--CAST(serv.Receiver_SocialSecurity_ID AS VARCHAR) + ' ' +
			ISNULL(UPPER(serv.Receiver_FirstName),'') + ' ' + ISNULL(UPPER(serv.Receiver_LastName),'') [NameOfReceiver],
			ISNULL(UPPER(NameOfReceiver),'') as [ReceiverName],
			CONVERT(varchar,serv.Preparation_Date,103) [PickUpDateTime],
			CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
			ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
			serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
			--serv.OrderStatus [OrderStatus]
			(SELECT so.OrderDescription FROM DeliveryBackOffice.dbo.StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) AS OrderStatus,
			serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
			ISNULL(serv.Receiver_Department, '')  [ReceiverDepartment]
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		--JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
		--	ON serv.Sender_ID = vpclient.CodeOfReference
		WHERE 
		--(vpclient.CustomerID = @CustomerId or @CustomerId = -1)
		--AND 
		(CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
		AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN  CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
		and serv.StatusOrderId <> 7
		AND serv.StatusOrderId <> 15 -- No guías generadas
		and SERV.Sender_ID = 0
		and @CustomerId = serv.IdCustomer
		) serv		
		order by serv.GuideNumber desc

		END
		

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
				''					[ManifestNumber],
				''					[ReceiverDepartment]
	END 




END
