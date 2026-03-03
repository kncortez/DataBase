-- EJECUTAR EN EL ORDEN --

-- CREACION DEL NUEVO SISTEMA
INSERT INTO DeliveryBackOffice.dbo.CatSystem (SysNameSystem, SysPlataform, SysDescription, SysRowStatus, SysTokenCreated, SysDateCreated, SysTokenUpdated, SysDateUpdated) VALUES (N'Gestion de Paquetes', N'subscriptions.package.admin', N'CRM Gestión de Paquetes y suscripciones', 1, N'SYS-BILKAR', N'2026-01-14 12:33:50.000', null, null)


-- ACTUALIZACION DE TABLA DE CatRol
alter table dbo.CatRol
    add RolAdminSystem bit default 0
go

exec sp_addextendedproperty 'MS_Description',
     N'Indica si este rol tiene privilegios de administrador al sistema al que está asignado', 'SCHEMA', 'dbo', 'TABLE',
     'CatRol', 'COLUMN', 'RolAdminSystem'
go

-- Actualizar los roles existentes para establecer RolAdminSystem en 0
UPDATE CatRol SET RolAdminSystem = 0;


-- ACTUALIZACION DE TABLA DE RegisterUser
alter table dbo.RegisterUser
    add UsrDateDisabled date
go

exec sp_addextendedproperty 'MS_Description', 'Fecha e qu fue deshabilitado el usuario', 'SCHEMA', 'dbo', 'TABLE',
     'RegisterUser', 'COLUMN', 'UsrDateDisabled'
go

alter table dbo.RegisterUser
    add UsrTokenDisabled varchar(50)
go

exec sp_addextendedproperty 'MS_Description', 'Token del usuario responsble de desactivar el usuario', 'SCHEMA', 'dbo',
     'TABLE', 'RegisterUser', 'COLUMN', 'UsrTokenDisabled'
go


-- ACTUALIZACION DE TABLA DE RolByUserBySystem
alter table dbo.RolByUserBySystem
    add RusDateDisabled DATETIME2
go

exec sp_addextendedproperty 'MS_Description', 'Fecha e qu fue deshabilitado el usuario del sistema relacionado', 'SCHEMA', 'dbo', 'TABLE',
     'RolByUserBySystem', 'COLUMN', 'RusDateDisabled'
go

alter table dbo.RolByUserBySystem
    add RusTokenDisabled varchar(50)
go

exec sp_addextendedproperty 'MS_Description', 'Token del usuario responsble de desactivar el usuario en el sistema definido', 'SCHEMA', 'dbo',
     'TABLE', 'RolByUserBySystem', 'COLUMN', 'RusTokenDisabled'
go




-- Tabla: AuthRefreshTokens
-- Propósito: Almacenar tokens de refresco para JWT
-- Relación: Cada token pertenece a un usuario registrado

CREATE TABLE AuthRefreshTokens (
    RefreshTokenId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NOT NULL,
    Token NVARCHAR(MAX) NOT NULL,
    TokenHash NVARCHAR(255) NOT NULL UNIQUE,
    ExpiresAt DATETIME2 NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RevokedAt DATETIME2 NULL,
    IsRevoked BIT NOT NULL DEFAULT 0,
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,

    CONSTRAINT FK_AuthRefreshTokens_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE CASCADE,
    CONSTRAINT CK_AuthRefreshTokens_ExpiresAt
        CHECK (ExpiresAt > CreatedAt)
);

-- Índices
CREATE INDEX IDX_AuthRefreshTokens_UserId ON AuthRefreshTokens(UserId);
CREATE INDEX IDX_AuthRefreshTokens_ExpiresAt ON AuthRefreshTokens(ExpiresAt);
CREATE INDEX IDX_AuthRefreshTokens_TokenHash ON AuthRefreshTokens(TokenHash);



-- Tabla: AuthLoginAttempts
-- Propósito: Registrar intentos de login para prevenir ataques de fuerza bruta
-- Relación: Cada intento pertenece a un usuario o se identifica por email

