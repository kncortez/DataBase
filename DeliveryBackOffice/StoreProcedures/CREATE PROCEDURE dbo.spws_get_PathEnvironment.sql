-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-15>
-- Description:	<spws_get_PathEnvironment>
-- =============================================


CREATE PROCEDURE [dbo].[spws_get_PathEnvironment]
	-- Add the parameters for the stored procedure here	
	@Path VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Value as Path FROM ConfigParams WHERE Name = 'DEV'

END



