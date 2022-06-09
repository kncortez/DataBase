CREATE TABLE [dbo].[SMS_UpdatedElements] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [UpdateStatus]   BIT            CONSTRAINT [DF_SMS_UpdatedElements_UpdateStatus] DEFAULT ((1)) NOT NULL,
    [ElementId]      INT            NOT NULL,
    [ElementName]    NVARCHAR (300) NOT NULL,
    [RowStatus]      BIT            CONSTRAINT [DF_SMS_UpdatedElements_RowStatus] DEFAULT ((1)) NOT NULL,
    [Token]          NVARCHAR (50)  NOT NULL,
    [UpdateDateTime] DATETIME       NOT NULL,
    CONSTRAINT [PK_SMS_UpdatedElements] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=There is an update ; 0=No updates', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMS_UpdatedElements', @level2type = N'COLUMN', @level2name = N'UpdateStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id starting at 10001', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMS_UpdatedElements', @level2type = N'COLUMN', @level2name = N'ElementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Element Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMS_UpdatedElements', @level2type = N'COLUMN', @level2name = N'ElementName';

