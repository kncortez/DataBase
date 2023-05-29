-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2023-02-23>
-- Description:	<Generar datos de entregas exitosas en rango de fecha especificada>
-- =============================================
CREATE PROCEDURE [dbo].[RDL_Info_DensityGMap]

    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
  
  IF((SELECT TOP 1 DOR.Guide_Number AS Guia
		FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt ATT WITH(NOLOCK)
		ON DOR.Guide_Serie = ATT.Guide_Serie AND DOR.Guide_Number = ATT.Guide_Number
		AND ATT.Delivered = 1
		WHERE DOR.DateCreated BETWEEN @StartDate
		AND @EndDate) IS NOT NULL)

		BEGIN
			SELECT DOR.Guide_Number AS Guia,ATT.Latitude AS Latitud,ATT.Longitude AS Longitud
				FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt ATT WITH(NOLOCK)
				ON DOR.Guide_Serie = ATT.Guide_Serie AND DOR.Guide_Number = ATT.Guide_Number
				AND ATT.Delivered = 1
				WHERE DOR.DateCreated BETWEEN @StartDate
				AND @EndDate
		END

	ELSE
	   BEGIN
		   SELECT 'NO SE ENCONTRARON ENTREGAS EXITOSAS EN EL RANGO DE FECHA ESPECIFICADA' AS MESSAGE
	   END
END