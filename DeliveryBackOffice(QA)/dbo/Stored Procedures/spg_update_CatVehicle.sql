
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-02-15>
-- Description:	<Actualiza los vehiculos>
-- =============================================
CREATE PROCEDURE [dbo].[spg_update_CatVehicle]
@IdVehicle int=NULL,
@UnitNumber VARCHAR (10) = NULL,
@CodeName VARCHAR (200) = 'TEST',
@IdTypeVehicle  INT  = 1,
@Plate VARCHAR (20) = 'C 123A',
@Year INT = 2020,
@Capacity DECIMAL (12,2)= 12.50 
,@WhiteLineCapacity	DECIMAL (12,2)= 12.50
,@IrregularCapacity	DECIMAL (12,2)= 12.50
,@RowStatus	bit = 1 
--,@TokenCreated varchar (50) = 'TEST'
,@Token varchar (50) = 'TEST'
,@CatVehicleCategoriesId int = 1
,@CatVehicleBrandId int = 1
,@Long decimal (14,2) = 0.00
,@Width decimal (14,2) = 0.00
,@High decimal (14,2) = 0.00
,@CubicMeters decimal (14,2) = 0.00
,@CapabilityEcomerce decimal (14,2) = 0.00
,@IdHub int
AS
BEGIN




--declare @valite int =	(select COUNT(UnitNumber) from CatVehicle
--		where UnitNumber = @UnitNumber and RowStatus = 1)

--declare @validate int =(select COUNT(Plate) from CatVehicle
--		where Plate = @Plate and RowStatus = 1)


--	if(@validate = 0)
--	begin
		BEGIN TRANSACTION
					BEGIN TRY

					UPDATE dbo.CatVehicle SET  CodeName = @CodeName, IdTypeVehicle = @IdTypeVehicle, Plate = @Plate, Year = @Year
					, Capacity = @Capacity, WhiteLineCapacity= @WhiteLineCapacity, IrregularCapacity = @IrregularCapacity, RowStatus = @RowStatus, TokenUpdated = @Token,
					DateUpdated = GETDATE(), CatVehicleCategoriesId = @CatVehicleCategoriesId, CatVehicleBrandId = @CatVehicleBrandId, Long = @Long, Width = @Width, High = @High, CubicMeters = @CubicMeters,
					CapabilityEcomerce = @CapabilityEcomerce,HubLogisticId=@IdHub,UnitNumber=@UnitNumber
					WHERE IdVehicle = @IdVehicle


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
						
						--end
					--else if(@validate > 0 )
					--begin 
					--	  select '406' as StatusCode 
					----end 
END