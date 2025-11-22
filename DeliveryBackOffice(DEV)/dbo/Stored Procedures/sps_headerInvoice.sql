/* =================================================
   SP:        [dbo].[sps_headerInvoice]
   Propósito: Inserta encabezado de factura
   Autor:     Luis Fernando Coti Itzep
   Historia:  ---
   Fecha:     2020-10-07

=== CHANGELOG ============================

2024-08-12 | Historia/épica: ---          | Autor: Cristian Suazo  |
2025-11-21 | Historia/épica: FDAPI-4961   | Autor: Brandon Pedroza |

=========================================== */
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
	,@TblBuyerInfo TblBuyerInfo READONLY
AS
BEGIN


DECLARE @IdCountry NVARCHAR(2),
		@IdCurrency INT,
		@invoiceHeaderId BIGINT=-1;

	SELECT @IdCountry=CountryId 
	FROM VisitPointClient WITH (NOLOCK)
	WHERE CodeOfReference = @VpCodeOfReferences

	SELECT @IdCurrency = CU.IdCatCurrencyCOD 
	FROM DeliveryCurrency DC WITH (NOLOCK)
	INNER JOIN CatCurrencyCOD CU WITH (NOLOCK)
		ON DC.IdCurrencyCOD = CU.IdCatCurrencyCOD
	WHERE DC.Currency_IdCountry = @IdCountry AND DC.Currency_Status = 1
	AND DC.DefaultPerCountry = 1


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
		   ,IdCurrency
		   ,IdCountry
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
		   ,@IdCurrency
		   ,@IdCountry
		   )
          SET @invoiceHeaderId= @@IDENTITY
        --INSERT EN TABLA LOG DE INFORMACION DEL CLIENTE CUANDO SE EMITE UNA FACTURA
            IF(@IdCountry = 'SV')
            BEGIN
            INSERT INTO InformationBuyerInvoice 
                        (
                        InvoiceId,
                        DistrictCode,
                        StateCode,
                        ActivityCode,
                        ActivityDescription,
                        NRC,
                        TypeIdentificationDocumentCode,
                        IdDocument,
                        Phone,
                        Rowstatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated,
                        OperationConditionCode
                        )
                SELECT @invoiceHeaderId
                        ,BI.DistrictCode
                        ,BI.StateCode
                        ,BI.ActivityCode
                        ,BI.ActivityDescription
                        ,BI.NRC
                        ,BI.TypeDocument
                        ,BI.IdDocument
                        ,BI.Phone
                        ,1
                        ,@tokenRegister
                        ,GETDATE()
                        ,NULL
                        ,NULL
                        ,BI.OperationConditionCode
                    FROM @TblBuyerInfo BI
            END
        
        SELECT @invoiceHeaderId 'IDENTITY'
END