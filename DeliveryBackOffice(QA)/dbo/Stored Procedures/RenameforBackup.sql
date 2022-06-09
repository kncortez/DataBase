
CREATE PROCEDURE [dbo].RenameforBackup
		 @name varchar(200)
		,@bktag varchar(200)
		,@type int
AS
BEGIN
DECLARE @fullnamebk VARCHAR(200) =  CONCAT(@name,'_',@bktag);
  DECLARE @sql varchar(64);
  SET @sql = ' DROP PROCEDURE  dbo.' + @name;
/*
	type 1 = RENOMBRADO PARA OBTENER COPIA DE SEGURIDAD
	type 2 = SE PROCEDE A REALIZAR ROLLBACK
*/
IF @type = 1
BEGIN
IF EXISTS (SELECT
			*
		FROM sysobjects
		WHERE Id = OBJECT_ID(N'[dbo].'+ @name)
		AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
BEGIN
      EXEC sp_rename @name, @fullnamebk;
END

	END
	IF @type = 2
BEGIN	
IF EXISTS (SELECT
			*
		FROM sysobjects
		WHERE Id = OBJECT_ID(N'[dbo].'+ @fullnamebk)
		AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
BEGIN
	 

	  EXEC(@sql);  --ELIMINA EL SP QUE SE HABÍA MODIFICADO, DEBIDO A QUE SE PROCEDE CON ROLLBACK
	  
      EXEC sp_rename @fullnamebk,@name;
END
END
END
