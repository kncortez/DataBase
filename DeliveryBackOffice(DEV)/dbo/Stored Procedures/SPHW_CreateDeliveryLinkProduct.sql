-- ============================================
-- Author:		  <Brandon, Pedroza >
-- Modified	date: <2024-10-02>
-- Description:	  <Se agrega validacion para actualizar el stock del producto>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CreateDeliveryLinkProduct]
  @LinkId INT,
  @ProductId INT,
  @Quantity INT,
  @Price  DECIMAL(14,2)
AS 
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		--ACTUALIZAR STOCK DE PRODUCTO
		IF EXISTS (
			SELECT 1 
			FROM Product 
			WHERE IdProduct = @ProductId AND Stock >= @Quantity
		)
		BEGIN
			UPDATE Product
			SET Stock = Stock - @Quantity
			WHERE IdProduct = @ProductId
		END
		ELSE
		BEGIN
			-- Coloca la cantidad que hay disponible en stock
			SET @Quantity = (SELECT Stock FROM Product WITH(NOLOCK) WHERE IdProduct = @ProductId)
		END
		INSERT INTO DeliveryBackOffice.dbo.DeliveryLinkProducts 
		(DeliveryLinkId,ProductId,Quantity,Price,RowStatus,UserCreated,DateCreated)
		VALUES
		(@LinkId,@ProductId,@Quantity,@Price,1,'SYSTEM',GETDATE())
		COMMIT TRANSACTION
		SELECT
		200 AS 'StatusCode',
		'Registro guardado correctamente' AS 'Description'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT
		400 AS 'StatusCode',
		'Error al registrar Producto' AS 'Description'
	END CATCH
END