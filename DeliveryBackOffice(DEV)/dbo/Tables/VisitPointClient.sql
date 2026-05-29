CREATE TABLE [dbo].[VisitPointClient] (
    [IdVisitPointClient]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
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
    [RestrictionByArticle]    BIT            NULL,
    [ParserGuideTypes]        NVARCHAR (100) DEFAULT ('Crédito') NULL,
    [isReturnWarehouse]       INT            NOT NULL CONSTRAINT DF_VisitPointClient_isReturnWarehouse DEFAULT 0,   
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
CREATE NONCLUSTERED INDEX [IDX_IdVisitPointClient]
    ON [dbo].[VisitPointClient]([IdVisitPointClient] ASC);

GO



GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Id unico de punto de visita de clientes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IdVisitPointClient'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de referencia de punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'CodeOfReference'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del cliente respecto al punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'DescriptionOfClient'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del cliente activo o desactivado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'StatusClient'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la ciudad a la que pertenece el punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'CountryId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Desktop Visitpoint' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'VisitPointId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'CustomerID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Address'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Zona a la que pertenece el punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Zone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Ciudad a la que pertenece el punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Town'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Departamento al que pertenece el punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Department'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Phone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto que se tiene del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'ContactName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de punto de visita del cliente como EXC, HUB, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IdKindOfVPClient'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de punto de visita de negocio de cliente como casa, oficina, EXC, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IdKindOfVPBusiness'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Asentamiento en donde se encuentra ubicado el punto de visita del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IdSettlement'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Email'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del lugar donde se encuentra el punto de visita, ubicacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IdTownship'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Latitud de la ubicacion del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Latitude'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Longitud de la ubicacion del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Longitude'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Exactitud de la ubicacion del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'Accuracy'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Se refiere al número de sucursal de la agencia, tienda u oficina identificada por cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'BranchCode'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Id del canal de ventas del punto de visita relacion con tabla CatSalesChannel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'SaleChannelId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye el precio de envio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'ExcludePriceShippingCOD'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye la comision.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'ExcludeCommissionCOD'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Es punto de visita origen del cliente si o no' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'IsOriginVisitPoint'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Ubicación (latitud) anterior o para revisión del punto de visita.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'LogLatitude'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Ubicación (longitud) anterior o para revisión del punto de visita.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'LogLongitude'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción para Contact Center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'DescriptionCC'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento de negocio al que pertenece.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'CatBusinessSegmentId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Indicativo si punto de visita permite registrar horarios de recolección programada.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'AllowScheduledPickups'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si el punto de visita esta asignado como punto de devolución' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'isReturnWarehouse'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que obtiene los valores de puntos de visita de un cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient'
GO
CREATE NONCLUSTERED INDEX [idx_VisitPointId_include]
    ON [dbo].[VisitPointClient]([VisitPointId] ASC)
    INCLUDE([CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusClient_IdSettlement_Included]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [IdSettlement] ASC)
    INCLUDE([DescriptionOfClient], [CustomerID], [Address]);


GO



GO
CREATE NONCLUSTERED INDEX [idx_IdKindOfVPClient]
    ON [dbo].[VisitPointClient]([IdKindOfVPClient] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [IDX_StatusClient]
    ON [dbo].[VisitPointClient]([StatusClient] ASC)
    INCLUDE([IdVisitPointClient], [DescriptionOfClient], [CountryId], [CustomerID], [Phone]);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusClient_IdKindOfVPBusiness_INCLUDE]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [IdKindOfVPBusiness] ASC)
    INCLUDE([DescriptionOfClient], [CountryId]);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusClient_CountryId_INCLUDE]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [CountryId] ASC)
    INCLUDE([DescriptionOfClient], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IDX_DescriptionOfClient_StatusClient_CountryId]
    ON [dbo].[VisitPointClient]([DescriptionOfClient] ASC, [StatusClient] ASC, [CountryId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera que indica si se utilizará tarifario por artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'RestrictionByArticle';


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointClient_Status_Country_Filter]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [CountryId] ASC, [CustomerID] ASC)
    INCLUDE([IdVisitPointClient], [DescriptionOfClient], [Phone]) WHERE ([StatusClient]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointClient_Status_Country_Customer]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [CountryId] ASC, [CustomerID] ASC)
    INCLUDE([IdVisitPointClient], [DescriptionOfClient], [Phone]) WHERE ([StatusClient]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointClient_Description]
    ON [dbo].[VisitPointClient]([DescriptionOfClient] ASC)
    INCLUDE([CustomerID], [IdVisitPointClient], [Phone], [CountryId]) WHERE ([StatusClient]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_CountryId_IdKindOfVPClient_DescriptionOfClient_INCLUDE]
    ON [dbo].[VisitPointClient]([CountryId] ASC, [IdKindOfVPClient] ASC, [DescriptionOfClient] ASC)
    INCLUDE([StatusClient], [IdSettlement], [CodeOfReference], [Address], [ContactName], [Phone], [Email]);


GO
CREATE NONCLUSTERED INDEX [IDX_VisitPointClient_CodeOfReference]
    ON [dbo].[VisitPointClient]([CodeOfReference] ASC, [StatusClient] ASC)
    INCLUDE([IdTownship], [Address], [Phone], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusClient_CountryId_IdKindOfVPClient_Consolidate]
    ON [dbo].[VisitPointClient]([StatusClient] ASC, [CountryId] ASC, [IdKindOfVPClient] ASC)
    INCLUDE([DescriptionOfClient], [Address], [Phone], [ContactName], [IdSettlement], [Email]);


GO
CREATE NONCLUSTERED INDEX [IDX_CustomerID_Include]
    ON [dbo].[VisitPointClient]([SaleChannelId] ASC)
    INCLUDE([CustomerID]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipos de guías permitidos que se puden crear desde Parsers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'ParserGuideTypes';

