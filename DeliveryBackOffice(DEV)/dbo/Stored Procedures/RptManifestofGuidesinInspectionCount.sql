-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-02-20>
-- Description:	<Description, SP para conteo de Manifiesto de guías en estado de inspección tras liquidación de entregas y devoluciones>
-- =============================================
CREATE PROCEDURE [dbo].[RptManifestofGuidesinInspectionCount]
@IdManifest INT
			
AS
BEGIN
	
	DECLARE @GuideCount INT
	DECLARE @IdStatus INT =(Select StatusOrderId From dbo.StatusOrder where OrderDescription ='Paquete abandonado')
	SET NOCOUNT ON;

	SET @GuideCount = (
		      Select COUNT(DO.Guide_Number)
				 From [dbo].[DeliveryOrderBySettlement] DOS 
					Inner Join
				  [dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
					ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
					Inner Join 
				 [dbo].[DeliveryOrder] DO WITH (NOLOCK)
			   ON DSD.Guide_Serie = DO.Guide_Serie AND DSD.Guide_Number = DO.Guide_Number
				Where  DO.StatusOrderId=@IdStatus and DSD.ID_DeliveryOrderBySettlement=@IdManifest
		
	)

		     Select 
			  
					@GuideCount as Guides_Received
			  

		
  
END