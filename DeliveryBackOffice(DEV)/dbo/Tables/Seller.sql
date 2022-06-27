CREATE TABLE [dbo].[Seller] (
    [IdSeller]        INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]      INT            NOT NULL,
    [Name]            NVARCHAR (100) NOT NULL,
    [CodeOfReference] NVARCHAR (100) NOT NULL,
    [IsPrincipal]     BIT            NOT NULL,
    [Status]          BIT            NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    CONSTRAINT [PK_Seller] PRIMARY KEY CLUSTERED ([IdSeller] ASC),
    CONSTRAINT [FK_Seller_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [Seller_UK] UNIQUE NONCLUSTERED ([CodeOfReference] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'IdSeller';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A quien pertenece el seller', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del seller', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código que identifica al seller', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el seller es principal o no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'IsPrincipal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Seller', @level2type = N'COLUMN', @level2name = N'DateCreated';

