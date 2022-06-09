CREATE TABLE [dbo].[CatCurrencyCOD] (
    [IdCatCurrencyCOD] INT           IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50) NOT NULL,
    [Symbol]           NVARCHAR (3)  NULL,
    [CodeISO]          NVARCHAR (3)  NOT NULL,
    [NumISO]           INT           NOT NULL,
    [RowStatus]        BIT           CONSTRAINT [DF_CatCurrencyCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]     NVARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME      CONSTRAINT [DF_CatCurrencyCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]     NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    CONSTRAINT [PK_CatCurrencyCOD_IdCatCurrencyCOD] PRIMARY KEY CLUSTERED ([IdCatCurrencyCOD] ASC),
    CONSTRAINT [UK_CatCurrencyCOD_Name_CodeISO_NumISO] UNIQUE NONCLUSTERED ([Name] ASC, [CodeISO] ASC, [NumISO] ASC)
);