CREATE TABLE AuthLoginAttempts (
    LoginAttemptId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NULL,
    Email NVARCHAR(255) NOT NULL,
    IsSuccessful BIT NOT NULL,
    FailureReason NVARCHAR(500) NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    AttemptedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AuthLoginAttempts_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE SET NULL
);

-- Índices
CREATE INDEX IDX_AuthLoginAttempts_UserId ON AuthLoginAttempts(UserId);
CREATE INDEX IDX_AuthLoginAttempts_Email ON AuthLoginAttempts(Email);
CREATE INDEX IDX_AuthLoginAttempts_IpAddress ON AuthLoginAttempts(IpAddress);
CREATE INDEX IDX_AuthLoginAttempts_AttemptedAt ON AuthLoginAttempts(AttemptedAt);


-- Tabla: AuthActiveSessions
-- Propósito: Registrar sesiones activas de usuarios
-- Relación: Cada sesión pertenece a un usuario registrado

-- Tabla: AuthRefreshTokens
-- Propósito: Almacenar tokens de refresco para JWT
-- Relación: Cada token pertenece a un usuario registrado

CREATE TABLE AuthRefreshTokens (
    RefreshTokenId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NOT NULL,
    Token NVARCHAR(MAX) NOT NULL,
    TokenHash NVARCHAR(255) NOT NULL UNIQUE,
    ExpiresAt DATETIME2 NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RevokedAt DATETIME2 NULL,
    IsRevoked BIT NOT NULL DEFAULT 0,
    IpAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,

    CONSTRAINT FK_AuthRefreshTokens_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE CASCADE,
    CONSTRAINT CK_AuthRefreshTokens_ExpiresAt
        CHECK (ExpiresAt > CreatedAt)
);

-- Índices
CREATE INDEX IDX_AuthRefreshTokens_UserId ON AuthRefreshTokens(UserId);
CREATE INDEX IDX_AuthRefreshTokens_ExpiresAt ON AuthRefreshTokens(ExpiresAt);
CREATE INDEX IDX_AuthRefreshTokens_TokenHash ON AuthRefreshTokens(TokenHash);



-- Tabla: AuthLoginAttempts
-- Propósito: Registrar intentos de login para prevenir ataques de fuerza bruta
-- Relación: Cada intento pertenece a un usuario o se identifica por email

CREATE TABLE AuthLoginAttempts (
    LoginAttemptId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NULL,
    Email NVARCHAR(255) NOT NULL,
    IsSuccessful BIT NOT NULL,
    FailureReason NVARCHAR(500) NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    AttemptedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_AuthLoginAttempts_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE SET NULL
);

-- Índices
CREATE INDEX IDX_AuthLoginAttempts_UserId ON AuthLoginAttempts(UserId);
CREATE INDEX IDX_AuthLoginAttempts_Email ON AuthLoginAttempts(Email);
CREATE INDEX IDX_AuthLoginAttempts_IpAddress ON AuthLoginAttempts(IpAddress);
CREATE INDEX IDX_AuthLoginAttempts_AttemptedAt ON AuthLoginAttempts(AttemptedAt);


-- Tabla: AuthActiveSessions
-- Propósito: Registrar sesiones activas de usuarios
-- Relación: Cada sesión pertenece a un usuario registrado

CREATE TABLE AuthActiveSessions (
    SessionId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NOT NULL,
    SessionToken NVARCHAR(MAX) NOT NULL,
    SessionTokenHash NVARCHAR(255) NOT NULL UNIQUE,
    RefreshTokenId BIGINT NULL,
    LoginTime DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastActivityTime DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2 NOT NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    DeviceName NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    LogoutTime DATETIME2 NULL,

    CONSTRAINT FK_AuthActiveSessions_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE CASCADE,
    CONSTRAINT FK_AuthActiveSessions_RefreshToken
        FOREIGN KEY (RefreshTokenId) REFERENCES AuthRefreshTokens(RefreshTokenId) ON DELETE NO ACTION,
    CONSTRAINT CK_AuthActiveSessions_ExpiresAt
        CHECK (ExpiresAt > LoginTime),
    CONSTRAINT CK_AuthActiveSessions_LogoutTime
        CHECK (LogoutTime IS NULL OR LogoutTime >= LoginTime)
);

