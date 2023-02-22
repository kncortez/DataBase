-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-02-20>
-- Description:	<Description, SP para  Manifiesto de guías en estado de inspección tras liquidación de entregas y devoluciones>
-- =============================================
CREATE  PROCEDURE [dbo].[RptManifestofGuidesinInspectionDetail]
@IdManifest INT
			
AS
BEGIN
	
	DECLARE @GuideCount INT
	DECLARE @IdStatus INT =(Select StatusOrderId From dbo.StatusOrder where OrderDescription ='Paquete abandonado')
	SET NOCOUNT ON;



	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(600),
		Sender_Fullname nvarchar(201),
		Sender_Address nvarchar(600)
	
	)

    -- tablix content
	INSERT INTO @temp
             Select   Distinct     
	                DO.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code,
	            	SUM(IIF(DA.Cold=1, 1, 0)) Pieces_Cold,
					SUM(IIF(DA.Dry=1, 1, 0)) Pieces_Dry ,
				    isnull(DO.Sender_FirstName,'') + ' ' + isnull(DO.Sender_LastName,'') as sender_Fullname,
					DO.Sender_Address,
					isnull(DO.Receiver_FirstName,'') + ' ' + isnull(DO.Receiver_LastName,'') as Receiver_Fullname,
				    DO.Receiver_Address
			 From [dbo].[DeliveryOrderBySettlement] DOS 
					 Inner Join
                  [dbo].[DeliverySettlementDetail] DSD
                ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
					Inner Join 
				  [dbo].[DeliveryOrder] DO
			   ON DSD.Guide_Serie = DO.Guide_Serie AND DSD.Guide_Number = DO.Guide_Number
					Inner JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sr 
		       ON sr.ID = DOS.ID_Courier
			   Inner Join [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA 
			   ON DO.Guide_Serie = DA.Guide_Serie AND DO.Guide_Number = DA.Guide_Number 
			 Where  DO.StatusOrderId = @IdStatus and DSD.ID_DeliveryOrderBySettlement=@IdManifest and  DA.ID_DeliveryOrderBySettlement=@IdManifest
			 Group by DO.Guide_Number, DO.Guide_Serie,DO.Sender_FirstName, DO.Sender_LastName, DO.Sender_Address, DO.Receiver_FirstName, DO.Receiver_LastName, DO.Receiver_Address

	SELECT * FROM @temp
	order by  Guide_Code



	        
  
END