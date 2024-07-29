
-- CARACTERES NUEVOS PARA AGREGAR AL MANEJO DE JSON
insert into dbo.tb_StringEncoding (StringToReplace,StringReplacement,EncodingType)
values('´','','json')
insert into dbo.tb_StringEncoding (StringToReplace,StringReplacement,EncodingType)
values('¨','','json')
insert into dbo.tb_StringEncoding (StringToReplace,StringReplacement,EncodingType)
values('`','\u0060','json')
insert into dbo.tb_StringEncoding (StringToReplace,StringReplacement,EncodingType)
values('#','\u0023','json')

-- MODIFICAR CARACTERES YA INGRESADOS EN LA TABLA
update dbo.tb_StringEncoding set StringReplacement = '\u005C' where StringToReplace = '\'
update dbo.tb_StringEncoding set StringReplacement = ' ' where StringToReplace = '/'
update dbo.tb_StringEncoding set StringReplacement = '\u0022' where StringToReplace = '"'
