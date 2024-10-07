update dbo.CatCityPlace
	set IdCountry='GT'
where idcountry is null
AND CityPlaceRowStatus=1

	update CatDeliveryOptions
		set IdCountry='GT'
	where idcountry is null