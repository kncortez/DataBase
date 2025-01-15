/***************INSERTAR NUEVOS MODULOS A ROLES A LA TABLA RolByModuleBySystem PARA LOS CLIENTES INDIVIDUALES ********************/
DECLARE @CustomerType INT = (
                                SELECT IdCustomerType FROM CustomerType WHERE Description = 'INDIVIDUAL'
                            )
DECLARE @ModuleId INT = (
                            SELECT ModIdModule FROM CatModule WHERE ModName = 'Link de entrega'
                        )

INSERT INTO RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsModuleMenu
)

SELECT RuaIdRol,
       1,
       @ModuleId,
       1,
       'SYS-CSUAZO',
       GETDATE(),
       1
FROM
(
    SELECT DISTINCT
        RBU.RuaIdRol
    FROM RegisterUser RU WITH (NOLOCK)
        INNER JOIN RolByUserByAccount RBU WITH (NOLOCK)
            ON RU.UsrIdUser = RBU.RuaIdUser
        INNER JOIN Account AC WITH (NOLOCK)
            ON RBU.RuaIdAccount = AC.AccIdAccount
        INNER JOIN Customer CU WITH (NOLOCK)
            ON CU.IdCustomer = AC.IdCustomer
    WHERE CU.IdCustomerType = @CustomerType 
          AND RU.UsrRowStatus = 1
          AND RBU.RuaRowStatus = 1
          AND AC.AccRowStatus = 1
--AND CU.RowSatus = 1
) DataRol