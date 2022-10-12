-- =============================================
-- Author:		<Edelman V>
-- Create date: <2022-10-10>
-- Description:	<SP>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateGuideStatus] 
@Guide AS NVARCHAR(20)
AS
BEGIN
		DECLARE @STATUS AS INT; 
	SET NOCOUNT ON;

  SELECT TOP 1 @STATUS = StatusOrderId
				   FROM dbo.DeliveryOrderDetail WITH (NOLOCK)
				   WHERE Guide_Serie+CAST(Guide_Number AS nvarchar) = @Guide
				   ORDER BY DateCreated DESC

 IF (@STATUS  IN(22,5,7))
	BEGIN

		SELECT Result = 1
	END
	ELSE
	BEGIN

		SELECT Result = 0
	END

END