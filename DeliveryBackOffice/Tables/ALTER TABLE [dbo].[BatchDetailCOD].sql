USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[BatchDetailCOD] ADD [Comments] [nvarchar](2000) NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ADD [BankName] [nvarchar](50) NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ADD [TypeAccountName] [varchar](40) NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ADD [AccountNumber] [nvarchar](50) NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ADD [AccountName] [nvarchar](2000) NULL;

--AGREGAR COMENTARIO A LAS COLUMNAS AGREGADAS
EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Motivo por el que se excluye el registro.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'Comments';

EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Nombre del banco al que pertenece la cuenta.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'BankName';

EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Nombre del tipo de cuenta al que pertenece la misma.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'TypeAccountName';

EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Numero de cuenta.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'AccountNumber';

EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Nombre de la cuenta.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'AccountName';

--MODIFICAR COLUMNAS
ALTER TABLE [dbo].[BatchDetailCOD] ALTER COLUMN [BankId] [int] NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ALTER COLUMN [CreditAccountId] [int] NULL;

ALTER TABLE [dbo].[BatchDetailCOD] ALTER COLUMN [CatAccountTypeCODId] [int] NULL;

--ELIMINAR LLAVE UNICA
ALTER TABLE [dbo].[BatchDetailCOD] DROP CONSTRAINT [UK_BatchDetailCOD_GuideSerie_GuideNumber_CreditAccountId]; 

--ELIMINAR LLAVE FORANEA
ALTER TABLE [dbo].[BatchDetailCOD] DROP CONSTRAINT [FK_BatchDetailCOD_DeliveryCustomerBankAccount]; 

--COMMIT



