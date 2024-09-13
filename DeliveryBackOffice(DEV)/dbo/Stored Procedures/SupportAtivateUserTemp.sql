CREATE PROCEDURE [dbo].[SupportAtivateUserTemp] 
AS
BEGIN

   UPDATE dbo.RegisterUser 
SET UsrRowStatus =1
WHERE UsrIdUser = 24206
 
UPDATE dbo.UserSystemRestriction
SET	 UstStatus ='ACTIVE'
WHERE UstIdUser = 24206
 
 
UPDATE dbo.RolByUserBySystem
SET RusRowStatus =1
WHERE RusIdUser = 24206

UPDATE dbo.Person
SET PerRowStatus =1
WHERE PerIdPerson = 24068
END;