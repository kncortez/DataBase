CREATE TYPE [dbo].[TblCustomerType] AS TABLE(
	[IdCustomerType] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[IdCustomerType] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
