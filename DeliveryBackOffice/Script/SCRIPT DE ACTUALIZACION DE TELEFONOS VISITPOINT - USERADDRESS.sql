--SCRIPT DE ACTUALIZACION DE TELEFONO DESDE TABLA VisitPointClient A  UserAddress (USUARIOS INDIVIDUALES)
BEGIN
BEGIN TRANSACTION

		BEGIN TRY
			--LIMPIEZA DE TELEFONOS CON FORMATO '(502)00000000' -> 00000000 EN VISITPOINTCLIENT
			---------------------------------------------------------------------
			DECLARE @regexPhoneNumber varchar(max)='[(][0-9][0-9][0-9][)]%';		
			--select (CASE WHEN VP.Phone LIKE @regexPhoneNumber THEN SUBSTRING(VP.Phone,6,8) ELSE VP.Phone END)
			UPDATE VP SET
				VP.Phone=(CASE WHEN VP.Phone LIKE @regexPhoneNumber THEN SUBSTRING(VP.Phone,6,8) ELSE VP.Phone END)
			FROM dbo.UserAddress UA 
							left join DBO.VisitPointClient vp on VP.CodeOfReference=UA.CodeOfReference
							left join dbo.Account AC on  ua.UadIdAccount=ac.AccIdAccount -- and vp.CustomerID=ac.IdCustomer 
							where AC.AccIdTypeAccount= (select TacIdTypeAccount from dbo.CatTypeAccount where TacShortName='IND')--FILTRO DE USUARIOS INDIVIDUALES
							and UadRowStatus=1
							and vp.StatusClient=1

			--ACTUALIZACIÓN DE TELEFENOS DE VISITPOINTCLIENT -> USERADDRESS DONDE EL REGISTRO EN VISITPOINTCLIENT ES EL MAS ACTUALIZADO ()
			------------------------------------------------------------------------------------------------------------------------------
			--No. de casos en producción: 93 registros
			UPDATE UA SET
				UA.UadNirPhone='502',
				UA.UadPhone=VP.Phone
				--,UA.UadDateUpdated=GETDATE(),
				--UA.UadTokenUpdated='SYS-ADMIN'
			FROM dbo.UserAddress UA 
							left join DBO.VisitPointClient vp on VP.CodeOfReference=UA.CodeOfReference
							left join dbo.Account AC on  ua.UadIdAccount=ac.AccIdAccount -- and vp.CustomerID=ac.IdCustomer 
							where AC.AccIdTypeAccount= (select TacIdTypeAccount from dbo.CatTypeAccount where TacShortName='IND')--FILTRO DE USUARIOS INDIVIDUALES
							AND UadRowStatus=1
							AND vp.StatusClient=1
							AND VP.Phone IS NOT NULL --TELEFONO DEL REGISTRO ORIGEN NO ES NULL
							AND VP.Phone <>''		 --TELEFONO DEL REGISTRO ORIGEN NO ES TEXTO VACIO
							AND (--APLICARAN LOS REGISTORS QUE CUMPLAN LO SIGUIENTE
								UA.UadPhone =''			--EL TELEFONO EN EL REGISTRO DESTINO ESTA VACÍO
								OR ua.UadPhone IS NULL	--EL TELEFONO EN EL REGISTRO DESTINO ES NULL
								OR vp.DateUpdated>UA.UadDateUpdated  --EL REGISTRO DE VP ES EL MAS ACTUALIZADO
							)
							
							


			--ACTUALIZACIÓN DE TELEFENOS DE USERADDRESS -> VISITPOINTCLIENT  DONDE EL REGISTRO EN USERADDRESS ES EL MAS ACTUALIZADO ()
			------------------------------------------------------------------------------------------------------------------------------
			--No. de casos en producción: 24 registros
			UPDATE VP SET
				VP.Phone=UA.UadPhone
				--,vp.DateUpdated=GETDATE(),
				--VP.TokenCreated='SYS-ADMIN'
			FROM dbo.UserAddress UA 
							left join DBO.VisitPointClient vp on VP.CodeOfReference=UA.CodeOfReference
							left join dbo.Account AC on  ua.UadIdAccount=ac.AccIdAccount -- and vp.CustomerID=ac.IdCustomer 
							where AC.AccIdTypeAccount= (select TacIdTypeAccount from dbo.CatTypeAccount where TacShortName='IND')--FILTRO DE USUARIOS INDIVIDUALES
							AND UadRowStatus=1
							AND vp.StatusClient=1
							AND UA.UadPhone IS NOT NULL --TELEFONO DE REGSITRO ORIGEN NO ES NULL
							AND UA.UadPhone <>''		 --TELEFONO DE REGISTRO ORIGEN NO ES TEXTO VACIO
							AND (--APLICARAN LOS REGISTORS QUE CUMPLAN LO SIGUIENTE
								VP.Phone =''			--EL TELEFONO EN EL REGISTRO DESTINO ESTA VACÍO
								OR VP.Phone  IS NULL	--EL TELEFONO EN EL REGISTRO DESTINO ES NULL
								OR UA.UadDateUpdated>vp.DateUpdated  --EL REGISTRO DE USERADDRESS ES EL MAS ACTUALIZADO
							)

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;
		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION;			
		END
END

