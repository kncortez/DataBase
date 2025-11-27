-- =============================================
-- Author:      <Juan Ramirez > <2025-10-02>
-- Description: <Se agrega objeto para manejar guias desde kiosko>
-- =============================================
CREATE TYPE dbo.GuidesKiosko AS TABLE
(
  Guide_Serie    NVARCHAR(2) NOT NULL,
  Guide_Number   INT         NOT NULL,
  IdCountry      NVARCHAR(2) NOT NULL
);