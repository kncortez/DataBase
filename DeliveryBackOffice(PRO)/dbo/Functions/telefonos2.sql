
create function telefonos2
(
	@nombre_apellido varchar (max)
)

returns varchar(max)

as
begin

declare @telefonos varchar(200)

	if (select count(nombress) from tablatemp where nombress = @nombre_apellido) > 1
		begin
			set @telefonos = (select telefonoss + ' '  from tablatemp where nombress = @nombre_apellido  
			FOR XML PATH(''))
			--print @telefonos
		end
	else
		begin
			set @telefonos = (select telefonoss from tablatemp where nombress = @nombre_apellido)
			--print @telefonos
		end
		return @telefonos
end