-- Índices
CREATE INDEX IDX_AuthActiveSessions_UserId ON AuthActiveSessions(UserId);
CREATE INDEX IDX_AuthActiveSessions_SessionTokenHash ON AuthActiveSessions(SessionTokenHash);
CREATE INDEX IDX_AuthActiveSessions_ExpiresAt ON AuthActiveSessions(ExpiresAt);
CREATE INDEX IDX_AuthActiveSessions_IsActive ON AuthActiveSessions(IsActive) WHERE IsActive = 1;



-- Tabla: AuthAuditLog
-- Propósito: Registrar todas las acciones de autenticación para auditoría
-- Relación: Cada log puede estar asociado a un usuario registrado

CREATE TABLE AuthAuditLog (
    AuditLogId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NULL,
    Action NVARCHAR(100) NOT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    ResourceAffected NVARCHAR(255) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    Timestamp DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    SessionId BIGINT NULL,

    CONSTRAINT FK_AuthAuditLog_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE SET NULL,
    CONSTRAINT FK_AuthAuditLog_Session
        FOREIGN KEY (SessionId) REFERENCES AuthActiveSessions(SessionId) ON DELETE NO ACTION,
    CONSTRAINT CK_AuthAuditLog_ActionType
        CHECK (ActionType IN ('Success', 'Failure', 'Warning', 'Info'))
);

-- Índices
CREATE INDEX IDX_AuthAuditLog_UserId ON AuthAuditLog(UserId);
CREATE INDEX IDX_AuthAuditLog_Action ON AuthAuditLog(Action);
CREATE INDEX IDX_AuthAuditLog_Timestamp ON AuthAuditLog(Timestamp);
CREATE INDEX IDX_AuthAuditLog_IpAddress ON AuthAuditLog(IpAddress);
CREATE INDEX IDX_AuthAuditLog_ActionType ON AuthAuditLog(ActionType);







-- Tabla: AuthAuditLog
-- Propósito: Registrar todas las acciones de autenticación para auditoría
-- Relación: Cada log puede estar asociado a un usuario registrado

CREATE TABLE AuthAuditLog (
    AuditLogId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NULL,
    Action NVARCHAR(100) NOT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    IpAddress NVARCHAR(45) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    ResourceAffected NVARCHAR(255) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    Timestamp DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    SessionId BIGINT NULL,

    CONSTRAINT FK_AuthAuditLog_RegisterUser
        FOREIGN KEY (UserId) REFERENCES RegisterUser(UsrIdUser) ON DELETE SET NULL,
    CONSTRAINT FK_AuthAuditLog_Session
        FOREIGN KEY (SessionId) REFERENCES AuthActiveSessions(SessionId) ON DELETE NO ACTION,
    CONSTRAINT CK_AuthAuditLog_ActionType
        CHECK (ActionType IN ('Success', 'Failure', 'Warning', 'Info'))
);

-- Índices
CREATE INDEX IDX_AuthAuditLog_UserId ON AuthAuditLog(UserId);
CREATE INDEX IDX_AuthAuditLog_Action ON AuthAuditLog(Action);
CREATE INDEX IDX_AuthAuditLog_Timestamp ON AuthAuditLog(Timestamp);
CREATE INDEX IDX_AuthAuditLog_IpAddress ON AuthAuditLog(IpAddress);
CREATE INDEX IDX_AuthAuditLog_ActionType ON AuthAuditLog(ActionType);




--- ACTUALIZACIÓN DE DESCRIPCIONES DE CAMPOS DE TABLAS EXISTENTES ---
--- ES POSIBLE QUE ALGUNOS FALLEN PORQUE YA EXISTEN LAS DESCRIPCIONES PERO DEBENM SER REEMPLAZADOS ---
exec sp_updateextendedproperty 'MS_Description', N'Descripción e la suscripción', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'SubscriptionDescription'
go

