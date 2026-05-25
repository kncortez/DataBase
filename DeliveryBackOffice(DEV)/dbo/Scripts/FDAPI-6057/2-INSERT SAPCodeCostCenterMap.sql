-- ============================================================
-- SCRIPT 2: INSERT SAPCodeCostCenterMap
-- ============================================================
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.SAPCodeCostCenterMap', 'U') IS NULL
        RAISERROR('La tabla dbo.SAPCodeCostCenterMap no existe en la base de datos.', 16, 1);

    IF OBJECT_ID('dbo.CatArticleSAP', 'U') IS NULL
        RAISERROR('La tabla dbo.CatArticleSAP no existe en la base de datos.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatArticleSAP] WITH(NOLOCK) WHERE [IdCountry] = N'GT' AND [RowSatus] = 1)
        RAISERROR('No se encontraron registros en CatArticleSAP para IdCountry = GT con RowStatus = 1.', 16, 1);

    INSERT [dbo].[SAPCodeCostCenterMap] ([SAPCode], [Name], [Description], [OcrCode2], [IdCountry])
    SELECT
        A.[SAPCode],
        A.[Name],
        A.[Description],
        CASE
            WHEN A.[SAPCode] IN (N'409010401', N'409010402', N'409010404')                                              THEN N'400100'
            WHEN A.[SAPCode] IN (N'409020104', N'409020105', N'409020106', N'409020107', N'409020108')                  THEN N'400200'
            WHEN A.[SAPCode] IN (N'409040101', N'409040102', N'409040103', N'409040104', N'409040105')                  THEN N'400300'
            WHEN A.[SAPCode] IN (N'409100101', N'409110101', N'409110102', N'409110103', N'409110104')                  THEN N'400600'
            ELSE N'400000'
        END AS [OcrCode2],
        A.[IdCountry]
    FROM [dbo].[CatArticleSAP] A WITH(NOLOCK)
    WHERE A.[IdCountry] = N'GT'
      AND A.[RowSatus]  = 1
      AND NOT EXISTS (
          SELECT 1
          FROM [dbo].[SAPCodeCostCenterMap] B
          WHERE B.[SAPCode]   = A.[SAPCode]
            AND B.[IdCountry] = A.[IdCountry]
            AND B.[RowStatus] = 1
      );

    DECLARE @RowsInserted INT = @@ROWCOUNT;

    COMMIT TRANSACTION;
    PRINT CONCAT(N' Transacción completada exitosamente. Registros insertados: ', @RowsInserted);

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMsg   NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSev   INT            = ERROR_SEVERITY();
    DECLARE @ErrorState INT            = ERROR_STATE();
    DECLARE @ErrorLine  INT            = ERROR_LINE();
    DECLARE @ErrorProc  NVARCHAR(200)  = ISNULL(ERROR_PROCEDURE(), N'Script directo');

    PRINT N'✘ Error durante la transacción:';
    PRINT CONCAT(N'  Procedimiento : ', @ErrorProc);
    PRINT CONCAT(N'  Línea         : ', @ErrorLine);
    PRINT CONCAT(N'  Severidad     : ', @ErrorSev);
    PRINT CONCAT(N'  Mensaje       : ', @ErrorMsg);

    RAISERROR(@ErrorMsg, @ErrorSev, @ErrorState);

END CATCH;