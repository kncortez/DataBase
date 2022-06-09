
-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-24>
-- Description:	<Devuelve todos los registros de la ubicación y guía en cuestión>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_warehouse]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@RackPosition NVARCHAR(30)
AS
BEGIN

  -- get all warehouse records
  SELECT w.[Id]
      ,w.[Rack_Position]
      ,w.[Guide_Serie]
      ,w.[Guide_Number]
      ,w.[Dry]
      ,w.[Cold]
      ,w.[Active]
	  --,do.Pieces_Dry AS Total_Pieces_Dry
	  --,do.Pieces_Cold AS Total_Pieces_Cold
  FROM [DeliveryBackOffice].[dbo].[Warehouse] w
  --JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK) ON do.Guide_Serie = w.Guide_Serie AND do.Guide_Number = w.Guide_Number
  WHERE 
  (w.Guide_Serie = @GuideSerie AND w.Guide_Number = @GuideNumber AND w.Active = 1)
  OR (w.Rack_Position = @RackPosition AND w.Active = 1) 

  -- get all pieces for guide (waybill)
  SELECT 
	 do.Guide_Serie
	,do.Guide_Number
	,do.Pieces_Dry as Total_Pieces_Dry
	,do.Pieces_Cold as Total_Pieces_Cold
  FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do
  WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

END