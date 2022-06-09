CREATE TABLE [dbo].[VisitPointClient_Parser] (
    [CustomerID]      INT            NULL,
    [CodeOfReference] INT            NULL,
    [Firstname]       NVARCHAR (255) NULL,
    [Lastname]        NVARCHAR (255) NULL,
    [Address]         NVARCHAR (255) NULL,
    [Zone]            NVARCHAR (255) NULL,
    [Town]            NVARCHAR (255) NULL,
    [Department]      NVARCHAR (255) NULL,
    [Phone]           NVARCHAR (255) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los puntos de visita del Parser.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla VisitPointClient_Parser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'CustomerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de referencia del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primer nombre del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Firstname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segundo nombre del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Lastname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Zona del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Zone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Municipio del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Town';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Departamento del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Department';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono del punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointClient_Parser', @level2type = N'COLUMN', @level2name = N'Phone';

