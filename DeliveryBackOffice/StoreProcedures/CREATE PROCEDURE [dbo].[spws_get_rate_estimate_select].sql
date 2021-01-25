USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-13>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_rate_estimate_select]
	-- Add the parameters for the stored procedure here
			@CodApp as nvarchar(50) = '' ,
		    @IdCustomer as int = 0, -- 6 express center
			@HeaderCodeDestiny as varchar(10)  = '',
			@HeaderCodeSource as varchar(10)  = '',
			@FechaCompra as datetime = '2020-08-03 11:51',
			@ProductWeight as decimal(18,2) = 12,
			@Country as nvarchar(2)   = 'GT',
			--fields complementaries optionals 
			@ObjectType as nvarchar(50)  = 'bateries | bateries | bateries |',
			@CountPieces as int = 3,
			@AmmountValue as decimal(18,2) = 195,
			@WeightValue as decimal(18,2) = 0,
			@Currency as NVARCHAR(3) = 'GTQ',
			@CodeCredit as nvarchar(10) = '0',
			@IsFragile as bit  = 'FALSE',
			@IsCollected as bit  = 'FALSE',
			@IsInsurance as bit  = 'FALSE'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		create table #TempRates(
			strJson nvarchar(max))

		declare @TypRate nvarchar(10) =  (select top 1 rt.RheShortName from dbo.RatebyCustomer rc
											join dbo.RateHeader rt on rt.RheId = rc.RbcIdRate
										where rc.RbcIdCustomer =  @IdCustomer)
	 IF @TypRate = 'IND' --SI ES INDIVIDUAL COTIZAR POR HUB
	 BEGIN
		INSERT INTO #TempRates
		exec [spws_get_rate_estimate_by_hub]
			@IdCustomer  = @IdCustomer -- 6 express center
			,@HeaderCodeSource  = @HeaderCodeSource
			,@HeaderCodeDestiny   = @HeaderCodeDestiny
			,@FechaCompra  = @FechaCompra
			,@Country  = @Country
			,@ObjectType  = @ObjectType
			,@CountPieces = @CountPieces
			,@AmmountValue  = @AmmountValue
			,@WeightValue  = @WeightValue
			,@Currency  =@Currency
			,@CodeCredit  = @CodeCredit
			,@IsFragile  = @IsFragile
			,@IsCollected   = @IsCollected
			,@IsInsurance  = @IsInsurance

	 END
	 ELSE -- COTIZAR POR TARIFAS DIFERENCIADAS
	 BEGIN
			INSERT INTO #TempRates
		exec [spws_get_rate_estimate_byheadercode]
			@IdCustomer  = @IdCustomer -- 6 express center
			,@HeaderCodeSource  = @HeaderCodeSource
			,@HeaderCodeDestiny   = @HeaderCodeDestiny
			,@FechaCompra  = @FechaCompra
			,@Country  = @Country
			,@ObjectType  = @ObjectType
			,@CountPieces = @CountPieces
			,@AmmountValue  = @AmmountValue
			,@WeightValue  = @WeightValue
			,@Currency  =@Currency
			,@CodeCredit  = @CodeCredit
			,@IsFragile  = @IsFragile
			,@IsCollected   = @IsCollected
			,@IsInsurance  = @IsInsurance

	 END

	select * from #TempRates

END