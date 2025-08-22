CREATE TABLE [dbo].[EcommerceBySeller] (
    [IdAssigment]      INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCommerce]       INT      NOT NULL,
    [IdSeller]         INT      NOT NULL,
    [StatusAssignment] BIT      NOT NULL,
    [DateCreated]      DATETIME NOT NULL,
    CONSTRAINT [PK_EcommerceBySeller] PRIMARY KEY CLUSTERED ([IdAssigment] ASC),
    CONSTRAINT [FK_EcommerceBySeller] FOREIGN KEY ([IdCommerce]) REFERENCES [dbo].[Ecommerce] ([IdEcommerce]),
    CONSTRAINT [FK_EcommerceBySeller_2] FOREIGN KEY ([IdSeller]) REFERENCES [dbo].[Seller] ([IdSeller])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de asignación de sellers a ecommerce', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EcommerceBySeller', @level2type = N'COLUMN', @level2name = N'IdAssigment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de ecommerce', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EcommerceBySeller', @level2type = N'COLUMN', @level2name = N'IdCommerce';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de seller', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EcommerceBySeller', @level2type = N'COLUMN', @level2name = N'IdSeller';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de asignación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EcommerceBySeller', @level2type = N'COLUMN', @level2name = N'StatusAssignment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EcommerceBySeller', @level2type = N'COLUMN', @level2name = N'DateCreated';

