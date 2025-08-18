CREATE TABLE [dbo].[CatScheduleCOD] (
    [IdCatScheduleCOD] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Hour]             TIME (7)      NOT NULL,
    [RowStatus]        BIT           CONSTRAINT [DF_CatScheduleCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]     NVARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME      CONSTRAINT [DF_CatScheduleCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]     NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    CONSTRAINT [PK_CatScheduleCOD_IdCatScheduleCOD] PRIMARY KEY CLUSTERED ([IdCatScheduleCOD] ASC),
    CONSTRAINT [UK_CatScheduleCOD_IdCatScheduleCOD] UNIQUE NONCLUSTERED ([Hour] ASC)
);

