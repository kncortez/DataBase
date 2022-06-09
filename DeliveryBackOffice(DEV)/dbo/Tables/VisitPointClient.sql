CREATE TABLE [dbo].[VisitPointClient] (
    [IdVisitPointClient]        INT            IDENTITY (1, 1) NOT NULL,
    [CodeOfReference]           INT            NOT NULL,
    [DescriptionOfClient]       NVARCHAR (100) NULL,
    [StatusClient]              BIT            NOT NULL,
    [CountryId]                 NVARCHAR (2)   NOT NULL,
    [VisitPointId]              BIGINT         NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    [CustomerID]                INT            NULL,
    [Address]                   NVARCHAR (600) NULL,
    [Zone]                      NVARCHAR (100) NULL,
    [Town]                      NVARCHAR (100) NULL,
    [Department]                NVARCHAR (100) NULL,
    [Phone]                     NVARCHAR (50)  NULL,
    [ContactName]               NVARCHAR (200) NULL,
    [IdKindOfVPClient]          INT            NULL,
    [IdKindOfVPBusiness]        INT            NULL,
    [IdSettlement]              BIGINT         NULL,
    [Email]                     NVARCHAR (200) NULL,
    [IdTownship]                INT            NULL,
    [Latitude]                  VARCHAR (50)   NULL,
    [Longitude]                 VARCHAR (50)   NULL,
    [Accuracy]                  VARCHAR (50)   NULL,
    [BranchCode]                NVARCHAR (50)  NULL,
    [SaleChannelId]             INT            NULL,
    [ExcludePriceShippingCOD]   BIT            CONSTRAINT [DF_VisitPointClient_ExcludePriceShippingCOD] DEFAULT ('FALSE') NULL,
    [ExcludeCommissionCOD]      BIT            CONSTRAINT [DF_VisitPointClient_ExcludeCommissionCOD] DEFAULT ('FALSE') NULL,
    [VisitPointToken]           NVARCHAR (50)  NULL,
    [VisitPointTokenExpiration] DATETIME       NULL,
    [DCBAID]                    INT            NULL,
    PRIMARY KEY CLUSTERED ([CodeOfReference] ASC),
    CONSTRAINT [FK_VisitPointClient_Customer2] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_VisitPointClient_KindOfVPBusiness2] FOREIGN KEY ([IdKindOfVPBusiness]) REFERENCES [dbo].[KindOfVPBusiness] ([IdKindOfVPBusiness]),
    CONSTRAINT [FK_VisitPointClient_KindOfVPClient2] FOREIGN KEY ([IdKindOfVPClient]) REFERENCES [dbo].[KindOfVPClient] ([IdKindOfVPClient]),
    CONSTRAINT [FK_VisitPointClient_Settlement2] FOREIGN KEY ([IdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [fk_VisitTownship2] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [UQ_CodeOfReferenceporVisitPointId2] UNIQUE NONCLUSTERED ([CodeOfReference] ASC, [VisitPointId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_customerid]
    ON [dbo].[VisitPointClient]([CustomerID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para indicar si se excluye el precio de envio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'ExcludePriceShippingCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para indicar si se excluye la comision.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'ExcludeCommissionCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de acceso para landing page de captura de datos de punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'VisitPointToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la cual el token vence y ya no puede ser utilizado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'VisitPointTokenExpiration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referencia al identificador de la tabla DeliveryCustomerBankAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient', @level2type = N'COLUMN', @level2name = N'DCBAID';

