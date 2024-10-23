-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-09-30>
-- Description:	<Actualiza el path de productos nuevos cuyo path esta vacia>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_UpdateImagesProductPath]
	@ProductImages TblImagesProductList READONLY , -- Recibe una tabla de imágenes
	@IdAccount NVARCHAR(50)
AS
BEGIN

  BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @IdProduct INT = (SELECT TOP 1 ProductId FROM @ProductImages);
	DECLARE @UserToken AS NVARCHAR(50) =   (
			SELECT CONVERT(VARCHAR(32), HASHBYTES('MD5', @IdAccount), 2) AS token
		);

	UPDATE Imp
        SET Imp.[Url] = P.[Url] -- Actualiza el campo path
			,Imp.DateUpdated =GETDATE() 
			,Imp.UserUpdated = @UserToken
        FROM dbo.ProductImages Imp
        INNER JOIN @ProductImages P ON Imp.[IdProductImages]  = P.[IdProductImages]-- Relación por IdProductImages

	  	COMMIT TRANSACTION;

		SELECT 200 AS 'StatusCode',
          'Datos Actualizados exitosamente' AS 'Description';

			--OBTENER DATOS DE PRODUCTO
		SELECT 
			[IdProduct],
			[Token],
			[Name],
			[Description],
			[AccountId],
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
			[StartDateSale],
			[EndDateSale],
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
	   
	END TRY
	
		BEGIN CATCH

			ROLLBACK TRANSACTION;

			SELECT 0 AS 'StatusCode',
               'Actualización de datos fallida' AS 'Description';

		 END CATCH

END

