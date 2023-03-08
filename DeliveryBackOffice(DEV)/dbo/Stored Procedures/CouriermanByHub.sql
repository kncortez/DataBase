-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-16-02>
-- Description:	<SP Obtener courierman por hub asignado>
-- =============================================
CREATE PROCEDURE [dbo].[CouriermanByHub] 
@IdHub int
AS
BEGIN
	
	SET NOCOUNT ON;

	Begin Try

		Select First_Name +' '+ Last_Name [Name]
		From [dbo].[SenderReceiver] WITH(NOLOCK)
		WHERE HubLogisticId =  @IdHub

    End Try

	Begin Catch

	 SELECT 0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description' 
	
	End Catch
END