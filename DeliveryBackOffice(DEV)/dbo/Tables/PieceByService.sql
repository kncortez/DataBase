CREATE TABLE [dbo].[PieceByService] (
    [IdServiceManagementByPiece] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ServiceManagmentId]         INT           NOT NULL,
    [GuidePieceId]               BIGINT        NOT NULL,
    [RowStatus]                  BIT           NOT NULL,
    [TokenCreated]               VARCHAR (150) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               VARCHAR (150) NULL,
    [DateUpdated]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdServiceManagementByPiece] ASC),
    CONSTRAINT [FK_PieceByService_ServiceManagmentId] FOREIGN KEY ([ServiceManagmentId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
);








GO
CREATE NONCLUSTERED INDEX [IX_PieceByServiceGuidePieceService]
    ON [dbo].[PieceByService]([GuidePieceId] ASC)
    INCLUDE([ServiceManagmentId]);


GO
CREATE NONCLUSTERED INDEX [idx_ServiceManagmentId]
    ON [dbo].[PieceByService]([ServiceManagmentId] ASC)
    INCLUDE([GuidePieceId]);


GO
CREATE NONCLUSTERED INDEX [idx_GuidePieceId]
    ON [dbo].[PieceByService]([GuidePieceId] ASC);

