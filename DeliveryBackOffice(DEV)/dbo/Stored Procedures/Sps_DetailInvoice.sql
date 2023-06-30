

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 7 Octubre 2020
-- Description:	Inserta detalle de facturacion
-- =============================================
CREATE PROCEDURE [dbo].[Sps_DetailInvoice]
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
	,@SAPCode varchar(50) = NULL
	,@SendToInvoice BIT = NULL
	,@CatInvoiceTypeId INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdType INT;

	IF(@orderNumber > 0)
		BEGIN
		IF(@CatInvoiceTypeId IS NULL)
			SET @IdType = (SELECT IdCatInvoiceType FROM CatInvoiceType WITH (NOLOCK) WHERE Name = 'Envío')
		ELSE
			SET @IdType = (SELECT IdCatInvoiceType FROM CatInvoiceType WITH (NOLOCK) WHERE IdCatInvoiceType = @CatInvoiceTypeId)

			UPDATE invoiceHeader 
			SET CatInvoiceTypeId = @IdType
			WHERE inv_pk_id = @header
		END
	ELSE	
	    BEGIN
			SET @IdType = (SELECT IdCatInvoiceType FROM CatInvoiceType WITH (NOLOCK) WHERE Name = 'Otros')
			UPDATE invoiceHeader 
			SET CatInvoiceTypeId = @IdType
			WHERE inv_pk_id = @header

		END


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
           ,[dti_tokenRegister]
		   ,[SAPCode]
		   ,[SendToInvoice])
     VALUES
           ( @header
			,CASE WHEN @orderNumber <= 0 THEN NULL
			ELSE @orderSerie END
			,CASE WHEN @orderNumber <= 0 THEN NULL
			ELSE @orderNumber END
			,@identification
			,@category
			,@quantity
			,@measurement
			,@priceUnit
			,@description
			,@IVA
			,@amount
			,GETDATE()
			,@tokenRegister
			,@SAPCode
			,@SendToInvoice)
			select @@ROWCOUNT 'rowCount'
END