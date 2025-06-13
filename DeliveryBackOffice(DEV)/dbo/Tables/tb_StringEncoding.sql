CREATE TABLE [dbo].[tb_StringEncoding] (
    [StringToReplace]   NVARCHAR (10) NOT NULL,
    [StringReplacement] NVARCHAR (10) NULL,
    [EncodingType]      NVARCHAR (25) NOT NULL,
    CONSTRAINT [pk_StringEncoding] PRIMARY KEY CLUSTERED ([EncodingType] ASC, [StringToReplace] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_EncodingType]
    ON [dbo].[tb_StringEncoding]([EncodingType] ASC);

