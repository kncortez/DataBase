-- =============================================
-- Author:       <Juan.Ramirez>
-- Updated date: <2025-02-17>
-- Description:  <Se agrega la tabla para guardar registros de detalle de recolecciones>
-- =============================================
CREATE TABLE FinishPickUpDetail 
(
   IdFinishPickUpDetail BIGINT IDENTITY(1,1) PRIMARY KEY,
   SchedulePickupId     BIGINT,
   GuideSerie           NVARCHAR(4),
   GuideNumber          INT,
   GuidePiece           INT,
   RowStatus            BIT,
   TokenCreated         NVARCHAR(200),
   DateCreated          DATETIME DEFAULT GETDATE(),
   TokenUpdated         NVARCHAR(200),
   DateUpdated          DATETIME,
   CONSTRAINT FK_PickupDetail_PickupHeader FOREIGN KEY (SchedulePickupId)
            REFERENCES FinishPickUpHeader (SchedulePickupId)
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
                            @value = N'Detalle de tabla para guardar los registros del request para recolecciones SetFinishPickUp',
                            @level0type = N'SCHEMA',
                            @level0name = N'dbo',
                            @level1type = N'TABLE',
                            @level1name = N'FinishPickUpDetail',
                            @level2type = NULL,
                            @level2name = NULL

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Identificador único del detalle de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'IdFinishPickUpDetail';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Id del servicio de recolección relacionado a la tabla FinishPickUpHeader', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'SchedulePickupId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Serie de la guía de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'GuideSerie';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Número de la guía de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'GuideNumber';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Número de piezas de la guía de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'GuidePiece';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Estado del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Token de creación del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha de creación del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Token de última actualización del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha de última actualización del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpDetail', 
                               @level2type = N'COLUMN', 
                               @level2name = N'DateUpdated';
