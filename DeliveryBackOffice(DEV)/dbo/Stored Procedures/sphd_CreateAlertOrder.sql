

-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-30>
-- Description:	<crea una nueva alerta para una guia>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_CreateAlertOrder]
    -- Add the parameters for the stored procedure here
    @guideserie NVARCHAR(2) = NULL,
    @guidenumber INT = NULL,
    @serviceManagementId INT = NULL,
    @tokenuser NVARCHAR(50),
    @idTypealert INT = 1,
    @alertdescription NVARCHAR(500),
    @serviceTypeId BIGINT = NULL,
    @flagModifyAlert BIT,
    @idAlert INT = NULL,
    @iduser BIGINT,
    @alertMessage NVARCHAR(500) = NULL
AS
BEGIN
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION CreateAlertOrderPT;
    ELSE
        BEGIN TRANSACTION;

    BEGIN TRY
        BEGIN

            DECLARE @AlertForGuide BIT = 0;
            DECLARE @AlertForService BIT = 1;

            IF (
                   @guideserie IS NOT NULL
                   AND @guidenumber IS NOT NULL
               )
               AND @AlertForService IS NULL
                SET @AlertForGuide = 1;
            IF @serviceManagementId IS NOT NULL
               AND
               (
                   @guideserie IS NULL
                   AND @guidenumber IS NULL
               )
                SET @AlertForService = 1;

            IF
            (
                SELECT @AlertForGuide ^ @AlertForService
            ) = 0
            BEGIN
                SELECT 0 AS 'StatusCode',
                       'Se esperaba solo serie y número de guía ó solo id de servicio' AS 'Description',
                       0 'NumTransferID',
                       ' ' 'Guide';
            END;
            ELSE
            BEGIN

                DECLARE @RModified INT;
                IF @flagModifyAlert = 1 --MODIFY ALERT
                BEGIN
                    UPDATE dbo.DeliveryOrderAlert
                    SET GuideSerie = @guideserie,
                        GuideNumber = @guidenumber,
                        ServiceTypeId = @serviceTypeId,
                        AlertDescription = @alertdescription,
                        AlertTypeId = @idTypealert,
                        TokenUpdated = @tokenuser,
                        DateUpdated = GETDATE()
                    WHERE IdDeliveryOrderAlert = @idAlert;

                    SELECT 1 AS 'StatusCode',
                           'Alerta Modificada' AS 'Description',
                           1 'NumTransferID',
                           '' 'Guide';

                    IF (@AlertForService = 1)
                    BEGIN
                        SELECT ISNULL(RA.IdCurrierMan, -1) 'IdCourier'
                        FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH (NOLOCK)
                                ON SM.IdPuRouteAssigment = RA.IdRouteAssigment
                        WHERE SM.IdServiceManagement = @serviceManagementId;
                    END;

                END;
                ELSE
                BEGIN --CREATE ALERT
                    INSERT INTO dbo.DeliveryOrderAlert
                    (
                        GuideSerie,
                        GuideNumber,
                        ServiceTypeId,
                        AlertDescription,
                        AlertTypeId,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated,
                        ServiceManagementId
                    )
                    VALUES
                    (@guideserie, @guidenumber, @serviceTypeId, @alertdescription, @idTypealert, 1, @tokenuser,
                     GETDATE(), NULL, NULL, @serviceManagementId);
                    SET @idAlert = SCOPE_IDENTITY();
                    INSERT INTO dbo.DeliveryOrderAlertDetail
                    (
                        author,
                        username,
                        comment,
                        DeliveryOrderAlertId,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated
                    )
                    VALUES
                    (   @iduser,
                        (
                            SELECT Username FROM dbo.InternalUser WHERE IdUser = @iduser
                        ), 'Alerta creada', @idAlert, 1, @tokenuser, GETDATE(), NULL, NULL),
                    (   @iduser,
                        (
                            SELECT Username FROM dbo.InternalUser WHERE IdUser = @iduser
                        ), IIF(@serviceManagementId IS NOT NULL, @alertMessage, @alertdescription),
                        IDENT_CURRENT('DeliveryOrderAlert'), 1, @tokenuser, GETDATE(), NULL, NULL);
                    SELECT 1 AS 'StatusCode',
                           'Alerta creada' AS 'Description',
                           1 'NumTransferID',
                           '' 'Guide';

                    IF (@AlertForService = 1)
                    BEGIN
                        SELECT ISNULL(RA.IdCurrierMan, -1) 'IdCourier'
                        FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH (NOLOCK)
                                ON SM.IdPuRouteAssigment = RA.IdRouteAssigment
                        WHERE SM.IdServiceManagement = @serviceManagementId;
                    END;

                END;
            END;



        END;
        IF @TranCounter = 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               @guideserie + CONVERT(NVARCHAR, @guidenumber) AS 'Guide';
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION CreateAlertOrderPT;
    END CATCH;


END;        
		