USE [DeliveryBackOffice];
GO

IF ( EXISTS ( SELECT TOP 1 1 FROM [dbo].CatContainerSubtype  WITH(NOLOCK)) )
BEGIN
    
	ALTER TABLE [dbo].[CatTypeContainer]
	ADD SubtypeContainerId BIGINT NOT NULL DEFAULT 1
	
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del subtipo de contenedor de la tabla CatContainerSubtype.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeContainer', @level2type=N'COLUMN',@level2name=N'SubtypeContainerId'

END