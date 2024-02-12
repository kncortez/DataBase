CREATE TABLE dbo.HSE_LGT_INF_Employees_Cash
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    CodeEmployee VARCHAR(8) NOT NULL, -- N�mero de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado seg�n Denarius
    DPI VARCHAR(25) NULL,             -- DPI seg�n Denarius
    StatusJob INT NOT NULL,           -- Estado laboral = 1 para altas; 2 para las bajas que se deben registrar en las tablas siguientes
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la informaci�n en bdd
);