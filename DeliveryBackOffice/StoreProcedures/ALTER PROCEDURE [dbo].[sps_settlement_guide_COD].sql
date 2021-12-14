USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_COD]    Script Date: 13/12/2021 11:52:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-25>
-- Description:	<Registrar transacción de liquidación (cobro) de guías en área de COD>
-- =============================================
ALTER PROCEDURE [dbo].[sps_settlement_guide_COD]
    @GuideSerie NVARCHAR(2),
    @GuideNumbers NVARCHAR(MAX),
    @Token NVARCHAR(50),
	@IdDeliveryOrderBySettlement INT,
	@Money TblMoneyByDeliveryOrderBySettlement READONLY,
	@IsIncident BIT,
	@Type VARCHAR(10),
    @Value DECIMAL(10,2),
    @Description NVARCHAR(500)
AS
BEGIN
	-- control transacción
	DECLARE @ValidateOperation INT = 0 
	-- cantidad de veces que aparece el registro
	DECLARE @Times INT = 0
    -- control de guías a manipular
    DECLARE @GuidesTable AS TABLE
    (
        Guide_Number INT
    );
    -- control de guía a iterar
    DECLARE @GuideNumber INT;
    -- CourierId de la guía a iterar
    DECLARE @CourierId INT;
    -- CatModuleId del modulo
    DECLARE @CatModuleId INT;
    -- Detecta si una guia tiene COD
    DECLARE @IsCOD BIT;


    BEGIN TRANSACTION;

    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#GuidesTemp', 'U') IS NOT NULL
            DROP TABLE #GuidesTemp;

        -- Convertir la lista de guías separadas por coma en una tabla
        INSERT @GuidesTable
        SELECT CAST(Item AS INT)
        FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumbers, ',');

        -- actualizar guía debido al proceso de liquidación
        UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
        SET GuideDischarged_TokenCreated = @Token,
            GuideDischarged_DateCreated = GETDATE(),
            Guide_Discharged = 1 -- guía liquidada en COD
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number IN
                  (
                      SELECT Guide_Number FROM @GuidesTable
                  )
              AND Guide_Settlement = 1; -- guía liquidada previamente en bodega

		IF COALESCE(@@ROWCOUNT,0) > 0
			SET @ValidateOperation = @ValidateOperation+1

        -- insertar guía en la tabla de guías procesadas COD
        -- Se insertar guías en tabla temporal
        SELECT *
        INTO #GuidesTemp
        FROM @GuidesTable;

        --Buscar ID modulo liquidación COD
        SET @CatModuleId = ISNULL(
                           (
                               SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación COD'
                           ),
                           0
                                 );

        -- mientras la tabla no este vacía
        WHILE EXISTS (SELECT * FROM #GuidesTemp)
        BEGIN
            -- se obtiene la guía a iterar
            SELECT TOP 1
                   @GuideNumber = Guide_Number
            FROM #GuidesTemp;

            -- se verifica que no exita en las guías procesadas
            IF NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[ProcessedGuideCOD]
                WHERE [GuideNumber] = @GuideNumber
            )
            BEGIN
                -- se obtiene el id del courierman
                SELECT TOP 1
                       @CourierId = ID_Courier
                FROM [dbo].[DeliveryAttempt]
                WHERE [Guide_Serie] = @GuideSerie
                      AND [Guide_Number] = @GuideNumber;

                -- se inserta en las guías procesadas si contine COD 
                INSERT INTO [dbo].[ProcessedGuideCOD]
                (
                    [GuideSerie],
                    [GuideNumber],
                    [CourierManId],
                    [Date],
                    [BatchCODId],
                    [BatchCODIdCommission],
                    [DataOriginId],
                    [Notificated],
                    [Token],
                    CustomerId
                )
                SELECT do.[Guide_Serie],
                       do.[Guide_Number],
                       @CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer
                FROM [dbo].[DeliveryOrder] do
                    LEFT JOIN dbo.VisitPointClient vp
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                WHERE do.[Guide_Number] = @GuideNumber
                      AND do.[Guide_Serie] = @GuideSerie
                      AND do.[Collect_OnDelivery] > 0
                UNION
                SELECT do.[Guide_Serie],
                       do.[Guide_Number],
                       @CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer
                FROM [dbo].[DeliveryOrder] do
                    LEFT JOIN dbo.VisitPointClient vp
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                WHERE do.[Guide_Number] = @GuideNumber
                      AND do.[Guide_Serie] = @GuideSerie
                      AND do.[Collect_OnDelivery] = 0
                      AND do.IsCollect = 'true';
            END;

            --- Se agrega nuevo checkpoint

            SET @IsCOD = CASE
                             WHEN
                             (
                                 SELECT Collect_OnDelivery
                                 FROM DeliveryBackOffice.dbo.DeliveryOrder
                                 WHERE Guide_Number = @GuideNumber
                             ) > 0 THEN
                                 'true'
                             ELSE
                                 'false'
                         END;

            IF (@IsCOD = 'true')
            BEGIN

                --BEGIN TRANSACTION;

                --BEGIN TRY

                    --Actualiza es stado a "COD liquidado" en tabla DeliveryOrder si la guia tuviera COD
                    UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                    SET StatusOrderId = 24
                    WHERE Guide_Number = @GuideNumber;

                    --Actualiza es stado a "COD liquidado" en tabla DeliveryOrderDetail si la guia tuviera COD

                    INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                    (
                        Guide_Serie,
                        Guide_Number,
                        StatusOrderId,
                        UserCreated,
                        DateCreated
                    )
                    VALUES
                    (@GuideSerie, @GuideNumber, 24, @Token, GETDATE());


                ---------------------
                --END TRY
                --BEGIN CATCH

                --    SELECT 'Error al actualizar el estado de la guia';

                --    ROLLBACK TRANSACTION;

                --END CATCH;

                --IF @@TRANCOUNT > 0
                --BEGIN

                --    COMMIT TRANSACTION;

                --    SELECT 'estado actualizado exitosamente';

                --END;

            END;

            -- se elimina la guía de la tabla temporal
            DELETE #GuidesTemp
            WHERE Guide_Number = @GuideNumber;
        END;

		--Se realiza el registro de las denominaciones
		INSERT INTO [dbo].[MoneyByDeliveryOrderBySettlement]
		SELECT IdCatMoney, @IdDeliveryOrderBySettlement, Quantity
		FROM @Money
		WHERE Quantity IS NOT NULL AND Quantity > 0

		IF COALESCE(@@ROWCOUNT,0) > 0
			SET @ValidateOperation = @ValidateOperation+1

		--Si se presenta una contingencia se registra
		IF @IsIncident = 1
		BEGIN

			INSERT INTO [dbo].[Contingency]
                        ([DeliveryOrderBySettlementId]
                        ,[Type]
                        ,[Value]
                        ,[Description]
                        ,[TokenCreated]
                        ,[DateCreated])
			VALUES 
                    (@IdDeliveryOrderBySettlement
                    ,@Type
                    ,@Value
                    ,@Description
                    ,@Token
                    ,GETDATE()
                    )

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1
		END
		ELSE
		BEGIN
			SET @ValidateOperation = @ValidateOperation+1
		END


    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@ValidateOperation = 3)
            SELECT 1 AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   @@TRANCOUNT AS 'NumTransferID';
        ELSE
            SELECT 0 AS 'StatusCode',
                   'Registro no guardado' AS 'Description',
                   0 AS 'NumTransferID';

        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
END;
