



-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-16>
-- Description:	<Se almacenara las imagenes de un visitpoint, se actualizara el visitpoint con las columnas Accuracy, Latitude, Longitude>
-- =============================================


CREATE PROCEDURE [dbo].[SetImageVisitPoint]
	-- Add the parameters for the stored procedure here	
	@TblIncidenceLink AS TblIncidenceLink READONLY,
	@CodeOfReference  INT = 0,
	@Accuracy    varchar (200) = '44',
	@Latitude varchar  (200) = '55798797342',
	@Longitude varchar  (200) = '546689',
	@Token varchar (200) = '545656asdf564afd'
	--@Photos varchar (MAX) = 'jkjadshkjfhjadhflkjads',
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	DECLARE @jsonToken NVARCHAR(MAX)
	 declare @TokenAct int  = (select top 1 RowStatus from LogTokenPOD where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
	declare @hourtoken int = (select DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD where LogTokenPOD  LIKE '%' + @Token + '%')
	
	print 'validando token'
	if (@TokenAct = 1 and @hourtoken <= 8)
		begin 
				print 'token validado'

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
									
									if (abs(@Latitude) >0 and abs(@Longitude)>0)
										begin
										update DeliveryBackOffice.dbo.VisitPointClient set Accuracy = @Accuracy, Latitude = @Latitude, Longitude = @Longitude
										where CodeOfReference = @CodeOfReference
										end
										INSERT INTO DeliveryBackOffice.dbo.ImagesByVisitPoint
										(CodeOfReference
										,PathImage
										,RowStatus
										,TokenCreated
										,DateCreated
										,TokenUpdated
										,DateUpdated
										)
										SELECT @CodeOfReference
										,li.PathIncidence
										,1
										,@Token
										,GETDATE()
										,null
										,null
										FROM @TblIncidenceLink li
								
				
				
				
					
								
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


								declare @JsonLInk nvarchar(max)
								
								   SET @JsonLInk =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"Url":"' + li.PathIncidence + '"}'
                                            FROM @TblIncidenceLink li
											FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );


								
									set @jsonResult = (SELECT STUFF(( 
									SELECT 
									  ',"Message":"Guardado exitosamente",' + '"Path":[' + @JsonLInk + ']' + '}'
								
									FOR XML PATH(''), TYPE
													).value('.', 'varchar(max)'),1,1,''
															) )
								
									--- succesfull
								END
								
								-- destruir tablas temporales
								
								
								IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
								
								-- retornar resultado en formato json
								
							select ('[{' + @jsonResult +  ']') jsonResult
												
										
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
															
		end

		else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
		begin 
				  print 'token inválido'
					SET @jsonToken = (
				   SELECT STUFF((
		   			SELECT  
					',{"IdResult":' + '403' + ',' +
					'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
					'}' 
					FOR XML PATH(''), TYPE
				   ).value('.', 'varchar(max)'),1,1,''
		   					  ) 
				   )
					 select '['+ @jsonToken + ']' jsonToken
	
				   return
	end

END
