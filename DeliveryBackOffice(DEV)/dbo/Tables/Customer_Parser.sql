CREATE TABLE [dbo].[Customer_Parser] (
    [IdCustomer]      INT            NULL,
    [Name]            NVARCHAR (255) NULL,
    [RegexSubject]    NVARCHAR (255) NULL,
    [RegexEmail]      NVARCHAR (MAX) NULL,
    [RegexFilename]   NVARCHAR (255) NULL,
    [ProcessedPrefix] NVARCHAR (255) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las cuentas del Parser.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla Customer_Parser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Expresión regular para el asunto del correo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'RegexSubject';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Expresión regular para el correo del que se recibirán archivos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'RegexEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Expresión regular para el nombre del archivo que se recibirá', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'RegexFilename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre que se le agrega al archivo después de procesarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer_Parser', @level2type = N'COLUMN', @level2name = N'ProcessedPrefix';

