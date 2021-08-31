USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spw_get_geliveryorders_track]    Script Date: 30/08/2021 13:13:43 ******/
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
ALTER PROCEDURE [dbo].[spw_get_geliveryorders_track]
    -- Add the parameters for the stored procedure here
    @Token AS VARCHAR(50) = 'ad1a2328ed27ea99622f68deae5d9976',
    @Rol AS BIGINT = 1864,
    @BeginDate AS VARCHAR(50) = '11/05/2020',
    @EndDate AS VARCHAR(50) = '12/05/2020',
    @IdCustomer AS INT = -1,
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
    
    DECLARE @DateIni AS DATE;
    DECLARE @DateFin AS DATE;
    DECLARE @CustomerId AS INT;

	SET DATEFORMAT DMY;
    SET @IdToken = @Token;
    SET @IdRol = @Rol;
    SET @DateIni = CONVERT(DATE, @BeginDate);
    SET @DateFin = CONVERT(DATE, @EndDate);
    SET @CustomerId = @IdCustomer;

    DECLARE @IdSystem AS INT;

    SELECT @IdSystem = ROL.LGN_IdSystem
    FROM DenariusUser_Dev.dbo.LGN_Rol ROL WITH (NOLOCK)
    WHERE ROL.LGN_IdRol = @IdRol;

    IF
    (
        SELECT COUNT(logtoken.SSN_IdToken) SSN_IdToken
        FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH (NOLOCK)
        WHERE logtoken.SSN_IdToken = @IdToken
              AND logtoken.SSN_IdSystem = @IdSystem
              AND logtoken.SSN_TokenStatus = 1
    ) > 0
    BEGIN

        IF (@CustomerId = -1)
        BEGIN
			IF(@GuideNumber = 0)
			BEGIN
				SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
					   ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
					   ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
					   ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
					   ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
					   CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
					   CONVERT(VARCHAR, serv.Shipping_Date, 103)    [ScheduledDeliveryDate],
					   ISNULL(CONVERT(VARCHAR,
							  (
								  SELECT TOP 1
										 dod.DateCreated
								  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
								  WHERE dod.Guide_Number = serv.Guide_Number
										AND dod.StatusOrderId = 5
							  ),103),'') AS [RealDeliveryDate],
					   serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
					   so.OrderDescription AS OrderStatus,
					   serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
					   ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
					   ISNULL(serv.Ticket_Number, '') [IdOrderReference]
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
					ON serv.StatusOrderId = so.StatusOrderId
				WHERE CONVERT(DATE, serv.DateCreated) BETWEEN @DateIni AND @DateFin
					AND serv.StatusOrderId <> 7 -- No guías anuladas
					AND serv.StatusOrderId <> 15 -- No guías generadas
			END
			ELSE
			BEGIN
				SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
					   ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
					   ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
					   ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
					   ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
					   CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
					   CONVERT(VARCHAR, serv.Shipping_Date, 103)    [ScheduledDeliveryDate],
					   ISNULL(CONVERT(VARCHAR,
							  (
								  SELECT TOP 1
										 dod.DateCreated
								  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
								  WHERE dod.Guide_Number = serv.Guide_Number
										AND dod.StatusOrderId = 5
							  ),103),'') AS [RealDeliveryDate],
					   serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
					   so.OrderDescription AS OrderStatus,
					   serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
					   ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
					   ISNULL(serv.Ticket_Number, '') [IdOrderReference]
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
					ON serv.StatusOrderId = so.StatusOrderId
				WHERE serv.Guide_Serie = @GuideSerie 
					AND serv.Guide_Number = @GuideNumber
					AND serv.StatusOrderId <> 7 -- No guías anuladas
					AND serv.StatusOrderId <> 15 -- No guías generadas
			END
        END
        ELSE
        BEGIN
			IF(@GuideNumber = 0)
			BEGIN
				SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				   ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
				   ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
				   ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                   ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                   CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                   CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                   ISNULL(CONVERT(VARCHAR,(
							SELECT TOP 1
									dod.DateCreated
							FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
							WHERE dod.Guide_Number = serv.Guide_Number
									AND dod.StatusOrderId = 5
										),103),'') AS [RealDeliveryDate],
				   serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                   so.OrderDescription AS OrderStatus,
                   serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR)		 [ManifestNumber]	,
                   ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                   ISNULL(serv.Ticket_Number, '') [IdOrderReference]
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
				JOIN DeliveryBackOffice.dbo.VisitPointClient vpclient WITH (NOLOCK)
					ON serv.Sender_ID = vpclient.CodeOfReference
				LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so
					ON serv.StatusOrderId = so.StatusOrderId
				WHERE ((serv.Sender_ID = 0 AND @CustomerId = serv.IdCustomer) OR (vpclient.CustomerID = @CustomerId AND serv.Sender_ID > 0))
					AND (CONVERT(DATE, serv.DateCreated) BETWEEN @DateIni AND @DateFin)
					AND serv.StatusOrderId <> 7 -- No guías anuladas
					AND serv.StatusOrderId <> 15 -- No guías generadas
			END
			ELSE
			BEGIN
				SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				   ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
				   ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
				   ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                   ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                   CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                   CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                   ISNULL(CONVERT(VARCHAR,(
							SELECT TOP 1
									dod.DateCreated
							FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
							WHERE dod.Guide_Number = serv.Guide_Number
									AND dod.StatusOrderId = 5
										),103),'') AS [RealDeliveryDate],
				   serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                   so.OrderDescription AS OrderStatus,
                   serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR)		 [ManifestNumber]	,
                   ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                   ISNULL(serv.Ticket_Number, '') [IdOrderReference]
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
				JOIN DeliveryBackOffice.dbo.VisitPointClient vpclient WITH (NOLOCK)
					ON serv.Sender_ID = vpclient.CodeOfReference
				LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so
					ON serv.StatusOrderId = so.StatusOrderId
				WHERE ((serv.Sender_ID = 0 AND @CustomerId = serv.IdCustomer) OR (vpclient.CustomerID = @CustomerId AND serv.Sender_ID > 0))
					AND serv.Guide_Serie = @GuideSerie
					AND serv.Guide_Number = @GuideNumber
					AND serv.StatusOrderId <> 7 -- No guías anuladas
					AND serv.StatusOrderId <> 15 -- No guías generadas
			END
        END


    END
    ELSE
    BEGIN
        SELECT 
            NULL [NameOfSender],
            '' [NameOfReceiver],
            '' [ReceiverName],
            '' [PickUpDateTime],
            '' [ScheduledDeliveryDate],
            '' [RealDeliveryDate],
            '' [GuideNumber],
            'INACTIVE TOKEN ' [OrderStatus],
            '' [ManifestNumber],
            '' [ReceiverDepartment],
            '' [IdOrderReference];
    END
END
