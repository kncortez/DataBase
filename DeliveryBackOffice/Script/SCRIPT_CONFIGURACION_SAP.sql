--=== SE REALIZA UN BACKUP DE LA TABLA DE CONFIGURACÓN DE FACTURACIÓN A SAP
SELECT * 
INTO del_ParametrosFactura_BK_05052021
FROM del_ParametrosFactura

--==== SE ACTUALIZAN LOS PARÁMETROS PARA LAS PRUEBAS

UPDATE del_ParametrosFactura SET dpf_SAPCompania = 'ZZZ_TEST_DELIVERY',
dpf_SAPUsuario = 'prdun05',
dpf_SAPContrasenia = '12345',
dpf_SAPUsuarioBD = 'hermes_sap_qa',
dpf_SAPContraseniaBD = 'wA4sa+Ye6dSLk)4'