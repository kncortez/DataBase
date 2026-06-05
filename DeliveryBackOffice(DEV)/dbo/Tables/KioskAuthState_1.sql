CREATE TABLE [dbo].[KioskAuthState] (
    [CodeOfReference] INT      NOT NULL,
    [IsActive]        BIT      CONSTRAINT [DF_KioskAuthState_IsActive] DEFAULT ((1)) NOT NULL,
    [AttemptsDate]    DATE     NULL,
    [AttemptsCount]   SMALLINT CONSTRAINT [DF_KioskAuthState_AttemptsCount] DEFAULT ((0)) NOT NULL,
    [LastAttemptAt]   DATE     NULL,
    PRIMARY KEY CLUSTERED ([CodeOfReference] ASC),
    CONSTRAINT [FK_KioskAuthState_Kiosk] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[del_ParametrosFactura] ([dpf_VpCodeOfReference])
);

