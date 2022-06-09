CREATE TABLE [dbo].[tmpManualInvoice] (
    [Guide]        INT            NOT NULL,
    [BusinessName] NVARCHAR (100) NULL,
    [Signature]    NVARCHAR (100) NULL,
    [Nit]          NVARCHAR (50)  NULL,
    CONSTRAINT [PK_tmpManualInvoice] PRIMARY KEY CLUSTERED ([Guide] ASC)
);

