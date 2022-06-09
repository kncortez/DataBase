CREATE PROCEDURE spgs_ActivateUserPortal
@UstIdUser bigint,
@Type int = 1,
@TokenCreated nvarchar(50),
@Mail nvarchar(100) = ''
as 
begin 
if (@Type = 1) --CONSULTA
BEGIN
 select 
 UstRetries,
 UstStatus,
 UstTokenCreated,
 UstDateCreated
 ,ru.UsrEmail
 ,*
from DeliveryBackOffice.dbo.UserSystemRestriction USR
left join DeliveryBackOffice.dbo.RegisterUser RU ON USR.UstIdUser = RU.UsrIdUser
 where --UstIdUser = @UstIdUser 
 --and 
 iif(@Mail is not null,RU.UsrEmail,@Mail) =  @Mail
END
else if (@Type = 2) --EDICIÓN
BEGIN
 update DeliveryBackOffice.dbo.UserSystemRestriction
 SET
 UstRetries = 0,
 UstStatus = 'ACTIVE',
 UstTokenCreated = @TokenCreated,
 UstDateCreated= GETDATE()
 where UstIdUser = @UstIdUser
END 
END