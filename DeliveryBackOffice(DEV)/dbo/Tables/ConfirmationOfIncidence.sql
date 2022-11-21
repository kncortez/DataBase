CREATE TABLE [dbo].[ConfirmationOfIncidence] (
    [IdConfirmationOfIncidence]        INT           IDENTITY (1, 1) NOT NULL,
    [ConfirmationOfIncidentToken]      NVARCHAR (50) NOT NULL,
    [CatTypeConfirmationOfIncidenceId] INT           NOT NULL,
    [IsValid]                          BIT           CONSTRAINT [DF_ConfirmationOfIncidence_IsValid] DEFAULT ((0)) NOT NULL,
    [IsConfirmed]                      BIT           CONSTRAINT [DF_ConfirmationOfIncidence_IsConfirmed] DEFAULT ((0)) NOT NULL,
    [StatusOrderId]                    TINYINT       NOT NULL,
    [DateStatusOrder]                  DATETIME      NOT NULL,
    [RowStatus]                        BIT           CONSTRAINT [DF_ConfirmationOfIncidence_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50) NOT NULL,
    [DateCreated]                      DATETIME      NOT NULL,
    [TokenUpdated]                     NVARCHAR (50) NULL,
    [DateUpdated]                      DATETIME      NULL,
    CONSTRAINT [PK_ConfirmationOfIncidence] PRIMARY KEY CLUSTERED ([IdConfirmationOfIncidence] ASC),
    CONSTRAINT [FK_ConfirmationOfIncidence_CatTypeConfirmationOfIncidence] FOREIGN KEY ([CatTypeConfirmationOfIncidenceId]) REFERENCES [dbo].[CatTypeConfirmationOfIncidence] ([IdCatTypeConfirmationOfIncidence]),
    CONSTRAINT [FK_ConfirmationOfIncidence_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si es confirmado por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'IsConfirmed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si courier está en el rango especificado respecto al punto de entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'IsValid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del tipo de confirmación de incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'CatTypeConfirmationOfIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token para identificar información en landingpage.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'ConfirmationOfIncidentToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de tabla ConfirmationOfIncidence. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'IdConfirmationOfIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar información de confirmación de incidencias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado que tiene la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de la creación del checkpoint, para ubicarlo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'DateStatusOrder';


GO
CREATE NONCLUSTERED INDEX [IX_ConfirmationOfIncidence_ConfirmationOfIncidentToken]
    ON [dbo].[ConfirmationOfIncidence]([ConfirmationOfIncidentToken] ASC);

