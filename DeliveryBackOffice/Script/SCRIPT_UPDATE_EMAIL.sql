UPDATE dbo.ConfigParams
  SET 
      dbo.ConfigParams.[Value] =
(
    SELECT CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)') Base64Encoding
    FROM
(
    SELECT CAST('marco.jimenez@forzalatam.com' AS VARBINARY(MAX)) AS bin
) AS bin_sql_server_temp
)
WHERE [Name] = 'EmailFrom';
UPDATE dbo.ConfigParams
  SET 
      dbo.ConfigParams.[Value] =
(
    SELECT CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)') Base64Encoding
    FROM
(
    SELECT CAST('192.168.31.39' AS VARBINARY(MAX)) AS bin
) AS bin_sql_server_temp
)
WHERE [Name] = 'Host';
UPDATE dbo.ConfigParams
  SET 
      dbo.ConfigParams.[Value] =
(
    SELECT CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)') Base64Encoding
    FROM
(
    SELECT CAST('25' AS VARBINARY(MAX)) AS bin
) AS bin_sql_server_temp
)
WHERE [Name] = 'Port';
UPDATE dbo.ConfigParams
  SET 
      dbo.ConfigParams.[Value] =
(
    SELECT CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)') Base64Encoding
    FROM
(
    SELECT CAST('!-[=E#jc56B\4&7A' AS VARBINARY(MAX)) AS bin
) AS bin_sql_server_temp
)
WHERE [Name] = 'Password';