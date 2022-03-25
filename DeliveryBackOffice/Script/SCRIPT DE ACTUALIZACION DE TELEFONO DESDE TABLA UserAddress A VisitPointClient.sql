--SCRIPT DE ACTUALIZACION DE TELEFONO DESDE TABLA UserAddress A VisitPointClient (USUARIOS INDIVIDUALES)
BEGIN
BEGIN TRANSACTION

		BEGIN TRY
			UPDATE VP SET
				VP.Phone=CONCAT('(',UA.UadNirPhone,')',UA.UadPhone)	
			FROM DBO.VisitPointClient vp 
				left join dbo.UserAddress UA on VP.CodeOfReference=UA.CodeOfReference
				left join dbo.Account AC on  ua.UadIdAccount=ac.AccIdAccount -- and vp.CustomerID=ac.IdCustomer 
				where AC.AccIdTypeAccount= (select TacIdTypeAccount from dbo.CatTypeAccount where TacShortName='IND')--FILTRO DE USUARIOS INDIVIDUALES
				and UadRowStatus=1
				and vp.StatusClient=1
				AND UA.UadNirPhone IS NOT NULL AND LEN(UA.UadNirPhone)>0 AND UA.UadPhone IS NOT NULL AND LEN(UA.UadPhone)>0 
				--ACTUALIZACIÓN DE TABLA VP EN CASOS DONDE EL CODIGO DE PAIS Y NUMERO NO SON VACIOS EN LA TABLA DE FAVORITOS

			UPDATE VP SET
				VP.Phone=UA.UadPhone
			FROM DBO.VisitPointClient vp 
				left join dbo.UserAddress UA on VP.CodeOfReference=UA.CodeOfReference
				left join dbo.Account AC on  ua.UadIdAccount=ac.AccIdAccount -- and vp.CustomerID=ac.IdCustomer 
				where AC.AccIdTypeAccount= (select TacIdTypeAccount from dbo.CatTypeAccount where TacShortName='IND')--FILTRO DE USUARIOS INDIVIDUALES
				and UadRowStatus=1
				and vp.StatusClient=1
				AND (UA.UadNirPhone IS NULL OR LEN(UA.UadNirPhone)=0) AND (UA.UadPhone IS NOT NULL AND LEN(UA.UadPhone)>0 )
				--ACTUALIZACIÓN DE TABLA VP EN CASOS DONDE EL CODIGO DE PAIS ES VACÍO Y EL NUMERO NO SON VACIOS EN LA TABLA DE FAVORITOS

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

