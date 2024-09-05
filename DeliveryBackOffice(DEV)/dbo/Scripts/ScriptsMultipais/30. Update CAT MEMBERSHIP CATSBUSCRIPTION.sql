update dbo.CatSubscription
	set IdCountry='GT'
where RowStatus=1
update dbo.CatMembership
	set IdCountry='GT'
where RowStatus=1