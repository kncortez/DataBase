
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Cabecera de manifiesto global de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestDeliveryGlobalHeaderTSE] 

AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
      COUNT(B.GuideNumber) TotalGuide,
	  0 Totalpiece,
	  COUNT(B.GuideNumber) AS Sobres
	
	  
	FROM [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] A  WITH(NOLOCK) 
		 INNER JOIN 
		 [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] B  WITH(NOLOCK) 
		 ON A.IDTSERoutePreparationHeader = B.TSERoutePreparationHeaderID
	WHERE  A.HasLastDeliveryProccess =1 AND B.RowStatus =1
	UNION ALL
	SELECT 
          0 TotalGuide,
		  COUNT(C.Detail) Totalpiece,
		  0  AS  Sobres
	    
	FROM [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] A  WITH(NOLOCK) 
		 INNER JOIN 
		 [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] B  WITH(NOLOCK) 
		 ON A.IDTSERoutePreparationHeader = B.TSERoutePreparationHeaderID
		 INNER JOIN 
		 [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] C  WITH(NOLOCK) 
		 ON
		 B.GuideSerie = C.GuideSerie AND B.GuideNumber = C.GuideNumber
	WHERE  A.HasLastDeliveryProccess =1 AND B.RowStatus =1
 
   
END