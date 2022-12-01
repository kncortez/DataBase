-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-11-30>
-- Description:	<Listar courier disponibles para asignar a usuario interno>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ListCouriermansPendingAssignment] 
@IdUser AS INT
AS
BEGIN
	
	SET NOCOUNT ON;
BEGIN TRY
   -- ID, Teléfono, Nombre y Apellido, Hub, Tipo
    SELECT SR.ID,SR.Phone,SR.First_Name+' '+SR.Last_Name,
	     (Select HubName From dbo.HubLogistics WITH(NOLOCK) WHERE HubLogisticId=SR.HubLogisticId) HubName,
		 (Select TypeName  From dbo.CatTypeSenderReceiver where CatTypeSenderReceiverId=SR.CatTypeSenderReceiverId) TypeSenderReceiver
	FROM [dbo].[SenderReceiver] SR WITH (NOLOCK)
	      INNER JOIN  
		  [dbo].[SenderReceiverByUser] SRU WITH(NOLOCK)
		  ON SR.ID! = SRU.SenderReceiverId
	WHERE SRU.UserId=@IdUser


END TRY
BEGIN CATCH
END CATCH
  
END