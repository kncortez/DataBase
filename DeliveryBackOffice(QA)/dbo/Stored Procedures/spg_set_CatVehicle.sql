
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-02-15>
-- Description:	<Guardar los vehiculos>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_CatVehicle]
@HubId INT,
@UnitNumber VARCHAR (10) = '1234',
@CodeName VARCHAR (200) = 'TEST',
@IdTypeVehicle  INT  = 1,
@Plate VARCHAR (20) = 'C 123A',
@Year INT = NULL,
@Capacity DECIMAL (12,2)= 12.50 
,@WhiteLineCapacity	DECIMAL (12,2)= 12.50
,@IrregularCapacity	DECIMAL (12,2)= 12.50
,@RowStatus	int = 1 
,@Token varchar (50) = 'TEST'
--,@TokenUpdated varchar (50) 
,@CatVehicleCategoriesId int = 1
,@CatVehicleBrandId int = 1
,@Long decimal (14,2) = 0.00
,@Width decimal (14,2) = 0.00
,@High decimal (14,2) = 0.00
,@CubicMeters decimal (14,2) = 0.00
,@CapabilityEcomerce decimal (14,2) = 0.00


AS
BEGIN
		

				declare @valite int =	(select COUNT(UnitNumber) from CatVehicle
						where UnitNumber = @UnitNumber and RowStatus = 1)

				declare @validate int =(select COUNT(Plate) from CatVehicle
						where Plate = @Plate and RowStatus = 1)


					if(@valite = 0 and @validate = 0)
					begin
					BEGIN TRANSACTION
					BEGIN TRY
							INSERT  INTO dbo.CatVehicle (UnitNumber, CodeName, IdTypeVehicle, Plate, Year, Capacity, WhiteLineCapacity, IrregularCapacity, RowStatus, TokenCreated, DateCreated
							, TokenUpdated, DateUpdated, CatVehicleCategoriesId, CatVehicleBrandId, Long, Width, High, CubicMeters, CapabilityEcomerce,HubLogisticId) 
							VALUES(@UnitNumber,@CodeName, @IdTypeVehicle, @Plate, @Year, @Capacity, @WhiteLineCapacity, @IrregularCapacity, @RowStatus, @Token, GETDATE()
							, null, null,@CatVehicleCategoriesId, @CatVehicleBrandId, @Long, @Width, @High, @CubicMeters, @CapabilityEcomerce,@HubId)

							END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
							select ERROR_MESSAGE()
								-- retornar mensaje de error
						
					END CATCH;
					IF @@TRANCOUNT > 0 BEGIN
						COMMIT TRANSACTION;
						select '200' as StatusCode 

						END
					end
					else if(@valite > 0 and @validate > 0 )
					begin 
						  select '406' as StatusCode 
					end 
					

END


--select * from CatVehicle


--dbo.spg_set_CatVehicle 
--@UnitNumber='13',
-- @CodeName='13123QWE',
--  @IdTypeVehicle=1,
--   @Plate='123QWE',
--    @Year=2020,
--	 @Capacity=0,
--	  @WhiteLineCapacity=1,
--	  @IrregularCapacity=12, 
--	  @RowStatus=1,
--	   @Token='SYS_SYSTEM'
--	    ,@CatVehicleCategoriesId1
--		 ,@CatVehicleBrandId=1
--		  , @Long=1, 
--		  @Width=1,
--		   @High=1,
--		   @CubicMeters=3
--		   , @CapabilityEcomerce=12