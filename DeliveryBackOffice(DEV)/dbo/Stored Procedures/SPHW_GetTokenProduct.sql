-- ============================================
-- Author:		<Brandon, Pedroza >
-- Create date: <2024-10-02>
-- Description:	<Obtiene token de producto>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetTokenProduct]
    @IdProduct AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION SPGetTokenProducts;
    ELSE
        BEGIN TRANSACTION;
    BEGIN TRY

        SELECT 200 AS 'StatusCode',
               'Registros obtenidos' AS 'Description';

        SELECT P.[IdProduct] [IdProduct],
               P.[Name] [Name],
               P.[Description] [Description],
               P.[Token] [Token]
        FROM [dbo].[Product] P WITH (NOLOCK)          
        WHERE P.[IdProduct] = @IdProduct


        IF @TranCounter = 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION SPGetTokenProducts;
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';
    END CATCH

END
