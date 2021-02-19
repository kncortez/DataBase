USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetCostPickUp]    Script Date: 16/02/2021 11:58:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-16>
-- Description:	<Recotizacion>
-- =============================================


CREATE PROCEDURE [dbo].[SetIncidenceService]
	-- Add the parameters for the stored procedure here
	@ServiceManagementId  INT = 0,
	@IncidenceTypeId   INT = 0,
	@DescriptionIncidence  varchar (200) = 'Problemas de ubicacion',
	@Accuracy    varchar (200) = '44',
	@Latitude varchar  (200) = '55798797342',
	@Longitude varchar  (200) = '546689',
	@Token varchar (200) = '545656asdf564afd',
	@Photos varchar (MAX) = 'jkjadshkjfhjadhflkjads'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

		-- insertar en tabla temporal posbibles mensajes de respuesta
			
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
			select * INTO #responsemessage from (SELECT  200 AS IdResult
					,'Estado  cambiado correctamente' AS Message
					,'OK' as Id 
			union
			SELECT  500 AS IdResult
					,'Error faltal intente de nuevo mas tarde' AS Message
					,'Transac' as Id 
		 )  as errror
	BEGIN TRANSACTION
		BEGIN TRY


					insert into DeliveryBackOffice.dbo.IncidenceServices(ServiceManagementId,IncidenceTypeId, DescriptionIncidence, Latitude, Longitude, Accuracy, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
					values (@ServiceManagementId, @IncidenceTypeId, @DescriptionIncidence, @Latitude, @Longitude, @Accuracy, 1, @Token, GETDATE(), null, null)
					
					declare @incidence int  = ( select top 1 IdIncidence from DeliveryBackOffice.dbo.IncidenceServices order by 1 desc)
					
					insert into DeliveryBackOffice.dbo.ProofIncidence(IncidenceId, PathIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
					values (@incidence, @Photos, 1, @Token, GETDATE(), null, null)
					



					---------------------------------------------- Actualiza el Status del Pickup  -------------------------------------------------------------------------
				
					declare @Status int = (	select IdServiceStatus from  CatServiceStatus where IdServiceStatus =  4)
			
					update ServiceManagement set ServiceStatusId = @Status
						from ServiceManagement
						where IdServiceManagement = @ServiceManagementId
			
						declare @transac int = (select top 1 IdServiceManagement from ServiceManagement where IdServiceManagement = @ServiceManagementId)
				
				   ---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	
					
					insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
					values( @transac, @Status, 1, @Token, GETDATE(), @DescriptionIncidence )
				
				
								-----------------------------------------------------------------------------------------------------------------------------------------------------------
				

	
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			select ERROR_MESSAGE()
				-- retornar mensaje de error
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '"IdResult":' +  convert(varchar,IdResult)    +',' 
				+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
		END CATCH;
		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;


			set @jsonResult = (SELECT STUFF(( 
			SELECT 
			  ',"Messege":"Incidente Guardado exitosamente"}'
	
			FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

			--- succesfull
		END
		
		-- destruir tablas temporales

		
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END

