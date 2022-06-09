-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 3 Noviembre 2020
-- Description:	Registra retorno de envio a SAP
-- =============================================
CREATE PROCEDURE [dbo].[sps_ResponseSAPToInvoice]
	-- Add the parameters for the stored procedure here
	@id as int,
	@status as int,
	@docEntry as int,
	@SAPError as varchar(1000),
	@token as varchar(50),
	@opcion as varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @opcion = 'documentoPrincipal' begin
		-- Insert statements for procedure here
		update DeliveryBackOffice.dbo.invoiceHeader
		set inv_SAPDocEntry = @docEntry,
		inv_SAPError = @SAPError,
		inv_tokenUpdate = @token,
		inv_dateUpdate = GETDATE(),
		inv_status = @status
		where inv_pk_id = @id

		select @@ROWCOUNT 'ROWCOUNT'
	end
	if @opcion = 'detalleDePagos' begin
		-- Insert statements for procedure here
		update DeliveryBackOffice.dbo.InOutOfMoneyDetail
		set io_SAPDocEntryPaymentDetail = @docEntry,
		io_SAPErrorPaymentDetail = @SAPError,
		io_updateToken = @token,
		io_updateDate = GETDATE(),
		io_status = @status
		where io_pk_id = @id

			
		select @@ROWCOUNT 'ROWCOUNT'
	end

END
