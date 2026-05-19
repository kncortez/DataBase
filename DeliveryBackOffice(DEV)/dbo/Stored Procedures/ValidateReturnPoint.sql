/* =================================================
   SP:        [dbo].[ValidateReturnPoint]
   Propósito: SP para validar el punto de devolución asignado a un cliente en un punto de visita específico.
   Autor:     Mario Herrarte
   Historia:  FDAPI-6135
   Fecha:     2026-05-19

=== CHANGELOG ============================
YYYY-MM-DD | Historia/épica: <>           | Autor: Nombre Apellido         | Descripción
=========================================== */
CREATE PROCEDURE [dbo].[ValidateReturnPoint]
	@IdCustomer as INT,
	@IdVisitPoint AS INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DescriptionOfClient NVARCHAR(100);
	DECLARE @CodeOfReference INT;
	
	SELECT TOP 1
		@DescriptionOfClient = DescriptionOfClient,
		@CodeOfReference = CodeOfReference
	FROM VisitPointClient WITH (NOLOCK)
	WHERE CustomerID = @IdCustomer
		AND isReturnWarehouse = 1;
	
	IF @DescriptionOfClient IS NOT NULL
	BEGIN
		IF @CodeOfReference = @IdVisitPoint
		BEGIN
			SELECT
			0 AS Code,
			'Seleccionado actualmente.' AS DescriptionOfClient;
		END
		ELSE
		BEGIN
			SELECT
				1 AS Code,
				@DescriptionOfClient AS DescriptionOfClient;
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS Code,
			'No tiene asignado Punto de devolución' AS DescriptionOfClient;
	END
	
END
