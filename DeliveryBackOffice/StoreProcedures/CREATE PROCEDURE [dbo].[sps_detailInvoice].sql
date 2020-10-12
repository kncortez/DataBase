USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_detailInvoice]    Script Date: 12/10/2020 00:13:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Inserta detalle de facturacion
-- =============================================
CREATE PROCEDURE [dbo].[sps_detailInvoice]
	 @header bigint
	,@orderSerie nvarchar(2)
	,@orderNumber int
	,@identification varchar(200)
	,@category varchar(50)
	,@quantity decimal(10,5)
	,@measurement varchar(20)
	,@priceUnit money
	,@description varchar(max)
	,@IVA money
	,@amount money
	,@tokenRegister varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[invoiceDetail]
           ([dti_fk_header]
           ,[dti_fk_orderSerie]
           ,[dti_fk_orderNumber]
           ,[dti_identification]
           ,[dti_category]
           ,[dti_quantity]
           ,[dti_measurement]
           ,[dti_priceUnit]
           ,[dti_description]
           ,[dti_IVA]
           ,[dti_amount]
           ,[dti_dateRegister]
           ,[dti_tokenRegister])
     VALUES
           ( @header
			,@orderSerie
			,@orderNumber
			,@identification
			,@category
			,@quantity
			,@measurement
			,@priceUnit
			,@description
			,@IVA
			,@amount
			,GETDATE()
			,@tokenRegister)
END
GO


