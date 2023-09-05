-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-11>
-- Description:	<Obtiene información de Departamentos y Municipios para el Parser>
-- =============================================
CREATE PROCEDURE [dbo].[GetArticleByCustomerByCodeOfReference]
	-- Add the parameters for the stored procedure here
	@CustomerId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		abc.Code
	   ,rbc.RbcCodeOfReference
	FROM RatebyCustomer rbc WITH (NOLOCK)
	INNER JOIN RateData rd WITH (NOLOCK)
		ON rbc.RbcIdRate = rd.RateId
			AND rd.RowStatus = 1
	INNER JOIN ArticleByCustomer abc WITH (NOLOCK)
		ON rd.ArticleId = abc.AbcId
	WHERE rbc.RbcIdCustomer = @CustomerId
	AND rbc.RbcRowStatus = 1
	GROUP BY abc.Code
			,rbc.RbcCodeOfReference

END