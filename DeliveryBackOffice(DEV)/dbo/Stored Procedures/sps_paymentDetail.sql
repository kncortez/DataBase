
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 13 Octubre 2020
-- Description:	Inserta registro de detalle de pago
-- =============================================
CREATE PROCEDURE [dbo].[sps_paymentDetail]
	 @type varchar(200),
	 @vpCodeOfReferences int,
	 @ticket varchar(100),
     @amount money,
     @status int = 1,
     @invoice bigint,
     @token varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[InOutOfMoneyDetail]
			   (
				[io_type],
				[io_vpCodeOfReferences],
				[io_ticket],
				[io_amount],
				[io_status],
				[io_invoice],
				[io_registryToken],
				[io_registryDate]
			   )
		 VALUES
			   (@type
			   ,@vpCodeOfReferences
			   ,@ticket
			   ,@amount
			   ,@status
			   ,@invoice
			   ,@token
			   ,GETDATE()
			   )
		SELECT @@ROWCOUNT 'RowCount'

END