exec sp_updateextendedproperty 'MS_Description', 'Precio normal del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'SubscriptionCost'
go

exec sp_updateextendedproperty 'MS_Description', N'Canidad máxima de servicios incluídos', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'SubscriptionMaxServiceFixedValue'
go

exec sp_updateextendedproperty 'MS_Description', N'Tiempo máximo de uso del paquete (expresado en meses)', 'SCHEMA',
     'dbo', 'TABLE', 'CatSubscription', 'COLUMN', 'SubscriptionValidity'
go

exec sp_updateextendedproperty 'MS_Description', N'Peso máximo incluído en el paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'SubscriptionWeight'
go

exec sp_updateextendedproperty 'MS_Description', 'Estado el registro', 'SCHEMA', 'dbo', 'TABLE', 'CatSubscription',
     'COLUMN', 'RowStatus'
go

exec sp_updateextendedproperty 'MS_Description', 'Token del creador del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'TokenCreated'
go

exec sp_updateextendedproperty 'MS_Description', N'Fecha de creación del regisro del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'DateCreated'
go

exec sp_updateextendedproperty 'MS_Description', N'Token de la última modificación del paquete', 'SCHEMA', 'dbo',
     'TABLE', 'CatSubscription', 'COLUMN', 'TokenUpdated'
go

exec sp_updateextendedproperty 'MS_Description', N'Fecha de última modificación del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'DateUpdated'
go

exec sp_updateextendedproperty 'MS_Description', 'Icono del paquete', 'SCHEMA', 'dbo', 'TABLE', 'CatSubscription',
     'COLUMN', 'Icon'
go

exec sp_updateextendedproperty 'MS_Description', 'Banner del paquete', 'SCHEMA', 'dbo', 'TABLE', 'CatSubscription',
     'COLUMN', 'NextSalesPackageBanner'
go

exec sp_updateextendedproperty 'MS_Description', 'Identificador del tipo de suscripcion', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'CatTypeSubscriptionId'
go

exec sp_updateextendedproperty 'MS_Description', N'Identificador de la categoría del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'CatProductCategoryId'
go

exec sp_updateextendedproperty 'MS_Description', 'Etiquetas del paquete', 'SCHEMA', 'dbo', 'TABLE', 'CatSubscription',
     'COLUMN', 'Tag'
go

exec sp_updateextendedproperty 'MS_Description', N'Posición de orden entre los demás registros del paquete', 'SCHEMA',
     'dbo', 'TABLE', 'CatSubscription', 'COLUMN', 'Position'
go

exec sp_updateextendedproperty 'MS_Description', N'Identificador del país del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'IdCountry'
go

exec sp_updateextendedproperty 'MS_Description', 'Identificador de la moneda del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'IdCatCurrencyCOD'
go









--- Se agregan campos nuevos a tablas CatSubscription y Membership
alter table dbo.CatSubscription
    add Draft bit default 0
go

exec sp_addextendedproperty 'MS_Description', 'Indica si su estatus es borrador y no publicado', 'SCHEMA', 'dbo',
     'TABLE', 'CatSubscription', 'COLUMN', 'Draft'
go

alter table dbo.CatSubscription
    add StartDate datetime
go

exec sp_addextendedproperty 'MS_Description', 'Fecha de inicio del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'StartDate'
go

alter table dbo.CatSubscription
    add EndDate datetime
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de finalización del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatSubscription', 'COLUMN', 'EndDate'
go

alter table dbo.CatSubscription
    add SubscriptionUsualPrice decimal(18, 2)
go

exec sp_addextendedproperty 'MS_Description',
     N'Precio habitual de la suscripción (sin descuento, se puede considerar como el precio normal)', 'SCHEMA', 'dbo',
     'TABLE', 'CatSubscription', 'COLUMN', 'SubscriptionUsualPrice'
go


