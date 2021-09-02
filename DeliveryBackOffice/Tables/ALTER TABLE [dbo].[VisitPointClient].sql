USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[VisitPointClient] ADD [ExcludePriceShippingCOD] [bit] NULL;

ALTER TABLE [dbo].[VisitPointClient] ADD [ExcludeCommissionCOD] [bit] NULL;

--AGREGAR COMENTARIO A LAS COLUMNAS AGREGADAS
EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Bandera para indicar si se excluye el precio de envio.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'VisitPointClient', 
								@level2type=N'COLUMN',
								@level2name=N'ExcludePriceShippingCOD';

EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Bandera para indicar si se excluye la comision.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'VisitPointClient', 
								@level2type=N'COLUMN',
								@level2name=N'ExcludeCommissionCOD';

--AGREGAR VALOR POR DEFECTO A LAS COLUMNAS
ALTER TABLE [dbo].[VisitPointClient] ADD  CONSTRAINT [DF_VisitPointClient_ExcludePriceShippingCOD]  DEFAULT ('FALSE') FOR [ExcludePriceShippingCOD]

ALTER TABLE [dbo].[VisitPointClient] ADD  CONSTRAINT [DF_VisitPointClient_ExcludeCommissionCOD]  DEFAULT ('FALSE') FOR [ExcludeCommissionCOD]


--COMMIT

