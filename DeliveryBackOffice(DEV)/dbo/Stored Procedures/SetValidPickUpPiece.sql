-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-15>
-- Description:	<Se validan las piezas que se van a procesar para la nueva APP de escaneo>
--'FD9561508-1,FD9561508-2',884469,'1681cb91fdded6f423ab40df9d3a5515','GT'
-- =============================================
CREATE PROCEDURE [dbo].[SetValidPickUpPiece]
    @InGuides NVARCHAR(MAX) = 'FD9559566-1,FD9559566-2',
    @IdPickup INT = NULL,
    @Token NVARCHAR(200) = NULL,
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRY
        DECLARE @NoPiece INT,
                @NoPieceEntered INT,
                @TokenAct INT,
                @hourtoken INT,
                @IspickupGuide INT,
                @GuideNumber INT,
                @Valid INT,
                @ValidCountry INT,
                @GuideSerie NVARCHAR(2) = 'FD'

        IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
            DROP TABLE #Temp;

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;

        SELECT TOP 1
            @TokenAct = RowStatus,
            @hourtoken = DATEDIFF(HOUR, DateCreated, GETDATE())
        FROM LogTokenPOD WITH (NOLOCK)
        WHERE LogTokenPOD = @Token
        ORDER BY DateCreated DESC

        IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
        BEGIN
            CREATE TABLE #Temp
            (
                Guide NVARCHAR(255),
                [Message] NVARCHAR(255),
            );

            CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

            CREATE TABLE #listGuides
            (
                ItemSerie NVARCHAR(2),
                ItemNumber INT
            );

            CREATE NONCLUSTERED INDEX templistGuides_Piece495
            ON #listGuides
            (
                ItemSerie,
                ItemNumber
            );

            INSERT INTO #listGuides
            (
                ItemSerie,
                ItemNumber
            )
            SELECT SUBSTRING(Item, 1, 2) AS ItemSerie,
                   CASE
                       WHEN CHARINDEX('-', Item) = 0 THEN
                           CAST(SUBSTRING(Item, 3, LEN(Item)) AS INT)
                       ELSE
                           CAST(SUBSTRING(Item, 3, CHARINDEX('-', Item) - 3) AS INT)
                   END AS ItemNumber
            FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

			------Guías procesadas------
            INSERT INTO #Temp
            (
                Guide,
                Message
            )
            SELECT DISTINCT
                CONCAT(DP.GuideSerie, DP.GuideNumber) AS Guide,
                'La guía ya fue procesada' AS Message
            FROM DeliveryOrderPiece DP WITH (NOLOCK)
                INNER JOIN #listGuides LS
                    ON DP.GuideSerie = LS.ItemSerie
                       AND DP.GuideNumber = LS.ItemNumber
            WHERE ISNULL(DP.IsPickup, 0) = 1        

			------Guías que no existen-----
            INSERT INTO #Temp
            (
                Guide,
                Message
            )
            SELECT DISTINCT
                CONCAT(LS.ItemSerie, LS.ItemNumber) AS Guide,
                CASE
                    WHEN DO.Guide_Number IS NULL THEN
                        'La guía no existe'
                    ELSE
                        'Ok'
                END AS Message
            FROM #listGuides LS
                LEFT JOIN DeliveryOrder DO WITH (NOLOCK)
                    ON DO.Guide_Serie = LS.ItemSerie
                       AND DO.Guide_Number = LS.ItemNumber

			------Guías de otro país-----
            INSERT INTO #Temp
            (
                Guide,
                Message
            )
            SELECT DISTINCT
                CONCAT(DO.Guide_Serie, DO.Guide_Number) AS Guide,
                CASE
                    WHEN DO.SenderCountryId != @IdCountry THEN
                        'Las guías petenecen a otro país'
                    ELSE
                        'Ok'
                END AS Message
            FROM #listGuides LS
                INNER JOIN DeliveryOrder DO WITH (NOLOCK)
                    ON DO.Guide_Serie = LS.ItemSerie
                       AND DO.Guide_Number = LS.ItemNumber

            SELECT CAST(Guide AS NVARCHAR(255)) AS Guide,
                   CAST([Message] AS NVARCHAR(255)) AS [Message] 
            FROM #Temp
            WHERE Message != 'Ok'
        END
        ELSE
        BEGIN
            SELECT '0' AS Guide,
                   'El Token no es valido' AS Message
        END

    END TRY
    BEGIN CATCH
        SELECT '0' AS Guide,
               ERROR_MESSAGE() AS Message
               --ERROR_LINE() AS ErrorLine
    END CATCH
END