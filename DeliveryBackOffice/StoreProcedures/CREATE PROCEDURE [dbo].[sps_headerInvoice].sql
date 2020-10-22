USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_headerInvoice]    Script Date: 12/10/2020 00:12:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Inserta encabezado de factura
-- =============================================
CREATE PROCEDURE [dbo].[sps_headerInvoice]
	-- Add the parameters for the stored procedure here
			@cmp_name varchar(500)
           ,@cmp_adress varchar(1000)
           ,@cmp_nit varchar(100)
           ,@cli_name varchar(500)
           ,@cli_adress varchar(1000)
           ,@cli_nit varchar(100)
           ,@cli_email varchar(500)
           ,@tickets varchar(500)
           ,@IVA money
           ,@amount money
           ,@tokenRegister varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[invoiceHeader]
           ([inv_cmp_name]
           ,[inv_cmp_adress]
           ,[inv_cmp_nit]
           ,[inv_cli_name]
           ,[inv_cli_adress]
           ,[inv_cli_nit]
           ,[inv_cli_email]
           ,[inv_date]
           ,[inv_tickets]
           ,[inv_IVA]
           ,[inv_amount]
           ,[inv_status]
           ,[inv_dateRegister]
           ,[inv_tokenRegister]
           )
     VALUES
           (@cmp_name
           ,@cmp_adress
           ,@cmp_nit
           ,@cli_name
           ,@cli_adress
           ,@cli_nit
           ,@cli_email
           ,GETDATE()
           ,@tickets
           ,@IVA
           ,@amount
           ,1
           ,GETDATE()
           ,@tokenRegister
           )
		   select @@IDENTITY 'IDENTITY'
END
GO


