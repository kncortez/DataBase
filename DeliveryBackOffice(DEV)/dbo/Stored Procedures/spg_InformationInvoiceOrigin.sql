-- =============================================
-- Author:		Eduardo López
-- Create date: 10 Marzo 2023
-- Description:	Obtener datos de facturas que origina NC para enviar en variables nuevas que solicita SAT para las NC
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoiceOrigin]
	-- Add the parameters for the stored procedure here
	@idInvoice bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SET LANGUAGE Español

    -- Insert statements for procedure here
	SELECT inv_certificationFEL,inv_serieFEL,inv_numberFEL FROM [dbo].[invoiceHeader] WITH(NOLOCK)
	WHERE inv_pk_id = @idInvoice 

	
END