CREATE TABLE [dbo].[DeliveryOrderPiece] (
    [GuidePiece]                        BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [GuideSerie]                        NVARCHAR (2)    NOT NULL,
    [GuideNumber]                       INT             NOT NULL,
    [PiecePhysicalWeight]               DECIMAL (12, 2) NULL,
    [PieceHeight]                       DECIMAL (12, 2) NULL,
    [PieceWidth]                        DECIMAL (12, 2) NULL,
    [PieceLength]                       DECIMAL (12, 2) NULL,
    [PieceWeight]                       DECIMAL (12, 2) NULL,
    [Detail]                            VARCHAR (2500)  NULL,
    [Currency]                          VARCHAR (20)    NULL,
    [Amount]                            DECIMAL (12, 2) NULL,
    [DateCreated]                       DATETIME        NOT NULL,
    [PieceUpdated]                      NVARCHAR (50)   NULL,
    [DateUpdated]                       DATETIME        NULL,
    [fragile]                           BIT             NULL,
    [IsPickup]                          BIT             NULL,
    [NoPiece]                           INT             NULL,
    [PieceHeightCheck]                  DECIMAL (12, 2) NULL,
    [PieceWidthCheck]                   DECIMAL (12, 2) NULL,
    [PieceLengthCheck]                  DECIMAL (12, 2) NULL,
    [MassWeight]                        DECIMAL (12, 2) NULL,
    [volumetricWeight]                  DECIMAL (12, 2) NULL,
    [CategoryCheck]                     INT             NULL,
    [IsDry]                             BIT             DEFAULT ((1)) NULL,
    [StatusOrderId]                     INT             NULL,
    [CodeOfSeller]                      NVARCHAR (20)   NULL,
    [ParcelCode]                        NVARCHAR (20)   NULL,
    [ExternalPieceId]                   NVARCHAR (50)   NULL,
    [TokenRegistrationExternalCode]     NVARCHAR (50)   NULL,
    [DateRegistrationExternalCode]      DATETIME        NULL,
    [AccountIdRegistrationExternalCode] BIGINT          NULL,
    [IdStatusGuideByContainer]          INT             NULL,
    [IsNewInContainer]                  BIT             NULL,
    CONSTRAINT [PK_DeliveryOrderPiece] PRIMARY KEY NONCLUSTERED ([GuideSerie] ASC, [GuideNumber] ASC, [GuidePiece] ASC),
    CONSTRAINT [FK_CategoryCheck] FOREIGN KEY ([CategoryCheck]) REFERENCES [dbo].[CatArticle] ([ArtId]),
    CONSTRAINT [FK_DeliveryOrderPiece_CatStatusGuideByContainer] FOREIGN KEY ([IdStatusGuideByContainer]) REFERENCES [dbo].[CatStatusGuideByContainer] ([IdStatus])
);












GO
CREATE NONCLUSTERED INDEX [IX_GuidePieceNumber]
    ON [dbo].[DeliveryOrderPiece]([GuidePiece] ASC)
    INCLUDE([GuideNumber]);


GO
CREATE NONCLUSTERED INDEX [idx_ParcelCode]
    ON [dbo].[DeliveryOrderPiece]([ParcelCode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_guide_serie_piece_status]
    ON [dbo].[DeliveryOrderPiece]([GuideNumber] ASC, [GuideSerie] ASC, [NoPiece] ASC, [StatusOrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_GuideSerie_GuideNumber_NoPiece]
    ON [dbo].[DeliveryOrderPiece]([GuideSerie] ASC, [GuideNumber] ASC, [NoPiece] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de pieza externo.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'ExternalPieceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario que registró el código externo.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'TokenRegistrationExternalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de registro de código externo.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'DateRegistrationExternalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cuenta del usuario que registra el código externo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'AccountIdRegistrationExternalCode'
GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderPiece_GetQueryRelationshipPieceCode]
	ON [dbo].[DeliveryOrderPiece] ([ExternalPieceId])
	INCLUDE ([GuideSerie],[GuideNumber],[NoPiece])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica estado de la pieza dentro del contenedor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'IdStatusGuideByContainer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si la pieza es nueva dentro del contenedor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPiece',
    @level2type = N'COLUMN',
    @level2name = N'IsNewInContainer'
GO
CREATE NONCLUSTERED INDEX [IX_DOP_Guide_SumAndWeightPick]
    ON [dbo].[DeliveryOrderPiece]([GuideSerie] ASC, [GuideNumber] ASC)
    INCLUDE([PieceWeight], [Amount], [NoPiece], [PiecePhysicalWeight]);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderPiece_SFTP_Webhook]
    ON [dbo].[DeliveryOrderPiece]([GuideSerie] ASC, [GuideNumber] ASC)
    INCLUDE([GuidePiece], [ExternalPieceId]);


GO
CREATE NONCLUSTERED INDEX [IDX_DOP_GuideSerie_GuideNumber]
    ON [dbo].[DeliveryOrderPiece]([GuideSerie] ASC, [GuideNumber] ASC)
    INCLUDE([NoPiece]);

