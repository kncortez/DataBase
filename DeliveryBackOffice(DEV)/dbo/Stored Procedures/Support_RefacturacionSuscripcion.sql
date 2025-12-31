/*
================================================================================
FECHA DE CREACIÓN: 2025-12-19
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_RefacturacionSuscripcion
    @CodigoCertificacionFEL VARCHAR(100),   -- Código de certificación FEL
    @NumeroVoucher VARCHAR(50),              -- Número de voucher/autorización
    @TokenUpdate VARCHAR(50)                 -- Token del usuario que realiza el cambio
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- PASO 1: Validar existencia y estado de la factura (InvoiceHeader)
        
        DECLARE @InvoiceHeaderId INT;
        DECLARE @InvoiceStatus INT;

        SELECT TOP 1
            @InvoiceHeaderId = INV_PK_Id,
            @InvoiceStatus = inv_status
        FROM dbo.InvoiceHeader WITH (NOLOCK)
        WHERE inv_certificationFEL = @CodigoCertificacionFEL;

        -- Validar si la factura existe
        IF @InvoiceHeaderId IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No fue posible encontrar la factura solicitada.' AS Mensaje,
                @CodigoCertificacionFEL AS CodigoCertificacionFEL;
            RETURN;
        END

        -- Validar si la factura está anulada
        IF @InvoiceStatus = -1
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La factura se encuentra en estado ANULADO. No se puede asociar suscripción.' AS Mensaje,
                @CodigoCertificacionFEL AS CodigoCertificacionFEL,
                @InvoiceHeaderId AS InvoiceHeaderId,
                @InvoiceStatus AS EstadoFactura;
            RETURN;
        END

        -- PASO 2: Validar que el detalle NO tenga suscripción asociada
        
        DECLARE @SubscriptionIdActual INT;

        SELECT TOP 1
            @SubscriptionIdActual = SubscriptionId
        FROM dbo.InvoiceDetail WITH (NOLOCK)
        WHERE DTI_FK_Header = @InvoiceHeaderId;


        IF @SubscriptionIdActual IS NOT NULL AND @SubscriptionIdActual <> 0
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La factura ya está asociada a una suscripción.' AS Mensaje,
                @InvoiceHeaderId AS InvoiceHeaderId,
                @SubscriptionIdActual AS SuscripcionActual;
            RETURN;
        END

        -- PASO 3: Validar existencia del voucher en registro de transacciones
        
        IF NOT EXISTS (
            SELECT TOP 1 1
            FROM dbo.RegistrationofTransactionProcessStates WITH (NOLOCK)
            WHERE OrderNumber = @NumeroVoucher
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Voucher no encontrado en el registro de transacciones. Validar con departamento comercial.' AS Mensaje,
                @NumeroVoucher AS NumeroVoucher;
            RETURN;
        END

        -- PASO 4: Obtener SubscriptionId desde SubscriptionPaymentLog
        
        DECLARE @SubscriptionIdNuevo INT;

        SELECT TOP 1
            @SubscriptionIdNuevo = SubscriptionId
        FROM dbo.SubscriptionPaymentLog WITH (NOLOCK)
        WHERE [Authorization] = @NumeroVoucher;

        -- Validar si existe el SubscriptionId
        IF @SubscriptionIdNuevo IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No se encontró una suscripción asociada al voucher proporcionado.' AS Mensaje,
                @NumeroVoucher AS NumeroVoucher;
            RETURN;
        END

        -- PASO 5: Actualizar InvoiceDetail con la nueva suscripción
        
        -- Capturar el valor ANTES del update para mostrar comparación
        DECLARE @SubscriptionIdAntes INT;
        
        SELECT TOP 1
            @SubscriptionIdAntes = SubscriptionId
        FROM dbo.InvoiceDetail WITH (NOLOCK)
        WHERE DTI_FK_Header = @InvoiceHeaderId;

        -- Realizar el UPDATE
        UPDATE dbo.InvoiceDetail
        SET 
            SubscriptionId = @SubscriptionIdNuevo,
            TokenUpdated = @TokenUpdate,
            DateUpdated = GETDATE()
        WHERE DTI_FK_Header = @InvoiceHeaderId;

        -- RESULTADO EXITOSO: Mostrar antes y después
        
        SELECT 
            'Éxito' AS Estado,
            'Se ha asociado la suscripción con la factura exitosamente.' AS Mensaje,
            @InvoiceHeaderId AS InvoiceHeaderId,
            @SubscriptionIdAntes AS SubscriptionId_Antes,
            @SubscriptionIdNuevo AS SubscriptionId_Despues,
            @TokenUpdate AS UsuarioModificacion,
            GETDATE() AS FechaModificacion;

    END TRY

    BEGIN CATCH
        
        SELECT 
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;
            
        THROW;

    END CATCH
END
GO

/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================

EXEC dbo.Support_RefacturacionSuscripcion 
    @CodigoCertificacionFEL = 'C8457275-C3B7-4FC6-8DC6-34F806887CC1',
    @NumeroVoucher = '214345',
    @TokenUpdate = 'SYS-IGONZALEZ';
================================================================================
HISTORIAL DE CAMBIOS:
    - 2025-12-19: Versión inicial - Asociación de suscripción a factura
                  Validaciones completas de estado y existencia
                  Output estructurado con antes/después de cambios
================================================================================
*/