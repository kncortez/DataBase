
-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-04-19>
-- Description:	<Desactiva un tarifario>
-- =============================================
 CREATE PROCEDURE [dbo].[sphd_delete_Rate]
	@IdRate INT,
	@Token VARCHAR(50)
AS
BEGIN
	UPDATE dbo.RateHeader
	SET RheRowStatus = 'FALSE'
		,RheTokenUpdated = @Token
		,RheCreateUpdated = GETDATE()
	WHERE RheId = @IdRate

	UPDATE RateData
	SET RowStatus = 'FALSE'
		,TokenUpdated = @Token
		,DateUpdated = GETDATE()
	WHERE RateId = @IdRate
END