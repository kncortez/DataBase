CREATE TABLE [dbo].[NotificationEmailConfig] (
    [IdConfig]         INT                IDENTITY (1, 1) NOT NULL,
    [Email]            NVARCHAR (255)     NOT NULL,
    [NotificationType] NVARCHAR (50)      NULL,
    [IsActive]         BIT                DEFAULT ((1)) NOT NULL,
    [CreatedAt]        DATETIMEOFFSET (7) DEFAULT (sysdatetimeoffset()) NOT NULL,
    CONSTRAINT [PK_NotificationEmailConfig] PRIMARY KEY CLUSTERED ([IdConfig] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NotificationEmailConfig_Type_Active]
    ON [dbo].[NotificationEmailConfig]([NotificationType] ASC, [IsActive] ASC);

