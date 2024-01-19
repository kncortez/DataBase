/*****
DEFINICION DE TABLAS
DenariusDesktop_Dev.dbo.LGT_INF_Employee = Listado de personal activo/inactivo en Denarius
DeliveryBackOffice.dbo.InternalUser = Homologa la información de colaboradores Denarius a Hermes (con código, usuario y contraseña)
DeliveryBackOffice.dbo.RegisterUser = Tabla maestra de usuarios (excepto los couriers)
DeliveryBackOffice.dbo.Person = Registro personal de usuarios de la tabla maestra de RegisterUser (excepto los couriers)
DeliveryBackOffice.dbo.UserSystemRestriction = Status de usuarios Hermes x sistema
DeliveryBackOffice.dbo.SenderReceiver = Listado de couriers
DenariusUser_Dev.dbo.LGN_Restriction = Status de usuarios Denarius x sistema
DeliveryBackOffice.dbo.RolByUserBySystem = 3 campos de llave foránea (buscar llave foránea)
*****/

/**********************************************************************************************************/
/**** TABLA 01 PARA ENCONTRAR SOLO LOS EMPLEADOS DE BAJA EN CASH, QUE SE DEBEN DAR DE BAJA EN DELIVERY ****/
/**********************************************************************************************************/

DECLARE @TblEmpFDE TABLE -- ALMACENA TODOS LOS EMPLEADOS DE FORZA DELIVERY QUE ESTÁN EN CASH
(
    Ficha VARCHAR(8) NOT NULL,
    NombreCompleto VARCHAR(100) NOT NULL,
    DPI VARCHAR(25) NULL,
    Estado INT NOT NULL
); -- 1,236

INSERT INTO @TblEmpFDE -- todos los empleados de Forza Delivery Express
SELECT emp.CodeEmployee,
       emp.FirstName + ' ' + emp.SecondName + ' ' + emp.LastName1 + ' ' + emp.LastName2,
       emp.DPI,
       emp.StatusJob
FROM [HOP_LINKEDSERVER].DenariusDesktop_Dev.dbo.LGT_INF_Employee emp WITH (NOLOCK)
WHERE 1 = 1
      AND emp.IdCountry = 'GX' -- Forza Delivery Express
	  --AND emp.CodeEmployee IN ('110049','110113','106333','110610');
	  --AND emp.CodeEmployee IN ('102340')


DECLARE @TblCash TABLE -- ALMACENA SOLO LAS BAJAS DE EMPLEADOS DE FORZA DELIVERY QUE ESTÁN EN CASH
(
    --IdEmployee INT NOT NULL,          -- Acá no se guardará porque difiere del de Hermes porque en esta solo se insertan los de Delivery
    CodeEmployee VARCHAR(8) NOT NULL, -- Número de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado según Denarius
    DPI VARCHAR(25) NULL              -- DPI según Denarius
    --StatusJob INT NOT NULL            -- Estado laboral = 2 para las bajas que se deben registrar en las tablas siguientes
);

INSERT INTO @TblCash
SELECT empBaja.Ficha,          -- CodeEmployee
       empBaja.NombreCompleto, -- NameEmployee
       empBaja.DPI             -- DPI
FROM @TblEmpFDE empBaja
    LEFT JOIN @TblEmpFDE empAlta
        ON empAlta.Estado = 1 -- empleado de alta
           AND
           (
               empAlta.DPI = empBaja.DPI
               OR empAlta.NombreCompleto = empBaja.NombreCompleto
           )
WHERE empBaja.Estado = 2 -- empleado de baja
      AND empAlta.DPI IS NULL -- remover empleados con status de alta (left excluding join)
ORDER BY empBaja.NombreCompleto ASC;


/*INSERT INTO @TblCash
SELECT --DISTINCT
       emp.CodeEmployee,
       emp.FirstName + ' ' + emp.SecondName + ' ' + emp.LastName1 + ' ' + emp.LastName2,
       emp.DPI
FROM [HOP_LINKEDSERVER].DenariusDesktop_Dev.dbo.LGT_INF_Employee emp WITH (NOLOCK)
WHERE 1 = 1
      AND emp.StatusJob = 2 -- 1 = empleado de alta; 2 = empleado de baja;
      AND emp.IdCountry = 'GX' -- GX = Forza Delivery Express
ORDER BY emp.CodeEmployee ASC;*/

