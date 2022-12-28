CREATE TABLE [dbo].[ConfirmedAddressByCustomer] (
    [IdConfirmedAddressByCustomer] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerId]                   INT           NOT NULL,
    [ConfirmedAddressId]           BIGINT        NOT NULL,
    [RowStatus]                    BIT           CONSTRAINT [DF__Confirmed__RowSt__0C31A3E9] DEFAULT ((1)) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateUpdated]                  DATETIME      NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    CONSTRAINT [PK__Confirme__47DA9DEC2D2550A0] PRIMARY KEY CLUSTERED ([IdConfirmedAddressByCustomer] ASC),
    CONSTRAINT [UK_ConfirmedAddressByCustomer_CustomerAddress] UNIQUE NONCLUSTERED ([CustomerId] ASC, [ConfirmedAddressId] ASC)
);

