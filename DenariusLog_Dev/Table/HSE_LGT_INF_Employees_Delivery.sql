CREATE TABLE dbo.HSE_LGT_INF_Employees_Delivery
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    IdEmployee INT NOT NULL,          -- ID de registro interno en la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Cash
    CodeEmployee VARCHAR(8) NOT NULL, -- N�mero de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado seg�n Denarius
    DPI VARCHAR(25) NULL,             -- DPI seg�n Denarius
    StatusJob SMALLINT NOT NULL,      -- Estado laboral = 1 activo; 2 = inactivo
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la informaci�n en bdd
);