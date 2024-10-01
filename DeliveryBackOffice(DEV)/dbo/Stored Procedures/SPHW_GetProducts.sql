-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-09-24>
-- Description:	<Obtiene lista de productos filtrada por usuario(Account)>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetProducts]
    @Account AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION SPGetProducts;
    ELSE
        BEGIN TRANSACTION;
    BEGIN TRY

        SELECT 200 AS 'StatusCode',
               'Registros obtenidos' AS 'Description';

        SELECT P.[IdProduct] [IdProduct],
               P.[Name] [Name],
               P.[Description] [Description],
               C.[Name] [CategoryName],
               P.[CatStatusStoreId] [StatusStoreId],
               S.[Name] [StatusStoreName],
               P.[Stock] [Stock],
               P.[Price] [Price],
               CUR.[Symbol] [CurrencySymbol],
               I.[Url] [Url]
        FROM [dbo].[Product] P WITH (NOLOCK)
            INNER JOIN CatProductSubCategory C WITH (NOLOCK)
                ON P.[CatProductSubCategoryId] = C.[IdCatProductSubCategory]
            INNER JOIN CatProductStatusStore S WITH (NOLOCK)
                ON P.[CatStatusStoreId] = S.[IdCatProductStatusStore]
            INNER JOIN CatCurrencyCOD CUR WITH (NOLOCK)
                ON P.[CatCurrencyCODId] = IdCatCurrencyCOD
            LEFT JOIN [ProductImages] I
                ON I.[ProductId] = P.[IdProduct]
        WHERE P.[AccountId] = @Account
              AND I.[Position] = 1
              AND P.[RowStatus] = 1


        IF @TranCounter = 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION SPGetProducts;
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';
    END CATCH

END