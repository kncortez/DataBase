/* =================================================
   SP:        [dbo].[sps_RegisterInvoiceForza]
   Propósito: Realiza el proceso de facturación
   Autor:     Alberto Ixchop
   Historia:  ---
   Fecha:     2022-04-21

=== CHANGELOG ============================

2024-06-27 | Historia/épica: ---        | Autor: Daniel Ramirez  |
2024-06-27 | Historia/épica: ---        | Autor: Brandon Pedroza |

=========================================== */
CREATE PROCEDURE [dbo].[sps_RegisterInvoiceForza]
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
    ,@IdCurrency INT = 1
    ,@IdCountry  VARCHAR(2) = 'GT'
	,@TblLstDetail TblLstDetail READONLY
	,@TblInOutOfMoneyDetail TblInOutOfMoneyDetail READONLY
	,@TblBuyerInfo TblBuyerInfo READONLY
AS
BEGIN
	DECLARE @invoiceHeaderId bigint=-1;
	DECLARE @Guide INT = 0;

	SET @Guide =(SELECT Count (ind.dti_fk_orderNumber)
				 FROM invoiceDetail ind WITH (NOLOCK)
				 INNER JOIN @TblLstDetail tbd	
				 ON ind.dti_fk_orderserie = tbd.orderSerie
					AND ind.dti_fk_orderNumber = tbd.orderNumber
				 INNER JOIN invoiceHeader inh WITH (NOLOCK)
				 ON ind.dti_fk_header = inh.inv_pk_id
				 WHERE inh.inv_certificationFEL IS NULL
				);
     IF(@Guide <= 0)

          BEGIN
			--Procesando nuevo registro para tabla invoiceHeader
					BEGIN TRANSACTION
					BEGIN TRY
						--DECLARE @invoiceHeaderId bigint=-1;
						IF (@systemOrigen = 0)
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

							DECLARE @idType INT;

							SET @idType = (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE Name = 'Envío')

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
                                ,[IdCurrency]
                                ,[IdCountry]
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
								,@idType
                                ,@IdCurrency
                                ,@IdCountry
								)
								SET @invoiceHeaderId= @@IDENTITY --'IDENTITY'

					--Procesando nuevo registro para tabla invoiceDetail



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
					SELECT	@invoiceHeaderId
							,CASE WHEN LstDtl.orderNumber <= 0 THEN NULL ELSE LstDtl.orderSerie END
							,CASE WHEN LstDtl.orderNumber <= 0 THEN NULL ELSE LstDtl.orderNumber END
							,LstDtl.identification
							,LstDtl.category
							,LstDtl.quantity
							,LstDtl.measurement
							,LstDtl.priceUnit
							,LstDtl.description
							,LstDtl.IVA
							,LstDtl.amount
							,GETDATE()
							,@tokenRegister
							,LstDtl.SAPCode
							,LstDtl.SendToInvoice
						FROM @TblLstDetail LstDtl     
							--select @@ROWCOUNT 'rowCount'

					--Procesando nuevo registro para tabla InOutOfMoneyDetail
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
					SELECT   MD.type
							,MD.vpCodeOfReferences
							,MD.ticket
							,MD.amount
							,MD.status
							,@invoiceHeaderId
							,@tokenRegister
							,GETDATE()
					FROM @TblInOutOfMoneyDetail MD
					
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



						INSERT INTO dbo.RoutePreparationLogError
						(
						    ErrorDescription
						  , ErrorNumber
						  , ErrorProcedure
						  , ErrorLine
						  , GuideSerie
						  , GuideNumber
						  , TokenCreated
						  , DateCreated
						)
						VALUES
						(   ERROR_MESSAGE()      -- ErrorDescription - varchar(300)
						  , ERROR_NUMBER()      -- ErrorNumber - int
						  , ERROR_PROCEDURE()      -- ErrorProcedure - varchar(100)
						  , ERROR_LINE()      -- ErrorLine - int
						  , NULL      -- GuideSerie - nvarchar(2)
						  , NULL      -- GuideNumber - int
						  , @cli_email        -- TokenCreated - varchar(50)
						  , GETDATE() -- DateCreated - datetime
						    )

					END CATCH
     END
          ELSE
			BEGIN
			SET @invoiceHeaderId = (SELECT TOP 1 dti_fk_header FROM invoiceDetail indt WITH (NOLOCK)
									INNER JOIN @TblLstDetail tbld
									ON indt.dti_fk_orderserie = tbld.orderSerie
									AND indt.dti_fk_orderNumber = tbld.orderNumber
									INNER JOIN invoiceHeader inh WITH (NOLOCK)
									ON indt.dti_fk_header = inh.inv_pk_id
								    WHERE inh.inv_certificationFEL IS NULL)
			SELECT @invoiceHeaderId 'IDENTITY'
		
			END
END