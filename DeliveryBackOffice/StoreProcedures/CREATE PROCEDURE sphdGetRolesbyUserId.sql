-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
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
        where IU.IdUser=@idUser and rus.RusRowStatus=1
END
GO
