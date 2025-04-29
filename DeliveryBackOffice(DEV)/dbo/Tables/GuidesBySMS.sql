CREATE TABLE [dbo].[GuidesBySMS] (
    [IdGuidesBySMS] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SmsId]         BIGINT        NOT NULL,
    [GuideSerie]    NVARCHAR (2)  NULL,
    [GuideNumber]   INT           NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  NVARCHAR (50) NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  NVARCHAR (50) NULL,
    [DateUpdated]   DATETIME      NULL,
    CONSTRAINT [PK_GuidesBySMS] PRIMARY KEY CLUSTERED ([IdGuidesBySMS] ASC),
    CONSTRAINT [FK_GuidesBySMS_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_GuidesBySMS_SMS_Received] FOREIGN KEY ([SmsId]) REFERENCES [dbo].[SMS_Received] ([SMS_ID])
);

