CREATE TABLE [dbo].[CatTypeDocument] (
    [IdRegister]        INT           IDENTITY (1, 1) NOT NULL,
    [IdTypeDocument]    INT           NOT NULL,
    [Name]              VARCHAR (50)  NOT NULL,
    [Descripcion]       VARCHAR (150) NOT NULL,
    [RowStatus]         BIT           NOT NULL,
    [TokenCreated]      VARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      VARCHAR (50)  NULL,
    [DateUpdated]       DATETIME      NULL
    CONSTRAINT [PK_CatTypeDocumentHN] PRIMARY KEY CLUSTERED ([IdRegister])
);