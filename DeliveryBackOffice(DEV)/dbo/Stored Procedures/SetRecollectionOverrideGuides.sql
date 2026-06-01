
/*
-- =============================================
-- Author:		<Jorge,Murillo>
-- Create date: <2021-02-10>
-- Description:	<Override a group guides>
-- =============================================
*/
-- Author:		<Edelman Vásquez>
-- Update date: <07/06/2022>
-- Description:	<Control de Anulación de guías y cupones>
-- =============================================

CREATE PROCEDURE [dbo].[SetRecollectionOverrideGuides]
    @System AS INT = 1
  , @IdCustomer AS INT = 1
  , @Token AS NVARCHAR(50) = ''
  , @NumberGuides AS VARCHAR(MAX) = ''
  , @SerieGuides AS VARCHAR(MAX) = ''
AS
BEGIN

    SET NOCOUNT ON;
    /*VALIDAR QUE NO EXISTA EL PAGO POR DETALLE*/
    DECLARE @COUNTGUIDES  INT = 0
          , @IDENTYGUIDES INT = 1
          , @TOTAL        INT = 0;
    DECLARE @TBGUIDES TABLE
    (
        ITERATOR INT IDENTITY(1, 1)
      , GuideNumber INT
      , SerieGuide VARCHAR(2)
    );
    DECLARE @STATUSGUIDE VARCHAR(50);
    ;WITH CTE
    AS (SELECT Split.a.value('.', 'NVARCHAR(MAX)')        GuideNumber
             , ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) RN
        FROM
        (
            SELECT CAST('<X>' + REPLACE(@NumberGuides, ',', '</X><X>') + '</X>' AS XML) AS String
        )                                  AS A
            CROSS APPLY String.nodes('/X') AS Split(a) )
        , CTE1
    AS (SELECT Split.a.value('.', 'NVARCHAR(MAX)')        SerieGuide
             , ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) RN
        FROM
        (
            SELECT CAST('<X>' + REPLACE(@SerieGuides, ',', '</X><X>') + '</X>' AS XML) AS String
        )                                  AS A
            CROSS APPLY String.nodes('/X') AS Split(a) )
    INSERT INTO @TBGUIDES
    (
        GuideNumber
      , SerieGuide
    )
    SELECT C.GuideNumber
         , C1.SerieGuide
    FROM CTE           C
        LEFT JOIN CTE1 C1
            ON C1.RN = C.RN;


    SELECT @COUNTGUIDES = COUNT(1)
    FROM @TBGUIDES;

    --Variabes Membresías y suscripciones
    DECLARE @MembershipId INT;
    DECLARE @SubscriptionId INT;
    DECLARE @MembershipSubscriptionLogId BIGINT;
    DECLARE @PointsByServiceLogId INT = NULL;
    DECLARE @PointsToReceive INT = NULL;
    -------------------------------------

    WHILE (@COUNTGUIDES > 0)
    BEGIN
        /*ANULAR GUIA INDIVIDUAL*/
        DECLARE @ESTADO INT = 0;
        /*
				select @ESTADO = isnull(O.ShipmentCompleted,0) from DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail O
				JOIN  @TBGUIDES T
				ON T.GuideNumber = O.GuideNumber AND RTRIM(LTRIM(O.GuideSerie)) = RTRIM(LTRIM(T.SerieGuide))
				WHERE T.ITERATOR = @IDENTYGUIDES
				*/
        SELECT @ESTADO = CASE
                             WHEN COUNT(1) > 0 THEN
                                 1
                             ELSE
                                 0
                         END
        FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
        WHERE OrderNumber =
        (
            SELECT (RTRIM(LTRIM(SerieGuide)) + CONVERT(VARCHAR, T.GuideNumber)) AS OrderNumber
            FROM @TBGUIDES T
            WHERE T.ITERATOR = @IDENTYGUIDES
        );


        IF (@ESTADO = 0)
        BEGIN
            --NO PAGADO CON TARJETA INDIVIDUAL
            SELECT @ESTADO = CASE
                                 WHEN COUNT(1) > 0 THEN
                                     2
                                 ELSE
                                     0
                             END
            FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail D WITH(NOLOCK)
                INNER JOIN @TBGUIDES                                          T
                    ON D.SerieNumber = T.SerieGuide
                       AND T.GuideNumber = D.ProductNumber
            WHERE T.ITERATOR = @IDENTYGUIDES;

            --SELECT @ESTADO						
            IF (@ESTADO = 0)
            BEGIN --SI ES PARTE DE UN LOTTE DE PAGADO CON TARJETA
                SELECT @ESTADO = CASE
                                     WHEN COUNT(1) > 0 THEN
                                         3
                                     ELSE
                                         0
                                 END
                FROM DeliveryBackOffice.dbo.DeliveryOrder O WITH(NOLOCK)
                    INNER JOIN @TBGUIDES                  T
                        ON 
                          O.Guide_Serie = T.SerieGuide
						   and T.GuideNumber = O.Guide_Number
                          
                          
                WHERE T.ITERATOR = @IDENTYGUIDES AND   O.StatusOrderId IN(15,1);

            END;
        END;
        IF (@ESTADO = 3)
        BEGIN
            ------Validación para saber si una guía tiene cupón redimido y no permita anulación
            --PENDIENTE DE PAGO


            SET @STATUSGUIDE =
            (
                SELECT CASE
                           WHEN PC.RedeemedDate IS NOT NULL
                                AND PC.RowStatus = 1
                                AND PC.GuideNumberDestination <> CAST(@NumberGuides AS INT) THEN
                               'CANJEADO'
                           WHEN PC.RedeemedDate IS NULL
                                AND PC.GuideNumberOrigin = CAST(@NumberGuides AS INT)
                                AND PC.RowStatus = 1 THEN
                               'Guía Origen'
                           WHEN PC.RowStatus = 0 THEN
                               'ANULADO'
                           WHEN PC.GuideNumberDestination IS NOT NULL
                                AND PC.RowStatus = 1
                                AND PC.GuideNumberDestination = CAST(@NumberGuides AS INT) THEN
                               'Guía Destino'
                           ELSE
                               SO.OrderDescription
                       END ESTATUSGUIDE
                FROM [DeliveryBackOffice].[dbo].PromoCoupon             PC WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].CatPromo      CP WITH (NOLOCK)
                        ON PC.CatPromoId = CP.IdPromo
                    RIGHT JOIN [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                        ON PC.GuideSerieOrigin = DO.Guide_Serie
                           AND PC.GuideNumberOrigin = DO.Guide_Number
                    INNER JOIN [DeliveryBackOffice].[dbo].StatusOrder   SO WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                WHERE DO.Guide_Serie = @SerieGuides
                      AND DO.Guide_Number = CAST(@NumberGuides AS INT)
            );

            ------------------------------------------------------------
            IF (@STATUSGUIDE = 'CANJEADO')
            BEGIN
                ---No se pueden anular guías que tengan cumpones redimidos----
                SET @TOTAL = @TOTAL + 0;
            END;
            ELSE IF (@STATUSGUIDE = 'Guía Origen')
            BEGIN
                ------- Anular cupon y guía de Origen -----------------
                UPDATE do
                SET StatusOrderId = 7
				FROM DeliveryBackOffice.dbo.DeliveryOrder do
				INNER JOIN @TBGUIDES tbg ON tbg.SerieGuide = do.Guide_Serie AND tbg.GuideNumber = do.Guide_Number
				WHERE tbg.ITERATOR = @IDENTYGUIDES;


                UPDATE [DeliveryBackOffice].[dbo].[PromoCoupon]
                SET SystemDestination = NULL
                  , CustomerDestination = NULL
                  , VisitPointClientDestination = NULL
                  , VisitPointClientPortfolioDestination = NULL
                  , GuideSerieDestination = NULL
                  , GuideNumberDestination = NULL
                  , ServiceManagementDestination = NULL
                  , RedeemedDate = NULL
                  , OriginalAmount = NULL
                  , DiscountAmount = NULL
                  , FinalAmount = NULL
                  , DateUpdated = GETDATE()
                  , TokenUpdated = @Token
                WHERE GuideSerieDestination = @SerieGuides
                      AND GuideNumberDestination = CAST(@NumberGuides AS INT);

                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie
                  , Guide_Number
                  , StatusOrderId
                  , UserCreated
                  , DateCreated
                  , DateCreatedInSystem
                )
                SELECT SerieGuide
                     , GuideNumber
                     , 7
                     , @Token
                     , GETDATE()
                     , GETDATE()
                FROM @TBGUIDES
                WHERE ITERATOR = @IDENTYGUIDES;

                --Membresías y suscripciones
                --Oscar Morales 25/07/2022
                SET @MembershipSubscriptionLogId = NULL;

                SELECT @MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
                     , @MembershipId                = msl.MembershipId
                     , @SubscriptionId              = msl.SubscriptionId
                FROM MembershipSubscriptionLog msl WITH (NOLOCK)
                    INNER JOIN @TBGUIDES       tb
                        ON tb.SerieGuide = msl.LogGuideSerie
                           AND tb.GuideNumber = msl.LogGuideNumber
                WHERE tb.ITERATOR = @IDENTYGUIDES
                      AND msl.RowStatus = 1;

                IF @MembershipSubscriptionLogId IS NOT NULL
                BEGIN

                    UPDATE MembershipSubscriptionLog
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId;

                    IF @SubscriptionId IS NULL
                    BEGIN

                        UPDATE Membership
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdMembership = @MembershipId;
                    END;
                    ELSE
                    BEGIN

                        UPDATE Subscription
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdSubscription = @SubscriptionId;
                    END;

                END;
                --Termina Membresías y suscripciones

                -- puntos forza
                SET @PointsByServiceLogId = NULL;
                SET @PointsToReceive = NULL;

                SELECT @PointsByServiceLogId = PBSL.IdPointsByServiceLog
                     , @MembershipId         = PBSL.MembershipId
                     , @PointsToReceive      = PBSL.PointsConsumed
                FROM [DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH (NOLOCK)
                    INNER JOIN @TBGUIDES                             TB
                        ON TB.SerieGuide = PBSL.GuideSerie
                           AND TB.GuideNumber = PBSL.GuideNumber
                           AND ISNULL(PBSL.PointsConsumed, 0) > 0
                WHERE TB.ITERATOR = @IDENTYGUIDES
                      AND PBSL.RowStatus = 1;

                IF (@PointsByServiceLogId IS NOT NULL)
                BEGIN

                    -- Inactivar registro de bitacora
                    UPDATE [DeliveryBackOffice].[dbo].[PointsByServiceLog]
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdPointsByServiceLog = @PointsByServiceLogId;

                    -- Devolver puntos forza
                    UPDATE [DeliveryBackOffice].[dbo].[Membership]
                    SET AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembership = @MembershipId;

                END;
                -- Termina puntos forza

                SET @TOTAL = @TOTAL + 1;

            END;
            ELSE IF (@STATUSGUIDE = 'ANULADO')
            BEGIN
                ---- GUÍA YA FUE ANULADA
                SET @TOTAL = @TOTAL + 0;
            END;
            ELSE IF (@STATUSGUIDE = 'Guía Destino')
            BEGIN

                ------- Anular cupon y guía de Destino -----------------
                UPDATE do
                SET StatusOrderId = 7
				FROM DeliveryBackOffice.dbo.DeliveryOrder do
				INNER JOIN @TBGUIDES tbg ON tbg.SerieGuide = do.Guide_Serie AND tbg.GuideNumber = do.Guide_Number
				WHERE tbg.ITERATOR = @IDENTYGUIDES;


                UPDATE [DeliveryBackOffice].[dbo].[PromoCoupon]
                SET SystemDestination = NULL
                  , CustomerDestination = NULL
                  , VisitPointClientDestination = NULL
                  , VisitPointClientPortfolioDestination = NULL
                  , GuideSerieDestination = NULL
                  , GuideNumberDestination = NULL
                  , ServiceManagementDestination = NULL
                  , RedeemedDate = NULL
                  , OriginalAmount = NULL
                  , DiscountAmount = NULL
                  , FinalAmount = NULL
                  , DateUpdated = GETDATE()
                  , TokenUpdated = @Token
                WHERE GuideSerieDestination = @SerieGuides
                      AND GuideNumberDestination = CAST(@NumberGuides AS INT);

                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie
                  , Guide_Number
                  , StatusOrderId
                  , UserCreated
                  , DateCreated
                  , DateCreatedInSystem
                )
                SELECT SerieGuide
                     , GuideNumber
                     , 7
                     , @Token
                     , GETDATE()
                     , GETDATE()
                FROM @TBGUIDES
                WHERE ITERATOR = @IDENTYGUIDES;

                --Membresías y suscripciones
                --Oscar Morales 25/07/2022
                SET @MembershipSubscriptionLogId = NULL;

                SELECT @MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
                     , @MembershipId                = msl.MembershipId
                     , @SubscriptionId              = msl.SubscriptionId
                FROM MembershipSubscriptionLog msl WITH (NOLOCK)
                    INNER JOIN @TBGUIDES       tb
                        ON tb.SerieGuide = msl.LogGuideSerie
                           AND tb.GuideNumber = msl.LogGuideNumber
                WHERE tb.ITERATOR = @IDENTYGUIDES
                      AND msl.RowStatus = 1;

                IF @MembershipSubscriptionLogId IS NOT NULL
                BEGIN

                    UPDATE MembershipSubscriptionLog
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId;

                    IF @SubscriptionId IS NULL
                    BEGIN

                        UPDATE Membership
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdMembership = @MembershipId;
                    END;
                    ELSE
                    BEGIN

                        UPDATE Subscription
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdSubscription = @SubscriptionId;
                    END;

                END;
                --Termina Membresías y suscripciones

                -- puntos forza
                SET @PointsByServiceLogId = NULL;
                SET @PointsToReceive = NULL;

                SELECT @PointsByServiceLogId = PBSL.IdPointsByServiceLog
                     , @MembershipId         = PBSL.MembershipId
                     , @PointsToReceive      = PBSL.PointsConsumed
                FROM [DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH (NOLOCK)
                    INNER JOIN @TBGUIDES                             TB
                        ON TB.SerieGuide = PBSL.GuideSerie
                           AND TB.GuideNumber = PBSL.GuideNumber
                           AND ISNULL(PBSL.PointsConsumed, 0) > 0
                WHERE TB.ITERATOR = @IDENTYGUIDES
                      AND PBSL.RowStatus = 1;

                IF (@PointsByServiceLogId IS NOT NULL)
                BEGIN

                    -- Inactivar registro de bitacora
                    UPDATE [DeliveryBackOffice].[dbo].[PointsByServiceLog]
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdPointsByServiceLog = @PointsByServiceLogId;

                    -- Devolver puntos forza
                    UPDATE [DeliveryBackOffice].[dbo].[Membership]
                    SET AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembership = @MembershipId;

                END;
                -- Termina puntos forza

                SET @TOTAL = @TOTAL + 1;
            END;
            --------Anular guía con estado Solicitado -----
            ELSE IF (@STATUSGUIDE = 'Solicitado')
            BEGIN
			
                UPDATE do
                SET StatusOrderId = 7
				FROM DeliveryBackOffice.dbo.DeliveryOrder do
				INNER JOIN @TBGUIDES tbg ON tbg.SerieGuide = do.Guide_Serie AND tbg.GuideNumber = do.Guide_Number
				WHERE tbg.ITERATOR = @IDENTYGUIDES;


                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie
                  , Guide_Number
                  , StatusOrderId
                  , UserCreated
                  , DateCreated
                  , DateCreatedInSystem
                )
                SELECT SerieGuide
                     , GuideNumber
                     , 7
                     , @Token
                     , GETDATE()
                     , GETDATE()
                FROM @TBGUIDES
                WHERE ITERATOR = @IDENTYGUIDES;

                --Membresías y suscripciones
                --Oscar Morales 25/07/2022
                SET @MembershipSubscriptionLogId = NULL;

                SELECT @MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
                     , @MembershipId                = msl.MembershipId
                     , @SubscriptionId              = msl.SubscriptionId
                FROM MembershipSubscriptionLog msl WITH	(NOLOCK)
                    INNER JOIN @TBGUIDES       tb
                        ON tb.SerieGuide = msl.LogGuideSerie
                           AND tb.GuideNumber = msl.LogGuideNumber
                WHERE tb.ITERATOR = @IDENTYGUIDES
                      AND msl.RowStatus = 1;

                IF @MembershipSubscriptionLogId IS NOT NULL
                BEGIN

                    UPDATE MembershipSubscriptionLog
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId;

                    IF @SubscriptionId IS NULL
                    BEGIN

                        UPDATE Membership
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdMembership = @MembershipId;
                    END;
                    ELSE
                    BEGIN

                        UPDATE Subscription
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdSubscription = @SubscriptionId;
                    END;

                END;
                --Termina Membresías y suscripciones

                -- puntos forza
                SET @PointsByServiceLogId = NULL;
                SET @PointsToReceive = NULL;

                SELECT @PointsByServiceLogId = PBSL.IdPointsByServiceLog
                     , @MembershipId         = PBSL.MembershipId
                     , @PointsToReceive      = PBSL.PointsConsumed
                FROM [DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH (NOLOCK)
                    INNER JOIN @TBGUIDES                             TB
                        ON TB.SerieGuide = PBSL.GuideSerie
                           AND TB.GuideNumber = PBSL.GuideNumber
                           AND ISNULL(PBSL.PointsConsumed, 0) > 0
                WHERE TB.ITERATOR = @IDENTYGUIDES
                      AND PBSL.RowStatus = 1;

                IF (@PointsByServiceLogId IS NOT NULL)
                BEGIN

                    -- Inactivar registro de bitacora
                    UPDATE [DeliveryBackOffice].[dbo].[PointsByServiceLog]
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdPointsByServiceLog = @PointsByServiceLogId;

                    -- Devolver puntos forza
                    UPDATE [DeliveryBackOffice].[dbo].[Membership]
                    SET AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembership = @MembershipId;

                END;
                -- Termina puntos forza


                SET @TOTAL = @TOTAL + 1;
            END;
            --------Anular guía con estado Generado -----
            ELSE IF (@STATUSGUIDE = 'Generado')
            BEGIN

			
                UPDATE do
                SET StatusOrderId = 7
				FROM DeliveryBackOffice.dbo.DeliveryOrder do
				INNER JOIN @TBGUIDES tbg ON tbg.SerieGuide = do.Guide_Serie AND tbg.GuideNumber = do.Guide_Number
				WHERE tbg.ITERATOR = @IDENTYGUIDES;


                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie
                  , Guide_Number
                  , StatusOrderId
                  , UserCreated
                  , DateCreated
                  , DateCreatedInSystem
                )
                SELECT SerieGuide
                     , GuideNumber
                     , 7
                     , @Token
                     , GETDATE()
                     , GETDATE()
                FROM @TBGUIDES
                WHERE ITERATOR = @IDENTYGUIDES;

                --Membresías y suscripciones
                --Oscar Morales 25/07/2022
                SET @MembershipSubscriptionLogId = NULL;

                SELECT @MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
                     , @MembershipId                = msl.MembershipId
                     , @SubscriptionId              = msl.SubscriptionId
                FROM MembershipSubscriptionLog msl with (nolock)
                    INNER JOIN @TBGUIDES       tb
                        ON tb.SerieGuide = msl.LogGuideSerie
                           AND tb.GuideNumber = msl.LogGuideNumber
                WHERE tb.ITERATOR = @IDENTYGUIDES
                      AND msl.RowStatus = 1;

                IF @MembershipSubscriptionLogId IS NOT NULL
                BEGIN

                    UPDATE MembershipSubscriptionLog
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId;

                    IF @SubscriptionId IS NULL
                    BEGIN

                        UPDATE Membership
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdMembership = @MembershipId;
                    END;
                    ELSE
                    BEGIN

                        UPDATE Subscription
                        SET ActualServiceCount = ActualServiceCount - 1
                          , TokenUpdated = @Token
                          , DateUpdated = GETDATE()
                        WHERE IdSubscription = @SubscriptionId;
                    END;

                END;
                --Termina Membresías y suscripciones

                -- puntos forza
                SET @PointsByServiceLogId = NULL;
                SET @PointsToReceive = NULL;

                SELECT @PointsByServiceLogId = PBSL.IdPointsByServiceLog
                     , @MembershipId         = PBSL.MembershipId
                     , @PointsToReceive      = PBSL.PointsConsumed
                FROM [DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH (NOLOCK)
                    INNER JOIN @TBGUIDES                             TB
                        ON TB.SerieGuide = PBSL.GuideSerie
                           AND TB.GuideNumber = PBSL.GuideNumber
                           AND ISNULL(PBSL.PointsConsumed, 0) > 0
                WHERE TB.ITERATOR = @IDENTYGUIDES
                      AND PBSL.RowStatus = 1;

                IF (@PointsByServiceLogId IS NOT NULL)
                BEGIN

                    -- Inactivar registro de bitacora
                    UPDATE [DeliveryBackOffice].[dbo].[PointsByServiceLog]
                    SET RowStatus = 0
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdPointsByServiceLog = @PointsByServiceLogId;

                    -- Devolver puntos forza
                    UPDATE [DeliveryBackOffice].[dbo].[Membership]
                    SET AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembership = @MembershipId;

                END;
                -- Termina puntos forza

                SET @TOTAL = @TOTAL + 1;
            END;
            ELSE
            BEGIN
                ------------ ESTADOS NO CONTEMPLADOS PARA PERMITIR LA ANULACIÓN
                SET @TOTAL = @TOTAL + 0;
            END;

        END;
        --Pieces
        DECLARE @TempGuide NVARCHAR(MAX) =
                (
                    SELECT T.GuideNumber FROM @TBGUIDES T WHERE T.ITERATOR = @IDENTYGUIDES
                );
        DECLARE @TempSerie NVARCHAR(MAX) =
                (
                    SELECT T.SerieGuide FROM @TBGUIDES T WHERE T.ITERATOR = @IDENTYGUIDES
                );



        UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
        SET StatusOrderId = 7
        WHERE GuideSerie = @TempSerie
              AND GuideNumber = @TempGuide;


        IF EXISTS
        (
            SELECT *
            FROM DeliveryBackOffice.dbo.GuideBatch WITH (NOLOCK)
            WHERE GuideSeries ='FD' AND GuideNumber = @TempGuide
                  AND RowStatus = 1
        )
        BEGIN

            UPDATE DeliveryBackOffice.dbo.GuideBatch
            SET RowStatus = 0
              , Status = 0
            WHERE GuideSeries = @TempSerie
                  AND GuideNumber = @TempGuide;

        END;

        --finish while for pieces
        SET @IDENTYGUIDES = @IDENTYGUIDES + 1;
        SET @COUNTGUIDES = @COUNTGUIDES - 1;
    END;

    SELECT FormatJson = '{ "TOTAL":' + CONVERT(VARCHAR, @TOTAL) + '}';

END;