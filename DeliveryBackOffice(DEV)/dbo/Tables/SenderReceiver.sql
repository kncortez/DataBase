CREATE TABLE [dbo].[SenderReceiver] (
    [ID]                      INT            IDENTITY (1, 1) NOT NULL,
    [First_Name]              NVARCHAR (100) NOT NULL,
    [Last_Name]               NVARCHAR (100) NOT NULL,
    [Address]                 NVARCHAR (200) NOT NULL,
    [Zone]                    NVARCHAR (100) NULL,
    [Town]                    NVARCHAR (100) NOT NULL,
    [Department]              NVARCHAR (100) NOT NULL,
    [Phone]                   NVARCHAR (50)  NOT NULL,
    [Social_Security_ID]      NVARCHAR (200) NULL,
    [Email]                   NVARCHAR (200) NULL,
    [CUI]                     NVARCHAR (25)  NULL,
    [Latitude]                NVARCHAR (40)  NULL,
    [Longitude]               NVARCHAR (40)  NULL,
    [Entity_Type]             TINYINT        NOT NULL,
    [User_Created]            NVARCHAR (50)  NOT NULL,
    [Date_Created]            DATETIME       NOT NULL,
    [Estatus]                 BIT            NULL,
    [HubLogisticId]           INT            NULL,
    [CatTypeSenderReceiverId] INT            NULL,
    [UniqueCode]              NVARCHAR (50)  NULL,
	[MessageCounter]          INT            NOT NULL DEFAULT (0),
	[MailCounter]             INT            NOT NULL DEFAULT (0),
	[Date_UpdateToken]        DATETIME       NULL,
    CONSTRAINT [PK_SenderReceiver] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SenderReceiver_CatTypeSenderReceiver] FOREIGN KEY ([CatTypeSenderReceiverId]) REFERENCES [dbo].[CatTypeSenderReceiver] ([IdCatTypeSenderReceiver]),
    CONSTRAINT [FK_SenderReceiver_HubLogistic] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [UC_CUI] UNIQUE NONCLUSTERED ([CUI] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contador de veces enviado token por mensaje de texto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'MessageCounter';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contador de veces enviado token por correo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'MailCounter';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha para manejar reinicio de contador de Mensajes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'Date_UpdateToken';








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del hub al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del tipo de piloto/courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'CatTypeSenderReceiverId';


GO
CREATE NONCLUSTERED INDEX [IDX_Phone_INCLUDE]
    ON [dbo].[SenderReceiver]([Phone] ASC)
    INCLUDE([First_Name], [Last_Name]);


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único por courier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'UniqueCode';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Información de los couriers(mensajeros) ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'First_Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Apellido',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Last_Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dirección',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Address'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de zona',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Zone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de municipio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Town'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de departamento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Department'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Teléfono',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Phone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de seguridad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Social_Security_ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Email'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'CUI',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'CUI'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Latitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Longitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica el tipo de entidad(1 Commerce, 2 Person, 3 Courier)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Entity_Type'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario que creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'User_Created'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Date_Created'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SenderReceiver',
    @level2type = N'COLUMN',
    @level2name = N'Estatus'