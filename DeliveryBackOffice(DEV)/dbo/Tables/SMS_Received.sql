CREATE TABLE [dbo].[SMS_Received] (
    [SMS_ID]                   BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SMS_Message_ID]           BIGINT         NOT NULL,
    [SMS_Message]              NVARCHAR (500) NOT NULL,
    [SMS_MSisdn]               NVARCHAR (50)  NOT NULL,
    [SMS_Short_Number]         NVARCHAR (50)  NOT NULL,
    [SMS_Type]                 NVARCHAR (50)  NOT NULL,
    [SMS_Status]               NVARCHAR (50)  NOT NULL,
    [SMS_Datetime]             DATETIME       NOT NULL,
    [SMS_Row_Status]           BIT            CONSTRAINT [DF_SMS_Received_SMS_Row_Status] DEFAULT ((1)) NOT NULL,
    [SMS_TokenCreated]         NVARCHAR (50)  NOT NULL,
    [SMS_TokenCreatedDatetime] DATETIME       NOT NULL,
    [SMS_TokenUpdate]          NVARCHAR (50)  NULL,
    [SMS_TokenUpdateDatetime]  DATETIME       NULL,
    CONSTRAINT [PK_SMS_Received] PRIMARY KEY CLUSTERED ([SMS_ID] ASC)
);






GO



GO
CREATE NONCLUSTERED INDEX [ismsR]
    ON [dbo].[SMS_Received]([SMS_MSisdn] ASC);

