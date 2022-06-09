-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2021-07-12>
-- Description:	<Valida si un token de portal web es existente y valido >
-- =============================================
CREATE PROCEDURE [dbo].[sphwGetValidTokenPortal]
	-- Add the parameters for the stored procedure here
	@Token AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Insert statements for procedure here
	SELECT COALESCE(TknIdToken,'') TknIdToken, TknDateCreated  ,TknRowStatus 
	FROM DeliveryBackOffice.dbo.TokenLog
	WHERE TknIdToken =  @Token  -- 'B3FE49341194EBBA9A8DB61C4173E06C'--
END
