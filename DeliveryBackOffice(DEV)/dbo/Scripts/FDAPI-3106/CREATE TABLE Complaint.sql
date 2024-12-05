CREATE TABLE [dbo].[Complaint] (
    [ComplaintId]          INT              IDENTITY (1, 1) NOT NULL,
    [GuideSerie]           NVARCHAR (2)     NOT NULL,
    [GuideNumber]          INT              NOT NULL,
    [Name]                 NVARCHAR (200)   NULL,
    [Email]                NVARCHAR (100)   NULL,
    [Identification]       NVARCHAR (20)    NULL,
    [Phone]                NVARCHAR (50)    NULL,
    [DateDelivery]         DATETIME         NULL,
    [Reason]               INT              NULL,
    [Description]          NVARCHAR (200)    NULL,
    [PackageAmmount]       NVARCHAR (20)    NULL,
    [NameBankAccount]      NVARCHAR (100)    NULL,
    [BankAccount]          NVARCHAR (50)    NULL,
    [TypeAccount]          INT              NULL,
    [Bank]                 INT              NULL,
    [CountryId]            NVARCHAR (2)     NULL,
    [StatusComplaint]      INT              NULL,
    [RowStatus]            BIT              CONSTRAINT [DF_Complaint_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50)    NOT NULL,
    [DateCreated]          DATETIME         NOT NULL,
    [TokenUpdated]         NVARCHAR (50)    NULL,
    [DateUpdated]          DATETIME         NULL,
    CONSTRAINT [PK_Complaint] PRIMARY KEY ([ComplaintId]),
    CONSTRAINT [FK_Complaint_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_Complaint_ReasonComplaint] FOREIGN KEY ([Reason]) REFERENCES [dbo].[ReasonComplaint] ([ReasonComplaintId]),
    CONSTRAINT [FK_Complaint_CatBankAccountTypeId] FOREIGN KEY ([TypeAccount]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_Complaint_DeliveryBankId] FOREIGN KEY ([Bank]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);
GO
CREATE NONCLUSTERED INDEX [IX_Complaint]
    ON [dbo].[Complaint]([GuideSerie] ASC, [GuideNumber] DESC);