CREATE TYPE [dbo].[TblBuyerInfo] AS TABLE
(
	DistrictCode		varchar (100) NULL,
	StateCode			varchar (100) NULL,
	ActivityCode		varchar (100) NULL,
	ActivityDescription	varchar (500) NULL,
	NRC					varchar (20) NULL,
	TypeDocument		varchar (100) NULL,
	IdDocument			varchar (100) NULL,
	Phone				varchar (100) NULL
)
