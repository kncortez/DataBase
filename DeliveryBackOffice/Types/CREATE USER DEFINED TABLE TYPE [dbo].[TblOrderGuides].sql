-- ================================
-- Create User-defined Table Type
-- ================================
USE [DeliveryBackOffice]
GO

-- Create the data type
CREATE TYPE [dbo].[TblOrderGuides] AS TABLE
(
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL
)
GO
