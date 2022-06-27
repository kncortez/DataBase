CREATE TABLE [dbo].[HttpInterceptorLog] (
    [IdHttpInterceptorLog] INT             IDENTITY (1, 1) NOT NULL,
    [PetitionMethod]       NVARCHAR (10)   NOT NULL,
    [PetitionUrl]          NVARCHAR (300)  NOT NULL,
    [PetitionDate]         DATE            NOT NULL,
    [RequestHeader]        NVARCHAR (2500) NULL,
    [RequestBody]          NVARCHAR (MAX)  NULL,
    [RequestLauValue]      NVARCHAR (100)  NULL,
    [RequestTime]          DATETIME        NULL,
    [ResponseHeader]       NVARCHAR (2500) NULL,
    [ResponseStatusCode]   INT             NULL,
    [ResponseBody]         NVARCHAR (MAX)  NULL,
    [ResponseLauValue]     NVARCHAR (100)  NULL,
    [ResponseTime]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdHttpInterceptorLog] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de peticiones web realizadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'IdHttpInterceptorLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Metodo de la petición realizada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'PetitionMethod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL a la que se realizó la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'PetitionUrl';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se realizó la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'PetitionDate';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezados de la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'RequestHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contenido de la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'RequestBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LauValue de la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'RequestLauValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se realizó la petición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'RequestTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezados de la respuesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'ResponseHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de estado de la respuesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'ResponseStatusCode';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contenido de la respuesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'ResponseBody';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LauValue de la respuesta, si hubiese', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'ResponseLauValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se retornó la respuesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HttpInterceptorLog', @level2type = N'COLUMN', @level2name = N'ResponseTime';

