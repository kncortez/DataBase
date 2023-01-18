

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-08-02>
-- Description:	<Devuelve las piezas activas en inventario de la guía en cuestión>
-- =============================================
CREATE PROCEDURE [dbo].[spg_active_waybill_pieces_warehouse]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN

  -- get all warehouse records
  SELECT 
      w.[Guide_Serie]
      ,w.[Guide_Number]
      ,SUM(CAST(w.[Dry] AS INT)) AS Total_Active_Dry
      ,SUM(CAST(w.[Cold]AS INT)) AS Total_Active_Cold
  FROM [DeliveryBackOffice].[dbo].[Warehouse] w
  WHERE w.Guide_Serie = @GuideSerie AND w.Guide_Number = @GuideNumber AND w.Active = 1
  GROUP BY w.Guide_Serie, w.Guide_Number

END
