USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_courier_dispatched_status]    Script Date: 21/09/2020 08:07:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		 <Cano,Carlos>
-- Create date:  <13/Agosto/2020>
-- Description:	 <Listado de afiliados y su status actual sobre entregas>
-- Modificado:   <López, Marcos>
-- Modified:     <14/Sepiembre/2020>
-- Description:  <Se agregó la columna del total de guías por usuario>
-- Modificado:   <Cano, Carlos>
-- Modified:     <10/Diciembre/2020>
-- Description:  <Se agregó la columna de guías pendientes para facilitar identificación de tareas por completar>
-- =============================================
ALTER PROCEDURE [dbo].[spg_courier_dispatched_status]
	@DispatchedDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		SUBQ2.ID_Courier,
		SUBQ2.Courier_Name,
		SUBQ2.Cantidad_Guias,
		SUBQ2.Dispatched,
		SUBQ2.Delivered,
		SUBQ2.Verified,
		SUBQ2.Failed,
		(
			SELECT 
				COUNT(sub_da.[Guide_Number])
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] sub_da
			WHERE 
				(Delivered = 1 OR ID_Incident IS NOT NULL)
				AND (Verified IS NULL OR Verified <> 1)
				AND CONVERT(VARCHAR, sub_da.Date_Created, 23) = @DispatchedDate
				AND SUBQ2.ID_Courier = sub_da.ID_Courier
		) AS Pending
	FROM
	(
		SELECT
			SUBQ.ID_Courier,
			SUBQ.Courier_Name,
			SUBQ.Cantidad_Guias,
			COUNT(SUBQ.Courier_Name) AS Dispatched,
			SUM(CAST(SUBQ.Delivered AS INT)) AS Delivered,
			SUM(CAST(SUBQ.Verified AS INT)) AS Verified,
			(SUM(CAST(SUBQ.Verified AS INT))- SUM(CAST(SUBQ.Accepted AS INT))) AS Failed
		FROM
		(
			SELECT
				da.ID_Courier
				,sr.First_Name + ' ' + sr.Last_Name AS Courier_Name
				,cg.Cantidad_Guias
				,da.Delivered
				,ISNULL(da.Verified,0) AS Verified
				,ISNULL(da.Accepted,0) AS Accepted
				,CONVERT(VARCHAR,da.Date_Created,103) AS Date_Created
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] da
			JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sr ON sr.ID = da.ID_Courier
			JOIN (
				SELECT ID_Courier, SUM(contador) Cantidad_Guias FROM (
					SELECT dv.ID_Courier, CONCAT(dv.Guide_Serie, dv.Guide_Number) guia, 1 contador
					FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] dv
					WHERE CONVERT(VARCHAR, dv.Date_Created, 23) = CONVERT(VARCHAR, @DispatchedDate, 23)
					GROUP BY dv.ID_Courier, CONCAT(dv.Guide_Serie, dv.Guide_Number)
				) temporal
				GROUP BY ID_Courier
			) cg ON da.ID_Courier = cg.ID_Courier
			WHERE CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, @DispatchedDate, 23)
		) AS SUBQ
		GROUP BY SUBQ.ID_Courier, SUBQ.Courier_Name, SUBQ.Cantidad_Guias
	) AS SUBQ2
	ORDER BY SUBQ2.Courier_Name

END
GO


