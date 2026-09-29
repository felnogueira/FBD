WITH MEDIAS AS ( # Common Table Expression com nota media dos municipios
	SELECT REG.NO_REGIAO, UF.NO_UF, UF.CO_UF, MUN.NO_MUNICIPIO, 
	ROUND(AVG(NOTA_FINAL),2) AS MEDIA_MUNICIPIO # Calcular media por municipio
	FROM (
		SELECT RR.NU_INSCRICAO, ((RR.NU_NOTA_REDACAO + SOMA_NOTAS) / 5) AS NOTA_FINAL # Calcula a nota final de cada participante
        FROM ENEM.RESULTADO_REDACAO RR
		INNER JOIN ( # JOIN entre resultado da redacao e das provas objetivas para computar nota final
				SELECT NU_INSCRICAO, SUM(NU_NOTA) AS SOMA_NOTAS # Calcula a somatoria das notas das provas objetivas de cada participante
                FROM RESULTADO_PROVA
				GROUP BY NU_INSCRICAO # agrupar por participante
                ) RP # Tabela com a soma das notas das provas objetivas dos participantes
				ON RR.NU_INSCRICAO = RP.NU_INSCRICAO
                ) TABELA_NOTA_FINAL # Tabela que apresenta a nota final calculada com dados do participante
	INNER JOIN ENEM.PARTICIPANTE PRTCP # JOINs para pegar dados geograficos
		ON TABELA_NOTA_FINAL.NU_INSCRICAO = PRTCP.NU_INSCRICAO
	INNER JOIN ENEM.MUNICIPIO MUN 
		ON PRTCP.CO_MUNICIPIO_PROVA = MUN.CO_MUNICIPIO
	INNER JOIN ENEM.REGIAO_GEOGRAFICA_IMEDIATA REG_IMED 
		ON MUN.CO_RG_IMED = REG_IMED.CO_RG_IMED
	INNER JOIN ENEM.REGIAO_GEOGRAFICA_INTERMEDIARIA REG_INTERMED 
		ON REG_IMED.CO_RG_INTERMED = REG_INTERMED.CO_RG_INTERMED
	INNER JOIN ENEM.UNIDADE_FEDERATIVA UF 
		ON REG_INTERMED.CO_UF = UF.CO_UF
	INNER JOIN ENEM.REGIAO REG 
		ON UF.CO_REGIAO = REG.CO_REGIAO
	GROUP BY CO_MUNICIPIO # Agrupar por Codigo de Municipio
),

RANKING AS ( # Common Table Expression que ranqueia os municipios dentro de cada UF
	SELECT *,
    RANK() OVER(
		PARTITION BY CO_UF # Segregar ranking por UF
        ORDER BY MEDIA_MUNICIPIO DESC) AS COLOCACAO # Ordenar por nota media
        FROM MEDIAS
)

SELECT NO_REGIAO, NO_UF, NO_MUNICIPIO, MEDIA_MUNICIPIO FROM RANKING WHERE COLOCACAO = 1
ORDER BY NO_REGIAO ASC; # Listar por ordem alfabetica do nome da Regiao