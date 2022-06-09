
create proc [dbo].[SPG_InsertRolByUserByRegion]
@IdRol int,
@IdUser varchar(50),
@UserName int

as
begin
insert into DenariusUser_Dev.dbo.LGN_RolByUserByRegion
values (@IdRol, @IdUser,'-1','GT', @UserName,'TRUE')
end
