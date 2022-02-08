
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,08-02-2022,>
-- Description:	<Description, Modificar rol de usuario de express center>
-- =============================================
CREATE PROCEDURE [dbo].[SpModifyRolUserExpressCenter]
 @RolName NVARCHAR(100)= '', -- nombre del rol que se encuentra en la tabla CatRol
 @Email NVARCHAR(100) ='' -- correo dle usuario de express

AS
BEGIN

	SET NOCOUNT ON;

UPDATE DeliveryBackOffice.dbo.RolByUserByAccount
      SET RuaIdRol = (SELECT RolIdRol 
	                         FROM DeliveryBackOffice.dbo.CatRol 
							      WHERE RolName = @RolName )
           WHERE RuaIdUser = (
                                SELECT UsrIdUser 
								      FROM DeliveryBackOffice.dbo.RegisterUser
                                           WHERE UsrEmail = @Email)

END
GO
