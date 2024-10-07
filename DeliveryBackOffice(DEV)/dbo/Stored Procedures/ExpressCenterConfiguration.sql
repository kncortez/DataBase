
-- =====================================================================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-05-17>
-- Description:	<Se crea un SP para que los compañeros de soporte
--				 puedan asociar el código de empleado a una cuenta en el portal web 
--				 junto a su respectivo Express Center>
-- =====================================================================================


--EXEC ExpressCenterConfiguration 7751,'','mako.a.jm@gmail.com',366,'SYS-MJIMENEZ'


CREATE PROCEDURE [dbo].[ExpressCenterConfiguration]
    @USR_IdEmployee AS BIGINT = 0
  , @USR_IdUser AS NVARCHAR(50) = '0'
  , @UserName AS VARCHAR(100)
  , @IdVisitPoint AS INT
  , @Token AS NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IdEmployee AS BIGINT = 0;
    DECLARE @IdUser AS NVARCHAR(50) = N'0';
    DECLARE @USR_Username AS VARCHAR(50) = '';
    DECLARE @ERROR AS BIT = 'FALSE';
    DECLARE @IdUser_Portal AS BIGINT = 0;
    BEGIN TRY
        BEGIN TRANSACTION;


        IF (@USR_IdEmployee != 0)
           AND
           (
               @USR_IdUser != '0'
               OR @USR_IdUser != ''
           )
        BEGIN
            PRINT 'SELECT 1';

            PRINT @USR_IdEmployee;
            PRINT @USR_IdUser;

            SELECT TOP 1
                   @IdUser       = USR_IdUser
                 , @USR_Username = USR_Username
                 , @IdEmployee   = USR_IdEmployee
            FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
            WHERE USR_IdUser = @USR_IdEmployee
                  AND USR_Username = @USR_IdUser;


            PRINT @IdUser;
            PRINT @USR_Username;
            PRINT @IdEmployee;
        END;
        ELSE
        BEGIN
            PRINT 'ERROR 1';
            SET @ERROR = 'TRUE'; --SE ASIGNA VALOR TRUE DEBIDO A QUE NO SE PUEDE CONTINUAR CON EL PROCESO
        END;
        PRINT '@ERROR';
        PRINT @ERROR;
        PRINT @IdUser;
        PRINT @USR_Username;
        IF @ERROR = 'FALSE'
           AND @IdUser != 0
           AND @USR_Username != '0' --AND @IdEmployee != 0
        BEGIN
            PRINT @ERROR;
            PRINT @IdUser;
            PRINT @USR_Username;
            -- SE OBTIENE EL IDUSER DEL PORTAL 
            SET @IdUser_Portal =
            (
                SELECT TOP 1
                       ru.UsrIdUser
                FROM DeliveryBackOffice.dbo.RegisterUser ru
                WHERE ru.UsrEmail = @UserName
                      AND ru.UsrRowStatus = 1
            );

            PRINT '@IdUser_Portal';
            PRINT @IdUser_Portal;

            --INSERTAR EN TABLA INTERMEDIA PARA ASOCIAR EL CÓDIGO EMPLEADO CON LA CUENTA DE PORTAL WEB
            IF NOT EXISTS
            (
                SELECT *
                FROM DeliveryBackOffice.dbo.InternalUser iu
                WHERE iu.IdUser = @IdUser_Portal
            )
            BEGIN

                PRINT 'No existe el empleado ';
                PRINT @USR_IdEmployee;
                INSERT INTO dbo.InternalUser
                (
                    IdUser
                  , Username
                  , IdEmployee
                  , RegisterUserID
                  , RowStatus
                  , TokenCreated
                  , DateCreated
                  , TokenUpdated
                  , DateUpdated
                )
                SELECT @IdUser
                     , @USR_Username
                     , @IdEmployee
                     , ru.UsrIdUser
                     , 1
                     , @Token
                     , GETDATE()
                     , NULL
                     , NULL
                FROM DeliveryBackOffice.dbo.RegisterUser ru
                WHERE ru.UsrEmail = @UserName;


            END;


            --SE ASIGNA EL ROL DE EXPRESS CENTER
            UPDATE DeliveryBackOffice.dbo.RolByUserByAccount
            SET RuaIdRol =
                (
                    SELECT RolIdRol
                    FROM CatRol
                    WHERE RolName = 'ADMINISTRACION Y CIERRES EXC PORTAL WEB'
                          AND RolIdSystem = 1
                )
            WHERE RuaIdUser = @IdUser_Portal;

            --SE ASOCIA EL USUARIO A UN EXPRESS CENTER
            --De existir una asociación, se NO se inserta.
            IF NOT EXISTS
            (
                SELECT *
                FROM DeliveryBackOffice.dbo.[VisitPointByUser]
                WHERE IdVisitPointClient = @IdVisitPoint
                      AND RegisterUserID = @IdUser_Portal
            )
            BEGIN
                INSERT INTO DeliveryBackOffice.dbo.[VisitPointByUser]
                VALUES
                (@IdVisitPoint, @IdUser_Portal, 1, @Token, GETDATE(), NULL, NULL);

                --SE CONFIGURA EL NOMBRE Y DESCRIPCION DE EXRESS CENTER 
                UPDATE Customer
                SET Name = 'FD EXPRESS CENTER'
                  , Description = 'FD EXPRESS CENTER'
                  , Abbreviation = 'FD EXPRESS CENTER'
                  , IdCustomerType = 2
                WHERE IdCustomer =
                (
                    SELECT ac.IdCustomer
                    FROM RegisterUser                         us
                        INNER JOIN [dbo].Person               pe
                            ON pe.PerIdPerson = us.UsrIdPerson
                               AND pe.PerRowStatus = 1
                        INNER JOIN [dbo].[RolByUserByAccount] rua
                            ON rua.RuaIdUser = us.UsrIdUser
                               AND rua.RuaRowStatus = 1
                        INNER JOIN [dbo].CatRol               ro
                            ON ro.RolIdRol = rua.RuaIdRol
                        INNER JOIN [dbo].Account              ac
                            ON ac.AccIdAccount = rua.RuaIdAccount
                               AND ac.AccRowStatus = 1
                        INNER JOIN [dbo].CatTypeAccount       ta
                            ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                    WHERE us.UsrIdUser = @IdUser_Portal
                          AND us.UsrRowStatus = 1
                );
            END;

            UPDATE ac
            SET ac.AccConfirm = 'C'
              , ac.AccTokenUpdated = @Token
              , ac.AccDateUpdated = GETDATE()
            FROM RegisterUser                 ru
                INNER JOIN RolByUserByAccount rbuba
                    ON rbuba.RuaIdUser = ru.UsrIdUser
                INNER JOIN Account            ac
                    ON ac.AccIdAccount = rbuba.RuaIdAccount
            WHERE ru.UsrIdUser = @IdUser_Portal;

            COMMIT TRANSACTION;
            SELECT 200                             AS ResultCode
                 , 'Cuenta asociada correctamente' AS [Description];
        END;


        ELSE
        BEGIN
            SET @ERROR = 'TRUE';
            ROLLBACK TRANSACTION;
        END;



    END TRY
    BEGIN CATCH

        SELECT ERROR_MESSAGE()
             , ERROR_LINE()
             , ERROR_NUMBER()
             , ERROR_STATE();
        ROLLBACK TRANSACTION;

    END CATCH;




END;



