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
      CodeOfReference  NVARCHAR(50) NOT NULL PRIMARY KEY, -- 1 fila por kiosko
      IsActive         BIT          NOT NULL CONSTRAINT DF_KioskAuthState_IsActive DEFAULT(1),
      AttemptsDate     DATE         NULL,                  -- último día contado
      AttemptsCount    SMALLINT     NOT NULL CONSTRAINT DF_KioskAuthState_AttemptsCount DEFAULT(0),
      LastAttemptAt    date         NULL
  );
END
GO