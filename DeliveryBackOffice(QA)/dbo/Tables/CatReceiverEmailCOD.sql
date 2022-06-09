CREATE TABLE [dbo].[CatReceiverEmailCOD] (
    [IdCatReceiverEmailCOD] INT            IDENTITY (1, 1) NOT NULL,
    [Email]                 NVARCHAR (100) NOT NULL,
    [RowStatus]             BIT            CONSTRAINT [DF_CatReceiverEmailCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateCreated]           DATETIME       CONSTRAINT [DF_CatReceiverEmailCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    [DateUpdated]           DATETIME       NULL,
    CONSTRAINT [PK_CatReceiverEmailCOD_IdCatReceiverEmailCOD] PRIMARY KEY CLUSTERED ([IdCatReceiverEmailCOD] ASC),
    CONSTRAINT [UK_CatReceiverEmailCOD_Email] UNIQUE NONCLUSTERED ([Email] ASC)
);

