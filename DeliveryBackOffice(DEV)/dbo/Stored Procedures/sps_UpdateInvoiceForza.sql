-- =============================================
-- Author:      <Cristian, Azurdia>
-- Modified:    <2025-00-10>
-- Description: <Facturacion SV - Se actualiza informacion del documento emitido>
-- =============================================
CREATE PROCEDURE [dbo].[sps_UpdateInvoiceForza]
     @IdInvoice int
    ,@cli_name varchar(500)
    ,@cli_address varchar(1000)
    ,@cli_nit varchar(100)
    ,@cli_email varchar(500)
    ,@tokenRegister varchar(200)
    ,@IdCountry  VARCHAR(2) = 'GT'
    ,@TblBuyerInfo TblBuyerInfo READONLY
AS
BEGIN

    BEGIN TRANSACTION
    BEGIN TRY
        --Actualizando registro de InvoiceHeader
        UPDATE [dbo].[invoiceHeader]
        SET [inv_cli_name] = @cli_name,
            [inv_cli_adress] = @cli_address,
            [inv_cli_nit] = @cli_nit,
            [inv_cli_email] = @cli_email
        WHERE inv_pk_id = @IdInvoice --'IDENTITY'

        --INSERT EN TABLA LOG DE INFORMACION DEL CLIENTE CUANDO SE EMITE UNA FACTURA
        IF(@IdCountry = 'SV')
        BEGIN

            UPDATE InformationBuyerInvoice
            SET DistrictCode = BI.DistrictCode
               ,StateCode = BI.StateCode
               ,ActivityCode = BI.ActivityCode
               ,ActivityDescription = BI.ActivityDescription
               ,NRC = BI.NRC
               ,TypeIdentificationDocumentCode = BI.TypeDocument
               ,IdDocument =BI.IdDocument
               ,Phone = BI.Phone
               ,TokenUpdated = @tokenRegister
               ,DateUpdated = GETDATE()
            FROM @TblBuyerInfo BI
            WHERE InvoiceId = @IdInvoice
        END

        SELECT @IdInvoice;

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