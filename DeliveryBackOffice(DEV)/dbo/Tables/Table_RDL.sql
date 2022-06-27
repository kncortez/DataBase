CREATE TABLE [dbo].[Table_RDL] (
    [Guide_Serie]  NVARCHAR (2) NULL,
    [Guide_Number] BIGINT       NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Table_RDL]
    ON [dbo].[Table_RDL]([Guide_Serie] ASC, [Guide_Number] ASC);

