-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-25>
-- Description:	<Actualiza el path de productos creados sin logueo>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_UpdateImagesProductPathWithoutLogin]
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
		FROM dbo.ProductImages Imp WITH(NOLOCK)
			INNER JOIN @ProductImages P 
				ON Imp.Position = P.Position 
				AND Imp.ProductId = P.ProductId
			WHERE P.ProductId = @IdProduct

	  	COMMIT TRANSACTION;

		SELECT 200 AS 'StatusCode',
          'Datos Actualizados exitosamente' AS 'Description';
	   
	END TRY
	
		BEGIN CATCH

			ROLLBACK TRANSACTION;

			SELECT 0 AS 'StatusCode',
               'Actualización de datos fallida' AS 'Description';

		 END CATCH

END
