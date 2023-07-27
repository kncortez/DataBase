CREATE TABLE [dbo].[SenderReceiver] (
    [ID]                      INT            IDENTITY (1, 1) NOT NULL,
    [First_Name]              NVARCHAR (100) NOT NULL,
    [Last_Name]               NVARCHAR (100) NOT NULL,
    [Address]                 NVARCHAR (200) NOT NULL,
    [Zone]                    NVARCHAR (100) NULL,
    [Town]                    NVARCHAR (100) NOT NULL,
    [Department]              NVARCHAR (100) NOT NULL,
    [Phone]                   NVARCHAR (50)  NOT NULL,
    [Social_Security_ID]      NVARCHAR (200) NULL,
    [Email]                   NVARCHAR (200) NULL,
    [CUI]                     NVARCHAR (25)  NULL,
    [Latitude]                NVARCHAR (40)  NULL,
    [Longitude]               NVARCHAR (40)  NULL,
    [Entity_Type]             TINYINT        NOT NULL,
    [User_Created]            NVARCHAR (50)  NOT NULL,
    [Date_Created]            DATETIME       NOT NULL,
    [Estatus]                 BIT            NULL,
    [HubLogisticId]           INT            NULL,
    [CatTypeSenderReceiverId] INT            NULL,
    [UniqueCode]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_SenderReceiver] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SenderReceiver_CatTypeSenderReceiver] FOREIGN KEY ([CatTypeSenderReceiverId]) REFERENCES [dbo].[CatTypeSenderReceiver] ([IdCatTypeSenderReceiver]),
    CONSTRAINT [FK_SenderReceiver_HubLogistic] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [UC_CUI] UNIQUE NONCLUSTERED ([CUI] ASC)
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del hub al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del tipo de piloto/courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'CatTypeSenderReceiverId';


GO
CREATE NONCLUSTERED INDEX [IDX_Phone_INCLUDE]
    ON [dbo].[SenderReceiver]([Phone] ASC)
    INCLUDE([First_Name], [Last_Name]);


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único por courier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiver', @level2type = N'COLUMN', @level2name = N'UniqueCode';

