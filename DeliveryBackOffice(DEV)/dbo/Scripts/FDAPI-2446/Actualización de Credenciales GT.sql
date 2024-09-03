SELECT
		dpf_VpCodeOfReference
	   ,dpf_FELCountry
	   ,dpf_FELAsuntoCorreoFactura
	   ,dpf_FELAsuntoCorreoNotaCredito
	   ,dpf_SAPServidorLicencias
	   ,dpf_SAPCompania
	   ,dpf_SAPUsuario
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuario
	   ,dpf_SAPContrasenia
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContraseniaBD
	   ,dpf_SAParticulo
	   ,dpf_OcrCode
	   ,dpf_OcrCode2
FROM del_ParametrosFactura
WHERE ISNULL(dpf_FELCountry,'GT') = 'GT'

update del_ParametrosFactura 
set 
	 dpf_SAPServidorLicencias = 'WIN-QF1OUTS7TLC'
	,dpf_SAPCompania = 'VVV_DELVERYGUATEMALATEST'
	,dpf_SAPUsuario = 'RPA_AGENT'
	,dpf_SAPContrasenia = 'Del$2025'
	,dpf_SAPServidor = '172.19.2.30'	
	,dpf_SAPUsuarioBD = 'delivery'
	,dpf_SAPContraseniaBD = 'R;XF%269z]$VG!HM=w<}PC' 
where ISNULL(dpf_FELCountry,'GT') = 'GT'

SELECT
		dpf_VpCodeOfReference
	   ,dpf_FELCountry
	   ,dpf_FELAsuntoCorreoFactura
	   ,dpf_FELAsuntoCorreoNotaCredito
	   ,dpf_SAPServidorLicencias
	   ,dpf_SAPCompania
	   ,dpf_SAPUsuario
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuario
	   ,dpf_SAPContrasenia
	   ,dpf_SAPServidor
	   ,dpf_SAPUsuarioBD
	   ,dpf_SAPContraseniaBD
	   ,dpf_SAParticulo
	   ,dpf_OcrCode
	   ,dpf_OcrCode2
FROM del_ParametrosFactura
WHERE ISNULL(dpf_FELCountry,'GT') = 'GT'