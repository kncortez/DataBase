-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Cabecera de manifiesto global de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestPickUpGlobalHeaderTSE] 

AS
BEGIN
	
	SET NOCOUNT ON;

	Select 
      COUNT(B.GuideNumber) TotalGuide,
	  0 Totalpiece,
	  COUNT(B.GuideNumber) AS Sobres
	
	  
	From [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] A  WITH(NOLOCK) 
		 Inner Join 
		 [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] B  WITH(NOLOCK) 
		 ON A.IDTSERoutePreparationHeader = B.TSERoutePreparationHeaderID
		 INNER JOIN
		 [DeliveryBackOffice].[dbo].[DeliveryOrder] do  WITH(NOLOCK) 
		 ON [do].[Guide_Serie] = [B].[GuideSerie] AND [do].[Guide_Number] = [B].[GuideNumber]
		 AND [do].[Pieces_Dry] > 1
	WHERE  A.HasFirstPickupProcess =1 And B.RowStatus =1
	UNION ALL
	Select 
          0 TotalGuide,
		  SUM([do].[Pieces_Dry]) Totalpiece,
		  0  AS  Sobres
	    
	From [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] A  WITH(NOLOCK) 
		 Inner Join 
		 [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] B  WITH(NOLOCK) 
		 ON A.IDTSERoutePreparationHeader = B.TSERoutePreparationHeaderID
		 INNER JOIN
		 [DeliveryBackOffice].[dbo].[DeliveryOrder] do  WITH(NOLOCK) 
		 ON [do].[Guide_Serie] = [B].[GuideSerie] AND [do].[Guide_Number] = [B].[GuideNumber]
		 AND [do].[Pieces_Dry] > 1
	WHERE  A.HasFirstPickupProcess =1 And B.RowStatus =1
 
   
END