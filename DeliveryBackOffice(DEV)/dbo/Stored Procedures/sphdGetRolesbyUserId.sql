
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-04>
-- Description:	<Obitene una lista de los roles que posee un usuario por medio del idUser>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRolesbyUserId]
	@idUser int
AS
BEGIN

IF EXISTS(
        select 
        1
        from  InternalUser IU 
        where IU.IdUser=@idUser)

		BEGIN
		 select 
        	rus.RusIdUser IdUser,
        	rus.RusIdRol Rol,
        	rus.StationId Station,
        	cr.RolName	,
        	cr.RolDescription ,
        	cr.RolAdminBrothers,
        	cr.RolAdminClient,
        	cr.RolAdminInternal,
			4 RusIdRol ,
			/*IU.SaleAdvisorID*/0 SaleAdvisorID
        from dbo.RolByUserBySystem rus 
        Inner Join InternalUser IU on  rus.RusIdUser= IU.RegisterUserID and IU.RowStatus=1
        inner join CatRol cr on rus.RusIdRol=cr.RolIdRol and cr.RolRowStatus=1
        where IU.IdUser=@idUser and rus.RusRowStatus=1;

		END;

		ELSE
		 select 
        	1,--@idUser IdUser,
        	4 Rol,
        	-1 Station,
        	'' RolName	,
        	'' RolDescription ,
        	0 RolAdminBrothers,
        	0 RolAdminClient,
        	0 RolAdminInternal,
			4 RusIdRol ,
			/*IU.SaleAdvisorID*/0 SaleAdvisorID
        
END;
