/***
-- INSERCION DE VALORES DEL_PARAMETROSFACTURA
-- PARA FACTURACIÓN EN EL SALVADOR
***/

BEGIN TRANSACTION;
BEGIN TRY

    INSERT INTO del_ParametrosFactura (
                dpf_VpCodeOfReference, 
                dpf_FELRequestor,
                dpf_FELTransaction,
                dpf_FELCountry,
                dpf_FELEntity,
                dpf_FELUser,
                dpf_FELUserName,
                dpf_FELData1,
                dpf_FELData3,
                dpf_FELCorreo,
                dpf_FELAsuntoCorreoFactura,
                dpf_FELAsuntoCorreoNotaCredito,
                dpf_FELEstablecimiento,
                dpf_FELCorreoCCO,
                dpf_SAPServidorLicencias,
                dpf_SAPCompania,
                dpf_SAPUsuario,
                dpf_SAPContrasenia,
                dpf_SAPServidor,
                dpf_SAPUsuarioBD,
                dpf_SAPContraseniaBD,
                dpf_SAPserieFactura,
                dpf_SAPserieNC,
                dpf_SAPseriePago,
                dpf_SAPcardCode,
                dpf_SAParticulo,
                dpf_SAPvendor,
                dpf_SAPcreditCard,
                dpf_OcrCode,
                dpf_OcrCode2,
                dpf_StatusFACE,
                dpf_WarehouseCode,
                inv_cmp_name,
                inv_cmp_nameComercial)

    VALUES(1162393,
           'Digifact21*',
           '',
           'SV',
           '800000001111',
           'SV.06142308221025.TESTFORZADELI',
           '',
           '',
           '',
           'juan.ramirez@forzadelivery.com',
           'Forza Delivery Factura',
           'Forza Delivery',
           0,
           'juan.ramirez@forzadelivery.com',
           'WIN-QF1OUTS7TLC',
           'DELIVERY_FORZA',
           '',
           '',
           '192.168.130.107',
           '',
           '',
           477,
           93,
           401,
           'CEC0001',
           '',
           1,
           97,
           10100,
           400000,
           'A',
           10100,
           'DELIVERY EXPRESS EL SALVADOR',
           'DELIVERY EXPRESS SV');

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH