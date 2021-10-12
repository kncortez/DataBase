USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA CONFIGURACION DE LOS PARAMETROS PARA LA FACTURA EN SAP
--PARA LA COURIERAPP COMO NUEVO VISITPOINT
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
     VALUES (222825,
			 '0D9502F3-144F-4B41-AF42-D6118F3B49FE',
			 'SYSTEM_REQUEST',
			 'GT',
			 '86534599',
			 '0D9502F3-144F-4B41-AF42-D6118F3B49FE',
			 'ADMINISTRADOR',
			 'POST_DOCUMENTGT',
			 'XML',
			 'envios.parser@gmail.com',
			 'Forza Delivery - Factura Electrónica',
			 'Forza Delivery - Nota de Crédito',
			 '1',
			 'develop@forzalatam.com',
			 '192.168.130.106',
			 'zzz_deliverynewproc_test',
			 'prdun05',
			 '12345',
			 '192.168.130.107',
			 'hermes_sap_qa',
			 'wA4sa+Ye6dSLk)4',
			 '262',
			 '264',
			 '266',
			 'CEC0056',
			 '409010101',
			 '1',
			 '56',
			 '10100',
			 '400000',
			 'A')

--COMMIT


SELECT *
FROM [dbo].[del_ParametrosFactura]