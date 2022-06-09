

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-04>
-- Description:	<Sp para dar de baja un token>
-- =============================================
CREATE PROCEDURE [dbo].[spws_set_logout]
	-- Add the parameters for the stored procedure here
	@TokenId VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.TokenLog SET TknRowStatus = 0, TknDateUpdated = GETDATE()
	WHERE TknIdToken = @TokenId
	
	SELECT @@rowcount AS 'RowsChanged';
END