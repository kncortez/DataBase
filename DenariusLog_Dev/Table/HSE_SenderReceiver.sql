USE DenariusLog_Dev;

--DROP TABLE dbo.HSE_SenderReceiver
CREATE TABLE dbo.HSE_SenderReceiver
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    SenRecID INT NOT NULL,                 -- 
    SenRecFirstName VARCHAR(100) NOT NULL, -- 
    SenRecLastName VARCHAR(100) NOT NULL,  -- 
    SenRecCUI VARCHAR(25) NULL,            -- 
    SenRecStatus BIT NULL,                 --
    RecordDate DATETIME NOT NULL           -- Fecha y hora en la que se registra la información en bdd
);