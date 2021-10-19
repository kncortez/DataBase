USE [DeliveryBackOffice]

--INSERTAR LA CONFIGURACION DE LOS PARAMETROS PARA LA FACTURA EN SAP
--PARA LA COURIERAPP COMO NUEVO VISITPOINT
DECLARE @dpf_VpCodeOfReference INT = 3000;
DECLARE @dpf_FELRequestor VARCHAR(200) = '0D9502F3-144F-4B41-AF42-D6118F3B49FE';
DECLARE @dpf_FELTransaction VARCHAR(200) = 'SYSTEM_REQUEST';
DECLARE @dpf_FELCountry VARCHAR(10) = 'GT';
DECLARE @dpf_FELEntity VARCHAR(20) = '86534599';
DECLARE @dpf_FELUser VARCHAR(200) = '0D9502F3-144F-4B41-AF42-D6118F3B49FE';
DECLARE @dpf_FELUserName VARCHAR(50) = 'ADMINISTRADOR';
DECLARE @dpf_FELData1 VARCHAR(50) = 'POST_DOCUMENTGT';
DECLARE @dpf_FELData3 VARCHAR(10) = 'XML';
DECLARE @dpf_FELCorreo VARCHAR(50) = 'envios.parser@gmail.com';
DECLARE @dpf_FELAsuntoCorreoFactura VARCHAR(200) = 'Forza Delivery - Factura Electrónica';
DECLARE @dpf_FELAsuntoCorreoNotaCredito VARCHAR(200) = 'Forza Delivery - Nota de Crédito';
DECLARE @dpf_FELEstablecimiento VARCHAR(15) = '1';
DECLARE @dpf_FELCorreoCCO VARCHAR(50) = 'develop@forzalatam.com';
DECLARE @dpf_SAPServidorLicencias VARCHAR(50) = '192.168.130.106';
DECLARE @dpf_SAPCompania VARCHAR(50) = 'zzz_deliverynewproc_test';
DECLARE @dpf_SAPUsuario VARCHAR(50) = 'prdun05';
DECLARE @dpf_SAPContrasenia NVARCHAR(100) = '12345';
DECLARE @dpf_SAPServidor VARCHAR(50) = '192.168.130.107';
DECLARE @dpf_SAPUsuarioBD VARCHAR(50) = 'hermes_sap_qa';
DECLARE @dpf_SAPContraseniaBD NVARCHAR(100) = 'wA4sa+Ye6dSLk)4';
DECLARE @dpf_SAPserieFactura VARCHAR(50) = '262';
DECLARE @dpf_SAPserieNC VARCHAR(50) = '264';
DECLARE @dpf_SAPseriePago VARCHAR(50) = '266';
DECLARE @dpf_SAPcardCode VARCHAR(50) = 'CEC0056';
DECLARE @dpf_SAParticulo VARCHAR(50) = '409010101';
DECLARE @dpf_SAPvendor VARCHAR(50) = '1';
DECLARE @dpf_SAPcreditCard VARCHAR(50) = '56';
DECLARE @dpf_OcrCode NVARCHAR(50) = '10100';
DECLARE @dpf_OcrCode2 NVARCHAR(50) = '400000';
DECLARE @dpf_StatusFACE NVARCHAR(1) = 'A';

INSERT INTO [dbo].[del_ParametrosFactura]
            ([dpf_VpCodeOfReference],
			 [dpf_FELRequestor],
			 [dpf_FELTransaction],
			 [dpf_FELCountry],
			 [dpf_FELEntity],
			 [dpf_FELUser],
			 [dpf_FELUserName],
			 [dpf_FELData1],
			 [dpf_FELData3],
			 [dpf_FELCorreo],
			 [dpf_FELAsuntoCorreoFactura],
			 [dpf_FELAsuntoCorreoNotaCredito],
			 [dpf_FELEstablecimiento],
			 [dpf_FELCorreoCCO],
			 [dpf_SAPServidorLicencias],
			 [dpf_SAPCompania],
			 [dpf_SAPUsuario],
			 [dpf_SAPContrasenia],
			 [dpf_SAPServidor],
			 [dpf_SAPUsuarioBD],
			 [dpf_SAPContraseniaBD],
			 [dpf_SAPserieFactura],
			 [dpf_SAPserieNC],
			 [dpf_SAPseriePago],
			 [dpf_SAPcardCode],
			 [dpf_SAParticulo],
			 [dpf_SAPvendor],
			 [dpf_SAPcreditCard],
			 [dpf_OcrCode],
			 [dpf_OcrCode2],
			 [dpf_StatusFACE])
     VALUES (@dpf_VpCodeOfReference,
			 @dpf_FELRequestor,
			 @dpf_FELTransaction,
			 @dpf_FELCountry,
			 @dpf_FELEntity,
			 @dpf_FELUser,
			 @dpf_FELUserName,
			 @dpf_FELData1,
			 @dpf_FELData3,
			 @dpf_FELCorreo,
			 @dpf_FELAsuntoCorreoFactura,
			 @dpf_FELAsuntoCorreoNotaCredito,
			 @dpf_FELEstablecimiento,
			 @dpf_FELCorreoCCO,
			 @dpf_SAPServidorLicencias,
			 @dpf_SAPCompania,
			 @dpf_SAPUsuario,
			 @dpf_SAPContrasenia,
			 @dpf_SAPServidor,
			 @dpf_SAPUsuarioBD,
			 @dpf_SAPContraseniaBD,
			 @dpf_SAPserieFactura,
			 @dpf_SAPserieNC,
			 @dpf_SAPseriePago,
			 @dpf_SAPcardCode,
			 @dpf_SAParticulo,
			 @dpf_SAPvendor,
			 @dpf_SAPcreditCard,
			 @dpf_OcrCode,
			 @dpf_OcrCode2,
			 @dpf_StatusFACE)
