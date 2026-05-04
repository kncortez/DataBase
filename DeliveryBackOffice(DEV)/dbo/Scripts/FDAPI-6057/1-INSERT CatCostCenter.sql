-- ============================================================
-- SCRIPT 1: INSERT CatCostCenter
-- ============================================================
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.CatCostCenter', 'U') IS NULL
        RAISERROR('La tabla dbo.CatCostCenter no existe en la base de datos.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400000' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400000', N'GENERICO',                N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400100' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400100', N'SERV. ESTANDAR',         N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400200' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400200', N'SERV. COD',              N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400300' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400300', N'SERV. INTERNACIONAL',    N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400400' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400400', N'SERV. SEGURO DE MERCANC',N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400500' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400500', N'SERV. TRANSPORTE FRIO',  N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400600' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400600', N'MEMBRESIAS Y SUSCRIPCIO',N'GT');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CatCostCenter] WHERE [Codigo] = N'400700' AND [IdCountry] = N'GT')
        INSERT [dbo].[CatCostCenter] ([Codigo], [Descripcion], [IdCountry]) VALUES (N'400700', N'SUB ARREND. ESPACIOS',   N'GT');

    COMMIT TRANSACTION;
    PRINT N' Transacción completada exitosamente.';

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

