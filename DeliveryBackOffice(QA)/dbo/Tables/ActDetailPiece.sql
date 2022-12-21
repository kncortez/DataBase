CREATE TABLE [dbo].[ActDetailPiece] (
    [IdActDetailPiece] INT           IDENTITY (1, 1) NOT NULL,
    [ActDetailId]      INT           NOT NULL,
    [PieceNumber]      INT           NOT NULL,
    [IsDryPiece]       BIT           CONSTRAINT [DF__ActDetail__IsDry__4DD54A14] DEFAULT ((1)) NOT NULL,
    [RowStatus]        BIT           CONSTRAINT [DF__ActDetail__RowSt__4EC96E4D] DEFAULT ((1)) NOT NULL,
    [TokenCreated]     NVARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME      NOT NULL,
    [TokenUpdated]     NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    [UserRevoke]       NVARCHAR (75) NULL,
    [DateRevoke]       DATETIME      NULL,
    CONSTRAINT [PK__ActDetai__EA4B46252BE4438C] PRIMARY KEY CLUSTERED ([IdActDetailPiece] ASC),
    CONSTRAINT [FK_ActDetailPiece_Guide] FOREIGN KEY ([ActDetailId]) REFERENCES [dbo].[ActDetail] ([IdActDetail]),
    CONSTRAINT [UQ_ActDetailPiece_GuidePiece] UNIQUE NONCLUSTERED ([ActDetailId] ASC, [PieceNumber] ASC)
);



