SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-04>
-- Description:	<Obitene una lista de los roles que posee un usuario por medio del idUser>
-- =============================================
CREATE PROCEDURE sphdGetRolesbyUserId
	@idUser int
AS
BEGIN
        select 
        	rus.RusIdUser,
        	rus.RusIdRol,
        	rus.StationId,
        	cr.RolName,
        	cr.RolDescription,
        	cr.RolAdminBrothers,
        	cr.RolAdminClient,
        	cr.RolAdminInternal
        from dbo.RolByUserBySystem rus 
        Inner Join InternalUser IU on  rus.RusIdUser= IU.RegisterUserID and IU.RowStatus=1
        inner join CatRol cr on rus.RusIdRol=cr.RolIdRol and cr.RolRowStatus=1
        where rus.RusRowStatus=1 and IU.IdUser=@idUser
END
GO
