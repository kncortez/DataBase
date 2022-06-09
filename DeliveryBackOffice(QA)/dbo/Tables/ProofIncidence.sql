CREATE TABLE [dbo].[ProofIncidence] (
    [IdProofIncidence] INT           IDENTITY (1, 1) NOT NULL,
    [IncidenceId]      INT           NULL,
    [PathIncidence]    VARCHAR (200) NULL,
    [RowStatus]        BIT           NOT NULL,
    [TokenCreated]     VARCHAR (150) NULL,
    [DateCreated]      DATETIME      NOT NULL,
    [TokenUpdated]     VARCHAR (150) NULL,
    [DateUpdated]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdProofIncidence] ASC),
    CONSTRAINT [FKProofIncidence] FOREIGN KEY ([IncidenceId]) REFERENCES [dbo].[IncidenceServices] ([IdIncidence])
);

