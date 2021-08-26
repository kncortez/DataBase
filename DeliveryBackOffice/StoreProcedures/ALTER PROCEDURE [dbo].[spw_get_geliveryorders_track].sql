USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spw_get_geliveryorders_track]    Script Date: 24/08/2021 11:33:34 ******/
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
    @IdDateOfType AS INT = 1, --1 PickUp 2 Delivery
    @IdCustomer AS INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @IdToken AS VARCHAR(50);
    DECLARE @IdRol AS BIGINT;
    
    DECLARE @DateIni AS VARCHAR(50);
    DECLARE @DateFin AS VARCHAR(50);
    DECLARE @IdDateType AS INT;
    DECLARE @CustomerId AS INT;

    SET @IdToken = @Token;
    SET @IdRol = @Rol;
    SET @DateIni = @BeginDate;
    SET @DateFin = @EndDate;
    SET @IdDateType = @IdDateOfType;
    SET @CustomerId = @IdCustomer;
    SET DATEFORMAT DMY;

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
            SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
				   ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
				   ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
                   ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                   ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                   CONVERT(VARCHAR, serv.Preparation_Date, 103) [PickUpDateTime],
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
                   (
                       SELECT so.OrderDescription
                       FROM DeliveryBackOffice.dbo.StatusOrder so
                       WHERE so.StatusOrderId = serv.StatusOrderId
                   ) AS OrderStatus,
                   serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                   ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                   ISNULL(serv.Ticket_Number, '') [IdOrderReference]
            FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
            WHERE @CustomerId = -1
                  AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
                  AND (CONVERT(DATE, serv.Shipping_Date)    BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
                  AND serv.StatusOrderId <> 7
                  AND serv.StatusOrderId <> 15 -- No guías generadas

        END
        ELSE
        BEGIN
            SELECT General.NameOfSender,
					General.NameOfReceiver,
					General.ReceiverName,
					General.PickUpDateTime,
					General.ScheduledDeliveryDate,
					General.RealDeliveryDate,
					General.GuideNumber,
					General.OrderStatus,
					General.ManifestNumber,
					General.ReceiverDepartment,
					General.IdOrderReference
            FROM
            (
                SELECT
                    CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
					ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + 
					ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
					ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                    ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                    CONVERT(VARCHAR, serv.Preparation_Date, 103) [PickUpDateTime],
                    CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                    ISNULL(CONVERT(VARCHAR,(
                               SELECT TOP 1
                                      dod.DateCreated
                               FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
                               WHERE dod.Guide_Number = serv.Guide_Number
                                     AND dod.StatusOrderId = 5
											),103),'') AS [RealDeliveryDate],
                    serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                    (
                        SELECT so.OrderDescription
                        FROM DeliveryBackOffice.dbo.StatusOrder so
                        WHERE so.StatusOrderId = serv.StatusOrderId
                    ) AS OrderStatus,
                    serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR)		 [ManifestNumber]	,
                    ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                    ISNULL(serv.Ticket_Number, '') [IdOrderReference]
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                    JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
                        ON serv.Sender_ID = vpclient.CodeOfReference
                WHERE (vpclient.CustomerID = @CustomerId)
                      AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin)  OR @IdDateType = 1) --PickUp
                      AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin)  OR @IdDateType = 2) --Delivery
                      AND serv.StatusOrderId <> 7
                      AND serv.StatusOrderId <> 15 -- No guías generadas
                      AND serv.Sender_ID > 0
                UNION
                SELECT
                    CAST(serv.Sender_ID AS VARCHAR) + ' - ' + 
					ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' +
                    ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
					ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                    ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                    CONVERT(VARCHAR, serv.Preparation_Date, 103) [PickUpDateTime],
                    CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                    ISNULL(CONVERT(VARCHAR,(
											SELECT TOP 1
													dod.DateCreated
											FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
											WHERE dod.Guide_Number = serv.Guide_Number
													AND dod.StatusOrderId = 5
											),103),'' ) AS [RealDeliveryDate],
                    serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                    (
                        SELECT so.OrderDescription
                        FROM DeliveryBackOffice.dbo.StatusOrder so
                        WHERE so.StatusOrderId = serv.StatusOrderId
                    ) AS OrderStatus,
                    serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                    ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                    ISNULL(serv.Ticket_Number, '') [IdOrderReference]
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                WHERE (CONVERT(DATE, serv.Preparation_Date) BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 1) --PickUp
                    AND (CONVERT(DATE, serv.Preparation_Date) BETWEEN CONVERT(DATE, @DateIni) AND CONVERT(DATE, @DateFin) OR @IdDateType = 2) --Delivery
                    AND serv.StatusOrderId <> 7
                    AND serv.StatusOrderId <> 15 -- No guías generadas
                    AND serv.Sender_ID = 0
                    AND @CustomerId = serv.IdCustomer
            ) General
            ORDER BY General.GuideNumber DESC

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
