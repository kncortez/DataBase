CREATE TABLE dbo.HSE_RegisterUser
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    UsrIdUser BIGINT NOT NULL,       -- 
    UsrIdPerson BIGINT NOT NULL,     -- 
    UserEmail VARCHAR(200) NOT NULL, --
    RowStatus BIT NOT NULL,           -- Estado del registro 1 = activo ; 0 = inactivo
    RecordDate DATETIME NOT NULL    -- Fecha y hora en la que se registra la informaci�n en bdd
);