/*INSERT INTO @TblCash
SELECT [CodeEmployee],
       [NameEmployee],
       [DPI]
FROM [DenariusDesktop_Dev].[dbo].[rrhh denarius] WITH (NOLOCK)
WHERE DPI IN ('1970738670101','2247072132101','2096977681609','2345724262001','2344323140101','2755294870601','2500270541312','3050493210117','2259191410101','1623311420101','1593142590101')
;*/


SELECT *
FROM @TblCash
ORDER BY NameEmployee ASC;


/**************************************************************************/
/*** TABLA 02 PARA ENCONTRAR EMPLEADOS COINCIDENTES DE CASH EN DELIVERY ***/
/**************************************************************************/
DECLARE @TblEmployees TABLE
(
    IdEmployee INT NOT NULL,          -- ID de registro interno en la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Cash
    CodeEmployee VARCHAR(8) NOT NULL, -- Número de ficha del colaborador
    NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado según Denarius
    DPI VARCHAR(25) NULL,             -- DPI según Denarius
    StatusJob SMALLINT NOT NULL       -- Estado laboral = 1 activo; 2 = inactivo
);

INSERT INTO @TblEmployees
SELECT --DISTINCT
    emp.IdEmployee,
    emp.CodeEmployee,
    emp.FirstName + ' ' + emp.SecondName + ' ' + emp.LastName1 + ' ' + emp.LastName2,
    emp.DPI,
    emp.StatusJob
FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee emp WITH (NOLOCK)
    INNER JOIN @TblCash cash
        ON cash.CodeEmployee = emp.CodeEmployee
ORDER BY emp.CodeEmployee ASC;

SELECT *
FROM @TblEmployees
WHERE StatusJob = 1 -- listar solo empleados activos
ORDER BY NameEmployee ASC;

--UPDATE DenariusDesktop_Dev.dbo.LGT_INF_Employee
--SET StatusJob = 2
--FROM @TblEmployees t
--WHERE t.CodeEmployee = LGT_INF_Employee.CodeEmployee
--AND LGT_INF_Employee.StatusJob = 1;



/******************************************************************************/
/*** TABLA 03 PARA RELACIONAR USUARIOS DE DENARIUS CON USUARIOS DE DELIVERY ***/
/******************************************************************************/
DECLARE @TblInternalUser TABLE
(
    IdUser BIGINT NOT NULL,         -- Número de ficha del colaborador
    Username NVARCHAR(50) NOT NULL, -- Nombre de usuario para iniciar sesión
    IdEmployee INT NULL,            -- ID de registro interno de la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Hermes, puede ser nulo porque hay usuarios de empleados para otros sistemas
    RegisterUserID BIGINT NOT NULL, -- ID de registro foráneo de la tabla RegisterUser en InternalUser de DeliveryBackOffice
    RowStatus BIT NULL              -- Estado del registro 1 = activo ; 0 = inactivo
);

INSERT INTO @TblInternalUser
SELECT --DISTINCT
    iu.IdUser,
    iu.Username,
    iu.IdEmployee,
    iu.RegisterUserID,
    iu.RowStatus
FROM DeliveryBackOffice.dbo.InternalUser iu WITH (NOLOCK)
    INNER JOIN @TblEmployees t
        ON CONVERT(BIGINT, t.CodeEmployee) = iu.IdUser; -- Relacionar por el número de ficha, el IdUser de InternalUser es la ficha de empleado

SELECT *
FROM @TblInternalUser
WHERE RowStatus = 1
ORDER BY RegisterUserID;

--UPDATE DeliveryBackOffice.dbo.InternalUser
--SET RowStatus = 0,
--    TokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
--    DateUpdated = GETDATE()
--FROM @TblInternalUser t
--WHERE t.IdEmployee = InternalUser.IdEmployee
--      AND InternalUser.RowStatus = 1;


/******************************************************************************/
/****** TABLA 04 PARA GUARDAR LA INFORMACIÓN DE LOS USUARIOS DE DELIVERY ******/
/******************************************************************************/
DECLARE @TblRegisterUser TABLE
(
    UsrIdUser BIGINT NOT NULL,       -- 
    UsrIdPerson BIGINT NOT NULL,     -- 
    UserEmail VARCHAR(200) NOT NULL, --
    RowStatus BIT NOT NULL           -- Estado del registro 1 = activo ; 0 = inactivo
);

