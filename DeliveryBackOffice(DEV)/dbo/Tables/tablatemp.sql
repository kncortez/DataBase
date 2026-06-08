CREATE TABLE [dbo].[tablatemp] (
    [nombress]   NVARCHAR (200) NULL,
    [telefonoss] NVARCHAR (100) NULL,
    [es_clie]    NVARCHAR (100) NULL,
    [RowID]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_Tablatemp] PRIMARY KEY CLUSTERED ([RowID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [Nombre]
    ON [dbo].[tablatemp]([nombress] ASC);

