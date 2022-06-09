

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-06-12>
-- Description:	<Confirmar entrega de guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_Confirmation_of_delivery]
    @Guide_Serie AS VARCHAR(2),   --guide serie
    @Guide_Number AS INT,         --guide number
    @DateOfDelivery VARCHAR(50),  --Date of delivery
    @NameOfReceiver VARCHAR(200), --Name of receiver
    @TokenId AS VARCHAR(50)       --token user
AS
BEGIN
    DECLARE @StatusId TINYINT = 5; --Status of delivery 
    DECLARE @ValidateOperation BIGINT;
    DECLARE @Times INT; -- cantidad de veces que se encuentra el registro con estado de entregado
    DECLARE @CatModuleId INT; -- CatModuleId del modulo
    DECLARE @CourierId INT; -- CourierId de la guía
    DECLARE @COD DECIMAL(14, 2); -- COD de la guía
    DECLARE @Datetime DATETIME; -- Fecha y hora del último checkpoint

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
        SET @Times =
        (
            SELECT COUNT(Guide_Number)
            FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @Guide_Number
                  AND
                  (
                      StatusOrderId = @StatusId
                      OR StatusOrderId = 14
                  )
        );

        IF (@Times = 0)
        BEGIN

            SET @Datetime =
            (
                SELECT TOP 1
                       DateCreated
                FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WITH (NOLOCK)
                WHERE Guide_Serie = @Guide_Serie
                      AND Guide_Number = @Guide_Number
                ORDER BY DateCreated DESC
            );

            IF (@DateOfDelivery > @Datetime)
            BEGIN

                -- Actualizar registro de guía a último estado 
                UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                SET StatusOrderId = @StatusId, --Status of delivery 			
                    NameOfReceiver = @NameOfReceiver
                WHERE Guide_Serie = @Guide_Serie
                      AND Guide_Number = @Guide_Number;

                UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
                SET Delivered = 1 --Status of delivery 	
                WHERE Guide_Serie = @Guide_Serie
                      AND Guide_Number = @Guide_Number
                      AND CAST(Date_Created AS DATE) = CAST(GETDATE() AS DATE);

                -- Insertar nuevo estado de guía en tabla histórica
                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    [Guide_Serie],
                    [Guide_Number],
                    [StatusOrderId],
                    [UserCreated],
                    [DateCreated],
                    [DateCreatedInSystem]
                )
                SELECT @Guide_Serie,
                       @Guide_Number,
                       @StatusId,
                       @TokenId,
                       CONVERT(DATETIME, @DateOfDelivery, 120),
                       GETDATE()
                WHERE EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                    WHERE Guide_Serie = @Guide_Serie
                          AND Guide_Number = @Guide_Number
                );

                SET @ValidateOperation = COALESCE(@@ROWCOUNT, 0);

                DECLARE @IdCustomer INT;
                DECLARE @COLLECT INT = 0;
                -- se obtiene COD de la guía
                SELECT @COD = ord.Collect_OnDelivery,
                       @IdCustomer = cus.IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE ord.Guide_Serie = @Guide_Serie
                      AND ord.Guide_Number = @Guide_Number;

                SELECT @COLLECT = 1
                FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = ord.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                WHERE ord.Guide_Serie = @Guide_Serie
                      AND ord.Guide_Number = @Guide_Number
                      AND ord.IsCollect = 'true'
                      AND NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                        JOIN CostDetail CD WITH (NOLOCK)
                            ON CD.IdCost = C.IdCost
                               AND CD.IdTypeOfMoney IN ( 2, 6 )
                    WHERE C.ProductNumber = CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR(50)))
                );
                -- se verifica que no exita en ProcessGuideCOD Y COD > 0
                IF (
                       @COD > 0
                       OR @COLLECT = 1
                   )
                   AND NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.ProcessedGuideCOD WITH (NOLOCK)
                    WHERE GuideSerie = @Guide_Serie
                          AND GuideNumber = @Guide_Number
                )
                BEGIN
                    --Buscar ID modulo liquidación COD
                    SET @CatModuleId = ISNULL(
                                       (
                                           SELECT ModIdModule
                                           FROM DeliveryBackOffice.dbo.CatModule WITH (NOLOCK)
                                           WHERE ModName = 'Confirmación de Entrega'
                                       ),
                                       0
                                             );
                    -- Obtener ID de Courier
                    SELECT TOP 1
                           @CourierId = ID_Courier
                    FROM DeliveryBackOffice.dbo.DeliveryAttempt WITH (NOLOCK)
                    WHERE Guide_Serie = @Guide_Serie
                          AND Guide_Number = @Guide_Number;

                    INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                    (
                        GuideSerie,
                        GuideNumber,
                        CourierManId,
                        Date,
                        BatchCODId,
                        BatchCODIdCommission,
                        DataOriginId,
                        Notificated,
                        Token,
                        CustomerId
                    )
                    VALUES
                    (@Guide_Serie, @Guide_Number, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @TokenId,
                     @IdCustomer);

                END;
                ELSE IF EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                        INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                            ON ord.Guide_Serie = DOP.GuideSerie
                               AND ord.Guide_Number = DOP.GuideNumber
                        LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                            ON vp.CodeOfReference = ord.Sender_ID
                        LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                            ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
                    WHERE ord.Guide_Serie = @Guide_Serie
                          AND ord.Guide_Number = @Guide_Number
                          AND ord.IsCollect = 'false'
                          AND DOP.TimePlaId = 2
                          AND NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                            JOIN CostDetail CD WITH (NOLOCK)
                                ON CD.IdCost = C.IdCost
                                   AND CD.IdTypeOfMoney IN ( 2, 6 )
                        WHERE C.ProductNumber = CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR(50)))
                    )
                )
                BEGIN
                    INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                    (
                        GuideSerie,
                        GuideNumber,
                        CourierManId,
                        Date,
                        BatchCODId,
                        BatchCODIdCommission,
                        DataOriginId,
                        Notificated,
                        Token,
                        CustomerId
                    )
                    VALUES
                    (@Guide_Serie, @Guide_Number, @CourierId, GETDATE(), NULL, NULL, @CatModuleId, 0, @TokenId,
                     @IdCustomer);

                END;


            END;
            ELSE
                SET @ValidateOperation = -2;

        END;
        -- registro existente
        ELSE
            SET @ValidateOperation = -1;

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@ValidateOperation > 0)
        BEGIN
            SELECT 1 AS 'StatusCode',
                   'Registros guardados correctamente' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';

            SELECT TOP 10
                   Guide_Serie + CAST(Guide_Number AS VARCHAR) Guide,
                   Ticket_Number Ticket,
                   Receiver_FirstName + ' ' + Receiver_LastName Name,
                   Courier_Route Route,
                   CONVERT(VARCHAR, Dispatched_Date, 103) RouteDate
            FROM DeliveryBackOffice.dbo.DeliveryOrder
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @Guide_Number;

            PRINT 'REGISTER EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
        END;
        ELSE IF (@ValidateOperation = -1)
        BEGIN
            SELECT -1 AS 'StatusCode',
                   'Registro duplicado' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE IF (@ValidateOperation = -2)
        BEGIN
            SELECT -2 AS 'StatusCode',
                   'Fecha y hora incorrecta' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
        END;
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'El registro no existe' AS 'Description',
                   @ValidateOperation AS 'NumTransferID';
            PRINT 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
        END;
        COMMIT TRANSACTION;
    END;
END;
