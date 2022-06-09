CREATE PROCEDURE dbo.usp_ExportImage (
   @PicName NVARCHAR (100)
   ,@ImageFolderPath NVARCHAR(1000)
   ,@Filename NVARCHAR(1000)
   )
AS
BEGIN
   DECLARE @ImageData VARBINARY (max);
   DECLARE @Path2OutFile NVARCHAR (2000);
   DECLARE @Obj INT
   print ('paso por aca')
 
   SET NOCOUNT ON
 
   SELECT @ImageData = (
         SELECT convert (VARBINARY (max), Proof_incident, 1)
         FROM DeliveryProof
         WHERE Guide_Number = 610343
         );

Print (@ImageData)
    print ('paso por aca tambien')
   SET @Path2OutFile = CONCAT (
         @ImageFolderPath
         ,'\'
         , @Filename
         );

		 print(@Path2OutFile)
    BEGIN TRY
	print ('aqui paso1')
     EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT;
	 print ('aqui paso2')
     EXEC sp_OASetProperty @Obj ,'Type',1;
	 print ('aqui paso3')
     EXEC sp_OAMethod @Obj,'Open';
	 print ('aqui paso4')
     EXEC sp_OAMethod @Obj,'Write', NULL, @ImageData;
	 print ('aqui paso5')
     EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @Path2OutFile, 2;
     EXEC sp_OAMethod @Obj,'Close';
     EXEC sp_OADestroy @Obj;
	 print ('aqui paso6')
    END TRY
    
 BEGIN CATCH
  --EXEC sp_OADestroy @Obj;
 END CATCH
 
   SET NOCOUNT OFF
END
