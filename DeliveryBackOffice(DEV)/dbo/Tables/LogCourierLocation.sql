CREATE TABLE [dbo].[LogCourierLocation] (
    [IdLogCourierLocation] INT           IDENTITY (1, 1) NOT NULL,
    [CourierId]            INT           NOT NULL,
    [Accuracy]             NVARCHAR (20) NOT NULL,
    [Latitude]             NVARCHAR (20) NOT NULL,
    [Longitude]            NVARCHAR (20) NOT NULL,
    [RowStatus]            BIT           NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLogCourierLocation] ASC),
    CONSTRAINT [FK_LogCourierLocation_Courier] FOREIGN KEY ([CourierId]) REFERENCES [dbo].[SenderReceiver] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_LogCourierLocation_Courier]
    ON [dbo].[LogCourierLocation]([CourierId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LogCourierLocation_CourierRowStatus]
    ON [dbo].[LogCourierLocation]([CourierId] ASC, [RowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de las ubicaciones de los Courier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'IdLogCourierLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador que hace referencia a la tabla SenderReceiver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'CourierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precisión del registro de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'Accuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud del registro de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'Latitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud  del registro de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacón', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LogCourierLocation', @level2type = N'COLUMN', @level2name = N'DateUpdated';

