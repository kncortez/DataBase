-- =============================================
-- Author:		Oscar Rodriguez
-- Create date: 09/04/2024
-- Description:	Validacion para lote de factura activo
-- =============================================
CREATE PROCEDURE [dbo].[sps_InvoicecreditNoteValidation]
	-- Add the parameters for the stored procedure here
	@idInvoice int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @ValidacionOk as int = 0;
    -- Insert statements for procedure here
	SELECT @ValidacionOk = ih.inv_pk_id
	from invoiceHeader ih WITH(NOLOCK)
	LEFT JOIN dbo.InvoiceBatchHeader ibh WITH (NOLOCK) ON ibh.CAI = ih.inv_serieFEL
	where inv_pk_id = @idInvoice
	AND ibh.RowStatus = 1
	AND ibh.TypeDocument = 1;


	select @ValidacionOk 'code'
END
