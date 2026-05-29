
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-02-15>
-- Description:	<Verifica si existen guias
--				 si estan en estado 15 (generado) o 1(solicitado)
--               Si no estan asignadas a otra recolección (IdPickup) >
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-03-10>
-- Description:	<Al procesar guías en proceso de recolección desde la CourierApp, si durante el proceso de verificación de montos se detecta una guía en estado terminal, debe impedir el proceso indicando las guías y los estados de estas.>
-- =============================================
-- =============================================  
-- Mofified:    <Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - se agrega parametro para buscar guias de un contenedor asociado o referencia>  
-- =============================================  
CREATE PROCEDURE [dbo].[spws_get_validate_guides_pickup_BNHL]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD138515,FD138513,FD13852,FD138514,FD138545,FD135539',
    @IdPickup BIGINT = 120,
    @Token NVARCHAR(50),
    @ReferencesGuide TblReferencesList READONLY,
    @ContainerReferences TblContainerList READONLY,
    @IdCountry NVARCHAR(2) = 'GT'
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#ErrorGuides', 'U') IS NOT NULL
            DROP TABLE #ErrorGuides;

        CREATE TABLE #listGuides
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT,
            charinde NVARCHAR(10),
            Item INT
        );
        -- BUSCAR GUIAS POR REFERENCIA Y CONTENEDOR  
        WITH CTE_Ranked
        AS (SELECT DO.Guide_Serie AS GuideSerie,
                   DO.Guide_Number AS GuideNumber,
                   DOP.NoPiece,
                   DO.Ticket_Number,
                   ROW_NUMBER() OVER (PARTITION BY DO.Ticket_Number ORDER BY DO.Guide_Number DESC) AS RowNum
            FROM DeliveryOrder DO WITH (NOLOCK)
                JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
                    ON DO.Guide_Serie = DOP.GuideSerie
                       AND DO.Guide_Number = DOP.GuideNumber
            WHERE DO.Ticket_Number IN
                  (
                      SELECT ReferenceGuide FROM @ReferencesGuide
                  )
                  AND DO.SenderCountryId = @IdCountry)
        INSERT INTO #listGuides
        (
            ItemSerie,
            ItemNumber,
            ItemPiece,
            charinde,
            Item
        )
        SELECT GuideSerie,
               GuideNumber,
               NoPiece,
               '',
               1
        FROM CTE_Ranked
        WHERE RowNum = 1       
        UNION
        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               ISNULL(   (CASE
                              WHEN LEN(SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))) > 1 THEN
                                  1
                              ELSE
                                  SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))
                          END
                         ),
                         0
                     ) ItemPiece,
               CHARINDEX('-', Item) charinde,
               LEN(Item) len
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

        IF
        (
            SELECT COUNT(*)FROM #listGuides
        ) > 2000 -- threshold recomendado por que  no se "amoritza" la creación del indice
        BEGIN
            CREATE NONCLUSTERED INDEX IX_listGuides_Pickup
            ON #listGuides (
                               ItemSerie,
                               ItemNumber
                           );
        END;

        --Se inserta log de cambio de recolección a un servicio
        INSERT INTO ServicePickupLog
        (
            GuideSerie,
            GuideNumber,
            OldIdHeaderRecolection,
            NewIdHeaderRecolection,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated
        )
        SELECT DISTINCT
               g.ItemSerie,
               g.ItemNumber,
               COALESCE(dopd.IdHeaderRecolection, -1),
               @IdPickup,
               1,
               @Token,
               GETDATE(),
               NULL,
               NULL
        FROM #listGuides g
            INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                ON dopd.GuideSerie = g.ItemSerie
                   AND dopd.GuideNumber = g.ItemNumber
            INNER JOIN DeliveryOrder do WITH (NOLOCK)
                ON do.Guide_Serie = g.ItemSerie
                   AND do.Guide_Number = g.ItemNumber
        WHERE COALESCE(dopd.IdHeaderRecolection, 0) <> @IdPickup
              AND do.StatusOrderId IN ( 16, 15, 1, 21, 20, 10 )
              AND do.StatusOrderId <> 7 --BNHL
              ;

        --Se asignan los servicios a la nueva recolección
        UPDATE dopd
        SET dopd.IdHeaderRecolection = @IdPickup
        FROM DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
            INNER JOIN #listGuides g
                ON g.ItemSerie = dopd.GuideSerie
                   AND g.ItemNumber = dopd.GuideNumber
            INNER JOIN DeliveryOrder do WITH (NOLOCK)
                ON do.Guide_Serie = g.ItemSerie
                   AND do.Guide_Number = g.ItemNumber
        WHERE COALESCE(dopd.IdHeaderRecolection, 0) <> @IdPickup
              AND do.StatusOrderId IN ( 16, 15, 1, 21, 20, 10 );

        SELECT DISTINCT
               lst.ItemSerie,
               lst.ItemNumber,
               ISNULL(dr.Guide_Number, 0) exist,
               IIF(ISNULL(pyt.IdHeaderRecolection, 0) = @IdPickup, 1, IIF(ISNULL(pyt.IdHeaderRecolection, 0) = 0, 1, 0)) pik,
               IIF(dr.StatusOrderId IN ( 16, 15, 1, 21, 20, 10 ), 1, 0) status,
               st.OrderDescription,
               --IIF(DR.SenderCountryId=@IDCOUNTRYSERVICE,1,0) samecountry,
               1 samecountry,
               dr.SenderCountryId guidecountry

        --, pyt.IdHeaderRecolection
        INTO #ErrorGuides
        FROM #listGuides lst
            LEFT JOIN dbo.DeliveryOrder dr WITH (NOLOCK)
                ON dr.Guide_Serie = lst.ItemSerie
                   AND dr.Guide_Number = lst.ItemNumber
            LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH (NOLOCK)
                ON pyt.GuideSerie = dr.Guide_Serie
                   AND pyt.GuideNumber = dr.Guide_Number
            LEFT JOIN dbo.StatusOrder st WITH (NOLOCK)
                ON st.StatusOrderId = dr.StatusOrderId
            INNER JOIN dbo.StatusOrder so WITH (NOLOCK)
                ON so.StatusOrderId = dr.StatusOrderId
                   AND so.CatCheckpointTypeId = 3
                   AND so.RowStatus = 1;
      
        CREATE NONCLUSTERED INDEX IX_ErrorGuides_Exist ON #ErrorGuides (exist);

        CREATE NONCLUSTERED INDEX IX_ErrorGuides_status ON #ErrorGuides (status);

        SELECT CONCAT(er.ItemSerie, er.ItemNumber) Guide,
               (CASE
                    WHEN er.exist = 0 THEN
                        'Servicio no existe'
                    ELSE
                        er.OrderDescription
                END
               ) Mensaje

        FROM #ErrorGuides er
        WHERE (
                  er.exist = 0
                  OR er.status = 0
                  OR er.samecountry = 0
              ); --  or er.pik =0  Se elimina esta validacione por la reasignación

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#ErrorGuides', 'U') IS NOT NULL
            DROP TABLE #ErrorGuides;

    END TRY
    BEGIN CATCH
        SELECT CAST(ERROR_NUMBER() AS NVARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS NVARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS NVARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS NVARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS NVARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS NVARCHAR(500)) AS ErrorMessage;

    END CATCH;

END;