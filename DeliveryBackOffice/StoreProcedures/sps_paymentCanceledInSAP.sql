USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_paymentCanceledInSAP]    Script Date: 4/12/2020 1:03:03 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 19 Nov 2020
-- Description:	Registra en base de datos si pagos asociados a factura fueron cancelados en SAP
-- =============================================
CREATE PROCEDURE [dbo].[sps_paymentCanceledInSAP]
	-- Add the parameters for the stored procedure here
	@idInvoice as int,
	@result bit,
	@description as varchar(2000),
	@token as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update InOutOfMoneyDetail
	set 
	io_canceledInSAP = @result,
	io_canceledInSAPDescription = @description,
	io_updateToken = @token,
	io_updateDate = GETDATE()
	where io_invoice = @idInvoice
END
GO


