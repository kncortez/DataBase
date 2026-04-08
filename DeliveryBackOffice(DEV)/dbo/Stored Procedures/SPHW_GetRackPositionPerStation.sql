/* =================================================
   SP:        [dbo].[SPHW_GetRackPositionPerStation]
   Propósito: Obtiene el rackposition por defecto para la estacion determinada
   Autor:     Brandon Pedroza
   Historia:  FDAPI-5662
   Fecha:     <2026-03-20>
   === CHANGELOG ============================

=========================================== */
CREATE PROCEDURE [dbo].[SPHW_GetRackPositionPerStation]
	@StationId INT
AS
BEGIN
	DECLARE @RackPosition NVARCHAR (60);
	
	SELECT @RackPosition = RackPositionDefault 
		FROM CatStation WITH(NOLOCK)
	WHERE IdStation = @StationId
	AND RowStatus = 1;

	IF(@RackPosition IS NULL)
	BEGIN
		SELECT '400'                      AS [StatusCode],
				''                        AS [RackPosition],
				'Estacion no encontrada'  AS [Message]    
	END
	ELSE
	BEGIN
		SELECT '200'                    AS [StatusCode],
			@RackPosition               AS [RackPosition],
			'Existe estacion'           AS [Message] 
		
	END
END
