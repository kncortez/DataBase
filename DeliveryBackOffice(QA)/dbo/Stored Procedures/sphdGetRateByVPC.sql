-- =============================================
-- Author:		<Sazo,César>
-- Create date: <28/01/2022>
-- Description:	<Obtiene las tarifas por punto de visita>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRateByVPC]
	@IdCustomer AS INT
	,@CodeOfReference AS INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT rbc.RbcId,
		   rbc.RbcIdRate,
		   rhd.RateTypeId,
		   rbc.RbcIdCustomer,
		   rbc.RbcRowStatus
	FROM dbo.RatebyCustomer rbc
		JOIN dbo.RateHeader rhd ON rhd.RheId = rbc.RbcIdRate
	WHERE rbc.RbcIdCustomer = @IdCustomer
	AND rbc.RbcRowStatus = 'TRUE'
	AND rbc.RbcCodeOfReference = @CodeOfReference

END
