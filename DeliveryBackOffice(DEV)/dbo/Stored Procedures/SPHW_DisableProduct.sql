
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-01>
-- Description:	<Actualiza el rowstatus de un producto>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_DisableProduct]
	@IdProduct AS INT
AS
BEGIN

  BEGIN TRANSACTION
	BEGIN TRY

	UPDATE Product
	SET Rowstatus = 0
	WHERE IdProduct = @IdProduct

	  	COMMIT TRANSACTION;

	SELECT 200 AS [StatusCode], 'El producto ha sido eliminado exitosamente' AS[Description]
	   
	END TRY
	
		BEGIN CATCH

			ROLLBACK TRANSACTION;

			SELECT 0 AS [StatusCode], 'No pudo realizarse la accion' AS[Description]

		 END CATCH

END