-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2022-09-26>
-- Description:	<Registrar facturas procesadas de forma manual>
-- =============================================

CREATE PROCEDURE [dbo].[RegisterInvoiceManual]
@Serie VARCHAR(5),
@Guide INT,
@Fel VARCHAR(100),
@Amount MONEY,
@SapCode VARCHAR(25),
@DateNow VARCHAR(10)

AS

	DECLARE @invoiceHeaderId bigint=-1;
	DECLARE @CountInvoice int = 0;
	DECLARE @invoiceIdExist int = 0;
	DECLARE @sumFac money = 0.00
	BEGIN
		
		SET @CountInvoice = (SELECT COUNT(inv_pk_id) FROM invoiceHeader with (nolock)
				WHERE inv_certificationFEL = @Fel)
		IF(@CountInvoice >=1)
			BEGIN
				SET @invoiceIdExist = (SELECT top 1 inv_pk_id FROM invoiceHeader with (nolock) WHERE inv_certificationFEL = @Fel)
				SET @sumFac = ((SELECT top 1 inv_amount FROM invoiceHeader with (nolock) WHERE inv_pk_id = @invoiceIdExist)+@Amount)

				UPDATE invoiceHeader
				SET inv_amount = @sumFac
				WHERE inv_pk_id = @invoiceIdExist
				--PRINT (@CountInvoice)
				--PRINT(@invoiceIdExist)
				--PRINT (@sumFac)
				INSERT INTO invoiceDetail (
									dti_fk_header,
									dti_fk_orderSerie, 
									dti_fk_orderNumber, 
									dti_identification, 
									dti_category, 
									dti_quantity, 
									dti_measurement, 
									dti_priceUnit, 
									dti_description, 
									dti_IVA, 
									dti_amount, 
									dti_dateRegister, 
									dti_tokenRegister, 
									SAPCode)
											VALUES (
											@invoiceIdExist,
											'FD', 
											@Guide, 
											'SERVICIO', 
											'BIEN', 
											1.00000, 
											'UND', 
											@Amount, 
											'TRANSPORTE PAQ. 1Lbs. '+CONVERT(varchar(25), @Guide), 
											0.00, 
											@Amount, 
											GETDATE(), 
											'CARGA_MANUAL_' + @DateNow,  
											@SapCode)

			END
			ELSE
			BEGIN
					BEGIN TRANSACTION
					BEGIN TRY

						INSERT INTO invoiceHeader(
						inv_vpCodeOfReferences, 
						inv_cmp_name, 
						inv_cmp_nameComercial, 
						inv_cmp_adress,
						inv_cmp_nit, 
						inv_cli_name,
						inv_cli_adress, 
						inv_cli_nit, 
						inv_cli_email, 
						inv_date, 
						inv_documentSend, 
						inv_documentRecieved, 
						inv_certificationFEL,
						inv_serieFEL,inv_numberFEL, 
						inv_descriptionFEL, 
						inv_RequestorFEL,
						inv_TransactionFEL,
						inv_CountryFEL, 
						inv_EntityFEL, 
						inv_UserFEL, 
						inv_UserName, 
						inv_Data1FEL, 
						inv_Data3FEL, 
						inv_MailSendFEL, 
						inv_subjectFEL, 
						inv_IVA,inv_amount, 
						inv_status,
						inv_dateRegister, 
						inv_tokenRegister, 
						inv_type, 
						inv_establecimientoFEL, 
						inv_FechaHoraFEL,
						systemOperation,
						IsManualInvoice)
								VALUES (
								10000,
								'DELIVERY EXPRESS, SOCIEDAD ANONIMA', 
								'DELIVERY EXPRESS',
								'AVENIDA PETAPA 42-51   ZONA 12 EDIFICIO C,',
								'86534599',
								'1',
								'Ciudad',
								'1',
								'factura.manual@forzalatam.com',
								'2022-09-30 00:00:00.000',
								'1',
								'1',
								@Fel,
								'1',
								'1',
								'PROCESO REALIZADO',
								'1',
								'SYSTEM_REQUEST',
								'GT',
								'GT',
								'1',
								'FACTURA MANUAL',
								'POST_DOCUMENTGT',
								'XML',
								'factura.manual@forzalatam.com',
								'Forza Delivery - Factura Electrónica',
								0.00,
								@Amount,
								2,
								GETDATE(),
								'CARGA_MANUAL_' + @DateNow,
								1,
								'1',
								'2022-01-31',
								3,
								1)

							SET @invoiceHeaderId= @@IDENTITY --'IDENTITY'

									INSERT INTO invoiceDetail (
									dti_fk_header,
									dti_fk_orderSerie, 
									dti_fk_orderNumber, 
									dti_identification, 
									dti_category, 
									dti_quantity, 
									dti_measurement, 
									dti_priceUnit, 
									dti_description, 
									dti_IVA, 
									dti_amount, 
									dti_dateRegister, 
									dti_tokenRegister, 
									SAPCode)
											VALUES (
											@invoiceHeaderId,
											'FD', 
											@Guide, 
											'SERVICIO', 
											'BIEN', 
											1.00000, 
											'UND', 
											@Amount, 
											'TRANSPORTE PAQ. 1Lbs. '+CONVERT(varchar(25), @Guide), 
											0.00, 
											@Amount, 
											GETDATE(), 
											'CARGA_MANUAL_' + @DateNow, 
											@SapCode)
							COMMIT TRANSACTION;
								END TRY
								BEGIN CATCH

								SELECT 0 [blnResult],
										   ERROR_NUMBER() AS [ErrorNumber],
										   ERROR_SEVERITY() AS [ErrorSeverity],
										   ERROR_STATE() AS [ErrorState],
										   ERROR_PROCEDURE() AS [ErrorProcedure],
										   ERROR_LINE() AS [ErrorLine],
										   ERROR_MESSAGE() AS [ErrorMessage];

									ROLLBACK TRANSACTION;

								END CATCH
					END

	END