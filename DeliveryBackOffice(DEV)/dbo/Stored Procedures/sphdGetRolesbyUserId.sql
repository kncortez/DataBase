
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-04>
-- Description:	<Obitene una lista de los roles que posee un usuario por medio del idUser>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRolesbyUserId]
	@idUser int
AS
BEGIN
SET ARITHABORT ON
IF EXISTS(
        select 
        1
        from  InternalUser IU WITH(NOLOCK)
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
        from dbo.RolByUserBySystem rus  WITH(NOLOCK)
        Inner Join InternalUser IU WITH(NOLOCK) on  rus.RusIdUser= IU.RegisterUserID 
        inner join CatRol cr WITH(NOLOCK) ON rus.RusIdRol=cr.RolIdRol 
        where IU.IdUser=@idUser and rus.RusRowStatus=1
		and IU.RowStatus=1
		AND cr.RolRowStatus=1 --BNHL 15/11/2024
		;

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
