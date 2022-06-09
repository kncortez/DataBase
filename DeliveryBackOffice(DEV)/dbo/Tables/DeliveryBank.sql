CREATE TABLE [dbo].[DeliveryBank] (
    [Id_bank]     INT            NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [Acronym]     NVARCHAR (15)  NULL,
    [Description] NVARCHAR (255) NULL,
    [create_date] DATETIME       NOT NULL,
    [Id_status]   INT            NOT NULL,
    [Id_country]  NVARCHAR (2)   NOT NULL,
    [URL_logo]    TEXT           NULL,
    [CardCode]    NVARCHAR (50)  NULL,
    [ACHCode]     INT            NULL,
    [PayingBank]  INT            CONSTRAINT [DF_DeliveryBank_PayingBank] DEFAULT ((31)) NULL,
    CONSTRAINT [PK_SP_DEPOSITOS_BANCOS] PRIMARY KEY CLUSTERED ([Id_bank] ASC),
    CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank] FOREIGN KEY ([PayingBank]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);