UPDATE dbo.CatSubscription SET SubscriptionUsualPrice = SubscriptionCost;







alter table dbo.CatMembership
    add Draft bit default 0
go

exec sp_addextendedproperty 'MS_Description', 'Indica si su estatus es borrador y no publicado', 'SCHEMA', 'dbo',
     'TABLE', 'CatMembership', 'COLUMN', 'Draft'
go

alter table dbo.CatMembership
    add StartDate datetime
go

exec sp_addextendedproperty 'MS_Description', 'Fecha de inicio del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatMembership', 'COLUMN', 'StartDate'
go

alter table dbo.CatMembership
    add EndDate datetime
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de finalización del paquete', 'SCHEMA', 'dbo', 'TABLE',
     'CatMembership', 'COLUMN', 'EndDate'
go

alter table dbo.CatMembership
    add MembershipUsualPrice decimal(18, 2)
go

exec sp_addextendedproperty 'MS_Description',
     N'Precio habitual de la suscripción (sin descuento, se puede considerar como el precio normal)', 'SCHEMA', 'dbo',
     'TABLE', 'CatMembership', 'COLUMN', 'MembershipUsualPrice'
go

alter table dbo.CatSubscription
    add PermanentlyDisabled bit default 0 not null
go

exec sp_addextendedproperty 'MS_Description',
     N'Desactiva e producto de forma permanente en la tienda pública, pero no crea impedimento a quienes ya comparon este producto',
     'SCHEMA', 'dbo', 'TABLE', 'CatSubscription', 'COLUMN', 'PermanentlyDisabled'
go


alter table dbo.CatMembership
    add PermanentlyDisabled bit default 0 not null
go

exec sp_addextendedproperty 'MS_Description',
     N'Desactiva e producto de forma permanente en la tienda pública, pero no crea impedimento a quienes ya comparon este producto',
     'SCHEMA', 'dbo', 'TABLE', 'CatMembership', 'COLUMN', 'PermanentlyDisabled'
go





-- Preparativos para separar los precios normal y con descuento
UPDATE dbo.CatSubscription SET SubscriptionUsualPrice = SubscriptionCost;
UPDATE dbo.CatMembership SET MembershipUsualPrice = MembershipCost;
UPDATE dbo.CatSubscription SET PermanentlyDisabled=0;
UPDATE dbo.CatMembership SET PermanentlyDisabled=0;





CREATE TABLE dbo.ProductChangeHistory (
    IdChangeHistory BIGINT IDENTITY(1,1) NOT NULL,
    EntityType NVARCHAR(50) NOT NULL,
    EntityId INT NOT NULL,
    ParentEntityId INT NULL,
    EntityName NVARCHAR(200) NULL,
    FieldName NVARCHAR(100) NOT NULL,
    FieldLabel NVARCHAR(100) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    ChangeType NVARCHAR(20) NOT NULL,
    ChangedByUserId NVARCHAR(50) NOT NULL,
    ChangedByUserName NVARCHAR(100) NULL,
    ChangeTimestamp DATETIME2(3) NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT PK_ProductChangeHistory PRIMARY KEY CLUSTERED (IdChangeHistory)
);
GO

-- 3. Índices para performance
CREATE NONCLUSTERED INDEX IX_ProductChangeHistory_EntityType_EntityId
ON dbo.ProductChangeHistory (EntityType, EntityId)
INCLUDE (ChangeTimestamp, ChangeType);

CREATE NONCLUSTERED INDEX IX_ProductChangeHistory_ParentEntityId
ON dbo.ProductChangeHistory (ParentEntityId)
WHERE ParentEntityId IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_ProductChangeHistory_ChangedByUserId
ON dbo.ProductChangeHistory (ChangedByUserId);

CREATE NONCLUSTERED INDEX IX_ProductChangeHistory_ChangeTimestamp
ON dbo.ProductChangeHistory (ChangeTimestamp DESC);
GO

PRINT 'Tabla ProductChangeHistory creada exitosamente (sin constraints)';
GO

