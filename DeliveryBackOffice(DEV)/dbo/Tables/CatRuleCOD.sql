CREATE TABLE [dbo].[CatRuleCOD] (
    [IdCatRuleCOD] INT           IDENTITY (1, 1) NOT NULL,
    [ListName]     NVARCHAR (50) NOT NULL,
    [Key]          NVARCHAR (50) NOT NULL,
    [Value]        NVARCHAR (50) NOT NULL,
    [Description]  NVARCHAR (50) NULL,
    [RowStatus]    BIT           CONSTRAINT [DF_CatRuleCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated] NVARCHAR (50) NOT NULL,
    [DateCreated]  DATETIME      CONSTRAINT [DF_CatRuleCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_CatRuleCOD_IdCatRuleCOD] PRIMARY KEY CLUSTERED ([IdCatRuleCOD] ASC),
    CONSTRAINT [UK_CatRuleCOD_ListName_Key_Value] UNIQUE NONCLUSTERED ([ListName] ASC, [Key] ASC, [Value] ASC)
);

