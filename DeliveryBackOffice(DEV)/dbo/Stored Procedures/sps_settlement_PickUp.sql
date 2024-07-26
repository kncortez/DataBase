

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Inserta el manifiesto de recoleccion>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-06-28>
-- Description:	<Validación sobre pago con Tarjeta o Datafono en CostDetail>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-03-14>
-- Description:	<agregar a bitacora de registro de guías en carrito que no son collect que no fueron liquidadas>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_PickUp]
    @Route NVARCHAR(100),
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

    ----------------
    DECLARE @TotalGuide DECIMAL(18, 2);

    BEGIN TRANSACTION;

    BEGIN TRY
        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#listNotGuides', 'U') IS NOT NULL
            DROP TABLE listNotGuides;
        IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL
            DROP TABLE #UpdOrd;


        CREATE TABLE #listGuides
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT
        );
        CREATE NONCLUSTERED INDEX listGuidesserie
        ON #listGuides (
                           ItemSerie,
                           ItemNumber
                       );

        --declare @InGuides   NVARCHAR(400) = 'FD198907-3,FD198910-1,FD198910-2,FD198941-1'
        INSERT INTO #listGuides
        (
            ItemSerie,
            ItemNumber,
            ItemPiece
        )
        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item)) ItemPiece
        --, 
        --SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
        --CHARINDEX('-',Item) charinde,  
        --len(Item) len
        --	into #listGuides
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

        --------------------------------------------------------------------------------------------------------------------------


        CREATE TABLE #listNotGuides
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT
        );
        CREATE NONCLUSTERED INDEX #listNotGuidessserie
        ON #listGuides (
                           ItemSerie,
                           ItemNumber
                       );


        INSERT INTO #listNotGuides
        (
            ItemSerie,
            ItemNumber,
            ItemPiece
        )
        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item)) ItemPiece
        --, 
        --SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
        --CHARINDEX('-',Item) charinde,  
        --len(Item) len
        --  INTO #listNotGuides
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@NotGuides, ',');

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

        SET @RUpdated = @@ROWCOUNT;
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

        -------------------------- Bitacora de Guías en carrito de compras no collect y que no fueron liquidadas y se recolectaron
        IF ((EXISTS
        (
            SELECT 1
            FROM [dbo].[AccountServiceCartDetail] ASCD WITH (NOLOCK)
            WHERE ASCD.GuideNumber IN
                  (
                      SELECT LG.ItemNumber FROM #listGuides LG
                  )
                  AND ASCD.RowStatus = 1
        )
            )
           )
        BEGIN

            BEGIN TRANSACTION;
            BEGIN TRY

                SET @TotalGuide =
                (
                    SELECT ISNULL(SUM([DO].[PriceShippment]), 0)
                    FROM
                    (
                        SELECT DISTINCT
                               [LGaux].[ItemSerie],
                               [LGaux].[ItemNumber]
                        FROM #listGuides LGaux
                    ) LG
                        INNER JOIN [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH (NOLOCK)
                            ON LG.ItemSerie = AccSCD.GuideSerie
                               AND LG.ItemNumber = AccSCD.GuideNumber
                        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                            ON [DO].[Guide_Serie] = [AccSCD].[GuideSerie]
                               AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
                        INNER JOIN [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                            ON [Co].[GuideSerie] = [DO].[Guide_Serie]
                               AND [Co].[GuideNumber] = [DO].[Guide_Number]
                    WHERE [AccSCD].[RowStatus] = 1
                          AND [DO].[IsCollect] = 0
                          AND [Co].[TotalAmountPaid] IS NULL
                );

                INSERT INTO [dbo].[ConflictManifest]
                (
                    CourierResponsible,
                    TotalAmount,
                    RowStatus,
                    TokenCreated,
                    DateCreated
                )
                VALUES
                (@IdCourier, ISNULL(@TotalGuide, 0), 1, @Token, GETDATE());


                DECLARE @IdConflictManifest INT = SCOPE_IDENTITY();

                --- Insert Detalle
                INSERT INTO [dbo].[ConflictManifestDetail]
                (
                    ConflictManifestId,
                    GuideSerie,
                    GuideNumber,
                    GuidePrice,
                    RowStatus,
                    TokenCreated,
                    DateCreated
                )
                SELECT @IdConflictManifest,
                       DO.Guide_Serie,
                       DO.Guide_Number,
                       DO.PriceShippment,
                       1,
                       @Token,
                       GETDATE()
                FROM
                (
                    SELECT DISTINCT
                           [LGaux].[ItemSerie],
                           [LGaux].[ItemNumber]
                    FROM #listGuides LGaux
                ) LG
                    INNER JOIN [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH (NOLOCK)
                        ON LG.ItemSerie = AccSCD.GuideSerie
                           AND LG.ItemNumber = AccSCD.GuideNumber
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        ON [DO].[Guide_Serie] = [AccSCD].[GuideSerie]
                           AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
                    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                        ON [Co].[GuideSerie] = [DO].[Guide_Serie]
                           AND [Co].[GuideNumber] = [DO].[Guide_Number]
                WHERE [AccSCD].[RowStatus] = 1
                      AND [DO].[IsCollect] = 0
                      AND [Co].[TotalAmountPaid] IS NULL;
					  
                UPDATE [Co]
                SET [Co].[TotalAmountPaid] = [Co].[TotalAmount],
                    [Co].[TokenUpdated] = @Token,
                    [Co].[DateUpdated] = GETDATE()
                FROM
                (
                    SELECT DISTINCT
                           [LGaux].[ItemSerie],
                           [LGaux].[ItemNumber]
                    FROM #listGuides LGaux
                ) LG
                    INNER JOIN [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH (NOLOCK)
                        ON LG.ItemSerie = AccSCD.GuideSerie
                           AND LG.ItemNumber = AccSCD.GuideNumber
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        ON [DO].[Guide_Serie] = [AccSCD].[GuideSerie]
                           AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
                    INNER JOIN [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                        ON [Co].[GuideSerie] = [DO].[Guide_Serie]
                           AND [Co].[GuideNumber] = [DO].[Guide_Number]
                WHERE [AccSCD].[RowStatus] = 1
                      AND [DO].[IsCollect] = 0
                      AND [Co].[TotalAmountPaid] IS NULL;

                UPDATE [dbo].[AccountServiceCartDetail]
                SET RowStatus = 0
				,[TokenUpdated] = @Token
	            ,[DateUpdated] = GETDATE()
                WHERE GuideNumber IN
                      (
                          SELECT LG.ItemNumber FROM #listGuides LG
                      );

                UPDATE [dbo].[DeliveryOrderPaymentDetail]
                SET [ShipmentCompleted] = 1
				,[TokenUpdated] = @Token
	            ,[DateUpdated] = GETDATE()
                WHERE GuideNumber IN
                      (
                          SELECT LG.ItemNumber FROM #listGuides LG
                      );

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                SELECT 0 AS 'StatusCode',
                       0 AS 'IdConflictManifest',
                       ERROR_MESSAGE() AS 'Description',
                       CONVERT(BIGINT, 0) AS 'NumTransferID';
                ROLLBACK TRANSACTION;
            END CATCH;

        END;

        ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	
        --Buscar ID modulo liquidación Recolecciones
        SET @CatModuleId = ISNULL(
                           (
                               SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación COD'
                           ),
                           0
                                 );

        IF OBJECT_ID('tempdb.dbo.#listGuidesNotProcess', 'U') IS NOT NULL
            DROP TABLE #listGuidesNotProcess;

        CREATE TABLE #listGuidesNotProcess
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT
        );

        CREATE NONCLUSTERED INDEX listGuidesTempesserie
        ON #listGuidesNotProcess (
                               ItemSerie,
                               ItemNumber
                           );

        INSERT INTO #listGuidesNotProcess
        (
            ItemSerie,
            ItemNumber,
            ItemPiece
        )
        SELECT ItemSerie
			  ,ItemNumber
			  ,ItemPiece
        FROM #listGuides
		WHERE NOT EXISTS (	SELECT	1 
							FROM	[dbo].[ProcessedGuideCOD] WITH (NOLOCK)
							WHERE	[GuideNumber] = ItemNumber
									AND GuideSerie = ItemSerie
						 );

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
                       cou.CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer
                FROM #listGuidesNotProcess   lgnp
					INNER JOIN [dbo].[DeliveryOrder] do WITH (NOLOCK)
						ON  do.Guide_Serie = lgnp.ItemSerie
						AND do.Guide_Number = lgnp.ItemNumber
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                        ON  lgnp.ItemSerie = DOP.GuideSerie
                        AND lgnp.ItemNumber = DOP.GuideNumber
					OUTER APPLY
					(
						SELECT	TOP 1
								ID_Courier [CourierId]
						FROM	[dbo].[DeliveryAttempt] WITH (NOLOCK)
						WHERE	[Guide_Serie] = lgnp.ItemSerie
							AND [Guide_Number] = lgnp.ItemNumber
					) cou
                WHERE do.IsCollect = 'false'
                  AND DOP.TimePlaId = 2;

    ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . FIN ----------------------		

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               0 AS 'IdConflictManifest',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@Idd > 0)
            SELECT @Idd AS 'StatusCode',
                   @IdConflictManifest AS 'IdConflictManifest',
                   'Registro guardado correctamente' AS 'Description',
                   @@TRANCOUNT AS 'NumTransferID';
        ELSE
            SELECT 0 AS 'StatusCode',
                   0 AS 'IdConflictManifest',
                   'Registro no encontrado' AS 'Description',
                   0 AS 'NumTransferID';

        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               0 AS 'IdConflictManifest',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';

END;