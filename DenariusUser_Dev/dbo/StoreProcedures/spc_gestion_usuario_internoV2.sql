
-- =============================================
-- Author:      <Cristian Azurdia>
-- Create date: <2025-04-22>
-- Description: <Actualizacion para manejo de multipais en roles y estaciones>
-- =============================================

CREATE PROCEDURE [dbo].[spc_gestion_usuario_internoV2] 
     @CODIGO NVARCHAR(100)
    ,@CONTRASEÑA NVARCHAR(MAX)
    ,@EXWEB INT
    ,@EXDESKTOP INT
    ,@IdCountry NVARCHAR(2) = 'GT'
AS
DECLARE
     @IDEMPLO INT = NULL
    ,@IDWEB INT = NULL
    ,@NOMBRE NVARCHAR(100) = NULL
    ,@APELLIDO NVARCHAR(100) = NULL
    ,@IDStation INT
    ,@IdSysWeb INT
    ,@IdSysDesktop INT
    ,@IdRolWeb INT
    ,@IdRolDesktop INT
    ,@AccessRetries INT

    SET @IDEMPLO = (SELECT IdEmployee FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee WHERE CodeEmployee = @CODIGO)
    SET @NOMBRE = (SELECT FirstName FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee WHERE CodeEmployee = @CODIGO)
    SET @APELLIDO = (SELECT LastName1 FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee WHERE CodeEmployee = @CODIGO)
    SET @IdSysDesktop = (SELECT SYS_IdSystem FROM DenariusUser_Dev.dbo.LGN_System WHERE SYS_SystemName = 'Forza Delivery Express' and SYS_Platform = 'Desktop')
    SET @IdSysWeb = (SELECT SYS_IdSystem FROM DenariusUser_Dev.dbo.LGN_System WHERE SYS_SystemName = 'Forza Delivery Express' and SYS_Platform = 'Web')
    SET @IdRolDesktop = (SELECT LGN_IdRol FROM DenariusUser_Dev.dbo.LGN_Rol WHERE LGN_Name = 'PREPARADOR DE RUTA FORZA DELIVERY' and LGN_IdSystem = @IdSysDesktop)
    SET @IdRolWeb = (SELECT LGN_IdRol FROM DenariusUser_Dev.dbo.LGN_Rol WHERE LGN_Name = 'TRA-RASTREO DE GUIAS' and LGN_IdSystem = )
    SET @IDStation = (SELECT STN_IdStation FROM DenariusUser_Dev.dbo.LGN_Station WHERE STN_StationName = 'Todas las estaciones' and STN_IdCountry = @IdCountry)
    SET @AccessRetries = 10 -- Cantidad de intentos

    declare @EMAIL NVARCHAR(200) = concat(lower(@nombre), '.', lower(@APELLIDO), '@forzadelivery.com')

    IF (@IDEMPLO > 0 OR @IDEMPLO IS NOT NULL)
    BEGIN

-- quitar insert por SP
        exec denariusweb_dev.dbo.insert_user_web '-1', @IdCountry, @NOMBRE, @APELLIDO, @EMAIL , 0

        SET @IDWEB =( SELECT MAX(USR_WebClientId) FROM DenariusWeb_Dev.dbo.[User])

            insert into [DenariusUser_Dev].[dbo].[LGN_User]
            values
            (
               @CODIGO
              ,lower(@NOMBRE)+'.'+lower(@APELLIDO)
              ,@CONTRASEÑA
              ,NULL
              ,@IDEMPLO
              ,@IDWEB
              ,0
              ,NULL
              ,lower(@NOMBRE)+'.'+lower(@APELLIDO)+'@forzadelivery.com'
              ,''
              ,GETDATE()+180
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,''
              ,null
              ,NULL 
              ,NULL
              ,NULL
              ,GETDATE()
              ,NULL
              ,NULL
              ,NULL
              ,0
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL -- sE AGREGO POR LAS DUDAS
             )

            IF (@EXDESKTOP = 1 OR @EXWEB = 1)
            BEGIN
                --INGRESO DE SISTEMA WEB (12)
                INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
                VALUES (@IdRolWeb,@CODIGO, @IDStation,@IdCountry ,lower(@NOMBRE)+'.'+lower(@APELLIDO) ,1 )

                INSERT INTO DenariusUser_Dev.dbo.LGN_Restriction 
                VALUES(@CODIGO,lower(@NOMBRE)+'.'+lower(@APELLIDO),@IdSysWeb,@AccessRetries,CASE WHEN @EXWEB = 1 THEN 'ACTIVE'ELSE 'INACTIVE' END ,0,GETDATE(),NULL,NULL,NULL)

                --INGRESO DE SISTEMA DESKTOP (13)
                INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
                VALUES (@IdRolDesktop,@CODIGO,@IDStation,@IdCountry ,lower(@NOMBRE)+'.'+lower(@APELLIDO) ,1 )

                INSERT INTO DenariusUser_Dev.dbo.LGN_Restriction 
                VALUES(@CODIGO,lower(@NOMBRE)+'.'+lower(@APELLIDO),@IdSysDesktop,@AccessRetries,CASE WHEN @EXDESKTOP = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END,0,GETDATE(),NULL,NULL,NULL)
            
            END

            SELECT 
                 USR.USR_IdUser'CODIGO'
                ,USR.USR_Username'USUARIO'
                ,USR.USR_Password'CONTRASEÑA'
                FROM DenariusUser_Dev.dbo.LGN_User USR
            WHERE USR.USR_IdEmployee = @IDEMPLO

END

ELSE
    BEGIN
        SELECT 'REVISEN REGISTRO EN RRRH' AS MENSAJE
    END