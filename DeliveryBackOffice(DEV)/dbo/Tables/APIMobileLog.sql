CREATE TABLE [dbo].[APIMobileLog] (
    [IdAPIMobileLog]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [PetitionMethod]   NVARCHAR (10)   NOT NULL,
    [PetitionUrl]      NVARCHAR (4000) NOT NULL,
    [RequestHeader]    NVARCHAR (4000) NULL,
    [RequestBody]      NVARCHAR (MAX)  NULL,
    [RequestDateTime]  DATETIME        NOT NULL,
    [RequestLauValue]  NVARCHAR (500)  NULL,
    [ResponseHeader]   NVARCHAR (4000) NULL,
    [ResponseBody]     NVARCHAR (MAX)  NULL,
    [ResponseDateTime] DATETIME        NULL,
    [ResponseCode]     INT             NULL,
    PRIMARY KEY CLUSTERED ([IdAPIMobileLog] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo HTTP de la respuesta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'ResponseCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de la respuesta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'ResponseDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuerpo de respuesta de la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'ResponseBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cabeceras de respuesta de la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'ResponseHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LauValue de la petición realizada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'RequestLauValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se realizo la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'RequestDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contenido de la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'RequestBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cabeceras envíadas en la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'RequestHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL a donde se realizo la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'PetitionUrl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Metodo HTTP realizado en la petición.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'PetitionMethod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APIMobileLog', @level2type = N'COLUMN', @level2name = N'IdAPIMobileLog';

