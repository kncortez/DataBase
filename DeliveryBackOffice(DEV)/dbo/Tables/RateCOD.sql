CREATE TABLE [dbo].[RateCOD] (
    [IdRateCOD]           BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RateId]              INT             NOT NULL,
    [TypeServiceId]       INT             NOT NULL,
    [TypeSegmentId]       INT             NOT NULL,
    [CODRate]             DECIMAL (12, 2) NOT NULL,
    [CODExempt]           DECIMAL (12, 2) NULL,
    [CreditCardSurcharge] DECIMAL (12, 2) NULL,
    [RowStatus]           INT             NOT NULL,
    [TokenCreated]        VARCHAR (50)    NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TokenUpdated]        VARCHAR (50)    NULL,
    [DateUpdated]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdRateCOD] ASC),
    FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    FOREIGN KEY ([TypeSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);




GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_include]
    ON [dbo].[RateCOD]([RowStatus] ASC)
    INCLUDE([RateId], [TypeServiceId], [TypeSegmentId], [CODRate], [CODExempt]);


GO
CREATE NONCLUSTERED INDEX [IDX_RateId_TypeServiceId_TypeSegmentId_RowStatus_INCLUDE]
    ON [dbo].[RateCOD]([RateId] ASC, [TypeServiceId] ASC, [TypeSegmentId] ASC, [RowStatus] ASC)
    INCLUDE([CODRate], [CODExempt]);

