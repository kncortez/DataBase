-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Inserta el manifiesto de recoleccion>
-- =============================================
CREATE PROCEDURE dbo.sps_settlement_PickUp
    @Route NVARCHAR(100),
    --@GuideQuantity INT,
    --	@RouteReceived DATETIME,
    @Token NVARCHAR(50),
    @PiecesDry SMALLINT,
    @PiecesCold SMALLINT,
    @GuidesQuantity SMALLINT,
    @InGuides NVARCHAR(MAX) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
    @NotGuides NVARCHAR(MAX) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
    @IdCourier INT
AS
BEGIN

    -- control de guía a iterar
    DECLARE @GuideNumber INT;
    DECLARE @GuideSerie VARCHAR(2);
    -- CourierId de la guía a iterar
    DECLARE @CourierId INT;
    -- CatModuleId del modulo
    DECLARE @CatModuleId INT;
    -- Detecta si una guia tiene COD
    DECLARE @IsCOD BIT;
    -- control de actualizaciones para transacción
    DECLARE @RUpdated INT;

    BEGIN TRANSACTION;

    BEGIN TRY
        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#listNotGuides', 'U') IS NOT NULL
            DROP TABLE listNotGuides;
        IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL
            DROP TABLE #UpdOrd;
        --select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
        --	into #listGuides
        --	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

        --declare @InGuides   NVARCHAR(400) = 'FD198907-3,FD198910-1,FD198910-2,FD198941-1'

        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item)) ItemPiece
        --, 
        --SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
        --CHARINDEX('-',Item) charinde,  
        --len(Item) len
        INTO #listGuides
        FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides, ',');

        --------------------------------------------------------------------------------------------------------------------------

        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item)) ItemPiece
        --, 
        --SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
        --CHARINDEX('-',Item) charinde,  
        --len(Item) len
        INTO #listNotGuides
        FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@NotGuides, ',');

        DECLARE @Idd INT;

        INSERT INTO dbo.SettlementByPickup
        (
            RouteAssigmentId,
            DatePrinted,
            TokenCreated,
            DateCreated,
            PiecesDry,
            PiecesCold,
            GuidesQuantity,
            PiecesDryReceived,
            PiecesColdReceived,
            GuidesQuantityReceived,
            IdCourier
        )
        VALUES
        (@Route, GETDATE(), @Token, GETDATE(), @PiecesDry, @PiecesCold, @GuidesQuantity, NULL, NULL, NULL, @IdCourier);

        SET @RUpdated = @@rowcount;
        SET @Idd = SCOPE_IDENTITY();

        IF (@Idd > 0)
        BEGIN
            INSERT INTO dbo.SettlementByPickupDetail
            (
                SettlementByPickupId,
                GuideSerie,
                GuideNumber,
                RowStatus,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
                IsPieceLiquidaded,
                NoPiece
            )
            SELECT @Idd,
                   ls.ItemSerie,
                   ls.ItemNumber,
                   1,
                   @Token,
                   GETDATE(),
                   NULL,
                   NULL,
                   1,
                   ls.ItemPiece
            FROM #listGuides ls;
            ---------------------------------------------------------------------------------------------------
            DECLARE @validator INT =
                    (
                        SELECT TOP 1 ItemNumber FROM #listNotGuides
                    );
            IF (@validator >= 1)
            BEGIN
                INSERT INTO dbo.SettlementByPickupDetail
                (
                    SettlementByPickupId,
                    GuideSerie,
                    GuideNumber,
                    RowStatus,
                    TokenCreated,
                    DateCreated,
                    TokenUpdated,
                    DateUpdated,
                    IsPieceLiquidaded,
                    NoPiece
                )
                SELECT @Idd,
                       ls.ItemSerie,
                       ls.ItemNumber,
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       0,
                       ls.ItemPiece
                FROM #listNotGuides ls;
            END;
        END;



        ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	




        --Buscar ID modulo liquidación Recolecciones
        SET @CatModuleId = ISNULL(
                           (
                               SELECT ModIdModule
                               FROM CatModule WITH (NOLOCK)
                               WHERE ModName = 'Liquidación COD'
                           ),
                           0
                                 );

        SELECT *
        INTO #listGuidesTemp
        FROM #listGuides;
        -- mientras la tabla no este vacía
        WHILE EXISTS (SELECT * FROM #listGuidesTemp)
        BEGIN
            -- se obtiene la guía a iterar
            SELECT TOP 1
                   @GuideNumber = ItemNumber,
                   @GuideSerie = ItemSerie
            FROM #listGuidesTemp;

            -- se obtiene el id del courierman
            SELECT TOP 1
                   @CourierId = ID_Courier
            FROM [dbo].[DeliveryAttempt]
            WHERE [Guide_Serie] = @GuideSerie
                  AND [Guide_Number] = @GuideNumber;

            -- se verifica que no exita en las guías procesadas
            IF NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[ProcessedGuideCOD]
                WHERE [GuideNumber] = @GuideNumber
                      AND GuideSerie = @GuideSerie
            )
            BEGIN
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
                FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                        ON do.Guide_Serie = DOP.GuideSerie
                           AND do.Guide_Number = DOP.GuideNumber
                WHERE do.[Guide_Number] = @GuideNumber
                      AND do.[Guide_Serie] = @GuideSerie
                      AND
                      (
                          do.Collect_OnDelivery = 0
                          AND do.IsCollect = 'false'
                          AND DOP.PayTypeId = 1
                          AND
                          (
                              DOP.TimePlaId = 1
                              OR DOP.TimePlaId = 2
                          )
                          AND DOP.TypeofInOutMoneyId = 1
                      )
                      AND NOT EXISTS
                (
                    SELECT 1
                    FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                        JOIN CostDetail CD WITH (NOLOCK)
                            ON CD.IdCost = C.IdCost
                               AND CD.IdTypeOfMoney IN ( 2, 6 )
                    WHERE C.ProductNumber = CONCAT(do.Guide_Serie, CAST(do.Guide_Number AS VARCHAR(50)))
                );
            --	AND LG.ItemNumber NOT IN (SELECT GuideNumber
            --FROM [dbo].[ProcessedGuideCOD]
            --WHERE [GuideNumber] = DO.Guide_Number AND GuideSerie = DO.Guide_Serie)
            END;

            DELETE #listGuidesTemp
            WHERE ItemNumber = @GuideNumber
                  AND ItemSerie = @GuideSerie;
        END;

    ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . FIN ----------------------		

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@trancount > 0
    BEGIN
        IF (@Idd > 0)
            SELECT @Idd AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   @@trancount AS 'NumTransferID';
        ELSE
            SELECT 0 AS 'StatusCode',
                   'Registro no encontrado' AS 'Description',
                   0 AS 'NumTransferID';

        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';

END;
