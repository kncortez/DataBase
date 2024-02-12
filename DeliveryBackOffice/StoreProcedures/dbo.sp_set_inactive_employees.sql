-- =============================================
-- Author:		<Carlos Cano>
-- Create date: <2024-01-26>
-- Description:	<Inactivaci�n de usuarios para empleados de baja>
-- =============================================
CREATE PROCEDURE [dbo].[sp_set_inactive_employees]
-- Add the parameters for the stored procedure here
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    /*****
	DEFINICION DE TABLAS
	1. y 2. DenariusDesktop_Dev.dbo.LGT_INF_Employee = Listado de personal activo/inactivo en Denarius
	3. DeliveryBackOffice.dbo.InternalUser = Homologa la informaci�n de colaboradores Denarius a Hermes (con c�digo, usuario y contrase�a)
	4. DeliveryBackOffice.dbo.RegisterUser = Tabla maestra de usuarios (excepto los couriers)
	5. DeliveryBackOffice.dbo.Person = Registro personal de usuarios de la tabla maestra de RegisterUser (excepto los couriers)
	6. DeliveryBackOffice.dbo.UserSystemRestriction = Status de usuarios Hermes x sistema
	7. DeliveryBackOffice.dbo.SenderReceiver = Listado de couriers
	8. DenariusUser_Dev.dbo.LGN_Restriction = Status de usuarios Denarius x sistema
	9. DeliveryBackOffice.dbo.RolByUserBySystem = 3 campos de llave for�nea (buscar llave for�nea)
	*****/


    -- Insert statements for procedure here
    BEGIN TRANSACTION;

    BEGIN TRY

        /**********************************************************************************************************/
        /**** TABLA 01 PARA ENCONTRAR SOLO LOS EMPLEADOS DE BAJA EN CASH, QUE SE DEBEN DAR DE BAJA EN DELIVERY ****/
        /**********************************************************************************************************/
        PRINT 'TABLA 01';

        /************************ PREPARACI�N *************************************/
        -- ALMACENA TODOS LOS EMPLEADOS DE FORZA DELIVERY QUE EST�N EN LA BASE DE DATOS PRODUCTIVA DE CASH
        DECLARE @Tbl130100 TABLE
        (
            Ficha VARCHAR(8) NOT NULL,
            NombreCompleto VARCHAR(100) NOT NULL,
            DPI VARCHAR(25) NULL,
            Estado INT NOT NULL
        );

        -- ALMACENA SOLO LAS BAJAS DE EMPLEADOS DE FORZA DELIVERY QUE EST�N EN CASH
        DECLARE @TblSource TABLE
        (
            --IdEmployee INT NOT NULL,          -- Ac� no se guardar� porque difiere del de Hermes porque en esta solo se insertan los de Delivery
            CodeEmployee VARCHAR(8) NOT NULL, -- N�mero de ficha del colaborador
            NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado seg�n Denarius
            DPI VARCHAR(25) NULL,             -- DPI seg�n Denarius
            StatusJob INT NOT NULL            -- Estado laboral = 2 para las bajas que se deben registrar en las tablas siguientes
        );

        -- TODOS LOS EMPLEADOS DE FORZA DELIVERY EXPRESS QUE EST�N EN EL SERVIDOR 130.100
        INSERT INTO @Tbl130100

        --PRODUCCI�N EN EL SERVIDOR 3.200
        SELECT emp.CodeEmployee,
               emp.FirstName + ' ' + emp.SecondName + ' ' + emp.LastName1 + ' ' + emp.LastName2,
               emp.DPI,
               emp.StatusJob
        FROM [HOP_LINKEDSERVER].DenariusDesktop_Dev.dbo.LGT_INF_Employee emp WITH (NOLOCK)
        WHERE emp.IdCountry = 'GX'; -- Forza Delivery Express

        --PRUEBAS EN EL SERVIDOR 6.210
        /*SELECT [CodeEmployee],
               [NameEmployee],
               [DPI],
               [StatusJob]
        FROM [DenariusDesktop_Dev].[dbo].[rrhh denarius] WITH (NOLOCK);*/



        INSERT INTO @TblSource
        SELECT empBaja.Ficha,          -- CodeEmployee
               empBaja.NombreCompleto, -- NameEmployee
               empBaja.DPI,            -- DPI
               empBaja.Estado          -- StatusJob
        FROM @Tbl130100 empBaja
            LEFT JOIN @Tbl130100 empAlta
                ON empAlta.Estado = 1 -- empleado de alta
                   AND
                   (
                       empAlta.DPI = empBaja.DPI
                       OR empAlta.NombreCompleto = empBaja.NombreCompleto
                   )
        WHERE empBaja.Estado = 2 -- empleado de baja
              AND empAlta.DPI IS NULL -- remover empleados con status de alta (left excluding join)
        ORDER BY empBaja.NombreCompleto ASC;

        --SELECT * FROM @TblSource

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_LGT_INF_Employees_Cash
        SELECT CodeEmployee,
               NameEmployee,
               DPI,
               StatusJob,
               GETDATE()
        FROM @TblSource;




        /**************************************************************************/
        /*** TABLA 02 PARA ENCONTRAR EMPLEADOS COINCIDENTES DE CASH EN DELIVERY ***/
        /**************************************************************************/
        PRINT 'TABLA 02';

        /************************ PREPARACI�N *************************************/
        DECLARE @TblEmployees TABLE
        (
            IdEmployee INT NOT NULL,          -- ID de registro interno en la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Cash
            CodeEmployee VARCHAR(8) NOT NULL, -- N�mero de ficha del colaborador
            NameEmployee VARCHAR(100) NULL,   -- Nombre de empleado seg�n Denarius
            DPI VARCHAR(25) NULL,             -- DPI seg�n Denarius
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
            INNER JOIN @TblSource cash
                ON cash.CodeEmployee = emp.CodeEmployee
        ORDER BY emp.CodeEmployee ASC;


        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_LGT_INF_Employees_Delivery
        SELECT IdEmployee,
               CodeEmployee,
               NameEmployee,
               DPI,
               StatusJob,
               GETDATE()
        FROM @TblEmployees
        WHERE StatusJob = 1; -- listar solo empleados activos


        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee WHERE codeemployee = @Ficha
        UPDATE DenariusDesktop_Dev.dbo.LGT_INF_Employee
        SET StatusJob = 2
        FROM @TblEmployees t
        WHERE t.CodeEmployee = LGT_INF_Employee.CodeEmployee
              AND LGT_INF_Employee.StatusJob = 1;
        --SELECT * FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee WHERE codeemployee = @Ficha




        /******************************************************************************/
        /*** TABLA 03 PARA RELACIONAR USUARIOS DE DENARIUS CON USUARIOS DE DELIVERY ***/
        /******************************************************************************/
        PRINT 'TABLA 03';

        /************************ PREPARACI�N *************************************/
        DECLARE @TblInternalUser TABLE
        (
            IdUser BIGINT NOT NULL,         -- N�mero de ficha del colaborador
            Username NVARCHAR(50) NOT NULL, -- Nombre de usuario para iniciar sesi�n
            IdEmployee INT NULL,            -- ID de registro interno de la tabla LGT_Inf_Employee de DenariusDesktop_Dev en Hermes, puede ser nulo porque hay usuarios de empleados para otros sistemas
            RegisterUserID BIGINT NOT NULL, -- ID de registro for�neo de la tabla RegisterUser en InternalUser de DeliveryBackOffice
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
                ON CONVERT(BIGINT, t.CodeEmployee) = iu.IdUser; -- Relacionar por el n�mero de ficha, el IdUser de InternalUser es la ficha de empleado

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_InternalUser
        SELECT IdUser,
               Username,
               IdEmployee,
               RegisterUserID,
               RowStatus,
               GETDATE()
        FROM @TblInternalUser
        WHERE RowStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.InternalUser WHERE IdEmployee = @EmployeeID
        UPDATE DeliveryBackOffice.dbo.InternalUser
        SET RowStatus = 0,
            TokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
            DateUpdated = GETDATE()
        FROM @TblInternalUser t
        WHERE t.IdUser = InternalUser.IdUser
              AND t.Username = InternalUser.Username
              AND InternalUser.RowStatus = 1;
        --SELECT * FROM DeliveryBackOffice.dbo.InternalUser WHERE IdEmployee = @EmployeeID




        /******************************************************************************/
        /****** TABLA 04 PARA GUARDAR LA INFORMACI�N DE LOS USUARIOS DE DELIVERY ******/
        /******************************************************************************/
        PRINT 'TABLA 04';

        /************************ PREPARACI�N *************************************/
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

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_RegisterUser
        SELECT UsrIdUser,
               UsrIdPerson,
               UserEmail,
               RowStatus,
               GETDATE()
        FROM @TblRegisterUser
        WHERE RowStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.RegisterUser WHERE UsrIdUser = @InternalUser
        UPDATE DeliveryBackOffice.dbo.RegisterUser
        SET UsrRowStatus = 0,
            UsrTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
            UsrDateUpdated = GETDATE()
        FROM @TblRegisterUser t
        WHERE t.UsrIdUser = RegisterUser.UsrIdUser
              AND RegisterUser.UsrRowStatus = 1;
        --SELECT * FROM DeliveryBackOffice.dbo.RegisterUser WHERE UsrIdUser = @InternalUser




        /******************************************************************************/
        /****** TABLA 05 PARA GUARDAR LA INFORMACI�N DE LAS PERSONAS DE DELIVERY ******/
        /******************************************************************************/
        PRINT 'TABLA 05';

        /************************ PREPARACI�N *************************************/
        DECLARE @TblPerson TABLE
        (
            PerIdPerson BIGINT NOT NULL,        -- 
            PerFirstName VARCHAR(100) NOT NULL, -- Primer Nombre
            PerLastName VARCHAR(100) NOT NULL,  -- Primer Apellido
                                                -- PerIdentification VARCHAR(50) NOT NULL, -- CUI / DPI (no se guardar� porque los datos no tienen control de calidad)
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

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_Person
        SELECT PerIdPerson,
               PerFirstName,
               PerLastName,
               PerRowStatus,
               GETDATE()
        FROM @TblPerson
        WHERE PerRowStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.Person WHERE PerIdPerson = @InternalUser
        UPDATE DeliveryBackOffice.dbo.Person
        SET PerRowStatus = 0,
            PerTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
            PerDateUpdated = GETDATE()
        FROM @TblPerson t
        WHERE t.PerIdPerson = Person.PerIdPerson
              AND Person.PerRowStatus = 1;
        --SELECT * FROM DeliveryBackOffice.dbo.Person WHERE PerIdPerson = @InternalUser



        /******************************************************************************/
        /******** TABLA 06 PARA GESTIONAR LOS PERMISOS POR M�DULO DE SISTEMAS *********/
        /******************************************************************************/
        PRINT 'TABLA 06';

        /************************ PREPARACI�N *************************************/
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

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_UserSystemRestriction
        SELECT UstIdRestriction,
               UstIdUser,
               UstIdSystem,
               UstStatus,
               UstRowStatus,
               GETDATE()
        FROM @TblUserSystemRestriction
        WHERE UstStatus = 'ACTIVE'
              OR UstRowStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.UserSystemRestriction WHERE UstIdUser = @InternalUser
        UPDATE DeliveryBackOffice.dbo.UserSystemRestriction
        SET UstRowStatus = 0,
            UstStatus = 'INACTIVE',
            UstTokenCreated = 'SYS-SUSPENSION-EMPLOYEE',
            UstOperationDate = GETDATE()
        FROM @TblUserSystemRestriction t
        WHERE t.UstIdUser = UserSystemRestriction.UstIdUser
              AND
              (
                  UserSystemRestriction.UstStatus = 'ACTIVE'
                  OR UserSystemRestriction.UstRowStatus = 1
              );
        --SELECT * FROM DeliveryBackOffice.dbo.UserSystemRestriction WHERE UstIdUser = @InternalUser



        /******************************************************************************/
        /************ TABLA 07 PARA GESTIONAR LOS PERMISOS PARA COURIERS **************/
        /******************************************************************************/
        PRINT 'TABLA 07';

        /************************ PREPARACI�N *************************************/
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
            INNER JOIN @TblSource t
                ON t.DPI = sr.CUI;

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_SenderReceiver
        SELECT SenRecID,
               SenRecFirstName,
               SenRecLastName,
               SenRecCUI,
               SenRecStatus,
               GETDATE()
        FROM @TblSenderReceiver
        WHERE SenRecStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.SenderReceiver WHERE CUI = @CUI
        UPDATE DeliveryBackOffice.dbo.SenderReceiver
        SET Estatus = 0,
            User_Created = 'SYS-SUSPENSION-EMPLOYEE',
            Date_Created = GETDATE()
        FROM @TblSenderReceiver t
        WHERE t.SenRecCUI = SenderReceiver.CUI
              AND SenderReceiver.Estatus = 1;
        --SELECT * FROM DeliveryBackOffice.dbo.SenderReceiver WHERE CUI = @CUI


        /******************************************************************************/
        /**** TABLA 08 PARA GESTIONAR LOS PERMISOS POR M�DULO DE SISTEMAS (LEGACY) ****/
        /******************************************************************************/
        PRINT 'TABLA 08';

        /************************ PREPARACI�N *************************************/
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

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_LGN_Restriction
        SELECT RstIdUser,
               RstUsername,
               RstIdSystem,
               RstStatus,
               GETDATE()
        FROM @TblRestriction
        WHERE RstStatus = 'ACTIVE';

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DenariusUser_Dev.dbo.LGN_Restriction WHERE RST_IdUser = @Ficha AND RST_Username = @Username
        UPDATE DenariusUser_Dev.dbo.LGN_Restriction
        SET RST_Status = 'INACTIVE',
            LGN_OperationToken = 'SYS-SUSPENSION-EMPLOYEE',
            LGN_OperationDate = GETDATE()
        FROM @TblRestriction t
        WHERE t.RstIdUser = LGN_Restriction.RST_IdUser
              AND t.RstUsername = LGN_Restriction.RST_Username
              AND LGN_Restriction.RST_Status = 'ACTIVE';
        --SELECT * FROM DenariusUser_Dev.dbo.LGN_Restriction WHERE RST_IdUser = @Ficha AND RST_Username = @Username


        /***************************************************************************************/
        /**** TABLA 09 PARA GESTIONAR LOS PERMISOS POR ROL POR USUARIO POR SISTEMA (LEGACY) ****/
        /***************************************************************************************/
        PRINT 'TABLA 09';

        /************************ PREPARACI�N *************************************/
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

        /************************* BIT�CORA ***************************************/
        INSERT INTO DenariusLog_Dev.dbo.HSE_RolByUserBySystem
        SELECT RusIdSystem,
               RusIdUser,
               RusRowStatus,
               GETDATE()
        FROM @TblRolByUserBySystem
        WHERE RusRowStatus = 1;

        /********************** ACTUALIZACI�N ************************************/
        --SELECT * FROM DeliveryBackOffice.dbo.RolByUserBySystem WHERE RusIdUser = @InternalUser
        UPDATE DeliveryBackOffice.dbo.RolByUserBySystem
        SET RusRowStatus = 0,
            RusTokenUpdated = 'SYS-SUSPENSION-EMPLOYEE',
            RusDateUpdated = GETDATE()
        FROM @TblRolByUserBySystem t
        WHERE t.RusIdUser = RolByUserBySystem.RusIdUser
              AND RolByUserBySystem.RusRowStatus = 1;
        --SELECT * FROM DeliveryBackOffice.dbo.RolByUserBySystem WHERE RusIdUser = @InternalUser

        COMMIT TRANSACTION;

        SELECT 1 'StatusCode',
               'Operaci�n exitosa.' 'Description';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT 0 'StatusCode',
               ERROR_MESSAGE() 'Description';
    END CATCH;
END;
GO


