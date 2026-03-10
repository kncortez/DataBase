/* =================================================
   SP:        dbo.Support_RefacturacionSuscripcion
   Propósito: Asociar una suscripción a una factura verificando estado y existencia.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5301
   Fecha:     2025-12-19
=========================================== */

CREATE PROCEDURE dbo.Support_RefacturacionSuscripcion
    @CodigoCertificacionFEL NVARCHAR(200), 
    @NumeroVoucher NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- PASO 1: Validar existencia y estado de la factura
        DECLARE @InvoiceHeaderId INT;
        DECLARE @InvoiceStatus   INT;
        DECLARE @PaisFactura     NVARCHAR(4);

        SELECT TOP 1
            @InvoiceHeaderId = INV_PK_Id,
            @InvoiceStatus   = inv_status,
            @PaisFactura     = inv_CountryFEL
        FROM DeliveryBackOffice.dbo.InvoiceHeader WITH (NOLOCK)
        WHERE inv_certificationFEL = @CodigoCertificacionFEL;

        IF @InvoiceHeaderId IS NULL
        BEGIN
            SELECT 
                'Error'                                           AS Estado,
                'No fue posible encontrar la factura solicitada.' AS Mensaje,
                @CodigoCertificacionFEL                           AS CodigoCertificacionFEL;
            RETURN;
        END

        IF @InvoiceStatus = -1
        BEGIN
            SELECT 
                'Error'                                                                       AS Estado,
                'La factura se encuentra en estado ANULADO. No se puede asociar suscripción.' AS Mensaje,
                @CodigoCertificacionFEL                                                       AS CodigoCertificacionFEL,
                @InvoiceHeaderId                                                              AS InvoiceHeaderId,
                @InvoiceStatus                                                                AS EstadoFactura;
            RETURN;
        END

        -- PASO 2: Validar que el detalle NO tenga suscripción asociada
        DECLARE @SubscriptionIdActual INT;

        SELECT TOP 1
            @SubscriptionIdActual = SubscriptionId
        FROM DeliveryBackOffice.dbo.InvoiceDetail WITH (NOLOCK)
        WHERE DTI_FK_Header = @InvoiceHeaderId;

        IF @SubscriptionIdActual IS NOT NULL AND @SubscriptionIdActual <> 0
        BEGIN
            SELECT 
                'Error'                                          AS Estado,
                'La factura ya está asociada a una suscripción.' AS Mensaje,
                @InvoiceHeaderId                                 AS InvoiceHeaderId,
                @SubscriptionIdActual                            AS SuscripcionActual;
            RETURN;
        END

        -- PASO 3: Validar existencia del voucher en registro de transacciones
        IF NOT EXISTS (
            SELECT TOP 1 1
            FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates WITH (NOLOCK)
            WHERE OrderNumber = @NumeroVoucher
        )
        BEGIN
            SELECT 
                'Error'                                                  AS Estado,
                'Voucher no encontrado en el registro de transacciones.' AS Mensaje,
                @NumeroVoucher                                           AS NumeroVoucher;
            RETURN;
        END

        -- PASO 3.5: Validar que el país de la factura coincida con el país del cliente en la transacción
        DECLARE @PaisTransaccion NVARCHAR(2);

        SELECT TOP 1
            @PaisTransaccion = C.CountryID
        FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.Customer C WITH (NOLOCK)
            ON C.IdCustomer = RT.CustomerId
        WHERE RT.OrderNumber = @NumeroVoucher;

        IF @PaisTransaccion IS NULL
        BEGIN
            SELECT 
                'Error'                                                          AS Estado,
                'No se pudo determinar el país del cliente asociado al voucher.' AS Mensaje,
                @NumeroVoucher                                                   AS NumeroVoucher;
            RETURN;
        END

        IF @PaisFactura <> @PaisTransaccion
        BEGIN
            SELECT 
                'Error'                                                                        AS Estado,
                'El país de la factura no coincide con el país del cliente en la transacción.' AS Mensaje,
                @CodigoCertificacionFEL                                                        AS CodigoCertificacionFEL,
                @InvoiceHeaderId                                                               AS InvoiceHeaderId,
                @PaisFactura                                                                   AS PaisFactura,
                @NumeroVoucher                                                                 AS NumeroVoucher,
                @PaisTransaccion                                                               AS PaisTransaccion;
            RETURN;
        END

        -- PASO 4: Obtener SubscriptionId desde SubscriptionPaymentLog
        DECLARE @SubscriptionIdNuevo INT;

        SELECT TOP 1
            @SubscriptionIdNuevo = SubscriptionId
        FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog WITH (NOLOCK)
        WHERE [Authorization] = @NumeroVoucher;

        IF @SubscriptionIdNuevo IS NULL
        BEGIN
            SELECT 
                'Error'                                                             AS Estado,
                'No se encontró una suscripción asociada al voucher proporcionado.' AS Mensaje,
                @NumeroVoucher                                                      AS NumeroVoucher;
            RETURN;
        END

        -- PASO 5: Actualizar InvoiceDetail con la nueva suscripción
        DECLARE @SubscriptionIdAntes INT;

        SELECT TOP 1
            @SubscriptionIdAntes = SubscriptionId
        FROM DeliveryBackOffice.dbo.InvoiceDetail WITH (NOLOCK)
        WHERE DTI_FK_Header = @InvoiceHeaderId;

        UPDATE DeliveryBackOffice.dbo.InvoiceDetail
        SET 
            SubscriptionId = @SubscriptionIdNuevo
        WHERE DTI_FK_Header = @InvoiceHeaderId;

        -- RESULTADO EXITOSO: Mostrar antes y después
        SELECT 
            'Éxito'                                                      AS Estado,
            'Se ha asociado la suscripción con la factura exitosamente.' AS Mensaje,
            @InvoiceHeaderId                                             AS InvoiceHeaderId,
            @SubscriptionIdAntes                                         AS SubscriptionId_Antes,
            @SubscriptionIdNuevo                                         AS SubscriptionId_Despues;

    END TRY
    BEGIN CATCH
        SELECT 
            'Error'                                                    AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()                                             AS ErrorNumero,
            ERROR_MESSAGE()                                            AS ErrorDescripcion,
            ERROR_LINE()                                               AS ErrorLinea;

        THROW;
    END CATCH
END
GO