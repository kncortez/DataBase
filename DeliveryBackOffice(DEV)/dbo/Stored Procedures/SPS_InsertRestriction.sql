
create proc [dbo].[SPS_InsertRestriction]
@IdUser nvarchar(50),
@UserName varchar(50),
@IdSystem int

as
begin
insert into DenariusUser_Dev.dbo.LGN_Restriction
values (@IdUser, @UserName, @IdSystem, 10,'ACTIVE',0,GETDATE(),NULL,NULL,NULL)
end