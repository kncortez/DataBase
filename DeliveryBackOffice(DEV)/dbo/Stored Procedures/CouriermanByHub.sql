-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-16-02>
-- Description:	<SP Obtener courierman por hub asignado, debe devolver nombre y id>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <2024-06-10>
-- Description:	<Filtra el courier por hun y pais asignado>
-- =============================================
CREATE PROCEDURE [dbo].[CouriermanByHub] 
@IdHub int,
@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Begin Try
	
		Select First_Name +' '+ Last_Name [Name], ID
		From [dbo].[SenderReceiver] WITH(NOLOCK)
		WHERE HubLogisticId =  @IdHub
		AND IIF(IdCountry IS NULL ,'GT', IdCountry) = @IdCountry

    End Try

	Begin Catch

	 SELECT 0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description' 
	
	End Catch
END