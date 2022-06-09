
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-11-03>
-- Description:	<Devuelve el nombre de los Visit Point registrados
--				basado en coincidencia de  rol>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_kindofvpclient]
	-- Add the parameters for the stored procedure here
	@Status as integer = 1
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select  kvp.IdKindOfVPClient, kvp.KindOfVPName from KindOfVPClient kvp
	where kvp.KindOfVPStatus = @Status
		
END