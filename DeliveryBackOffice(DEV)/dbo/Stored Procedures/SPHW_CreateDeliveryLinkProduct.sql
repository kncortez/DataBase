CREATE PROCEDURE [dbo].[SPHW_CreateDeliveryLinkProduct]
  @LinkId INT,
  @ProductId INT,
  @Quantity INT,
  @Price  DECIMAL(14,2)
AS 
BEGIN 
	
	BEGIN TRY
		INSERT INTO DeliveryBackOffice.dbo.DeliveryLinkProducts 
		(DeliveryLinkId,ProductId,Quantity,Price,RowStatus,UserCreated,DateCreated)
		VALUES
		(@LinkId,@ProductId,@Quantity,@Price,1,'SYSTEM',GETDATE())

		SELECT
		200 AS 'StatusCode',
		'Registro guardado correctamente' AS 'Description'
	END TRY
	BEGIN CATCH
		SELECT
		400 AS 'StatusCode',
		'Error al registrar Producto' AS 'Description'
	END CATCH
END