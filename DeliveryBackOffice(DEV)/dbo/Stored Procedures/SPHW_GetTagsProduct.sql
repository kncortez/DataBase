-- =============================================
-- Author:		<Brandon, Pedroza >
-- Create date: <2024-09-25>
-- Description:	<Obtiene lista de tags de productos para link de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetTagsProduct]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION spgetSubcategories;
    ELSE
        BEGIN TRANSACTION;
    BEGIN TRY

        SELECT 200 AS 'StatusCode',
               'Registros obtenidos' AS 'Description';

        SELECT C.[IdCatProductTag] [Id],
               C.[Description] [Description]
        FROM [dbo].[CatProductTag] C WITH(NOLOCK)
        WHERE C.[RowStatus] = 'TRUE'



        IF @TranCounter = 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION spgetSubcategories;
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';
    END CATCH

END

