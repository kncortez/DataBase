-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-22>
-- Description:	<Administración de lotes - Obtener listado de tipo de documentos.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTypeDocument]
@IdTypeDocument INT = -1
AS
BEGIN
BEGIN TRY

	SELECT
		  IdTypeDocument	AS 'Id'
		, [Name]			AS 'Name'
		, Descripcion		AS 'Description'
	FROM DeliveryBackOffice.dbo.CatTypeDocument WITH(NOLOCK)
	WHERE (IdTypeDocument = @IdTypeDocument OR
	      @IdTypeDocument = -1) AND RowStatus = 1

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;