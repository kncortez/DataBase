USE DenariusLog_Dev;

/* TABLA 1 */ SELECT * FROM dbo.HSE_LGT_INF_Employees_Cash ORDER BY recorddate, NameEmployee DESC;
/* TABLA 2 */ SELECT * FROM dbo.HSE_LGT_INF_Employees_Delivery ORDER BY recorddate, NameEmployee DESC;
/* TABLA 3 */ SELECT * FROM dbo.HSE_InternalUser ORDER BY recorddate, RegisterUserID;
/* TABLA 4 */ SELECT * FROM dbo.HSE_RegisterUser ORDER BY recorddate, UsrIdUser;
/* TABLA 5 */ SELECT * FROM dbo.HSE_Person ORDER BY recorddate, PerIdPerson;
/* TABLA 6 */ SELECT * FROM dbo.HSE_UserSystemRestriction ORDER BY recorddate, UstIdUser;
/* TABLA 7 */ SELECT * FROM dbo.HSE_SenderReceiver ORDER BY recorddate, SenRecCUI;
/* TABLA 8 */ SELECT * FROM dbo.HSE_LGN_Restriction ORDER BY recorddate, RstIdUser, RstUsername;
/* TABLA 9 */ SELECT * FROM dbo.HSE_RolByUserBySystem ORDER BY recorddate, RusIdUser

/*
DECLARE @Ficha VARCHAR(8) = '102340'
DECLARE @EmployeeID INT = 4605
DECLARE @IdUser INT = 8065

UPDATE DenariusDesktop_Dev.dbo.LGT_INF_Employee  SET StatusJob = 1 WHERE codeemployee = @Ficha
UPDATE DeliveryBackOffice.dbo.InternalUser SET RowStatus = 1 WHERE InternalUser.IdEmployee = @EmployeeID
UPDATE DeliveryBackOffice.dbo.RegisterUser SET UsrRowStatus = 0 WHERE RegisterUser.UsrIdUser = @IdUser

SELECT *
FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee where CodeEmployee = '105346'

SELECT *
FROM DeliveryBackOffice.dbo.InternalUser
WHERE USERNAME IN ('mharlon.laing','hector.chacon','karla.jacome')
--WHERE t.IdEmployee = InternalUser.IdEmployee AND InternalUser.RowStatus = 1;

SELECT *
FROM DeliveryBackOffice.dbo.InternalUser
where rowstatus = 1

*/


/*
DELETE dbo.HSE_LGT_INF_Employees_Cash
DELETE dbo.HSE_LGT_INF_Employees_Delivery
DELETE dbo.HSE_InternalUser
DELETE dbo.HSE_RegisterUser
DELETE dbo.HSE_Person
DELETE dbo.HSE_UserSystemRestriction
DELETE dbo.HSE_SenderReceiver
DELETE dbo.HSE_LGN_Restriction
DELETE dbo.HSE_RolByUserBySystem
*/



/*SELECT TOP 100 * FROM DenariusUser_Dev.dbo.LGN_LogByToken
SELECT TOP 100 * FROM DeliveryBackOffice.dbo.GeneratedTokens
SELECT TOP 100  * FROM DeliveryBackOffice.dbo.TokenLog ORDER BY TknDateCreated DESC
SELECT TOP 100 * FROM DeliveryBackOffice.dbo.SenderReceiver WHERE ID = 2070 ORDER BY Date_Created DESC*/