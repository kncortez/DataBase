USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_Person
CREATE TABLE dbo.HSE_Person
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    PerIdPerson BIGINT NOT NULL,        -- 
    PerFirstName VARCHAR(100) NOT NULL, -- Primer Nombre
    PerLastName VARCHAR(100) NOT NULL,  -- Primer Apellido
                                        -- PerIdentification VARCHAR(50) NOT NULL, -- CUI / DPI (no se guardará porque los datos no tienen control de calidad)
    PerRowStatus BIT NULL,               -- Estado del registro 1 = activo ; 0 = inactivo
    RecordDate DATETIME NOT NULL    -- Fecha y hora en la que se registra la información en bdd
);