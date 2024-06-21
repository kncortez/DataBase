/*   Procedimiento para crear usuarios  */
/*No es obligatorio ejecutarlos, es para crear usuarios de prueba Linehaul*/

EXECUTE  DenariusUser_Dev.[dbo].[spc_gestion_usuario_interno] @CODIGO='100100',@CONTRASEÑA='vFv0umnLOr5z3Fk3xH2n7g==',@EXWEB=1, @EXDESKTOP=1 , @IdCountry='GT'



EXEC dbo.SupportCreatNewDesktopUser @Code = 100100     -- int
                                  , @User = N'carlos.valdes'    -- nvarchar(50)
                                  , @Token = N'SYS-EVASQUEZ'   -- nvarchar(50)
                                  , @rol = 12					-- int
                                  , @idStation = 2 --98 -- int


/*Si ya existe el usuario crear el registro con rol 25 (Admin Hermes Mobile) y systema 12 (Hermes Mobile)*/

SELECT * FROM dbo.RolByUserBySystem
WHERE RusIdUser = 10861


