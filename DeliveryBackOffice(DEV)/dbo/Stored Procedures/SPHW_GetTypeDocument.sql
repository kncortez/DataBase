/* =================================================
   SP:        [dbo].[SPHW_GetTypeDocument]
   Propósito: <Administración de lotes - Obtener listado de tipo de documentos.>
   Autor:     <Walter Orozco>
   Historia:  <FADPI-3104>
   Fecha:     2024-10-22
============================================
=== CHANGELOG ================================
-- 2024-10-22 | Historia/épica: FADPI-3104 | Autor: Walter Orozco  |
=========================================== */

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