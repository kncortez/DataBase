
-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2023-02-06>
-- Description:	<Reporte de guias cliente Difrisa>
-- =============================================
CREATE PROCEDURE [dbo].[RDL_report_Difrisa]

    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN

SELECT (do.Guide_Serie + CONVERT(varchar(10), do.Guide_Number)) AS Guía, 
COUNT(dop.GuideNumber) AS Pieza, 
SUM(dop.PieceWeight) AS Peso, 
do.TypeService AS Tipo_Servicio,
--do.Segment AS Tarifa_Aplicada,
(SELECT [dbo].[fn_get_segment](do.Guide_Serie, do.Guide_Number)) AS Tarifa_Aplicada
		FROM DeliveryOrder do with (nolock)
		LEFT JOIN DeliveryOrderPiece dop with(nolock)
		ON do.Guide_Number = dop.GuideNumber
		WHERE do.Sender_ID = 235119
		 AND CAST(do.DateCreated AS DATE) >= @StartDate
         AND CAST(do.DateCreated AS DATE) <= @EndDate
		GROUP BY do.Guide_Number, 
				 do.Guide_Serie,
				 do.TypeService,
				 do.Segment,
				 do.Sender_Town,
				 do.Receiver_Town,
				 do.Sender_Department,
				 do.Receiver_Department
				 
END