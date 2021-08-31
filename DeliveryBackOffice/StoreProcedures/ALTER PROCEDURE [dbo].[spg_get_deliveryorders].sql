USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_deliveryorders]    Script Date: 30/08/2021 23:47:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_deliveryorders]
	-- Add the parameters for the stored procedure here
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1864,
		@VisitPointID AS BIGINT = 146290,
		@BeginDate AS VARCHAR(50) = '11/05/2020',
		@EndDate AS VARCHAR(50)  = '12/05/2020',
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
	SET @IdVisitPoint = @VisitPointID;
	SET @DateIni = CONVERT(DATE, @BeginDate);
	SET @DateFin = CONVERT(DATE, @EndDate);

	DECLARE @IdSystem AS INT 

	SELECT @IdSystem = ROL.LGN_IdSystem FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH(NOLOCK) WHERE ROL.LGN_IdRol = @IdRol

	IF (
		SELECT COUNT(logtoken.SSN_IdToken) SSN_IdToken
		FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH(NOLOCK)
		WHERE logtoken.SSN_IdToken = @IdToken AND logtoken.SSN_IdSystem = @IdSystem 
		AND logtoken.SSN_TokenStatus = 1
	   ) > 0 
	BEGIN 

		IF(@GuideNumber = 0)
		BEGIN
			SELECT  
				CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				UPPER(ISNULL(serv.Sender_FirstName,'')) + ' '+ UPPER(ISNULL(serv.Sender_LastName,'')) [NameOfSender],
				ISNULL(UPPER(ISNULL(serv.Receiver_FirstName,'')) + ' ' + UPPER(ISNULL(serv.Receiver_LastName,'')),'') [NameOfReceiver],
				ISNULL(UPPER(serv.NameOfReceiver),'') as [ReceiverName],
				CONVERT(varchar,serv.DateCreated,103) [PickUpDateTime],
				CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
				ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
				serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
				--serv.OrderStatus [OrderStatus]
				so.OrderDescription AS OrderStatus,
				serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
				ISNULL(serv.Ticket_Number,'') [IdOrderReference]
			FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
			JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
				ON serv.Sender_ID = vpclient.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so
				ON serv.StatusOrderId = so.StatusOrderId
			WHERE vpclient.VisitPointId = @IdVisitPoint
				AND CONVERT(DATE, serv.DateCreated) BETWEEN @DateIni AND @DateFin
				AND serv.StatusOrderId <> 7 -- No guías anuladas
				AND serv.StatusOrderId <> 15 -- No guías generadas
		END
		ELSE
		BEGIN
			SELECT  
				CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				UPPER(ISNULL(serv.Sender_FirstName,'')) + ' '+ UPPER(ISNULL(serv.Sender_LastName,'')) [NameOfSender],
				ISNULL(UPPER(ISNULL(serv.Receiver_FirstName,'')) + ' ' + UPPER(ISNULL(serv.Receiver_LastName,'')),'') [NameOfReceiver],
				ISNULL(UPPER(serv.NameOfReceiver),'') as [ReceiverName],
				CONVERT(varchar,serv.DateCreated,103) [PickUpDateTime],
				CONVERT(varchar,serv.Shipping_Date,103) [ScheduledDeliveryDate],
				ISNULL(CONVERT(varchar,(SELECT TOP 1 dod.DateCreated FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WHERE dod.Guide_Number = serv.Guide_Number AND dod.StatusOrderId = 5 ),103),'') AS	[RealDeliveryDate],
				serv.Guide_Serie + Cast(serv.Guide_Number as varchar) [GuideNumber],
				--serv.OrderStatus [OrderStatus]
				so.OrderDescription AS OrderStatus,
				serv.Manifest_Serie + Cast(serv.Manifest_Number as varchar) [ManifestNumber],
				ISNULL(serv.Ticket_Number,'') [IdOrderReference]
			FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
			JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
				ON serv.Sender_ID = vpclient.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so
				ON serv.StatusOrderId = so.StatusOrderId
			WHERE vpclient.VisitPointId = @IdVisitPoint
				AND serv.Guide_Serie = @GuideSerie
				AND serv.Guide_Number = @GuideNumber
				AND serv.StatusOrderId <> 7 -- No guías anuladas
				AND serv.StatusOrderId <> 15 -- No guías generadas
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
				''					[IdOrderReference]
	END 




END
