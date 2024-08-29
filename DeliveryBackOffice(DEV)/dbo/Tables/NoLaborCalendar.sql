CREATE TABLE [dbo].[NoLaborCalendar] (
    [IdNoLaborCalendar] BIGINT        IDENTITY (1, 1) NOT NULL,
    [NoLaborDate]       DATE          NOT NULL,
    [RowStatus]         BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenCreated]      NVARCHAR (50) NOT NULL,
    [DateUpdated]       DATETIME      NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [IdCountry]         VARCHAR  (2)  NOT NULL,
    PRIMARY KEY CLUSTERED ([IdNoLaborCalendar] ASC),
    FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [UQ_NoLaborCalendar_Composite] UNIQUE NONCLUSTERED ([NoLaborDate] ASC, [IdCountry] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha la cual debe ser ignorada por procesos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'NoLaborDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN', @level2name = N'IdNoLaborCalendar';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del país al que pertenece la fecha no laboral.' , @level0type = N'SCHEMA', @level0name=N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar', @level2type = N'COLUMN',@level2name = N'IdCountry'


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de días los cuales se consideran no laborales y deben omitirse en el cálculo de fechas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NoLaborCalendar';

GO
CREATE NONCLUSTERED INDEX IDX_NoLaborCalendar_DateAvailable
ON [dbo].[NoLaborCalendar] ( [NoLaborDate], [RowStatus] )