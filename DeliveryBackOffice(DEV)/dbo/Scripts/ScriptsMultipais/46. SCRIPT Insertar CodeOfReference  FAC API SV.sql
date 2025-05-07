/***
INSERTAR CODEOFREFERENCE PARA FACTURAR A TRAVES DE API 
***/

BEGIN TRANSACTION;
BEGIN TRY
    -- Inserciones de datos
insert into del_ParametrosFactura( dpf_VpCodeOfReference, dpf_FELRequestor, dpf_FELTransaction, dpf_FELCountry, dpf_FELEntity, dpf_FELUser, dpf_FELUserName, dpf_FELData1, dpf_FELData3, dpf_FELCorreo,dpf_FELAsuntoCorreoFActura,dpf_FELAsuntoCorreoNotaCredito,dpf_FELEstablecimiento,dpf_FELCorreoCCO,dpf_SAPServidorLicencias,dpf_SAPCompania,dpf_SAPUsuario,dpf_SAPContrasenia,dpf_SAPServidor,dpf_SAPUsuarioBD, dpf_SAPContraseniaBD, dpf_SAPserieFactura, dpf_SAPserieNC, dpf_SAPSeriePago, dpf_SAPcardCode, dpf_SAParticulo, dpf_SAPvendor, dpf_SAPCreditCard, dpf_OcrCode, dpf_OcrCode2, dpf_StatusFACE, dpf_WarehouseCode, inv_cmp_name, inv_cmp_nameComercial, KioskCode, dpf_SAPSerieAsiento)
VALUES('1162415','8A454E3F-CEA1-41D8-A13A-A748A4891BBF','','SV','800000001026','0D9502F3-144F-4B41-AF42-D6118F3B49FE','TEST','','','bidcar.herrera@forzalatam.com','','',0,'miguel.aleman@forzadelivery.com','WIN-QF1OUTS7TLC','ZZZ_DELIVERYHONDURAS','RPA_AGENT','12345','172.19.2.30','delivery','R;XF%269z]$VG!HM=w<}PC',73,74,75,'CXPC20103','',1,1,511,400000,'A',511,'Delivery Express El Salvador S.A. De C.V.','DELIVERY EXPRESS EL SALVADOR, S.A. DE C.V.',4635,77)
    
    -- Si llegamos aquí sin errores, confirmamos la transacción
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    -- Si hay cualquier error, revertimos todo
    ROLLBACK TRANSACTION;
    
    -- Capturamos y mostramos el error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH