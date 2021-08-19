USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_GuidesByCustomer]    Script Date: 8/3/2021 10:03:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Michael, Espinoza>
-- Create date: <2021-08-02>
-- Description:	<Devuelve el nombre de un cliente individual asi como su IdCustomer>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_CustomerByEmailOrDpi]
    -- Add the parameters for the stored procedure here
    --@StartDate DATETIME,
    --@EndDate DATETIME ,
    @Token VARCHAR(200),
    @Email VARCHAR(50),
    @DPI VARCHAR(50)

AS

BEGIN

DECLARE @IdAccount INT;
DECLARE @IdUser INT;
DECLARE @jsonResult NVARCHAR(MAX);

IF (@Email='')

BEGIN

SELECT TOP 1 @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.Person 
JOIN dbo.RegisterUser ru ON ru.UsrIdPerson = PerIdPerson
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE PerIdentification= @DPI

END

ELSE

BEGIN

SELECT @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.RegisterUser 
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE UsrEmail = @Email

END

SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdAccount":"' + CONVERT(NVARCHAR,ISNULL(@IdAccount, '')) + '",'
										+'"IdUser":"' + CONVERT(NVARCHAR, ISNULL(@IdUser, '')) + '",'
										+'"IdCustomer":"' + CONVERT(NVARCHAR, ISNULL(cu.[IdCustomer], '')) + '",'
										+'"Name":"' + ISNULL(cu.[Name], '') + '",'
										+'"Email":"' + ISNULL(ru.[UsrEmail], '') + '",'
										+'"Phone":"' + ISNULL(ru.[Phone], '') + '"'
                                        +'}'
                                FROM DeliveryBackOffice.dbo.Account ac 
								JOIN DeliveryBackOffice.dbo.Customer cu ON cu.IdCustomer = ac.IdCustomer
								JOIN DeliveryBackOffice.dbo.RegisterUser ru ON ru.UsrIdUser = @IdUser
								WHERE ac.AccIdAccount = @IdAccount
							
                                
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

 SELECT ('[' + @jsonResult + ']') jsonResult;

END;
