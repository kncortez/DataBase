USE [DeliveryBackOffice];

BEGIN TRAN;

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[ArticleByCustomer] ADD [Height] [decimal](18, 2) NULL, 
										  [Width] [decimal](18, 2) NULL, 
										  [Length] [decimal](18, 2) NULL,
										  [MassWeight] [decimal](18, 2) NULL,
										  [VolumetricWeight] [decimal](18, 2) NULL,
										  [ShowDefault] [bit] NULL;

--CAMBIAR LA COLUMNA ABCIDCUSTOMER A NULL
ALTER TABLE [dbo].[ArticleByCustomer] ALTER COLUMN [AbcIdCustomer] [int] NULL;

--COMMIT;
