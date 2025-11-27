
BEGIN TRY

UPDATE Customer set IsVoucherRequired = 0 where IsVoucherRequired is null 

END TRY
BEGIN CATCH
	PRINT 'ERROR EN ACTUALIZACION DE CLIENTES SIN COMPROBANTE REQUERIDO'
END CATCH

BEGIN TRY

ALTER TABLE Customer
ADD CONSTRAINT DF_Customer_IsvoucherRequired DEFAULT 0 FOR IsVoucherRequired;

END TRY
BEGIN CATCH
	PRINT 'ERROR VALOR POR DEFECTO EN CLIENTES QUE NO REQUIEREN VOUCHER '
END CATCH

BEGIN TRY

UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 1;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 19646;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 21641;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 36166;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 44538;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 60796;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 47422;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 65761;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 54600;
UPDATE Customer set IsVoucherRequired = 1 Where IdCustomer = 55324;

END TRY
BEGIN CATCH
	PRINT 'ERROR EN ACTUALIZACION DE CLIENTES CON COMPROBANTE REQUERIDO'
END CATCH