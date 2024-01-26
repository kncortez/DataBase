USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_LGT_INF_Employees_Delivery
CREATE TABLE dbo.HSE_LGT_INF_Employees_Delivery
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    IdEmployee INT NOT NULL,          -- ID de registro interno en la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Cash
    CodeEmployee VARCHAR(8) NOT NULL, -- Número de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado según Denarius
    DPI VARCHAR(25) NULL,             -- DPI según Denarius
    StatusJob SMALLINT NOT NULL,      -- Estado laboral = 1 activo; 2 = inactivo
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la información en bdd
);