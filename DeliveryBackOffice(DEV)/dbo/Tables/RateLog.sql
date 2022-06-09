CREATE TABLE [dbo].[RateLog] (
    [IdRate_Log]           INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]           INT            NULL,
    [CodeOfReference]      INT            NULL,
    [TokenCreated]         NVARCHAR (50)  NOT NULL,
    [ModuleCreated]        NVARCHAR (100) NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [OriginalRateHeaderId] INT            NULL,
    [NewRateHeaderId]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdRate_Log] ASC),
    FOREIGN KEY ([NewRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    FOREIGN KEY ([OriginalRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los log de los cambios en los tarifarios de los módulos: Tarifarios, Socios de negocio y Puntos de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para identificar de manera unica cada log.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'IdRate_Log';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para identificar al cliente que se le actualizo o asigno un tarifario, este campo queda NULL desde el módulo de Tarifarios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para identificar al punto de visita que se le asigna un tarifario, este campo queda NULL desde los módulos, Tarifarios y Socios de negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el Token del usuario que genero el log.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el módulo que genero el log.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'ModuleCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar la fecha en la que se genero el log.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el identificador del tarifario original que tenia determinado cliente, este campo queda NULL desde el modulo de Tarifarios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'OriginalRateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el identificador del tarifario nuevo que se crea ó que se le asigna a determinado cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateLog', @level2type = N'COLUMN', @level2name = N'NewRateHeaderId';

