

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Inserta el manifiesto de recoleccion>
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



        ----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	




        --Buscar ID modulo liquidación Recolecciones
        SET @CatModuleId = ISNULL(
                           (
                               SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación COD'
                           ),
                           0
                                 );


        IF OBJECT_ID('tempdb.dbo.#listGuidesTemp', 'U') IS NOT NULL
            DROP TABLE #listGuidesTemp;

        CREATE TABLE #listGuidesTemp
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT
        );
        CREATE NONCLUSTERED INDEX listGuidesTempesserie
        ON #listGuidesTemp (
                               ItemSerie,
                               ItemNumber
                           );

        INSERT INTO #listGuidesTemp
        (
            ItemSerie,
            ItemNumber,
            ItemPiece
        )
        SELECT *
        --  INTO #listGuidesTemp
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
            FROM [dbo].[DeliveryAttempt] WITH (NOLOCK)
            WHERE [Guide_Serie] = @GuideSerie
                  AND [Guide_Number] = @GuideNumber
            ORDER BY [Date_Created] DESC;

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
                      AND do.IsCollect = 'false'
                      AND DOP.TimePlaId = 2;
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

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@Idd > 0)
            SELECT @Idd AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   @@TRANCOUNT AS 'NumTransferID';
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
	 DECLARE @TotalGuide Decimal(18,2)

	------------------------ Bitacora de Guías en carrito de compras no collect y que no fueron liquidadas y se recolectaron
		If(@Idd>0)
		 Begin


		     SET @TotalGuide= ( SELECT
									 
								Sum([DO].[PriceShippment])
							FROM
								[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
							ON
							    [DO].[Guide_Serie] = [AccSCD].[GuideSerie] AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
							ON
								[Co].[GuideSerie] = [DO].[Guide_Serie] AND [Co].[GuideNumber] = [DO].[Guide_Number]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
							ON  Co.GuideSerie = DSD.Guide_Serie And  Co.GuideNumber= DSD.Guide_Number
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
							ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID AND dsd.RowStatus = 1
							Inner Join   
							    [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] spd WITH(NOLOCK)
							ON   DO.Guide_Serie = spd.GuideSerie AND DO.Guide_Number = spd.GuideNumber
							INNER JOIN 
							    [DeliveryBackOffice].[dbo].[SettlementByPickup] sp WITH(NOLOCK)
			                ON spd.SettlementByPickupId = sp.Id
							WHERE  [AccSCD].[RowStatus] = 1 AND
								   [DO].[IsCollect] = 0 AND
								   [Co].[TotalAmountPaid] IS NULL AND
								   [sp].Id = @Idd
							)
			  
				 Insert Into [dbo].[ConflictManifest] 
				 (
				 CourierResponsible,
				 TotalAmount,
				 RowStatus,
				 TokenCreated,
				 DateCreated
				 )
				 SELECT 
					isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,''),
					@TotalGuide,
					1,
					'Route_Settlement',
					Getdate()
				FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs WITH(NOLOCK)
				INNER JOIN 
				     [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH(NOLOCK)
				ON sr.ID = dobs.IdCourier
				INNER JOIN 
				     [DenariusUser_Dev].[dbo].[LGN_LogByToken] lbt WITH(NOLOCK)
				ON lbt.SSN_IdToken = dobs.TokenCreated
				INNER JOIN 
				     [DenariusUser_Dev].[dbo].[RouteAssigment] ra WITH(NOLOCK)
				ON (ra.IdRouteAssigment = dobs.RouteAssigmentId)
				INNER JOIN 
				     [DenariusUser_Dev].[dbo].[CatRoute] cr WITH(NOLOCK) 
				ON (cr.IdRoute = ra.IdRoute)
				WHERE dobs.ID = @Idd

			DECLARE	@Id INT = SCOPE_IDENTITY()
			
			--- Insert Detalle
			Insert Into [dbo].[ConflictManifestDetail]
			(
			
			ConflictManifestId,
			GuideSerie,
			GuideNumber,
			GuidePrice,
			RowStatus,
			TokenCreated,
			DateCreated
			)
				Select 
						@Id,
						DO.Guide_Serie,
						Do.Guide_Number,
						DO.PriceShippment,
						1,
						'Route_Settlement',
						GETDATE()
				FROM
									[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH(NOLOCK)
								INNER JOIN
									[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
								ON
									[DO].[Guide_Serie] = [AccSCD].[GuideSerie] AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
								INNER JOIN
									[DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
								ON
									[Co].[GuideSerie] = [DO].[Guide_Serie] AND [Co].[GuideNumber] = [DO].[Guide_Number]
								INNER JOIN
									[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
								ON  Co.GuideSerie = DSD.Guide_Serie And  Co.GuideNumber= DSD.Guide_Number
								INNER JOIN
									[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
								ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID AND dsd.RowStatus = 1
								Inner Join   
									[DeliveryBackOffice].[dbo].[SettlementByPickupDetail] spd WITH(NOLOCK)
								ON   DO.Guide_Serie = spd.GuideSerie AND DO.Guide_Number = spd.GuideNumber
								INNER JOIN 
									[DeliveryBackOffice].[dbo].[SettlementByPickup] sp WITH(NOLOCK)
								ON spd.SettlementByPickupId = sp.Id
				WHERE  [AccSCD].[RowStatus] = 1 AND
									   [DO].[IsCollect] = 0 AND
									   [Co].[TotalAmountPaid] IS NULL AND
									   [sp].Id = @Idd



		 End

