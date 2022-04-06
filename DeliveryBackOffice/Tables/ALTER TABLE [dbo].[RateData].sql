USE [DeliveryBackOffice]

ALTER TABLE [dbo].[RateData]
ADD WeightFrom DECIMAL(12,2) NULL,
	 WeightTo DECIMAL(12,2) NULL;

EXEC sys.sp_addextendedproperty @name = N'MS_Description'
							   ,@value = N'Peso desde en tarifario por peso.'
							   ,@level0type = N'SCHEMA'
							   ,@level0name = N'dbo'
							   ,@level1type = N'TABLE'
							   ,@level1name = N'RateData'
							   ,@level2type = N'COLUMN'
							   ,@level2name = N'WeightFrom'
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
							   ,@value = N'Peso hasta en tarifario por peso.'
							   ,@level0type = N'SCHEMA'
							   ,@level0name = N'dbo'
							   ,@level1type = N'TABLE'
							   ,@level1name = N'RateData'
							   ,@level2type = N'COLUMN'
							   ,@level2name = N'WeightTo'
GO