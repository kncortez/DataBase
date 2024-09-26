-- =============================================
-- Author:		<Brandon, Pedroza >
-- Create date: <2024-09-25>
-- Description:	<Obtiene datos de un producto especifico para link de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetProductById]
	@IdProduct AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION spgetProductId;
    ELSE
        BEGIN TRANSACTION;
    BEGIN TRY

        SELECT 200 AS 'StatusCode',
               'Registros obtenidos' AS 'Description';
		
		--OBTENER DATOS DE PRODUCTO
		SELECT 
			[IdProduct],
			[Token],
			[Name],
			[Description],
			[AccountId]
			[IdOriginAddress],
			[CatProductSubCategoryId],
			[IsPublic],
			[CatStatusStoreId],
			[CatProductConditionId],
			[Sku],
			[Stock],
			[StockRequired],
			[Price],
			[CatCurrencyCODId],
			[Brand],
			[AverageRating],
			ISNULL([NameSale],'')		[NameSale],
			ISNULL([StartDateSale],'')	[StartDateSale],
			ISNULL([EndDateSale],'')	[EndDateSale],
			ISNULL([PercentageSale],0)	[PercentageSale]
		FROM [dbo].[Product] WITH(NOLOCK)
		WHERE [IdProduct] = @IdProduct
		AND [RowStatus] = 'TRUE';


		--OBTENER TAGS DEL PRODUCTO
		SELECT C.[IdCatProductTag] [IdTag],
               C.[Description] [Description]
        FROM [dbo].[CatProductTag] C WITH(NOLOCK)
		INNER JOIN [dbo].[TagByProduct] T WITH(NOLOCK)
			ON C.IdCatProductTag = T.TagId
		INNER JOIN [dbo].[Product] P WITH(NOLOCK)
			ON T.[ProductId] = P.[IdProduct]
        WHERE P.[IdProduct] = @IdProduct
		AND C.[RowStatus] = 'TRUE'

		--OBTENER IMAGENES DEL PRODUCTO
        SELECT I.[IdProductImages]	[IdImage],
		I.[ProductId]				[IdProduct],	
		I.[Url]						[Url],	
		I.[Position]				[Position]
		FROM [dbo].[Product] P WITH(NOLOCK)
		LEFT JOIN [dbo].[ProductImages] I WITH(NOLOCK)
		ON P.IdProduct = I.ProductId
		WHERE P.[IdProduct] = @IdProduct
		AND I.RowStatus = 'TRUE';



        IF @TranCounter = 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION spgetProductId;
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';
    END CATCH

END

