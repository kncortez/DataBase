
--exec SetInvoiceLog 5695,17150,'srvMonitorSAPDelivery','{"IdInvoice":5695,"Header":{"Cardcode":"CEC0002","DocDueDate":"\/Date(-62135575200000)\/","DocDate":"\/Date(1619711869313)\/","NumAtCard":"","TaxDate":"\/Date(-62135575200000)\/","DocType":"","coment":"","Detail":[{"Itemcode":"409010101","Quantity":1,"TaxCode":"IVA","WhsCode":"","Price":16,"ocrCode":"","shipToCode":"","safe":"","codigoF":"","currency":"","slpCode":"","address":""}],"payments":{"totalCash":16,"totalCreditCard":0,"coment":"Serie FEL: 1978945312","intCreditCard":1,"VoucherNum":"","idForza":5639},"slpCode":1,"NIT":"","intInvoiceSeries":51,"intPaymentSeries":53,"intCreditNoteSeries":-1,"U_FacNit":"CF","U_FacNom":"Consumidor Final","U_Firma_Eletronica":"6F830713-75F4-4F20-BE54-CF2ABC287857","U_Numero_Documento":"1978945312","U_Factura_Serie":"PRUEBAS","U_Fecha_Face":"2021-04-29T09:57:49-06:00","U_N_documento_nc":"","U_Fecha_nc":"","U_motivo_nc":""},"Tipo":1,"Status":2,"OcrCode":"10400","OcrCode2":"509401","StatusFACE":"A","method":"sendToSAP"}','"{ SAPDocEntry: " 1759 " }"','',1
CREATE PROC [dbo].[SetInvoiceLog] @inv_pk_id BIGINT,
@SAPDocEntry AS INT,
@Token AS NVARCHAR(200),
@inv_DataSent NVARCHAR(MAX),
@inv_DataReceived NVARCHAR(MAX),
@ErrorDesc NVARCHAR(MAX),
@TransactionStatus INT, --> 0 = Transacción no completada
--> 1 = Transacción completada
@CreateUser AS NVARCHAR(200)=NULL
AS
BEGIN

	DECLARE @Intentos AS INT;
	DECLARE @MAX_Intentos AS INT = 10;
	DECLARE @InvIdRestriction AS BIGINT;
	DECLARE @InvoiceLogID as int = 0;

	SET @Intentos = (SELECT
			ISNULL(SUM([invRetries]), 0)
		FROM InvoiceRestriction
		WHERE inv_pk_id = @inv_pk_id)
	IF @Intentos <= @MAX_Intentos
	BEGIN

	print @Intentos;

		SET @Intentos = @Intentos + 1
    print 'Intentos';
	print @Intentos;

		SET @InvIdRestriction = (SELECT
				ISNULL(InvIdRestriction, 0)
			FROM dbo.InvoiceRestriction
			WHERE inv_pk_id = @inv_pk_id)

	print '@InvIdRestriction';
	print @InvIdRestriction;

		IF @InvIdRestriction > 0
		BEGIN

			print '@InvIdRestriction mayor a 0';

			UPDATE dbo.InvoiceRestriction
			SET inv_SAPDocEntry = @SAPDocEntry
			   ,invRetries = @Intentos
			   ,invRowStatus = @TransactionStatus
			   ,invOperationDate = GETDATE()
			WHERE InvIdRestriction = @InvIdRestriction

		END
		ELSE
		BEGIN
		print 'insertar en InvoiceRestiction'
			INSERT INTO dbo.InvoiceRestriction (inv_pk_id, inv_SAPDocEntry, invRetries,
			invRowStatus, invTokenCreated, invDateCreated, invOperationDate)
				SELECT
					@inv_pk_id
				   ,@SAPDocEntry
				   ,@Intentos
				   ,@TransactionStatus
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()

			SET @InvIdRestriction = SCOPE_IDENTITY();
				print '@InvIdRestriction scope identity';
	            print @InvIdRestriction;
		END



			print 'Inserta InvoiceLog';
		INSERT INTO dbo.InvoiceLog (inv_pk_id, InvIdRestriction, inv_DataSent, inv_DataReceived, ErrorDesc,
		[Date], TransactionStatus,CreateUser)
			SELECT
				@inv_pk_id
			   ,@InvIdRestriction
			   ,@inv_DataSent
			   ,@inv_DataReceived
			   ,@ErrorDesc
			   ,GETDATE()
			   ,@TransactionStatus
			   ,@CreateUser

			   SET @InvoiceLogID = SCOPE_IDENTITY();

			   SELECT ISNULL(@InvoiceLogID,0) AS InvoiceLogID
	END

END
