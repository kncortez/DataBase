-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Cabecera de manifiesto global de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestDeliveryGlobalHeaderTSE] 

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
	WHERE  A.HasLastDeliveryProccess =1 And B.RowStatus =1
	UNION ALL
	Select 
          0 TotalGuide,
		  COUNT(C.Detail) Totalpiece,
		  0  AS  Sobres
	    
	From [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] A  WITH(NOLOCK) 
		 Inner Join 
		 [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] B  WITH(NOLOCK) 
		 ON A.IDTSERoutePreparationHeader = B.TSERoutePreparationHeaderID
		 Inner Join 
		 [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] C  WITH(NOLOCK) 
		 ON
		 B.GuideSerie = C.GuideSerie And B.GuideNumber = C.GuideNumber
	WHERE  A.HasLastDeliveryProccess =1 And B.RowStatus =1
 
   
END