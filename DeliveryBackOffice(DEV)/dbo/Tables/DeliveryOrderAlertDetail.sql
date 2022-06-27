CREATE TABLE [dbo].[DeliveryOrderAlertDetail] (
    [idDeliveryOrderAlertDetail] INT            IDENTITY (1, 1) NOT NULL,
    [author]                     BIGINT         NOT NULL,
    [username]                   NVARCHAR (50)  NOT NULL,
    [comment]                    NVARCHAR (200) NULL,
    [DeliveryOrderAlertId]       INT            NULL,
    [RowStatus]                  BIT            NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    CONSTRAINT [PKDeliveryOrderAlertDetail] PRIMARY KEY CLUSTERED ([idDeliveryOrderAlertDetail] ASC),
    CONSTRAINT [FKDeliveryOrderAlertDetail_DeliveryOrderAlert] FOREIGN KEY ([DeliveryOrderAlertId]) REFERENCES [dbo].[DeliveryOrderAlert] ([IdDeliveryOrderAlert]),
    CONSTRAINT [FKDeliveryOrderAlertDetail_InternalUser] FOREIGN KEY ([author], [username]) REFERENCES [dbo].[InternalUser] ([IdUser], [Username])
);




GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comentarios de alertas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'idDeliveryOrderAlertDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del autor bajo la tabla de InternalUser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'author';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del usuario que creo el comentario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'username';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto del comentario realizado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la alerta a la que pertenece el comentario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'DeliveryOrderAlertId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlertDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';

