-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-09-30>
-- Description:	<Registra informacion de un nuevo producto, o actualiza la informacion>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_SetProduct]
	@IdUser VARCHAR(50),
    @IdProduct INT = NULL,                        -- Parámetro que define si es nuevo o existente
    @Name NVARCHAR(100),
    @Description NVARCHAR(200) = NULL,
    @AccountId BIGINT,
	@IdOriginAddress INT,
    @CatProductSubCategoryId INT,
    @IsPublic BIT,
    @CatStatusStoreId INT,
    @CatProductConditionId INT,
    @Sku NVARCHAR(50) = NULL,
    @Stock INT = NULL,
    @StockRequired BIT,
    @Price DECIMAL(14, 2),
    @CatCurrencyCODId INT,
    @Brand NVARCHAR(200) = NULL,
    @AverageRating DECIMAL(14, 2) = NULL,
    @NameSale NVARCHAR(100) = NULL,
    @StartDateSale DATE = NULL,
    @EndDateSale DATE = NULL,
    @PercentageSale DECIMAL(14, 2) = NULL,
    @ProductImages TblImagesProductList READONLY, -- Recibe una tabla de imágenes
    @Tags TblTagsProductList READONLY             -- Recibe una tabla de etiquetas
AS
BEGIN
    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION spSetProduct;
    ELSE
        BEGIN TRANSACTION;
	BEGIN TRY
		SET NOCOUNT ON;
		DECLARE @UserToken AS NVARCHAR(50) =   (
			SELECT CONVERT(VARCHAR(32), HASHBYTES('MD5', @IdUser), 2) AS token
		);

		DECLARE @Token AS NVARCHAR(50) =   (
			SELECT CONVERT(VARCHAR(32), HASHBYTES('MD5', @IdUser), 2) AS token
		);

		IF EXISTS (SELECT 1 FROM Product 
					WHERE Sku = @Sku 
					AND AccountId = @AccountId 
					AND @IdProduct IS NULL 
					AND RowStatus = 1
				)
		BEGIN
			SELECT 201 AS 'StatusCode',
				   'El producto ya existe' AS 'Description';
			DECLARE @IdProductExists INT = (SELECT TOP 1 IdProduct FROM Product WHERE Sku = @Sku AND AccountId = @AccountId)
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
			WHERE [IdProduct] = @IdProductExists
			AND [RowStatus] = 'TRUE';


			--OBTENER TAGS DEL PRODUCTO
			SELECT C.[IdCatProductTag] [IdTag],
					C.[Description] [Description]
			FROM [dbo].[CatProductTag] C WITH(NOLOCK)
			INNER JOIN [dbo].[TagByProduct] T WITH(NOLOCK)
				ON C.IdCatProductTag = T.TagId
			INNER JOIN [dbo].[Product] P WITH(NOLOCK)
				ON T.[ProductId] = P.[IdProduct]
			WHERE P.[IdProduct] = @IdProductExists
			AND C.[RowStatus] = 'TRUE'

			--OBTENER IMAGENES DEL PRODUCTO
			SELECT TOP 10
			I.[IdProductImages]	[IdImage],
			I.[ProductId]				[IdProduct],	
			I.[Url]						[Url],	
			I.[Position]				[Position],
			T.[StrImage]				[StrImage]
			FROM [dbo].[Product] P WITH(NOLOCK)
			LEFT JOIN [dbo].[ProductImages] I WITH(NOLOCK)
			ON P.IdProduct = I.ProductId
			INNER JOIN @ProductImages T 
			ON T.Position = I.Position		
			WHERE P.[IdProduct] = @IdProductExists
			AND I.RowStatus = 'TRUE'
		END
		ELSE
		BEGIN
			SELECT 200 AS 'StatusCode',
				'Registros obtenidos' AS 'Description';

			IF @IdProduct IS NULL
			BEGIN
				-- Insertar nuevo producto
				INSERT INTO Product
				(
					[Name],
					[Description],
					[AccountId],
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
					[NameSale],
					[StartDateSale],
					[EndDateSale],
					[PercentageSale],
					[RowStatus],
					[UserCreated],
					[DateCreated],
					[IdOriginAddress]
				)
				VALUES
				(
					@Name,
					@Description,
					@AccountId,
					@CatProductSubCategoryId,
					@IsPublic,
					@CatStatusStoreId,
					@CatProductConditionId,
					@Sku,
					@Stock,
					@StockRequired,
					@Price,
					@CatCurrencyCODId,
					@Brand,
					@AverageRating,
					@NameSale,
					@StartDateSale,
					@EndDateSale,
					@PercentageSale,
					1  ,
					@UserToken,
					GETDATE(),
					@IdOriginAddress
				);

				-- Obtener el Id del producto insertado
				SET @IdProduct = SCOPE_IDENTITY();

				--se actualiza el token de producto
				UPDATE Product
				SET Token = CONVERT(VARCHAR(64), HASHBYTES('MD5', CONCAT(IdProduct,Name)), 2)
				WHERE IdProduct = @IdProduct


				-- Insertar imágenes
				INSERT INTO ProductImages
				(
					[ProductId],
					[Url],
					[Position],
					[RowStatus],
					[UserCreated],
					[DateCreated]
				)
				SELECT @IdProduct,
						'',--se agrega vacio para saber que se debe crear archivo en disco
						[Position],
						1,
						@UserToken,
						GETDATE()
				FROM @ProductImages;

				-- Insertar etiquetas
				INSERT INTO TagByProduct
				(
					TagId,
					ProductId,
					RowStatus,
					UserCreated,
					DateCreated
				)
				SELECT IdCatProductTag,
						@IdProduct,
						1,
						@UserToken,
						GETDATE()
				FROM @Tags;
			END
			ELSE
			BEGIN
				-- Actualizar producto existente
				UPDATE Product
				SET 
					[Name] = @Name,
					[Description] = @Description,
					[CatProductSubCategoryId] = @CatProductSubCategoryId,
					[IsPublic] = @IsPublic,
					[CatStatusStoreId] = @CatStatusStoreId,
					[CatProductConditionId] = @CatProductConditionId,
					[Sku] = @Sku,
					[Stock] = @Stock,
					[StockRequired] = @StockRequired,
					[Price] = @Price,
					[CatCurrencyCODId] = @CatCurrencyCODId,
					[Brand] = @Brand,
					[AverageRating] = @AverageRating,
					[NameSale] = @NameSale,
					[StartDateSale] = @StartDateSale,
					[EndDateSale] = @EndDateSale,
					[PercentageSale] = @PercentageSale,
					[UserUpdated] = @UserToken,
					[DateUpdated] = GETDATE(),
					[IdOriginAddress] = @IdOriginAddress
				WHERE IdProduct = @IdProduct;

				-- Manejo de imágenes:

				-- 1. Marcar imágenes que no están en la nueva lista como inactivas (RowStatus = 0)
				UPDATE ProductImages
				SET RowStatus = 0,
					UserUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE ProductId = @IdProduct
						AND IdProductImages NOT IN (
														SELECT ISNULL(IdProductImages,0) FROM @ProductImages
													);

				-- 2. Marcar imágenes existentes en la lista como activas (RowStatus = 1)
				UPDATE ProductImages
				SET [RowStatus] = 1,
					[Position] = PIM.[Position],
					--[Url] = PIM.[Url],
					[UserUpdated] = @UserToken,
					[DateUpdated] = GETDATE()
				FROM ProductImages I WITH(NOLOCK)
					INNER JOIN @ProductImages PIM
						ON I.IdProductImages = PIM.IdProductImages
				WHERE I.ProductId = @IdProduct;

				-- 3. Insertar nuevas imágenes que no existían previamente
				INSERT INTO ProductImages
				(
					[ProductId],
					[Url],
					[Position],
					[RowStatus],
					[UserCreated],
					[DateCreated]
				)
				SELECT @IdProduct,
						'', --[Url], se agrega vacio para saber que se debe crear archivo en disco
						[Position],
						1,
						@UserToken,
						GETDATE()
				FROM @ProductImages PIM
				WHERE NOT EXISTS
				(
					SELECT 1
					FROM ProductImages I WITH(NOLOCK)
					WHERE I.ProductId = @IdProduct
							AND I.IdProductImages = PIM.IdProductImages
				);

				-- Manejo de etiquetas (Tags):

				-- 1. Marcar etiquetas que no están en la nueva lista como inactivas (RowStatus = 0)
				UPDATE TagByProduct
				SET RowStatus = 0,
					UserUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE ProductId = @IdProduct
						AND TagId NOT IN (
											SELECT IdCatProductTag FROM @Tags
										);

				-- 2. Marcar etiquetas que ya existen en la lista como activas (RowStatus = 1)
				UPDATE TagByProduct
				SET RowStatus = 1,
					UserUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE ProductId = @IdProduct
						AND TagId IN (
										SELECT IdCatProductTag FROM @Tags
									);

				-- 3. Insertar nuevas etiquetas que no existían previamente
				INSERT INTO TagByProduct
				(
					TagId,
					ProductId,
					RowStatus,
					UserCreated,
					DateCreated
				)
				SELECT IdCatProductTag,
						@IdProduct,
						1,
						@UserToken,
						GETDATE()
				FROM @Tags T
				WHERE NOT EXISTS
				(
					SELECT 1
					FROM TagByProduct TBP WITH(NOLOCK)
					WHERE TBP.ProductId = @IdProduct
							AND TBP.TagId = T.IdCatProductTag
				);
			END


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
			SELECT TOP 10
			I.[IdProductImages]	[IdImage],
			I.[ProductId]				[IdProduct],	
			I.[Url]						[Url],	
			I.[Position]				[Position],
			T.[StrImage]				[StrImage]
			FROM [dbo].[Product] P WITH(NOLOCK)
			LEFT JOIN [dbo].[ProductImages] I WITH(NOLOCK)
			ON P.IdProduct = I.ProductId
			INNER JOIN @ProductImages T 
			ON T.Position = I.Position		
			WHERE P.[IdProduct] = @IdProduct
			AND I.RowStatus = 'TRUE'
		END


		IF @TranCounter = 0
            COMMIT TRANSACTION spSetProduct;
	END TRY
	BEGIN CATCH
		IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION spSetProduct;
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';

	END CATCH

END;

