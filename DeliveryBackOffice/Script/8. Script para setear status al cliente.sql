--select *from CustomerType ctp
SELECT * FROM Customer cst --JOIN CustomerType ctp on cst.IdCustomerType = ctp.IdCustomerType
WHERE IdCustomerType  not in ( 3,1001)
AND IdCustomerType IN (1,2) --todos excepto el portal 3
--AND cst.RowSatus = 'TRUE'


UPDATE Customer
SET RowSatus = 'TRUE',
TokenCreated = 'SYS-ERAMIREZ',
DateCreated = GETDATE()
WHERE IdCustomerType IN (1,2) --todos excepto el portal 3
and IdCustomerType  not in ( 3,1001)
