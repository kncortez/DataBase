CREATE TABLE [dbo].[VisitPointClient] (
    [IdVisitPointClient]      INT            IDENTITY (1, 1) NOT NULL,
    [CodeOfReference]         INT            NOT NULL,
    [DescriptionOfClient]     NVARCHAR (100) NULL,
    [StatusClient]            BIT            NOT NULL,
    [CountryId]               NVARCHAR (2)   NOT NULL,
    [VisitPointId]            BIGINT         NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    [CustomerID]              INT            NULL,
    [Address]                 NVARCHAR (600) NULL,
    [Zone]                    NVARCHAR (100) NULL,
    [Town]                    NVARCHAR (100) NULL,
    [Department]              NVARCHAR (100) NULL,
    [Phone]                   NVARCHAR (50)  NULL,
    [ContactName]             NVARCHAR (200) NULL,
    [IdKindOfVPClient]        INT            NULL,
    [IdKindOfVPBusiness]      INT            NULL,
    [IdSettlement]            BIGINT         NULL,
    [Email]                   NVARCHAR (200) NULL,
    [IdTownship]              INT            NULL,
    [Latitude]                VARCHAR (50)   NULL,
    [Longitude]               VARCHAR (50)   NULL,
    [Accuracy]                VARCHAR (50)   NULL,
    [BranchCode]              NVARCHAR (50)  NULL,
    [SaleChannelId]           INT            NULL,
    [ExcludePriceShippingCOD] BIT            NULL,
    [ExcludeCommissionCOD]    BIT            NULL,
    [IsOriginVisitPoint]      BIT            CONSTRAINT [DF_VisitPointClient_IsOriginVisitPoint] DEFAULT ((1)) NOT NULL,
    [LogLatitude]             NVARCHAR (20)  NULL,
    [LogLongitude]            NVARCHAR (20)  NULL,
    [DescriptionCC]           NVARCHAR (100) NULL,
    [CatBusinessSegmentId]    INT            NULL,
    [AllowScheduledPickups]   BIT            DEFAULT ((1)) NULL,
    CONSTRAINT [PK_VisitPointClient_1] PRIMARY KEY CLUSTERED ([CodeOfReference] ASC),
    CONSTRAINT [FK_VisitPointClient_CatBusinessSegment] FOREIGN KEY ([CatBusinessSegmentId]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_VisitPointClient_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_VisitPointClient_KindOfVPBusiness] FOREIGN KEY ([IdKindOfVPBusiness]) REFERENCES [dbo].[KindOfVPBusiness] ([IdKindOfVPBusiness]),
    CONSTRAINT [FK_VisitPointClient_KindOfVPClient] FOREIGN KEY ([IdKindOfVPClient]) REFERENCES [dbo].[KindOfVPClient] ([IdKindOfVPClient]),
    CONSTRAINT [FK_VisitPointClient_Settlement] FOREIGN KEY ([IdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [fk_VisitTownship] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [UQ_CodeOfReferenceporVisitPointId] UNIQUE NONCLUSTERED ([CodeOfReference] ASC, [VisitPointId] ASC)
);












GO
CREATE NONCLUSTERED INDEX [idx_customerid]
    ON [dbo].[VisitPointClient]([CustomerID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para indicar si se excluye el precio de envio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'ExcludePriceShippingCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para indicar si se excluye la comision.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'ExcludeCommissionCOD';


GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Desktop Visitpoint', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'VisitPointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Se refiere al número de sucursal de la agencia, tienda u oficina identificada por cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'BranchCode';


GO
CREATE NONCLUSTERED INDEX [IDX_IdVisitPointClient]
    ON [dbo].[VisitPointClient]([IdVisitPointClient] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicativo si punto de visita permite registrar horarios de recolección programada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'AllowScheduledPickups';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ubicación (longitud) anterior o para revisión del punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'LogLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ubicación (latitud) anterior o para revisión del punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'LogLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción para Contact Center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'DescriptionCC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento de negocio al que pertenece.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'CatBusinessSegmentId';

