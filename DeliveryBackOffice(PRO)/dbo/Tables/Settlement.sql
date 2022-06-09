CREATE TABLE [dbo].[Settlement] (
    [IdSettlement]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [Settlement]         NVARCHAR (100) NULL,
    [SettlementLatitud]  DECIMAL (9, 6) NULL,
    [SettlementLongitud] DECIMAL (9, 6) NULL,
    [PostalCode]         NVARCHAR (5)   NULL,
    [SettlementSatus]    BIT            NULL,
    [IdTownship]         INT            NULL,
    [IdProvince]         INT            NULL,
    [IdCountry]          NVARCHAR (2)   NULL,
    [IsSpecial]          BIT            NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    CONSTRAINT [PK_Settlement] PRIMARY KEY CLUSTERED ([IdSettlement] ASC),
    CONSTRAINT [FK_Settlement_Province] FOREIGN KEY ([IdProvince]) REFERENCES [dbo].[Province] ([IdProvince]),
    CONSTRAINT [FK_Settlement_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
CREATE NONCLUSTERED INDEX [IX_Settlement_SettlementStatusList]
    ON [dbo].[Settlement]([IdSettlement] ASC, [SettlementSatus] ASC);

