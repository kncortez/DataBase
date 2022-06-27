CREATE TABLE [dbo].[SellerDepot] (
    [IdSellerDepot]       INT            IDENTITY (1, 1) NOT NULL,
    [IdSeller]            INT            NOT NULL,
    [IdSettlement]        BIGINT         NOT NULL,
    [CodeOfReference]     NVARCHAR (100) NOT NULL,
    [DescriptionOfClient] NVARCHAR (100) NOT NULL,
    [Address]             NVARCHAR (200) NOT NULL,
    [Phone]               NVARCHAR (50)  NULL,
    [ContactName]         NVARCHAR (200) NULL,
    [Status]              BIT            NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [DateUpdated]         DATETIME       NULL,
    [IdVisitPointClient]  INT            NULL,
    CONSTRAINT [PK_SellerDepot] PRIMARY KEY CLUSTERED ([IdSellerDepot] ASC),
    CONSTRAINT [FK_SellerDepot_Seller] FOREIGN KEY ([IdSeller]) REFERENCES [dbo].[Seller] ([IdSeller]),
    CONSTRAINT [FK_SellerDepot_Settlement] FOREIGN KEY ([IdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [FK_SellerDepot_VisitPointClient] FOREIGN KEY ([IdVisitPointClient]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [SellerDepot_UK] UNIQUE NONCLUSTERED ([IdSeller] ASC, [CodeOfReference] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'IdSellerDepot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del seller', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'IdSeller';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ubicación del depósito para cálculo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'IdSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'DescriptionOfClient';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección de bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono de bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del contacto de bodega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'ContactName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El punto de visita asociado a la bodega que será el origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SellerDepot', @level2type = N'COLUMN', @level2name = N'IdVisitPointClient';

