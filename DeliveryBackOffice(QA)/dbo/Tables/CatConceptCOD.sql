CREATE TABLE [dbo].[CatConceptCOD] (
    [IdCatConceptCOD] INT           IDENTITY (1, 1) NOT NULL,
    [Concept]         NVARCHAR (50) NOT NULL,
    [RowStatus]       BIT           CONSTRAINT [DF_CatConceptCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]    NVARCHAR (50) NOT NULL,
    [DateCreated]     DATETIME      CONSTRAINT [DF_CatConceptCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]    NVARCHAR (50) NULL,
    [DateUpdated]     DATETIME      NULL,
    CONSTRAINT [PK_CatConceptCOD_IdCatConceptCOD] PRIMARY KEY CLUSTERED ([IdCatConceptCOD] ASC),
    CONSTRAINT [UK_CatConceptCOD_Concept] UNIQUE NONCLUSTERED ([Concept] ASC)
);

