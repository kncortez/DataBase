/* ===============================================
   SP:        DeliveryBackOffice.dbo.KioskAuthState
   Propósito: <Tabla que almacena los intentos de logueo fallido y control de cuenta para Kiosko>
   Autor:     <Juan Ramirez>
   Historia:  <FDAPI-4605>
   Fecha:     2025-10-29
=========================================== */
IF OBJECT_ID('DeliveryBackOffice.dbo.KioskAuthState','U') IS NULL
BEGIN
  CREATE TABLE DeliveryBackOffice.dbo.KioskAuthState
  (
      CodeOfReference  INT NOT NULL PRIMARY KEY, -- 1 fila por kiosko
      IsActive         BIT          NOT NULL CONSTRAINT DF_KioskAuthState_IsActive DEFAULT(1),
      AttemptsDate     DATE         NULL,                  -- último día contado
      AttemptsCount    SMALLINT     NOT NULL CONSTRAINT DF_KioskAuthState_AttemptsCount DEFAULT(0),
      LastAttemptAt    date         NULL
  );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys 
    WHERE name = 'FK_KioskAuthState_Kiosk'
      AND parent_object_id = OBJECT_ID('DeliveryBackOffice.dbo.KioskAuthState')
)
BEGIN
    ALTER TABLE DeliveryBackOffice.dbo.KioskAuthState
    ADD CONSTRAINT FK_KioskAuthState_Kiosk
        FOREIGN KEY (CodeOfReference)
        REFERENCES DeliveryBackOffice.dbo.del_ParametrosFactura(dpf_VpCodeOfReference);
END
ELSE
BEGIN
    PRINT 'LA LLAVE PRIMARIA {FK_KioskAuthState_Kiosk} YA EXISTE'
END