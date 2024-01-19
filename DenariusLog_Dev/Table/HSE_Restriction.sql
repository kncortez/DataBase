USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_Restriction
CREATE TABLE dbo.HSE_Restriction
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    RstIdUser VARCHAR(50) NOT NULL,   -- 
    RstUsername VARCHAR(50) NOT NULL, -- 
    RstIdSystem INT NOT NULL,         -- 
    RstStatus VARCHAR(8) NOT NULL,    -- 
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la información en bdd
);