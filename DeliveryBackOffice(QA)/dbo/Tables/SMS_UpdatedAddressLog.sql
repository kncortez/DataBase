CREATE TABLE [dbo].[SMS_UpdatedAddressLog] (
    [UpdatedAddressId] INT            IDENTITY (1, 1) NOT NULL,
    [GuideSerie]       NVARCHAR (2)   NOT NULL,
    [GuideNumber]      INT            NOT NULL,
    [OriginalAddress]  NVARCHAR (200) NULL,
    [UpdatedAddress]   NVARCHAR (200) NULL,
    [NameReceiver]     NVARCHAR (200) NULL,
    [PhoneReceiver]    NVARCHAR (100) NULL,
    [Token]            NVARCHAR (50)  NULL,
    [DateCreated]      DATETIME       NULL,
    CONSTRAINT [PK_SMS_UpdatedAddressLog] PRIMARY KEY CLUSTERED ([UpdatedAddressId] ASC),
    CONSTRAINT [FK_SMS_UpdatedAddressLog] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);

