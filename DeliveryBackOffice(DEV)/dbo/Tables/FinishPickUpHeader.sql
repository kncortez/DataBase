-- =============================================
-- Author:       <Juan.Ramirez>
-- Updated date: <2025-02-17>
-- Description:  <Se agrega la tabla para guardar registros de Header de recolecciones>
-- =============================================
CREATE TABLE FinishPickUpHeader 
(
  SchedulePickupId   BIGINT PRIMARY KEY,
  TypeofInOutMoneyId INT,
  Amount             DECIMAL(18,2),
  [Signature]        NVARCHAR(500),
  StartDate          DATETIME,
  EndDate            DATETIME,
  PickupEmail        NVARCHAR(100),
  PickupLatitude     DECIMAL(10,7),
  PickupLongitude    DECIMAL(10,7),
  ServiceStatusId    INT,
  Observation        NVARCHAR(400),
  Voucher            NVARCHAR(300),
  RowStatus          BIT,
  TokenCreated       NVARCHAR(200),
  DateCreated        DATETIME DEFAULT GETDATE(),
  TokenUpdated       NVARCHAR(200),
  DateUpdated        DATETIME
  CONSTRAINT FK_FinishPickUpHeader_CatServiceStatus FOREIGN KEY (ServiceStatusId)
            REFERENCES CatServiceStatus(IdServiceStatus),
  CONSTRAINT FK_FinishPickUpHeader_SchedulePickup FOREIGN KEY (SchedulePickupId)
            REFERENCES SchedulePickup(SchedulePickupId)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N' Id del servicio de recolección relacionado a la tabla SchedulePickup ', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'SchedulePickupId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Identificador del tipo de transacción de dinero', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'TypeofInOutMoneyId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Monto de la recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'Amount';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Firma digital capturada', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'Signature';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha y hora de inicio del servicio', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'StartDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha y hora de finalización del servicio', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'EndDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Correo electrónico de la persona que atendió el servicio de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'PickupEmail';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Latitud de la ubicación donde se realizó el retiro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'PickupLatitude';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Longitud de la ubicación donde se realizó el retiro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'PickupLongitude';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Estado del servicio de recolección', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'ServiceStatusId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Observaciones adicionales del servicio', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'Observation';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Número de comprobante del servicio', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'Voucher';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Estado del registro', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Token de creación', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha de creación', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Token de actualización', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', 
                               @value = N'Fecha de actualización', 
                               @level0type = N'SCHEMA', 
                               @level0name = N'dbo', 
                               @level1type = N'TABLE', 
                               @level1name = N'FinishPickUpHeader', 
                               @level2type = N'COLUMN', 
                               @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Encabezado de tabla para guardar los registros del request para recolecciones SetFinishPickUp ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'FinishPickUpHeader',
    @level2type = NULL,
    @level2name = NULL;