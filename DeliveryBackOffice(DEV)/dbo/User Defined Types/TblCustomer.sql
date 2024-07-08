CREATE TYPE [dbo].[TblCustomer] AS TABLE(
	[IdCustomer] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[IdCustomer] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)