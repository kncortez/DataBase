CREATE TABLE [dbo].[ServiceRequest] (
    [Messageid]        NVARCHAR (MAX) NULL,
    [Receiver_Name]    NVARCHAR (100) NOT NULL,
    [Receiver_Email]   NVARCHAR (200) NOT NULL,
    [PathReceivedFile] NVARCHAR (200) NULL,
    [PathSticker]      NVARCHAR (100) NULL,
    [Status]           NVARCHAR (50)  NOT NULL,
    [Receiver_Date]    DATETIME       NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [Manifest_Serie]   NVARCHAR (2)   NOT NULL,
    [Manifest_Number]  INT            NOT NULL,
    [CustomerID]       INT            NULL,
    CONSTRAINT [pk_manifest] PRIMARY KEY CLUSTERED ([Manifest_Serie] ASC, [Manifest_Number] ASC),
    CONSTRAINT [FK_ServiceRequest_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([IdCustomer])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serie de manifiesto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Manifest_Serie'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Numero de manifiesto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Manifest_Number'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id cliente(Referencia a CustomerID de la tabla Customer)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'CustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien genera el servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Messageid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de receptor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Receiver_Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email de receptor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Receiver_Email'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta donde se guardara el archivo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'PathReceivedFile'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta absoluta de la guia generada',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'PathSticker'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado de la guia(DOWNLOADED, ENVIADO, Requested)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Status'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de receptor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = N'COLUMN',
    @level2name = N'Receiver_Date'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Información de servicios solicitados. Muestra información de creacion de guías',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceRequest',
    @level2type = NULL,
    @level2name = NULL