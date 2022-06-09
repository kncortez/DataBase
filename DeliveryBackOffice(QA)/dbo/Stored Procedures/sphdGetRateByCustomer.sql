-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-07-06>
-- Description:	<Obtiene las tarifas por cliente>
-- De momento solo 1 puede ser valida a la vez
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRateByCustomer]
	-- Add the parameters for the stored procedure here
	@IdCustomer AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT rbc.RbcId,
		   rbc.RbcIdRate,
		   rhd.RateTypeId,
		   rbc.RbcIdCustomer,
		   rbc.RbcRowStatus
	FROM dbo.RatebyCustomer rbc
		JOIN dbo.RateHeader rhd ON rhd.RheId = rbc.RbcIdRate
	WHERE rbc.RbcIdCustomer = @IdCustomer
	AND rbc.RbcRowStatus = 'TRUE'
	AND rbc.RbcCodeOfReference IS NULL

END
