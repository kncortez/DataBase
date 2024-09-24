CREATE TABLE [dbo].[ProductImages]
(
	[IdProductImages] INT IDENTITY (1, 1) NOT NULL, 
    [ProductId] INT NOT NULL, 
    [Url] NVARCHAR(200) NOT NULL, 
    [Position] TINYINT NOT NULL, 
    [RowStatus] BIT NOT NULL, 
    [UserCreated] NVARCHAR(50) NOT NULL, 
    [DateCreated] DATETIME NOT NULL, 
    [UserUpdated] NVARCHAR(50) NULL, 
    [DateUpdated] DATETIME NULL,
	PRIMARY KEY CLUSTERED ([IdProductImages] ASC),
    CONSTRAINT FK_ProductImages_ProductId FOREIGN KEY (ProductId) REFERENCES Product(IdProduct)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la imagen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'IdProductImages'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del producto (FK a Product)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'ProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ubicación de la imagen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'Url'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posición de aparición de la imagen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'Position'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ProductImages',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'