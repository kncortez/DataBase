-- Actualiza el Rate por default en la tabla RatebyCustomer para el cliente con RbcIdCustomer = 101534
UPDATE RatebyCustomer SET
	RbcIdRate = 5108
WHERE RbcIdCustomer = 101534;