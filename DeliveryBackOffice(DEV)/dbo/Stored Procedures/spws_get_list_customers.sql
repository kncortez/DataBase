-- =============================================
-- Author:		<Alfredo, Monroy>
-- Create date: <2021-08-25>
-- Description:	<Devuelve una lista de clientes tanto corporativos como individuales segun filtros aplicados>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_customers]
    @Token VARCHAR(200) = '*',
    @Name VARCHAR(100)  = '*',
    @Code INT = 0,
    @Email VARCHAR(50) = '*',
	@DPI VARCHAR(50) = '*'

AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);

IF NOT EXISTS
(
    SELECT 1
    FROM DeliveryBackOffice.dbo.TokenLog
    WHERE TknRowStatus = 1
            AND TknIdToken = @Token
            AND CAST(TknDateCreated AS DATE) = CAST(GETDATE() AS DATE)
)
BEGIN
    PRINT 'token inválido';

    SET @jsonResult =
    (
        SELECT STUFF(
                        (
                            SELECT ',{"IdError":' + '500' + ',' + '"DescriptionError":"' + 'Token inválido'
                                    + '"' + '}'
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );
    SELECT '[' + @jsonResult + ']' FormatJson;

    RETURN;
END;

SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT TOP 100
									',{"Id":"' + CONVERT(NVARCHAR, ISNULL(cu.IdCustomer, 0)) + '",'
									-- titulo: IdCustomer ???
									+ '"IdCustomerType":"' + CONVERT(NVARCHAR, ISNULL(cu.IdCustomerType, 0)) + '",'
									+ '"IdAccount":"' + CONVERT(NVARCHAR, ISNULL(ac.AccIdAccount, 0)) + '",'
									+ '"IdUser":"' + CONVERT(NVARCHAR, ISNULL(rub.RuaIdUser, 0)) + '",'
									+ '"Name":"' + REPLACE(cu.[Name], '"','')  + '",'
									+ '"Phone":"'+(CASE WHEN cu.IdCustomerType = 1 THEN ISNULL([CustomerPhone],'') ELSE ISNULL(ru.Phone,'') END) + '",'
								    + '"Email":"'+(CASE WHEN cu.IdCustomerType = 1 THEN ISNULL([ContactEmail],'') ELSE ISNULL(ru.UsrEmail,'') END) + '",'
								    + '}'
								FROM DeliveryBackOffice.dbo.Customer cu
									LEFT JOIN DeliveryBackOffice.dbo.Account ac ON cu.IdCustomer = ac.IdCustomer --LAMM
									LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rub ON rub.RuaIdAccount = ac.AccIdAccount --LAMM
									LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru ON rub.RuaIdUser = ru.UsrIdUser  --LAMM
									LEFT JOIN DeliveryBackOffice.dbo.Person p ON p.PerIdPerson = ru.UsrIdPerson  --LAMM
								WHERE
									cu.IdCustomerType in (1,3)
									-- AND cu.RowSatus = 1
									-- AND RowSatus = 1 ??
									AND ((@Name = '') OR (REPLACE(cu.[Name], '"','') like ('%'+@Name+'%')))
									AND ((@Code = 0)  OR (@Code = cu.IdCustomer))
									--AND ((@Email = '') OR (@Email = (CASE WHEN cu.IdCustomerType = 1 THEN ISNULL([ContactEmail],'') ELSE ru.UsrEmail END)))
									AND ((@Email = '') OR (@Email = ru.UsrEmail))
									AND ((@DPI = '') OR (@DPI = p.PerIdentification))
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

 SELECT ('[' + @jsonResult + ']') jsonResult;

END;