INSERT INTO @TblRegisterUser
SELECT --DISTINCT
    ru.UsrIdUser,
    ru.UsrIdPerson,
    ru.UsrEmail,
    ru.UsrRowStatus
FROM DeliveryBackOffice.dbo.RegisterUser ru WITH (NOLOCK)
    INNER JOIN @TblInternalUser t
        ON t.RegisterUserID = ru.UsrIdUser; -- RegisterUserID de InternalUser

SELECT *
FROM @TblRegisterUser
WHERE RowStatus = 1
ORDER BY UsrIdUser;

--UPDATE DeliveryBackOffice.dbo.RegisterUser
--SET UsrRowStatus = 0,
--    UsrTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
--    UsrDateUpdated = GETDATE()
--FROM @TblRegisterUser t
--WHERE t.UsrIdUser = RegisterUser.UsrIdUser
--      AND RegisterUser.UsrRowStatus = 1;


/******************************************************************************/
/****** TABLA 05 PARA GUARDAR LA INFORMACIÓN DE LAS PERSONAS DE DELIVERY ******/
/******************************************************************************/
DECLARE @TblPerson TABLE
(
    PerIdPerson BIGINT NOT NULL,        -- 
    PerFirstName VARCHAR(100) NOT NULL, -- Primer Nombre
    PerLastName VARCHAR(100) NOT NULL,  -- Primer Apellido
                                        --PerIdentification VARCHAR(50) NOT NULL, -- CUI / DPI (no se guardará porque los datos no tienen control de calidad)
    PerRowStatus BIT NULL               -- Estado del registro 1 = activo ; 0 = inactivo
);

INSERT INTO @TblPerson
SELECT --DISTINCT
    p.PerIdPerson,
    p.PerFirstName,
    p.PerLastName,
    p.PerRowStatus
FROM DeliveryBackOffice.dbo.Person p WITH (NOLOCK)
    INNER JOIN @TblRegisterUser t
        ON t.UsrIdPerson = p.PerIdPerson; -- 

SELECT *
FROM @TblPerson
WHERE PerRowStatus = 1
ORDER BY PerIdPerson;

--UPDATE DeliveryBackOffice.dbo.Person
--SET PerRowStatus = 0,
--    PerTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
--    PerDateUpdated = GETDATE()
--FROM @TblPerson t
--WHERE t.PerIdPerson = Person.PerIdPerson
--      AND Person.PerRowStatus = 1;



/******************************************************************************/
/******** TABLA 06 PARA GESTIONAR LOS PERMISOS POR MÓDULO DE SISTEMAS *********/
/******************************************************************************/
DECLARE @TblUserSystemRestriction TABLE
(
    UstIdRestriction BIGINT NOT NULL, -- 
    UstIdUser BIGINT NOT NULL,        -- 
    UstIdSystem INT NOT NULL,         -- 
    UstStatus VARCHAR(10) NOT NULL,   -- 
    UstRowStatus BIT NOT NULL         -- 
);

INSERT INTO @TblUserSystemRestriction
SELECT --DISTINCT
    usr.UstIdRestriction,
    usr.UstIdUser,
    usr.UstIdSystem,
    usr.UstStatus,
    usr.UstRowStatus
FROM DeliveryBackOffice.dbo.UserSystemRestriction usr
    INNER JOIN @TblRegisterUser t
        ON t.UsrIdUser = usr.UstIdUser;

SELECT *
FROM @TblUserSystemRestriction
WHERE UstStatus = 'ACTIVE'
      OR UstRowStatus = 1
ORDER BY UstIdUser;

--UPDATE DeliveryBackOffice.dbo.UserSystemRestriction
--SET UstRowStatus = 0,
--    UstStatus = 'INACTIVE',
--    UstTokenCreated = 'SYS-SUSPENSION-EMPLOYEE',
--    UstOperationDate = GETDATE()
--FROM @TblUserSystemRestriction t
--WHERE t.UstIdUser = UserSystemRestriction.UstIdUser
--      AND
--      (
--          UserSystemRestriction.UstStatus = 'ACTIVE'
--          OR UserSystemRestriction.UstRowStatus = 1
--      );



