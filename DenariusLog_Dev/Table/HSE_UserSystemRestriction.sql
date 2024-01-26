USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_UserSystemRestriction
CREATE TABLE dbo.HSE_UserSystemRestriction
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    UstIdRestriction BIGINT NOT NULL, -- 
    UstIdUser BIGINT NOT NULL,        -- 
    UstIdSystem INT NOT NULL,         -- 
    UstStatus VARCHAR(10) NOT NULL,   -- 
    UstRowStatus BIT NOT NULL,        -- 
    RecordDate DATETIME NOT NULL      -- Fecha y hora en la que se registra la información en bdd
);