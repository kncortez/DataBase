-- ================================
-- Create User-defined Table Type
-- ================================
USE DeliveryBackOffice
GO

-- Create the data type
--drop type DBO.TblLstDetail 
CREATE TYPE DBO.TblLstDetail AS TABLE 
(
	 --header bigint
	orderSerie nvarchar(2)
	,orderNumber int
	,identification varchar(200)
	,category varchar(50)
	,quantity decimal(10,5)
	,measurement varchar(20)
	,priceUnit money
	,description varchar(max)
	,IVA money
	,amount money
	,SAPCode varchar(50) NULL
	,SendToInvoice BIT NULL
)
GO
