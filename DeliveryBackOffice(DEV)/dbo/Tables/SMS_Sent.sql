CREATE TABLE [dbo].[SMS_Sent] (
    [Sent_Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Sent_Guide_Series] NVARCHAR (50) NOT NULL,
    [Sent_Guide_Number] INT           NOT NULL,
    [Sent]              BIT           CONSTRAINT [DF_SMS_Sent_Sent] DEFAULT ((0)) NOT NULL,
    [Sent_Batch_Id]     BIGINT        NULL,
    [RowStatus]         BIT           CONSTRAINT [DF_SMS_Sent_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]      NVARCHAR (50) NOT NULL,
    [CreatedDatetime]   DATETIME      NOT NULL,
    [TokenUpdate]       NVARCHAR (50) NULL,
    [UpdatedDatetime]   DATETIME      NULL,
    [SentTypeStatus]    INT           NULL,
    CONSTRAINT [PK_SMS_Sent] PRIMARY KEY CLUSTERED ([Sent_Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_SMS_Sent_GuideList]
    ON [dbo].[SMS_Sent]([Sent_Guide_Series] ASC, [Sent_Guide_Number] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de envío realizado (NULL o 0 = sin enviar; 1 = enviado recoleccion; 2 = enviado arribo instalaciones)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMS_Sent', @level2type = N'COLUMN', @level2name = N'SentTypeStatus';



