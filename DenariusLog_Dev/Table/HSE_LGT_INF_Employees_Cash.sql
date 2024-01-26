USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_LGT_INF_Employees_Cash
CREATE TABLE dbo.HSE_LGT_INF_Employees_Cash
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    CodeEmployee VARCHAR(8) NOT NULL, -- Número de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado según Denarius
    DPI VARCHAR(25) NULL,             -- DPI según Denarius
    StatusJob INT NOT NULL,           -- Estado laboral = 1 para altas; 2 para las bajas que se deben registrar en las tablas siguientes
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la información en bdd
);