

-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2022-05-13>
-- Description:	<Obtiene información de los tipos de facturas>
-- =============================================

CREATE PROCEDURE [dbo].[GetCatInvoiceType] 
-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT IdCatInvoiceType Id
		, Name
		, Description
	FROM CatInvoiceType 
	WHERE RowStatus = 1
	ORDER BY Id

	SET NOCOUNT OFF;
END