CREATE TABLE [dbo].[DeliveryOrderPiece] (
    [GuidePiece]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [GuideSerie]          NVARCHAR (2)    NOT NULL,
    [GuideNumber]         INT             NOT NULL,
    [PiecePhysicalWeight] DECIMAL (12, 2) NULL,
    [PieceHeight]         DECIMAL (12, 2) NULL,
    [PieceWidth]          DECIMAL (12, 2) NULL,
    [PieceLength]         DECIMAL (12, 2) NULL,
    [PieceWeight]         DECIMAL (12, 2) NULL,
    [Detail]              VARCHAR (2500)  NULL,
    [Currency]            VARCHAR (20)    NULL,
    [Amount]              DECIMAL (12, 2) NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [PieceUpdated]        NVARCHAR (50)   NULL,
    [DateUpdated]         DATETIME        NULL,
    [fragile]             BIT             NULL,
    [IsPickup]            BIT             NULL,
    [NoPiece]             INT             NULL,
    [PieceHeightCheck]    DECIMAL (12, 2) NULL,
    [PieceWidthCheck]     DECIMAL (12, 2) NULL,
    [PieceLengthCheck]    DECIMAL (12, 2) NULL,
    [MassWeight]          DECIMAL (12, 2) NULL,
    [volumetricWeight]    DECIMAL (12, 2) NULL,
    [CategoryCheck]       INT             NULL,
    [IsDry]               BIT             DEFAULT ((1)) NULL,
    [StatusOrderId]       INT             NULL,
    [CodeOfSeller]        NVARCHAR (20)   NULL,
    [ParcelCode]          NVARCHAR (10)   NULL,
    CONSTRAINT [PK_DeliveryOrderPiece] PRIMARY KEY NONCLUSTERED ([GuideSerie] ASC, [GuideNumber] ASC, [GuidePiece] ASC),
    CONSTRAINT [FK_CategoryCheck] FOREIGN KEY ([CategoryCheck]) REFERENCES [dbo].[CatArticle] ([ArtId])
);




GO
CREATE NONCLUSTERED INDEX [IX_GuidePieceNumber]
    ON [dbo].[DeliveryOrderPiece]([GuidePiece] ASC)
    INCLUDE([GuideNumber]);


GO
CREATE NONCLUSTERED INDEX [idx_guide_serie_piece_status]
    ON [dbo].[DeliveryOrderPiece]([GuideNumber] ASC, [GuideSerie] ASC, [NoPiece] ASC, [StatusOrderId] ASC);

