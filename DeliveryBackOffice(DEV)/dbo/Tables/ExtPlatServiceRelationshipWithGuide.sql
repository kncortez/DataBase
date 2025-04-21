CREATE TABLE [dbo].[ExtPlatServiceRelationshipWithGuide] (
    [IdExtPlatServiceRelationshipWithGuide] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ExtPlatServiceId]                      INT           NOT NULL,
    [GuideSerie]                            NVARCHAR (2)  NOT NULL,
    [GuideNumber]                           INT           NOT NULL,
    [RowStatus]                             INT           NOT NULL,
    [TokenCreated]                          NVARCHAR (50) NOT NULL,
    [DateCreated]                           DATETIME      NOT NULL,
    [TokenUpdated]                          NVARCHAR (50) NULL,
    [DateUpdated]                           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExtPlatServiceRelationshipWithGuide] ASC),
    CONSTRAINT [ExtPlatServiceRelationshipWithGuide_Guide_FK] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [ExtPlatServiceRelationshipWithGuide_IdService_FK] FOREIGN KEY ([ExtPlatServiceId]) REFERENCES [dbo].[ExtPlatformService] ([IdExtPlatformService])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'IdExtPlatServiceRelationshipWithGuide';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de servicio de plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'ExtPlatServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatServiceRelationshipWithGuide', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideNumber_ExtPlatServiceId]
    ON [dbo].[ExtPlatServiceRelationshipWithGuide]([GuideSerie] ASC, [GuideNumber] ASC, [ExtPlatServiceId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideNumber]
    ON [dbo].[ExtPlatServiceRelationshipWithGuide]([GuideSerie] ASC, [GuideNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ExtPlatServiceIdindex]
    ON [dbo].[ExtPlatServiceRelationshipWithGuide]([ExtPlatServiceId] ASC);

