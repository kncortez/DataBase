-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-11-30>
-- Description:	<SP listar courier asignados a cliente interno>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ListCouriermansAssignedtoaUser] 
@IdUser AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

BEGIN TRY

	SELECT SR.ID, 
		   SR.First_Name+' '+SR.Last_Name [NAME], 
		   SR.CUI, 
		   HL.HubName, 
		   SR.Phone, 
		   CTSR.TypeName 
	FROM [dbo].[SenderReceiverByUser] SRU WITH (NOLOCK)
		INNER JOIN [dbo].[SenderReceiver] SR WITH(NOLOCK)
	ON SRU.SenderReceiverId = SR.ID
	    LEFT JOIN [dbo].[HubLogistics] HL WITH(NOLOCK)
    ON SR.HubLogisticId=HL.IdHubLogistic
	    LEFT JOIN [dbo].[CatTypeSenderReceiver] CTSR WITH(NOLOCK)
	ON SR.CatTypeSenderReceiverId  = CTSR.IdCatTypeSenderReceiver
	WHERE SRU.UserId =@IdUser

	 

END TRY
        BEGIN CATCH
            	  SELECT  [blnResult]=0
                   
			
        END CATCH

END