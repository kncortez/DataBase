-- ================================
-- Create User-defined Table Type
-- ================================
USE DeliveryBackOffice
GO

-- Create the data type
CREATE TYPE dbo.TblInOutOfMoneyDetail AS TABLE
(
	 type varchar(200),
	 vpCodeOfReferences int,
	 ticket varchar(100),
     amount money,
     status int,-- = -1
     invoice bigint
)
GO
