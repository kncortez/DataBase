-- Actualza el nombre de lac compañia que esta configurada en SAP entorno de pruebas
--Se ejecuta sin where en QA debido a que se debe cambiar para todos los registros

UPDATE del_ParametrosFactura SET dpf_SAPCompania = 'zzz_deliverynewproc_test'