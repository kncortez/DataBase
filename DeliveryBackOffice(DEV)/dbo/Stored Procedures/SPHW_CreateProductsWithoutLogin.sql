-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-25>
-- Description:	<Creacion de productos para link de entrega sin logueo>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CreateProductsWithoutLogin]
	@AccountId BIGINT,
    @IdOriginAddress INT,
    @ProductImages TblImagesProductList READONLY, -- Tabla de imágenes
    @Products TblProductWithoutLogin READONLY      -- Tabla de productos
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @IdProduct INT;

        -- Variable de tabla para almacenar los Ids de los productos insertados
        DECLARE @InsertedProducts TABLE (Reference INT, IdProduct INT,Quantity INT, Price DECIMAL(14,2));
        
        DECLARE product_cursor CURSOR FOR 
        SELECT [Id], [Name], [Description], [Quantity], [Price] FROM @Products;

        DECLARE @ProductId INT;
        DECLARE @Name NVARCHAR(200);
        DECLARE @Description NVARCHAR(200);
        DECLARE @Quantity INT;
        DECLARE @Price DECIMAL(14, 2);
		DECLARE @IdCurrency INT;

		SET @IdCurrency =( SELECT C.IdCatCurrencyCOD 
							FROM  CatCurrencyCOD C WITH(NOLOCK) 
							INNER JOIN DeliveryCurrency D WITH(NOLOCK)
							ON C.IdCatCurrencyCOD = IdCurrencyCOD 
							  INNER JOIN UserAddress A WITH(NOLOCK)
							  ON D.Currency_IdCountry = A.UadIdCountry
							WHERE A.UadIdAddress  = @IdOriginAddress 
							AND D.DefaultPerCountry = 1); 
        OPEN product_cursor;
        FETCH NEXT FROM product_cursor INTO @ProductId, @Name, @Description, @Quantity, @Price;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Insertar el producto
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
                1,
                0,
                1,
                1,
                '',
                @Quantity,
                0,
                @Price,
                @IdCurrency,
                '',
                5,
                '',
                NULL,
                NULL,
                0.0,
                1,
                'SYSTEM',
                GETDATE(),
                @IdOriginAddress
            );

            -- Obtener el Id del producto insertado
            SET @IdProduct = SCOPE_IDENTITY();

            -- Agregar el Id del producto insertado a la variable de tabla
            INSERT INTO @InsertedProducts (Reference,IdProduct,Quantity,Price) VALUES (@ProductId,@IdProduct, @Quantity, @Price);

            -- Actualizar el token del producto
            UPDATE Product
            SET Token = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(IdProduct, Name)), 2)
            WHERE IdProduct = @IdProduct;

            -- Insertar imágenes relacionadas con el producto actual
            INSERT INTO ProductImages
            (
                [ProductId],
                [Url],
                [Position],
                [RowStatus],
                [UserCreated],
                [DateCreated]
            )
            SELECT 
                @IdProduct,
                [Url],
                Position,
                1,
                'SYSTEM',
                GETDATE()
            FROM @ProductImages
            WHERE ProductId = @ProductId; -- Asociar la imagen al producto actual

            -- Avanzar al siguiente producto
            FETCH NEXT FROM product_cursor INTO @ProductId, @Name, @Description, @Quantity, @Price;
        END

        CLOSE product_cursor;
        DEALLOCATE product_cursor;

        COMMIT TRANSACTION;

        -- Mensaje de éxito
        SELECT
            200 AS 'StatusCode',
            'Registro guardado correctamente' AS 'Description';

		-- Seleccionar los productos recién insertados
        SELECT Reference,IdProduct,Quantity,Price FROM @InsertedProducts; 

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT
            400 AS 'StatusCode',
            'Error al registrar Producto' AS 'Description';
    END CATCH
END;