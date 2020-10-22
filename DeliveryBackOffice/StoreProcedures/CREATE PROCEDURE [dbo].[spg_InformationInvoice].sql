USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_InformationInvoice]    Script Date: 12/10/2020 00:14:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Retorna informacion de la factura
-- =============================================
CREATE PROCEDURE [dbo].[spg_InformationInvoice]
	-- Add the parameters for the stored procedure here
	@idInvoice bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select * from [dbo].[invoiceHeader]
	where inv_pk_id = @idInvoice

	select * from [dbo].[invoiceDetail]
	where dti_fk_header = @idInvoice
END
GO


