-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-07-07>
-- Description:	<Sp para dar de baja usuario corporativos>
-- =============================================

CREATE PROCEDURE [dbo].[SupportGetStatusCorporateUser] @InternalUser INT
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM dbo.InternalUser it WITH (NOLOCK)
        WHERE it.IdUser = @InternalUser
    )
    BEGIN

        DECLARE @idRegister INT;
        DECLARE @idCustemer INT;
		DECLARE @idPerson INT;



        SELECT @idRegister = it.RegisterUserID, @idPerson = rg.UsrIdPerson
        FROM dbo.InternalUser it WITH (NOLOCK)
			INNER JOIN dbo.RegisterUser rg WITH(NOLOCK) ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @InternalUser;

        SELECT @idCustemer = vp.CustomerID
        FROM dbo.VisitPointClient vp WITH (NOLOCK)
        WHERE vp.CodeOfReference = @InternalUser;


        SELECT 'InternalUser' [Tabla]
             , it.IdUser
             , it.Username
             , it.RegisterUserID
             , it.RowStatus
			 , it.Comment
        FROM dbo.InternalUser it WITH (NOLOCK)
        WHERE it.IdUser = @InternalUser;

        SELECT 'RolByUserBySystem' [Tabla]
             , RusIdUser
             , RusRowStatus
        FROM dbo.RolByUserBySystem WITH (NOLOCK)
        WHERE RusIdUser = @idRegister;




        SELECT 'RegisterUser' [Tabla]
             , rg.UsrIdUser
             , rg.UsrIdPerson
             , rg.UsrEmail
             , rg.UsrRowStatus
             , rg.UsrLastPassword
        FROM dbo.RegisterUser rg WITH (NOLOCK)
        WHERE rg.UsrIdUser = @idRegister;


		SELECT 'Person' [Tabla], pr.* FROM dbo.Person pr WITH(NOLOCK)
		WHERE pr.PerIdPerson = @idPerson



        SELECT 'UserSystemRestriction' [Tabla]
             , *
        FROM dbo.UserSystemRestriction rst WITH (NOLOCK)
        WHERE UstIdUser = @idRegister;


        SELECT 'VisitPointClient' [Tabla]
             , vp.CodeOfReference
             , vp.DescriptionOfClient
             , vp.StatusClient
        FROM dbo.VisitPointClient vp WITH (NOLOCK)
        WHERE CodeOfReference = @InternalUser;


        SELECT 'Customer' [Tabla]
             , cs.IdCustomer
             , cs.Name
             , cs.RowSatus
        FROM dbo.Customer cs WITH (NOLOCK)
        WHERE cs.IdCustomer = @idCustemer;
    END;
    ELSE
    BEGIN
        SELECT 'Usuario no exite ';
    END;
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportGetStatusCorporateUser] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportGetStatusCorporateUser] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportGetStatusCorporateUser] TO [cvaldes]
    AS [dbo];

