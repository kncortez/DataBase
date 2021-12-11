USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sphdGetRolesbyUserId]    Script Date: 10/12/2021 15:49:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-04>
-- Description:	<Obitene una lista de los roles que posee un usuario por medio del idUser>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetRolesbyUserId]
	@idUser int
AS
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
			IU.SaleAdvisorID
        from dbo.RolByUserBySystem rus 
        Inner Join InternalUser IU on  rus.RusIdUser= IU.RegisterUserID and IU.RowStatus=1
        inner join CatRol cr on rus.RusIdRol=cr.RolIdRol and cr.RolRowStatus=1
        where IU.IdUser=@idUser and rus.RusRowStatus=1
END
GO


