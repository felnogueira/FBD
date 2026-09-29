SELECT 
	TP_FAIXA_ETARIA, 
    ROUND(AVG(NOTA_FINAL),2) AS NOTA_MEDIA, # Calcula nota media por grupo etario
    COUNT(TP_FAIXA_ETARIA) AS NUMERO_PESSOAS, # Conta numero de pessoas por grupo etario
    ROUND((COUNT(TP_FAIXA_ETARIA) / SUM(COUNT(*)) OVER()) * 100,2) AS PERCENTUAL # Calcula percentual de participacao do grupo no exame
FROM (
	SELECT RR.NU_INSCRICAO, ((RR.NU_NOTA_REDACAO + SOMA_NOTAS) / 5) AS NOTA_FINAL # Calcula a nota final de cada participante
    FROM ENEM.RESULTADO_REDACAO RR
	INNER JOIN ( # Join para calcular nota final de cada participante
		SELECT NU_INSCRICAO, SUM(NU_NOTA) AS SOMA_NOTAS # Calcula a somatoria das notas das provas objetivas de cada participante
		FROM RESULTADO_PROVA 
		GROUP BY NU_INSCRICAO # agrupar por participante
        ) RP # Tabela com a soma das notas das provas objetivas dos participantes
	ON RR.NU_INSCRICAO = RP.NU_INSCRICAO
    ) TABELA_NOTA_FINAL # Tabela que apresenta a nota final calculada com dados do participante
INNER JOIN ENEM.PARTICIPANTE PRTCP ON TABELA_NOTA_FINAL.NU_INSCRICAO = PRTCP.NU_INSCRICAO
GROUP BY TP_FAIXA_ETARIA # Agrupar por grupo etario
ORDER BY TP_FAIXA_ETARIA ASC; # Ordenar por grupo etário do mais novo para o mais velho