
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-13>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_rate_estimate_select]
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
			@IsInsurance as bit  = 'FALSE',
			@WeigthParcels as nvarchar(300) ='0',
			@InsuranceAmount as decimal (18,2) =0,
			@IsCreditCardPayment as bit = 'false'
			,@ParcelCode as nvarchar(200) = '0'
			,@Zone as int =0
			,@AddressParse as nvarchar(600)= ''
			,@IdSettlementDestiny as int =0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--se identifica el Ecommerce en base al CodeApp enviado 
		select  IdEcommerce,
				EcomerceName,	
				IdCountry,	
				UserKey,	
				Passkey,	
				SecretKey,	
				EcommerceStatus,	
				IdCustomer
		into #Ecommrce
		from DeliveryBackOffice.[dbo].[Ecommerce] eco 
		where eco.UserKey = @CodApp --'SIFDCECOM300720201459'
		and eco.IdCountry = @Country
		and eco.EcommerceStatus = 'TRUE'
	if @IdCustomer = 0 -- si el Id Customer es 0 lo obtiene con base al CodApp
			set @IdCustomer  = (select top 1 ec.IdCustomer from #Ecommrce ec where ec.EcommerceStatus = 'TRUE')

		create table #TempRates(
			strJson nvarchar(max))

		declare @TypRate nvarchar(10) =  (select top 1 rt.RheShortName from dbo.RatebyCustomer rc
											join dbo.RateHeader rt on rt.RheId = rc.RbcIdRate
										where rc.RbcIdCustomer =  @IdCustomer)
	 IF @TypRate = 'IND' or @TypRate ='EXP' --SI ES INDIVIDUAL COTIZAR POR HUB
	 BEGIN

	 DECLARE @FlagPiece as bit = 'true'

		 if @FlagPiece = 'true'
		 begin
			INSERT INTO #TempRates
			exec [spws_get_rate_estimate_by_hub_by_piece]
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
				,@WeigthParcels = @WeigthParcels
				,@InsuranceAmount = @InsuranceAmount
				,@IsCreditCardPayment = @IsCreditCardPayment
				,@Zone=@Zone
				,@AddressParse  =@AddressParse
				,@IdSettlementDestiny =@IdSettlementDestiny
		 end
		 else
		 begin 
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
			end

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
			--,@ParcelCode=@ParcelCode

	 END

	select * from #TempRates

END