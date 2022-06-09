-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2021-11-03>
-- Description:	<Devuelve lista de usuarios por criterio de busqueda>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetUserbyId]
	-- Add the parameters for the stored procedure here
			@IdSystem AS INT = -1,
			@IdRol AS INT = -1,
			@IdEmployee AS INT = -1,
			@CodeUser AS BIGINT = -1,
			@Username AS VARCHAR(50) = '',
			@IdStation AS INT = -1,
			@IdCountry AS NVARCHAR(3)= 'all'
AS
BEGIN
	--devuelve estructura de consulta de usuarios por criterio de busqueda
		SELECT rur.RusIdUser		[IdUser],
			   ius.IdUser			[CodeUser],
			   ius.Username			[Username],
			   rur.RusIdRol			[IdRol],
			   rol.RolName			[NameRol],
			   rur.RusIdSystem		[IdSystem],
			   sis.SysNameSystem	[NameSystem],
			   ius.IdEmployee		[IdEmployee],
			   rus.UsrIdPerson		[IdPerson],
			   rus.UsrNickName		[NickName],
			   rus.UsrEmail			[EmailUser],
			   rur.StationId		[IdStation],
			   CASE cst.StationType 
			   WHEN 1 THEN 'FD HUB ' + UPPER(cst.StationName)	
			   WHEN 2 THEN 'FD EXC ' + UPPER(cst.StationName) 
			   ELSE cst.StationName 
			   END					[NameStation],
			   cct.CountryNameES	[CountryName] ,
			   rur.RusRowStatus		[Status],
			   rua.RuaIdAccount		[IdAccount],
			   acc.IdCustomer		[IdCustomer]
		FROM DeliveryBackOffice.dbo.RolByUserBySystem rur
			JOIN DeliveryBackOffice.dbo.CatRol rol
				ON rol.RolIdRol = rur.RusIdRol
				AND rur.RusRowStatus = 'true'
			JOIN DeliveryBackOffice.dbo.CatSystem sis
				ON sis.SysIdSystem = rol.RolIdSystem
				   AND sis.SysIdSystem = rur.RusIdSystem
			LEFT JOIN DeliveryBackOffice.dbo.CatStation cst
				ON cst.IdStation = rur.StationId
			LEFT JOIN DeliveryBackOffice.dbo.CatCountry cct
				ON cct.IdCountry = cst.CountryId
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rus
				ON rus.UsrIdUser = rur.RusIdUser
			LEFT JOIN DeliveryBackOffice.dbo.InternalUser ius
				ON ius.RegisterUserID = rus.UsrIdUser
			LEFT JOIN dbo.RolByUserByAccount rua 
				ON rua.RuaIdRol = rol.RolIdRol
				AND rua.RuaIdUser = rus.UsrIdUser
			LEFT JOIN dbo.Account acc ON 
				acc.AccIdAccount = rua.RuaIdAccount
		WHERE 1 = 1 ---rur.RusRowStatus = 'TRUE'
			  AND (@IdEmployee = -1 OR ius.IdEmployee = @IdEmployee)
			  AND (@IdSystem = -1 OR sis.SysIdSystem = @IdSystem)
			  AND (@IdRol = -1 OR rol.RolIdRol = @IdRol)
			  AND (@CodeUser = -1 OR ius.IdUser = @CodeUser)
			  AND (@Username = '' OR ius.Username LIKE '%' + @Username + '%')
			  AND (@IdStation = -1 OR cst.IdStation = @IdStation)
			  AND (@IdCountry = 'all' OR (CASE WHEN cst.CountryId IS NULL THEN 'all' ELSE cst.CountryId END) = @IdCountry)


END
