CREATE TABLE dbo.HSE_InternalUser
(
    IDRecord BIGINT PRIMARY KEY IDENTITY,
    IdUser BIGINT NOT NULL,         -- N�mero de ficha del colaborador
    Username NVARCHAR(50) NOT NULL, -- Nombre de usuario para iniciar sesi�n
    IdEmployee INT NULL,            -- ID de registro interno de la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Hermes, puede ser nulo porque hay usuarios de empleados para otros sistemas
    RegisterUserID BIGINT NOT NULL, -- ID de registro for�neo de la tabla RegisterUser en InternalUser de DeliveryBackOffice
    RowStatus BIT NULL,             -- Estado del registro 1 = activo ; 0 = inactivo
    RecordDate DATETIME NOT NULL    -- Fecha y hora en la que se registra la informaci�n en bdd
);