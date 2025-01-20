CREATE TABLE [dbo].[GuideSuscription] (
    [IdGuideSuscription]            INT IDENTITY (1, 1) NOT NULL,
    [IdUserSuscription]             INT NOT NULL,
    [GuideSerie]                    NVARCHAR(2) NOT NULL,
    [GuideNumber]                   INT NOT NULL,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_GuideSuscription] PRIMARY KEY CLUSTERED ([IdGuideSuscription] ASC),
	CONSTRAINT [FK_GuideSuscription_UserSuscription] FOREIGN KEY (IdUserSuscription) REFERENCES [dbo].[UserSuscription] (IdUserSuscription),
	CONSTRAINT FK_GuideSuscription_Guide FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [dbo].[DeliveryOrder] (Guide_Serie, Guide_Number)
);

CREATE NONCLUSTERED INDEX [IDX_GuideSuscription_GuideNumber_GuideSerie]
    ON [dbo].[GuideSuscription]([GuideNumber] ASC, [GuideSerie] ASC);
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del tipo de suscripción', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'IdGuideSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'IdUserSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'GuideSerie'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Número de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'GuideNumber'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'GuideSuscription', N'COLUMN', N'TokenUpdated'
GO
