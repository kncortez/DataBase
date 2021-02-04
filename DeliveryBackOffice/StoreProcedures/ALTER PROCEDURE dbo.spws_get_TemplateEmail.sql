-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-15>
-- Description:	<spws_get_TemplateEmail>
-- =============================================


ALTER PROCEDURE [dbo].[spws_get_TemplateEmail]
	-- Add the parameters for the stored procedure here	
	@TemplateName VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Value AS TemplateName  FROM ConfigParams WHERE Name = @TemplateName

END



