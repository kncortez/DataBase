CREATE TABLE [dbo].[tablatemp] (
    [nombress]   NVARCHAR (200) NULL,
    [telefonoss] NVARCHAR (100) NULL,
    [es_clie]    NVARCHAR (100) NULL
);


GO
CREATE NONCLUSTERED INDEX [Nombre]
    ON [dbo].[tablatemp]([nombress] ASC);

