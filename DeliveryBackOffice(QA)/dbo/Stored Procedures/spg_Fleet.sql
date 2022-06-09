
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve los vehiculos que esten activos>
-- =============================================
Create PROCEDURE [dbo].[spg_Fleet]
@RowStatus	bit = 1 

AS
BEGIN

		select  cv.UnitNumber UNITNUMBER, cv.Plate PLATE, cvb.Name NAMEBRAND , ctv.Name NAMETYPE, cvc.Name NAMECATEGORIES
		,cv.Year YEARC
		,cv.Long LONG, cv.Width WIDTH,  cv.High HIGH, cv.CubicMeters CUBICMETERS
		,cv.CapabilityEcomerce CAPACITY, cv.WhiteLineCapacity WHITELINE, cv.IrregularCapacity IRREGULARCAPACITY 
		
		from CatVehicle cv
		left join CatTypeVehicle ctv on (cv.IdTypeVehicle = ctv.IdTypeVehicle)
		left join CatVehicleBrand cvb on (cv.CatVehicleBrandId = cvb.IdCatVehicleBrand)
		left join CatVehicleCategories cvc on (cv.CatVehicleCategoriesId = cvc.IdCatVehicleCategories)
		where  cv.RowStatus = @RowStatus

END


select * from CatVehicle