/******************************************************************************/
/************ TABLA 07 PARA GESTIONAR LOS PERMISOS PARA COURIERS **************/
/******************************************************************************/
DECLARE @TblSenderReceiver TABLE
(
    SenRecID INT NOT NULL,                 -- 
    SenRecFirstName VARCHAR(100) NOT NULL, -- 
    SenRecLastName VARCHAR(100) NOT NULL,  -- 
    SenRecCUI VARCHAR(25) NULL,            -- 
    SenRecStatus BIT NULL                  --
);

INSERT INTO @TblSenderReceiver
SELECT --DISTINCT
    sr.ID,
    sr.First_Name,
    sr.Last_Name,
    sr.CUI,
    sr.Estatus
FROM DeliveryBackOffice.dbo.SenderReceiver sr
    INNER JOIN @TblCash t
        ON t.DPI = sr.CUI;

SELECT *
FROM @TblSenderReceiver
WHERE SenRecStatus = 1
ORDER BY SenRecCUI;

--UPDATE DeliveryBackOffice.dbo.SenderReceiver
--SET Estatus = 0,
--    User_Created = 'SYS-SUSPENSION-EMPLOYEE',
--    Date_Created = GETDATE()
--FROM @TblSenderReceiver t
--WHERE t.SenRecCUI = SenderReceiver.CUI
--      AND SenderReceiver.Estatus = 1;


/******************************************************************************/
/**** TABLA 08 PARA GESTIONAR LOS PERMISOS POR MÓDULO DE SISTEMAS (LEGACY) ****/
/******************************************************************************/
DECLARE @TblRestriction TABLE
(
    RstIdUser VARCHAR(50) NOT NULL,   -- 
    RstUsername VARCHAR(50) NOT NULL, -- 
    RstIdSystem INT NOT NULL,         -- 
    RstStatus VARCHAR(8) NOT NULL     -- 
);

INSERT INTO @TblRestriction
SELECT --DISTINCT
    r.RST_IdUser,
    r.RST_Username,
    r.RST_IdSystem,
    r.RST_Status
FROM DenariusUser_Dev.dbo.LGN_Restriction r
    INNER JOIN @TblInternalUser t
        ON t.IdUser = r.RST_IdUser
           AND t.Username = r.RST_Username;

SELECT *
FROM @TblRestriction
WHERE RstStatus = 'ACTIVE'
ORDER BY RstIdUser,
         RstUsername;

--UPDATE DenariusUser_Dev.dbo.LGN_Restriction
--SET RST_Status = 'INACTIVE',
--    LGN_OperationToken = 'SYS-SUSPENSION-EMPLOYEE',
--    LGN_OperationDate = GETDATE()
--FROM @TblRestriction t
--WHERE t.RstIdUser = LGN_Restriction.RST_IdUser
--      AND t.RstUsername = LGN_Restriction.RST_Username
--      AND LGN_Restriction.RST_Status = 'ACTIVE';



/***************************************************************************************/
/**** TABLA 09 PARA GESTIONAR LOS PERMISOS POR ROL POR USUARIO POR SISTEMA (LEGACY) ****/
/***************************************************************************************/
DECLARE @TblRolByUserBySystem TABLE
(
    RusIdSystem VARCHAR(50) NOT NULL, -- 
    RusIdUser VARCHAR(50) NOT NULL,   -- 
    RusRowStatus INT NOT NULL         -- 
);

INSERT INTO @TblRolByUserBySystem
SELECT --DISTINCT
    rbubs.RusIdSystem,
    rbubs.RusIdUser,
    rbubs.RusRowStatus
FROM DeliveryBackOffice.dbo.RolByUserBySystem rbubs
    INNER JOIN @TblRegisterUser t
        ON t.UsrIdUser = rbubs.RusIdUser;

SELECT *
FROM @TblRolByUserBySystem
WHERE RusRowStatus = 1
ORDER BY RusIdUser;

--UPDATE DeliveryBackOffice.dbo.RolByUserBySystem
--SET RusRowStatus = 0,
--    RusTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
--    RusDateUpdated = GETDATE()
--FROM @TblRolByUserBySystem t
--WHERE t.RusIdUser = RolByUserBySystem.RusIdUser
--      AND RolByUserBySystem.RusRowStatus = 1;