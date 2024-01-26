USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_RolByUserBySystem
CREATE TABLE dbo.HSE_RolByUserBySystem
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    RusIdSystem VARCHAR(50) NOT NULL, -- 
    RusIdUser VARCHAR(50) NOT NULL,   -- 
    RusRowStatus INT NOT NULL,        -- 
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la información en bdd
);