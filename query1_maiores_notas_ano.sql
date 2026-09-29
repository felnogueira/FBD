SELECT NU_INSCRICAO, TP_SEXO, TP_FAIXA_ETARIA, TP_NACIONALIDADE, ROUND(NOTA_FINAL,2) AS MEDIA_FINAL, 
	ANO_ENEM, CO_MUNICIPIO_PROVA, NO_MUNICIPIO, NO_UF, NO_REGIAO FROM (
		SELECT TABELA_NOTA_FINAL.*, 
		RANK() OVER(PARTITION BY ANO_ENEM ORDER BY NOTA_FINAL DESC) # Dividir por ano e ranquear por nota final
		AS RANKING FROM
			(SELECT RR.NU_INSCRICAO, ((RR.NU_NOTA_REDACAO + RP.SOMA_NOTAS) / 5) AS NOTA_FINAL,  # Calcular nota final
				PRTCP.ANO_ENEM, PRTCP.TP_SEXO, PRTCP.TP_FAIXA_ETARIA, 
				PRTCP.TP_NACIONALIDADE, PRTCP.CO_MUNICIPIO_PROVA FROM ENEM.RESULTADO_REDACAO RR
				INNER JOIN ( # Join para possibilitar calculo da nota final
					SELECT NU_INSCRICAO, SUM(NU_NOTA) AS SOMA_NOTAS # Coletar soma de nota das provas objetivas dos participantes
					FROM RESULTADO_PROVA 
					GROUP BY NU_INSCRICAO # Agrupar por participante
				) RP # Tabela com a soma das notas das provas objetivas dos participantes
					ON RR.NU_INSCRICAO = RP.NU_INSCRICAO 
				INNER JOIN PARTICIPANTE PRTCP # Join para select de informacoes do participante
					ON RR.NU_INSCRICAO = PRTCP.NU_INSCRICAO
		) TABELA_NOTA_FINAL # Tabela que apresenta a nota final calculada com dados do participante
	) TABELA_RANK # Tabela que apresenta a nota final calculada com ranking por ano e dados do participante
INNER JOIN ENEM.MUNICIPIO MUN # Joins para possibilitar select de dados geograficos
	ON TABELA_RANK.CO_MUNICIPIO_PROVA = MUN.CO_MUNICIPIO 
INNER JOIN ENEM.REGIAO_GEOGRAFICA_IMEDIATA REG_IMED 
	ON MUN.CO_RG_IMED = REG_IMED.CO_RG_IMED
INNER JOIN ENEM.REGIAO_GEOGRAFICA_INTERMEDIARIA REG_INTERMED 
	ON REG_IMED.CO_RG_INTERMED = REG_INTERMED.CO_RG_INTERMED
INNER JOIN ENEM.UNIDADE_FEDERATIVA UF 
	ON REG_INTERMED.CO_UF = UF.CO_UF
INNER JOIN ENEM.REGIAO REG 
	ON UF.CO_REGIAO = REG.CO_REGIAO
WHERE RANKING = 1 # Filtrar apenas os primeiros colocados
ORDER BY ANO_ENEM ASC; # Apresentar resultados por ano de modo crescente

