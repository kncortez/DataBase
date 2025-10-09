/*********************************************

NOTA:
	ESTE SCRIPT NO DEBE EJECUTARSE, PUES YA HA SIDO 
	EJECUTADO EN AMBIENTE PRODUCTIVO. ESTA UNICAMENTE 
	COMO HISTORICO DE LOS CAMBIOS QUE SE HAN EJECUTADO
	EN PRODUCCION.

**********************************************/


--Scripts que se actualizaron en produccion para corregir el modulo de facturacion
UPDATE CatEconomicActivityBySV 
   SET RowStatus = 0,
       TokenUpdated = 'SYS-JRAMIREZ',
       DateUpdated = GETDATE()

UPDATE BillingCustomerBySV
   SET ActivityId = NULL
 WHERE IdCustomer = 98051