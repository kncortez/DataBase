/*
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Inserta encabezado de factura
-- =============================================
*/
CREATE PROCEDURE [dbo].[sps_headerInvoice]
	-- Add the parameters for the stored procedure here
	 @VpCodeOfReferences int
    ,@cmp_nit varchar(100)
    ,@cli_name varchar(500)
    ,@cli_adress varchar(1000)
    ,@cli_nit varchar(100)
    ,@cli_email varchar(500)
    ,@IVA money
    ,@amount money
    ,@tokenRegister varchar(200)
	,@type int
	,@systemOrigen int = 1
	,@CatTypeInvoiceId INT = NULL
AS
BEGIN

if (@systemOrigen = 0)
BEGIN
 SET @systemOrigen = (select top 1 SysIdSystem
				from DeliveryBackOffice.dbo.CatSystem
				where SysNameSystem = 'FDExpressCenter'
				)
END
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	INSERT INTO [dbo].[invoiceHeader]
           ([inv_vpCodeOfReferences]
		   ,[inv_cmp_nit]
           ,[inv_cli_name]
           ,[inv_cli_adress]
           ,[inv_cli_nit]
           ,[inv_cli_email]
           ,[inv_date]
           ,[inv_IVA]
           ,[inv_amount]
           ,[inv_status]
           ,[inv_dateRegister]
           ,[inv_tokenRegister]
		   ,[inv_type]
           ,[systemOperation]
		   ,[CatInvoiceTypeId]
		   )
     VALUES
           (@VpCodeOfReferences
		   ,@cmp_nit
           ,@cli_name
           ,@cli_adress
           ,@cli_nit
           ,@cli_email
           ,GETDATE()
           ,@IVA
           ,@amount
           ,1
           ,GETDATE()
           ,@tokenRegister
		   ,@type
           ,@systemOrigen
		   ,ISNULL(@CatTypeInvoiceId, (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE Name = 'Envío' AND RowStatus = 1))
		   )
		   select @@IDENTITY 'IDENTITY'
END