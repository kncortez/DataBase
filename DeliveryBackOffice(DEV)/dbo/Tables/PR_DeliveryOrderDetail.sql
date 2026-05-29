CREATE TABLE [dbo].[PR_DeliveryOrderDetail] (
    [Guide_Serie]         NVARCHAR (2)   NOT NULL,
    [Guide_Number]        INT            NOT NULL,
    [StatusOrderId]       TINYINT        NOT NULL,
    [UserCreated]         NVARCHAR (50)  NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [DateCreatedInSystem] DATETIME       NULL,
    [Observations]        NVARCHAR (200) NULL,
    [Temperature_Celsius] DECIMAL (5, 2) NULL,
    [PieceId]             INT            NULL,
    [RowStatus]           BIT            CONSTRAINT [PR_DF_RowStatus] DEFAULT ((1)) NOT NULL,
    [DeliveryAttemptId]   BIGINT         NULL,
    [SystemOrigin]        INT            NULL,
    [StationId]           INT            NULL,
    [RowID]               INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PR_PK_DeliveryOrderDetail] PRIMARY KEY NONCLUSTERED ([Guide_Serie] ASC, [Guide_Number] ASC, [RowID] ASC) ON [PS_DelORDER_Guide_Number] ([Guide_Number])
) ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE CLUSTERED INDEX [PR_ClusteredIndex-GuideSerie-Number-Status]
    ON [dbo].[PR_DeliveryOrderDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [StatusOrderId] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);

