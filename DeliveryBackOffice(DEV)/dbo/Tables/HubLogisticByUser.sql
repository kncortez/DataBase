CREATE TABLE [dbo].[HubLogisticByUser] (
    [IdHubLogisticByUser] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [HubLogisticId]       INT           NOT NULL,
    [UserId]              BIGINT        NOT NULL,
    [RowStatus]           BIT           CONSTRAINT [DF_HubLogisticByUser_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK_HubLogisticByUser] PRIMARY KEY CLUSTERED ([IdHubLogisticByUser] ASC),
    CONSTRAINT [FK_HubLogisticByUser_HubLogistic] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_HubLogisticByUser_RegisterUser] FOREIGN KEY ([UserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualziación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del usuario de la tabla RegisterUser.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hubs de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser', @level2type = N'COLUMN', @level2name = N'IdHubLogisticByUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar hubs con usuarios internos desde usuario registrado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogisticByUser';

