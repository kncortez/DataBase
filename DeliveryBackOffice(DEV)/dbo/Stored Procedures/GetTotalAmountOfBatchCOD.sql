-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-19>
-- Description:	<Obtiene el monto total para un lote en Guías por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[GetTotalAmountOfBatchCOD]
	-- Add the parameters for the stored procedure here
	@BatchCODId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		ISNULL(SUM(bdc.Amount), 0) TotalAmount
	FROM BatchDetailCOD bdc WITH(NOLOCK)
	INNER JOIN BatchCOD bc WITH(NOLOCK)
		ON bc.IdBatchCOD = bdc.BatchCODId
	WHERE bc.BatchNumber = @BatchCODId
	AND bdc.Excluded = 0
	AND bdc.RowStatus = 1
	AND bc.RowStatus = 1
END