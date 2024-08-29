SELECT
		dpf_VpCodeOfReference
	   ,dpf_FELCountry
	   ,dpf_FELAsuntoCorreoFactura
	   ,dpf_FELAsuntoCorreoNotaCredito
	   ,dpf_SAPServidorLicencias
	   ,dpf_SAPCompania
	   ,dpf_SAPUsuario
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContrasenia
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContraseniaBD
	   ,dpf_SAParticulo
	   ,dpf_OcrCode
	   ,dpf_OcrCode2
FROM del_ParametrosFactura
WHERE dpf_FELCountry = 'HN'

update del_ParametrosFactura 
set 
	 dpf_SAPServidorLicencias = 'WIN-QF1OUTS7TLC'
	,dpf_SAPCompania = 'DELIVERY_FORZA'
	,dpf_SAPUsuario = 'RPA_AGENT'
	,dpf_SAPContrasenia = 'Del$2025'
	,dpf_SAPServidor = '192.168.130.107'
	,dpf_SAPUsuarioBD = 'delivery'
	,dpf_SAPContraseniaBD = 'Del$2024' 
where dpf_FELCountry= 'HN'

SELECT
		dpf_VpCodeOfReference
	   ,dpf_FELCountry
	   ,dpf_FELAsuntoCorreoFactura
	   ,dpf_FELAsuntoCorreoNotaCredito
	   ,dpf_SAPServidorLicencias
	   ,dpf_SAPCompania
	   ,dpf_SAPUsuario
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContrasenia
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContraseniaBD
	   ,dpf_SAParticulo
	   ,dpf_OcrCode
	   ,dpf_OcrCode2
FROM del_ParametrosFactura
WHERE dpf_FELCountry = 'HN'